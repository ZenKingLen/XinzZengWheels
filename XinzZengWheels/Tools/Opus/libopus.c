/** 
 * @file	libopus.h
 * @brief	
 * 
 *	封装OPUS编码库，提供对AudioCoding的接口
 * 
 * @author	rfge
 * @version	1.0
 * @date	2018-1-11
 * 
 * 
 */

#include <stdlib.h>
#include <string.h>
//#include <msp_errors.h>
#include "libopus.h"
#include <opus/opus.h>
#include "opus_arch.h"
#include "ogg.h"
#include "opus_general_header.h"

#include "stdio.h"

/* 120ms at 48000 */
#define MAX_OPUS_FRAME_SIZE (960*6)

#define OGG_OPUS_DECODE_SIZE 960

#define Max_Raw_Frame_Size 1280
#define Max_Com_Frame_Bytes 640
#define Min_Com_Frame_Bytes 6

#define NarrowBand_Mode 0
#define WideBand_Mode 1
#define Ogg_Mode 2
#define Super_WideBand_mode 3

#define Default_Sample_Rate 48000
#define Super_WideBand_Sample_Rate 24000
#define WideBand_Sample_Rate 16000
#define NarrowBand_Sample_Rate 8000
#define WideBand_Compress_Level WideBand_Sample_Rate
#define NarrowBand_Compress_Level NarrowBand_Sample_Rate

#define WideBand_OutPut 40
#define NarrowBand_OutPut 20

#define COMPLEXITY 7
#define COMPRESS_SIZE_PER_KILO 2.5

#define OGG_COMMENT "IFYTEK" 
///opus coding handle
typedef struct
{
	OpusEncoder*	encoder_;		//opus encoding handle
	unsigned int	frame_bytes_;	//raw frame bytes
	char			data_cache_[ Max_Raw_Frame_Size << 1 ];
	unsigned int	data_cache_len_;

	ogg_page       *og;
	ogg_packet     *op;
	ogg_stream_state *os;

	opus_int64 packet_number;

	int sample_rate;
	int is_ogg_initialized;
	int ogg_mode;

	int stream_init;

} OpusEncodingHandle;

///opus coding handle
typedef struct
{
	OpusDecoder*	decoder_;		//opus encoding handle
	unsigned int	frame_bytes_;	//raw frame bytes
	char			data_cache_[ Max_Raw_Frame_Size << 1 ];
	unsigned int	data_cache_len_;

	ogg_sync_state *oy;
	ogg_page       *og;
	ogg_packet     *op;
	ogg_stream_state *os;

	ogg_int64_t page_granule;
	opus_int64 packet_count;
	ogg_int32_t opus_serialno;

	int has_opus_stream;
	int has_tags_packet;
	int eos;
	int stream_init;

	int ogg_mode;

} OpusDecodingHandle;

#define FREE_MEM(x)	\
if( NULL != x )	\
{	\
	free(x);	\
	x = NULL;	\
}

int OpusEncodeInit( void** encode_handle, int opus_mode )
{
	OpusEncodingHandle*		opus_handle = NULL;
	int						bandwidth   = OPUS_AUTO;
	int						bitrate     = OPUS_AUTO; // 6k bit per second
	int						samplerate  = WideBand_Sample_Rate;		
	int						ret			= OPUS_ERROR_FAIL;

	///null pointer
	if( NULL == encode_handle )
	{
		return OPUS_ERROR_NULL_HANDLE;
	}
	*encode_handle = NULL;

	opus_handle = (OpusEncodingHandle *)malloc( sizeof( OpusEncodingHandle ));
	if( NULL == opus_handle )
	{
		return OPUS_ERROR_NO_ENOUGH_BUFFER;
	}
	opus_handle->encoder_ = NULL;
	opus_handle->ogg_mode = 0;

	if( NarrowBand_Mode == opus_mode )
	{
		samplerate = NarrowBand_Sample_Rate;
	}
	else if(WideBand_Mode == opus_mode)
	{
		samplerate = WideBand_Sample_Rate;
	}
	else if(Super_WideBand_mode == opus_mode)
	{
		samplerate = Super_WideBand_Sample_Rate;

	}
	//ogg mode use only to dynamically specify sample rate  
	//other than use various mode to represent differant sample rate like opus,opus-wb
	else
	{
		samplerate = opus_mode;
		opus_handle->ogg_mode = 1;


		opus_handle->og =  (ogg_page *)malloc( sizeof( ogg_page ));
		opus_handle->op =  (ogg_packet *)malloc( sizeof( ogg_packet ));
		opus_handle->os =  (ogg_stream_state *)malloc( sizeof( ogg_stream_state ));

		if(opus_handle->og==NULL ||opus_handle->op==NULL ||opus_handle->os==NULL )
			return OPUS_ERROR_NO_ENOUGH_BUFFER;

		opus_handle->packet_number =0;
		opus_handle->is_ogg_initialized=0;
		opus_handle->stream_init=0;

	}

	opus_handle->sample_rate = samplerate;

	opus_handle->encoder_ = opus_encoder_create( samplerate, 1, OPUS_APPLICATION_VOIP, &ret );
	if( OPUS_OK != ret )
	{
		FREE_MEM( opus_handle );
		return OPUS_ERROR_CREATE_HANDLE;
	}

	opus_encoder_ctl( opus_handle->encoder_, OPUS_SET_COMPLEXITY( COMPLEXITY ));
	opus_encoder_ctl( opus_handle->encoder_, OPUS_SET_BANDWIDTH( bandwidth ));
	opus_encoder_ctl( opus_handle->encoder_, OPUS_SET_VBR( 0 ));
	opus_encoder_ctl( opus_handle->encoder_, OPUS_SET_VBR_CONSTRAINT(0));

	opus_handle->frame_bytes_ = samplerate / 50 * sizeof( opus_int16 );
	opus_handle->data_cache_[0] = '\0';
	opus_handle->data_cache_len_ = 0;

	///set returned value
	*encode_handle = opus_handle;

	return OPUS_SUCCESS;
}

int OpusEncodeFini( void* encode_handle )
{
	OpusEncodingHandle*	opus_handle = (OpusEncodingHandle*)encode_handle;

	///not init
	if( NULL == opus_handle || NULL == opus_handle->encoder_ )
	{
		return OPUS_ERROR_NOT_INIT;
	}

	if(1 == opus_handle->ogg_mode)
	{
		if( opus_handle->og==NULL ||opus_handle->op==NULL ||opus_handle->os==NULL )
			return OPUS_ERROR_NOT_INIT;


		if (opus_handle->stream_init == 1)
			ogg_stream_clear(opus_handle->os);

		FREE_MEM( opus_handle->og );
		FREE_MEM( opus_handle->op );
		FREE_MEM( opus_handle->os );
	}

	opus_encoder_destroy( opus_handle->encoder_ );
	FREE_MEM( opus_handle );

	return OPUS_SUCCESS;
}

static void int_to_char(opus_uint32 i, unsigned char ch[2])
{
	ch[0] = i>>8;
	//ch[0] = (i>>8)&0xFF;
	ch[1] = i&0xFF;
}

static opus_uint32 char_to_int(unsigned char ch[2])
{
	return ((opus_uint32)ch[0]<< 8) |  (opus_uint32)ch[1];
}

int OpusEncode( void* encode_handle
			  , const char* audio
			  , unsigned int audio_len
			  , char* opus
			  , unsigned int* opus_len
			  , int bit_rate )

{
	const char*			pAudio = audio;
	char*				pOpus = opus;
	unsigned int		opus_buf_len = *opus_len;
	int					audio_remaining = audio_len;	//to specify how much data remained un-encoded in the audio buffer.
	unsigned int		opus_data_len = 0;				//to specify how much opus-format data in the speex buffer.
	int					ret = 0;
	int					opus_ogg_header_len =0;

	OpusEncodingHandle*	opus_handle = (OpusEncodingHandle *)encode_handle;

	///not init
	if( NULL == opus_handle || NULL == opus_handle->encoder_ )
	{
		return OPUS_ERROR_NOT_INIT;
	}

	ret = opus_encoder_ctl( opus_handle->encoder_, OPUS_SET_BITRATE( bit_rate ));
	if( OPUS_OK != ret ) 
	{
		return OPUS_ERROR_INVALID_PARA;
	}

	if(opus_handle->ogg_mode)
	{
		if(!opus_handle->is_ogg_initialized)
		{
			int packet_size =0;
			OpusHeader header;
			unsigned char header_data[276];

			if (opus_handle->stream_init == 0)
			{
				//init ogg stream,just give a random seriolno 
				ogg_stream_init(opus_handle->os,MAX_OPUS_FRAME_SIZE);
				opus_handle->stream_init =1;
			}

			header.preskip = 0;
			header.channels = 1;
			header.channel_mapping = 0;
			header.input_sample_rate= opus_handle->sample_rate;
			header.gain=0;

			packet_size=opus_header_to_packet(&header, header_data, sizeof(header_data));

			opus_handle->op->packet=header_data;
			opus_handle->op->bytes=packet_size;
			opus_handle->op->b_o_s=1;
			opus_handle->op->e_o_s=0;
			opus_handle->op->granulepos=0;
			opus_handle->op->packetno=opus_handle->packet_number++;

			//write the first header packet into a new pages
			ogg_stream_packetin(opus_handle->os, opus_handle->op);
			while((ogg_stream_flush(opus_handle->os, opus_handle->og)))
			{
				memcpy(pOpus,opus_handle->og->header,opus_handle->og->header_len);
				//opus_data_len += opus_handle->og->header_len;
				pOpus += opus_handle->og->header_len;

				memcpy(pOpus,opus_handle->og->body,opus_handle->og->body_len);
				//opus_data_len += opus_handle->og->body_len;
				pOpus += opus_handle->og->body_len;


				opus_ogg_header_len += opus_handle->og->header_len;
				opus_ogg_header_len += opus_handle->og->body_len;
				//opus_handle->pages_out++;
			}

			//write the second comment packet into a new page
			opus_handle->op->packet=(unsigned char*)OGG_COMMENT;
			opus_handle->op->bytes=strlen(OGG_COMMENT);

			opus_handle->op->b_o_s=0;
			opus_handle->op->e_o_s=0;
			opus_handle->op->granulepos=0;
			opus_handle->op->packetno=opus_handle->packet_number++;;

			ogg_stream_packetin(opus_handle->os, opus_handle->op);
			while((ogg_stream_flush(opus_handle->os, opus_handle->og)))
			{
				memcpy(pOpus,opus_handle->og->header,opus_handle->og->header_len);
				//opus_data_len += opus_handle->og->header_len;
				pOpus += opus_handle->og->header_len;

				memcpy(pOpus,opus_handle->og->body,opus_handle->og->body_len);
				//opus_data_len += opus_handle->og->body_len;
				pOpus += opus_handle->og->body_len;

				opus_ogg_header_len += opus_handle->og->header_len;
				opus_ogg_header_len += opus_handle->og->body_len;
			}

			opus_handle->is_ogg_initialized = 1;
		}

		///encoding
		while( audio_remaining + opus_handle->data_cache_len_ >= (int)( opus_handle->frame_bytes_ ))
		{
			char			opus_frame[ Max_Com_Frame_Bytes ] = { 0 };
			opus_int32		write_bytes = 0;

			unsigned int	copy_len = opus_handle->frame_bytes_ - opus_handle->data_cache_len_;

			///reset bits and copy data
			memcpy( opus_handle->data_cache_ + opus_handle->data_cache_len_, pAudio, copy_len );
			opus_handle->data_cache_len_ += copy_len;
			pAudio += copy_len;
			audio_remaining -= copy_len;

			///encode current frame
			write_bytes = opus_encode( opus_handle->encoder_
				, (opus_int16 *)opus_handle->data_cache_
				, opus_handle->frame_bytes_ >> 1
				, opus_frame
				, Max_Com_Frame_Bytes );
			if( write_bytes < 0 )
			{
				return OPUS_ERROR_INVALID_DATA;
			}

			opus_data_len += write_bytes;

			opus_handle->op->packet = (unsigned char*)opus_frame;
			opus_handle->op->bytes = write_bytes;
			opus_handle->op->packetno=opus_handle->packet_number++;
			opus_handle->op->granulepos += OGG_OPUS_DECODE_SIZE;

			ogg_stream_packetin(opus_handle->os, opus_handle->op);

			opus_handle->data_cache_len_ = 0;
		}

		///cache remaining data
		if( 0 == ret && 0 != audio_remaining )
		{
			memcpy( opus_handle->data_cache_ + opus_handle->data_cache_len_, pAudio, audio_remaining );
			opus_handle->data_cache_len_ += audio_remaining;
		}

		//force packets into ogg pages
		if(opus_data_len != 0)
		{
			int header_len =0;
			int body_len =0;
			ogg_stream_flush(opus_handle->os, opus_handle->og);

			header_len = opus_handle->og->header_len;
			body_len = opus_handle->og->body_len;

			if( header_len +  body_len <= opus_buf_len )
			{
				///copy the speex-format data and adjust variables about buffer
				memcpy( pOpus, opus_handle->og->header, header_len );
				pOpus +=  header_len;

				///copy the speex-format data and adjust variables about buffer
				memcpy( pOpus, opus_handle->og->body, body_len );
				pOpus +=  body_len;

				opus_data_len = header_len +  body_len;
				
			}
			else
			{
				ret = OPUS_ERROR_NO_ENOUGH_BUFFER;
			}
		}

		///set returned value
		*opus_len = opus_data_len + opus_ogg_header_len;
		return ret;
	
	}
	else
	{
	///encoding
	while( audio_remaining + opus_handle->data_cache_len_ >= (int)( opus_handle->frame_bytes_ ))
	{
		char			opus_frame[ Max_Com_Frame_Bytes ] = { 0 };
		opus_int32		write_bytes = 0;
		unsigned char   writes[2] = {0};

		unsigned int	copy_len = opus_handle->frame_bytes_ - opus_handle->data_cache_len_;

		///reset bits and copy data
		memcpy( opus_handle->data_cache_ + opus_handle->data_cache_len_, pAudio, copy_len );
		opus_handle->data_cache_len_ += copy_len;
		pAudio += copy_len;
		audio_remaining -= copy_len;

		///encode current frame
		write_bytes = opus_encode( opus_handle->encoder_
								 , (opus_int16 *)opus_handle->data_cache_
								 , opus_handle->frame_bytes_ >> 1
								 , opus_frame
								 , Max_Com_Frame_Bytes );
		if( write_bytes < 0 )
		{
			return OPUS_ERROR_INVALID_DATA;
		}
		
	
		if( opus_data_len + write_bytes + sizeof(writes) <= opus_buf_len )
		{
			///write 2 bytes frame head to store encoded length
			int_to_char(write_bytes,writes);
			memcpy(pOpus,writes,sizeof(writes));

			pOpus += sizeof(writes);
			opus_data_len += sizeof(writes);

			///copy the speex-format data and adjust variables about buffer
			memcpy( pOpus, opus_frame, write_bytes );
			pOpus += write_bytes;
			opus_data_len += write_bytes;
			opus_handle->data_cache_len_ = 0;
		}
		else
		{
			ret = OPUS_ERROR_NO_ENOUGH_BUFFER;
			break;
		}
	}

	///cache remaining data
	if( 0 == ret && 0 != audio_remaining )
	{
		memcpy( opus_handle->data_cache_ + opus_handle->data_cache_len_, pAudio, audio_remaining );
		opus_handle->data_cache_len_ += audio_remaining;
	}

	///set returned value
	*opus_len = opus_data_len;
	return ret;
	}
}

int OpusDecodeInit( void** decode_handle, int opus_mode )
{
	OpusDecodingHandle*		opus_handle = NULL;
	int						samplerate  = WideBand_Sample_Rate;
	int						ret			= OPUS_ERROR_FAIL;

	///null pointer
	if( NULL == decode_handle )
	{
		return OPUS_ERROR_NULL_HANDLE;
	}
	*decode_handle = NULL;

	///malloc memory for handle of decoder
	opus_handle = (OpusDecodingHandle *)malloc( sizeof( OpusDecodingHandle ));
	if( NULL == opus_handle )
	{
		return OPUS_ERROR_NO_ENOUGH_BUFFER;
	}

	opus_handle->decoder_ = NULL;
	opus_handle->ogg_mode =0;


	if( NarrowBand_Mode == opus_mode )
	{
		samplerate = NarrowBand_Sample_Rate;
	}
	else if(WideBand_Mode == opus_mode)
	{
		samplerate = WideBand_Sample_Rate;
	}
	else if(Super_WideBand_mode == opus_mode)
		samplerate = Super_WideBand_Sample_Rate;
	else
	{
		opus_handle->ogg_mode =1;
	}	

	//if not under ogg mode, create decoder here
    //if under ogg mode,create decoder when we have the first ogg page
	if(0 == opus_handle->ogg_mode)
	{
		opus_handle->decoder_ = opus_decoder_create( samplerate, 1, &ret );
		if( OPUS_OK != ret )
		{
			FREE_MEM( opus_handle );
			return OPUS_ERROR_CREATE_HANDLE;
		}
	}
	

	opus_handle->frame_bytes_ = samplerate / 50 * sizeof( opus_int16 );
	opus_handle->data_cache_[0] = '\0';
	opus_handle->data_cache_len_ = 0;

if(1 == opus_handle->ogg_mode)
{
	opus_handle->oy =  (ogg_sync_state *)malloc( sizeof( ogg_sync_state ));
	opus_handle->og =  (ogg_page *)malloc( sizeof( ogg_page ));
	opus_handle->op =  (ogg_packet *)malloc( sizeof( ogg_packet ));
	opus_handle->os =  (ogg_stream_state *)malloc( sizeof( ogg_stream_state ));

	if(opus_handle->oy==NULL || opus_handle->og==NULL ||opus_handle->op==NULL ||opus_handle->os==NULL )
		return OPUS_ERROR_NO_ENOUGH_BUFFER;

	ogg_sync_init(opus_handle->oy);

	opus_handle->page_granule =0;
	opus_handle->packet_count =0;
	opus_handle->opus_serialno=-1;

	opus_handle->has_opus_stream=0;
	opus_handle->has_tags_packet=0;
	opus_handle->eos=0;
	opus_handle->stream_init=0;
}

	*decode_handle = opus_handle;
	return OPUS_SUCCESS;
}

int OpusDecodeFini( void* decode_handle )
{
	OpusDecodingHandle*		opus_handle = (OpusDecodingHandle *)decode_handle;

	///not init
	if( NULL == opus_handle)
	{
		return OPUS_ERROR_NOT_INIT;
	}

	if(opus_handle->decoder_ != NULL)
		opus_decoder_destroy( opus_handle->decoder_ );
	else if(1 == opus_handle->ogg_mode)
		;
	else
		return OPUS_ERROR_NOT_INIT;

if(1 == opus_handle->ogg_mode)
{
	if(opus_handle->oy==NULL || opus_handle->og==NULL ||opus_handle->op==NULL ||opus_handle->os==NULL )
		return OPUS_ERROR_NOT_INIT;

	if (opus_handle->stream_init == 1)
		ogg_stream_clear(opus_handle->os);
	
	ogg_sync_clear(opus_handle->oy);

	FREE_MEM( opus_handle->oy );
	FREE_MEM( opus_handle->og );
	FREE_MEM( opus_handle->op );
	FREE_MEM( opus_handle->os );

}

	FREE_MEM( opus_handle );

	return OPUS_SUCCESS;
}

int OpusDecode( void* decode_handle
			  , const char* opus
			  , unsigned int opus_len
			  , char* audio
			  , unsigned int* audio_len )
{

	const char*			pOpus = opus;
	char*				pAudio = audio;
	unsigned int		audio_buf_len = *audio_len;
	int					opus_remaining = opus_len;
	unsigned int		audio_data_len = 0;
	opus_int16			speech[ MAX_OPUS_FRAME_SIZE ];
	int					ret = 0;


	OpusDecodingHandle*	opus_handle = (OpusDecodingHandle *)decode_handle;

	if(0 == opus_handle->ogg_mode)
	{
		if( NULL == opus_handle || NULL == opus_handle->decoder_ )
		{
			return OPUS_ERROR_NOT_INIT;
		}
	}

	if(1 == opus_handle->ogg_mode)
	{
		char *data;

		//reset to 0, incase its original input value is not 0
		*audio_len = 0;

		/*Get the ogg buffer for writing*/
		data = ogg_sync_buffer(opus_handle->oy, opus_len);
		/*Read bitstream from input file*/
		memcpy(data, opus, opus_len);
		ogg_sync_wrote(opus_handle->oy, opus_len);

		while (ogg_sync_pageout(opus_handle->oy, opus_handle->og)==1)
		{
			if (opus_handle->stream_init == 0)
			{

				//初始化比特流，给它个串行号
				ogg_stream_init(opus_handle->os, ogg_page_serialno(opus_handle->og));
				opus_handle->stream_init = 1;
			}

			if (ogg_page_serialno(opus_handle->og) != (opus_handle->os)->serialno)
			{
				/* so all streams are read. */
				ogg_stream_reset_serialno(opus_handle->os, ogg_page_serialno(opus_handle->og));
			}
			/*Add page to the bitstream*/
			ogg_stream_pagein(opus_handle->os, opus_handle->og);
			opus_handle->page_granule = ogg_page_granulepos(opus_handle->og);
			/*Extract all available packets*/
			while (ogg_stream_packetout(opus_handle->os, opus_handle->op) == 1)
			{
				/*OggOpus streams are identified by a magic string in the initial
				  stream header.*/
				if (opus_handle->op->b_o_s && opus_handle->op->bytes>=8 && !memcmp(opus_handle->op->packet, "OpusHead", 8))
				{
					if(opus_handle->has_opus_stream && opus_handle->has_tags_packet)
					{
						 /*If we're seeing another BOS OpusHead now it means
						   the stream is chained without an EOS.*/
						 opus_handle->has_opus_stream=0;
						
					}
					if(!opus_handle->has_opus_stream)
					{
						if(opus_handle->packet_count>0 && opus_handle->opus_serialno==opus_handle->os->serialno)
						{
							return OPUS_ERROR_OGG_INVALID_FORMAT;
						}
						 opus_handle->opus_serialno = opus_handle->os->serialno;
						 opus_handle->has_opus_stream = 1;
						 opus_handle->has_tags_packet = 0;
						 opus_handle->packet_count = 0;
						 opus_handle->eos = 0;
					} 
				}
				if (!opus_handle->has_opus_stream || opus_handle->os->serialno != opus_handle->opus_serialno)
					break;
				/*If first packet in a logical stream, process the Opus header*/
				if (opus_handle->packet_count==0)
				{
					OpusHeader header;
					int sample_rate = 0;

					if (opus_header_parse(opus_handle->op->packet, opus_handle->op->bytes, &header)==0)
					{
						return OPUS_ERROR_OGG_INVALID_HEADER;
					}
					sample_rate = header.input_sample_rate;
					if(opus_handle->decoder_ == NULL)
					{
						opus_handle->decoder_ = opus_decoder_create( sample_rate, 1, &ret );
						if( OPUS_OK != ret )
						{
							FREE_MEM( opus_handle );
							return OPUS_ERROR_CREATE_HANDLE;
						}				

						opus_handle->frame_bytes_ = sample_rate / 50 * sizeof( opus_int16 );
					}


				   if(ogg_stream_packetout(opus_handle->os, opus_handle->op)!=0 || opus_handle->og->header[opus_handle->og->header_len-1]==255)
				   {
					  /*The format specifies that the initial header and tags packets are on their
						own pages. To aid implementors in discovering that their files are wrong
						we reject them explicitly here. In some player designs files like this would
						fail even without an explicit test.*/
					   return OPUS_ERROR_OGG_INVALID_FORMAT;
				   }
				} 
				//skip ogg comment header and Setup Header
				else if (opus_handle->packet_count==1)
				{
				   opus_handle->has_tags_packet=1;
				   if(ogg_stream_packetout(opus_handle->os, opus_handle->op)!=0 || opus_handle->og->header[opus_handle->og->header_len-1]==255)
				   {
					   return OPUS_ERROR_OGG_INVALID_FORMAT;
				   }
				}
				else {
				   int write_bytes;

				   /*End of stream condition*/
				   if (opus_handle->op->e_o_s && opus_handle->os->serialno == opus_handle->opus_serialno)
					   opus_handle->eos=1; /* don't care for anything except opus eos */


					/*Decode Opus packet*/
				   write_bytes = opus_decode( opus_handle->decoder_
					   , opus_handle->op->packet
					   , opus_handle->op->bytes
					   , speech
					   , MAX_OPUS_FRAME_SIZE
					   , 0 );

				   /*If the decoder returned less than zero, we have an error.*/
				   if (write_bytes<0)
				   {
					   return OPUS_ERROR_OGG_INVALID_FORMAT;
				   }
				   write_bytes = write_bytes*sizeof(opus_int16);

				   memcpy( pAudio+audio_data_len, speech, write_bytes );

				    audio_data_len += write_bytes;
				}
				opus_handle->packet_count++;
			}
			 if(opus_handle->eos)
			 {
				opus_handle->has_opus_stream=0;
			 }
		}

		if(opus_handle->packet_count > 0)
		{
			*audio_len = audio_data_len;
			return OPUS_SUCCESS;
		}		
	}
	else{
	///decode
	while( opus_remaining + opus_handle->data_cache_len_ >= Min_Com_Frame_Bytes )
	{
		opus_int32		read_bytes = 0;
		unsigned char     reads[2] ={0};
		int				copy_len = 0;
		int	write_bytes = opus_handle->frame_bytes_;

		if( 0 == opus_handle->data_cache_len_ )
		{
			memcpy(opus_handle->data_cache_,pOpus, sizeof(reads));
			memcpy(reads,pOpus, sizeof(reads));
			pOpus += sizeof(reads);
			opus_remaining -=  sizeof(reads);
			opus_handle->data_cache_len_ +=  sizeof(reads);
		}
		else if(1 == opus_handle->data_cache_len_)
		{
			//if we only cached 1 bytes,we cannot parse the length
			//need to make it to 2 bytes
			memcpy(opus_handle->data_cache_+ opus_handle->data_cache_len_,pOpus,1);
			opus_handle->data_cache_len_++;
			pOpus++;
			opus_remaining--;
		}
		read_bytes = char_to_int((unsigned char*)opus_handle->data_cache_);

		copy_len = read_bytes - opus_handle->data_cache_len_ +  sizeof(reads);
		
		///bad compressed frame
		if( read_bytes <= 0 || copy_len < 0 )
		{
			ret = OPUS_ERROR_INVALID_DATA;
			break;
		}
		if( opus_remaining < copy_len )
		{
			break;
		}


		if (copy_len > (Max_Raw_Frame_Size << 1) - opus_handle->data_cache_len_)
		{
			ret = OPUS_ERROR_NO_ENOUGH_BUFFER;
			break;
		}

		memcpy( opus_handle->data_cache_+ opus_handle->data_cache_len_, pOpus, copy_len );
		opus_handle->data_cache_len_ += copy_len;
		pOpus += copy_len;
		opus_remaining -= copy_len;
		
		///uncompress frame
		write_bytes = opus_decode( opus_handle->decoder_
								 , opus_handle->data_cache_ +  sizeof(reads)
								 , read_bytes
								 , speech
								 , opus_handle->frame_bytes_ >> 1
								 , 0 );
		if( write_bytes > 0 )
		{
			write_bytes <<= 1;

			if(write_bytes != opus_handle->frame_bytes_)
				return OPUS_ERROR_INVALID_DATA;

			if( audio_data_len + write_bytes <= audio_buf_len )
			{
				memcpy( pAudio, speech, write_bytes );
				pAudio += write_bytes;
				audio_data_len += write_bytes;
				opus_handle->data_cache_len_ = 0;
			}
			else
			{
				ret = OPUS_ERROR_NO_ENOUGH_BUFFER;
				break;
			}
		}
		else	//corrupt compressed frame
		{
			ret = OPUS_ERROR_INVALID_DATA;
			break;
		}
	}

	if( 0 == ret && 0 != opus_remaining)
	{
		if((opus_handle->data_cache_len_ + opus_remaining) <= sizeof(opus_handle->data_cache_))
			
		{
			memcpy( opus_handle->data_cache_ + opus_handle->data_cache_len_, pOpus, opus_remaining );
			opus_handle->data_cache_len_ += opus_remaining;
		}
		else
			ret = OPUS_ERROR_NO_ENOUGH_BUFFER;	
	}
	
	///set returned value
	*audio_len = audio_data_len;
	return ret;
	}
    return ret;
}


int OpusGetWbFrameLen( int mode )
{
	return mode/1000*COMPRESS_SIZE_PER_KILO + 2;
}

int OpusGetNbFrameLen( int mode )
{
	return mode/1000*COMPRESS_SIZE_PER_KILO + 2;
}

int OpusDetectFrameLen( const unsigned char *frame )
{
	unsigned char reads[2] ={0};
	int readbytes  = 60;
			
	if (NULL == frame)
		return 0;

	memcpy(reads,frame,sizeof(reads));
	readbytes = char_to_int((unsigned char*)reads);

	return readbytes + 2;
}

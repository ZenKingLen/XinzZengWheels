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

#ifndef __LIBOPUS_H__
#define __LIBOPUS_H__

#ifndef MSC_OPUS_EXPORT
# if defined(WIN32)
#  define MSC_OPUS_EXPORT __declspec(dllexport)
# elif defined(__GNUC__)
#   define MSC_OPUS_EXPORT __attribute__ ((visibility ("default")))
# else
#  define MSC_OPUS_EXPORT
# endif
#endif
//#define ICT_INPUT	(256)		 /*samples of in*/
//#define ICT_OUTPUT	(64) /*samples of out*/

#ifdef __cplusplus
extern "C" 
{
#endif /* C++ */


enum {
	OPUS_SUCCESS = 0,
	OPUS_ERROR_FAIL = 1,
	OPUS_ERROR_NULL_HANDLE = 10102,
	OPUS_ERROR_NO_ENOUGH_BUFFER = 10107,
	OPUS_ERROR_CREATE_HANDLE = 10129,
	OPUS_ERROR_NOT_INIT = 10111,
	OPUS_ERROR_INVALID_PARA = 10106,
	OPUS_ERROR_INVALID_DATA = 10109,

	OPUS_ERROR_OGG_INVALID_HEADER        =11910,
	OPUS_ERROR_OGG_INVALID_FORMAT        =11911,
};


/*---------------------------------------------------------------------------------------------------------*/
/* Define Function Prototypes                                                                              */
/*---------------------------------------------------------------------------------------------------------*/
MSC_OPUS_EXPORT int OpusEncodeInit( void** encode_handle, int opus_mode );
typedef MSC_OPUS_EXPORT int (* Proc_OpusEncodeInit)( void** encode_handle, int opus_mode );

MSC_OPUS_EXPORT int OpusEncode( void* encode_handle, const char* audio, unsigned int audio_len, char* opus, unsigned int* opus_len, int bit_rate );
typedef MSC_OPUS_EXPORT int (* Proc_OpusEncode)( void* encode_handle, const char* audio, unsigned int audio_len, char* opus, unsigned int* opus_len, int bit_rate );

MSC_OPUS_EXPORT int OpusEncodeFini( void* encode_handle );
typedef MSC_OPUS_EXPORT int (* Proc_OpusEncodeFini)( void* encode_handle );

MSC_OPUS_EXPORT int OpusDecodeInit( void** decode_handle, int opus_mode );
typedef MSC_OPUS_EXPORT int (* Proc_OpusDecodeInit)( void** decode_handle, int opus_mode );

MSC_OPUS_EXPORT int OpusDecode( void* decode_handle, const char* opus, unsigned int opus_len, char* audio, unsigned int* audio_len );
typedef MSC_OPUS_EXPORT int (* Proc_OpusDecode)( void* decode_handle, const char* opus, unsigned int opus_len, char* audio, unsigned int* audio_len );

MSC_OPUS_EXPORT int OpusDecodeFini( void* decode_handle );
typedef MSC_OPUS_EXPORT int (* Proc_OpusDecodeFini)( void* decode_handle );

MSC_OPUS_EXPORT int OpusGetWbFrameLen( int mode );
typedef MSC_OPUS_EXPORT int (* Proc_OpusGetWbFrameLen)( int mode );

MSC_OPUS_EXPORT int OpusGetNbFrameLen( int mode );
typedef MSC_OPUS_EXPORT int (* Proc_OpusGetNbFrameLen)( int mode );

MSC_OPUS_EXPORT int OpusDetectFrameLen( const unsigned char *frame );
typedef MSC_OPUS_EXPORT int (* Proc_OpusDetectFrameLen)( const unsigned char *frame );

#ifdef __cplusplus
} /* extern "C" */
#endif /* C++ */

#endif /* __LIBOPUS_H__ */
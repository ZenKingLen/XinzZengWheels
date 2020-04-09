//
//  NewOpusMgr.m
//  XinzZengWheels
//
//  Created by 曾杏枝 on 2019/12/16.
//  Copyright © 2019 zengqinglong. All rights reserved.
//

#import "NewOpusMgr.h"
#import <opus/opus.h>

/**
 * 采样率
 * 每秒钟采样次数，采样率越高越能表达高频信号的细节内容。
 * 一般有8K、16K、24K、44.1K、48K。
 */
#define SAMPLE_RATE     16000



/**
 * 通道数
 * 单通道为1， 双通道（立体声）为2
 */
#define CHANNELS        1


/**
 * 位深度
 * 每一个采样数据由多少位来表示，代表了幅度值丰富的变化程度。
 * 1字节 = 8bit, 2个字节 = 16bit, 3字节 = 24bit， 4字节 = 32bit
 */
#define PCM_BIT_DEPTH   16


/**
 * 比特率(码率)
 * 即音频每秒的传播的位数。这里是期望编码器压缩后的码率，而不是录音的码率。
 * BITRATE = SAMPLE_RATE * CHANNELS * PCM_BIT_DEPTH
 */
#define BITRATE         16000

/**
 * 音频帧大小
 * 以时间分割而得，在调用的时候必须使用的是恰好的一帧(2.5ms的倍数：2.5，5，10，20，40，60ms)的音频数据。
 * Fs/ms   2.5     5       10      20      40      60
 * 16kHz   40      80      160     320     640     960
 * 48kHz   120     240     480     960     1920    2880
 */
#define FRAME_SIZE      960 // 16000kHZ * 0.06s


#define APPLICATION         OPUS_APPLICATION_VOIP
#define MAX_PACKET_BYTES    (FRAME_SIZE * CHANNELS * sizeof(opus_int16))
#define MAX_FRAME_SIZE      (FRAME_SIZE * CHANNELS * sizeof(opus_int16))

// 用于记录opus块大小的类型
typedef opus_int16 OPUS_DATA_SIZE_T;


@implementation NewOpusMgr {
    OpusEncoder *_encoder;
    OpusDecoder *_decoder;
}

+ (instancetype)shared {
    static id _instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[super allocWithZone: NULL] init];
    });
    return _instance;
}

+ (id)allocWithZone:(struct _NSZone *)zone {
    return [self shared];
}

- (id)copyWithZone:(struct _NSZone *)zone {
    return [[self class] shared];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _encoder = opus_encoder_create(SAMPLE_RATE, CHANNELS, APPLICATION, NULL);
        opus_encoder_ctl(_encoder, OPUS_SET_BITRATE(BITRATE));
//        opus_encoder_ctl(_encoder, OPUS_SET_SIGNAL(OPUS_SIGNAL_VOICE));
        //        opus_encoder_ctl(_encoder, OPUS_SET_VBR(0));
                opus_encoder_ctl(_encoder, OPUS_SET_APPLICATION(OPUS_APPLICATION_AUDIO));
        
        _decoder = opus_decoder_create(SAMPLE_RATE, CHANNELS, NULL);
    }
    return self;
}

#pragma mark - Public

- (NSData *)encode:(NSData *)PCM {
    opus_int16 *PCMPtr = (opus_int16 *)PCM.bytes;
    int PCMSize = (int)PCM.length / sizeof(opus_int16);
    opus_int16 *PCMEnd = PCMPtr + PCMSize;
    
    NSMutableData *mutData = [NSMutableData data];
    unsigned char encodedPacket[MAX_PACKET_BYTES];
    
    // 记录opus块大小
    OPUS_DATA_SIZE_T encodedBytes = 0;
    
    while (PCMPtr + FRAME_SIZE < PCMEnd) {
        encodedBytes = opus_encode(_encoder, PCMPtr, FRAME_SIZE, encodedPacket, MAX_PACKET_BYTES);
        if (encodedBytes <= 0) {
            NSLog(@"ERROR: encodedBytes<=0");
            return nil;
        }
        NSLog(@"encodedBytes: %d",  encodedBytes);
        
        // 保存opus块大小
        [mutData appendBytes:&encodedBytes length:sizeof(encodedBytes)];
        // 保存opus数据
        [mutData appendBytes:encodedPacket length:encodedBytes];
        
        PCMPtr += FRAME_SIZE;
    }
    
    return mutData.length > 0 ? mutData : nil;
}

- (NSData *)decode:(NSData *)opus {
    unsigned char *opusPtr = (unsigned char *)opus.bytes;
    int opusSize = (int)opus.length;
    unsigned char *opusEnd = opusPtr + opusSize;
    
    NSMutableData *mutData = [NSMutableData data];
    
    opus_int16 decodedPacket[MAX_FRAME_SIZE];
    int decodedSamples = 0;
    
    // 保存opus块大小的数据
    OPUS_DATA_SIZE_T nBytes = 0;
    
    while (opusPtr < opusEnd) {
        // 取出opus块大小的数据
        nBytes = *(OPUS_DATA_SIZE_T *)opusPtr;
        opusPtr += sizeof(nBytes);
        
        decodedSamples = opus_decode(_decoder, opusPtr, nBytes, decodedPacket, MAX_FRAME_SIZE, 0);
        if (decodedSamples <= 0) {
            NSLog(@"ERROR: decodedSamples<=0");
            return nil;
        }
        NSLog(@"decodedSamples:%d", decodedSamples);
        [mutData appendBytes:decodedPacket length:decodedSamples * sizeof(opus_int16)];
        
        opusPtr += nBytes;
    }
    
    return mutData.length > 0 ? mutData : nil;
}

@end

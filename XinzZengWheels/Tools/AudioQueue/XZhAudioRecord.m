//
//  XZhAudioRecord.m
//  XinzZengWheels
//
//  Created by 曾杏枝 on 2019/9/2.
//  Copyright © 2019 zengqinglong. All rights reserved.
//
/**
 多次调用 start 且不调用 stop 异常容错机制:
 1. 单例模式下, 回调指针 inUserData 必须为指向单例对象, 作为抢占式容错方案
 2. 多实例模式下, 回调指针 inUserData 需要指向新的对象, 则使用静态变量保持当前对象, 需要判断初始化对象与当前对象是否一致, 如不一致, 则静态变量需调用 stop 方法, 清空原有进行中的操作, 重新复制静态变量, 调用 start 方法.
 */

#import "XZhAudioRecord.h"
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>


//const int xzh_sample_rate = 16000;          // 采样率
//const int xzh_cache_size = 1280;            // 音频流缓冲区大小. 实际值 <= 1280
//const int xzh_bit_channel = 16;             // 每采样点占用位数
//const int xzh_channel_perframe = 1;         // 声道数
const int xzh_queue_buffer_size = 3;                        // 音频采集队列缓冲个数
const AudioFormatID xzh_format_id = kAudioFormatLinearPCM;  // 录制音频格式

BOOL _recording = NO;

@interface XZhAudioRecord () {
    AudioQueueRef _queueRef;    // 录音数据输出队列
    AudioStreamBasicDescription _basicDesc; // 录音参数配置
    AudioQueueBufferRef _queueBuffer[xzh_queue_buffer_size]; // 录音缓存
    UInt32 bufferByteSize;  // 缓冲区大小
    dispatch_queue_t _opQueue;
}

@end

@implementation XZhAudioRecord {
    struct {
        unsigned int xzhRecordStart: 1;
        unsigned int xzhRecordStop: 1;
        unsigned int xzhRecordError: 1;
        unsigned int xzhRecording: 1;
    } delegateRespondsTo;
}

static XZhAudioRecord *_xzhARInstance;
+ (instancetype)share {
    if (!_xzhARInstance) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{        
            _xzhARInstance = [[XZhAudioRecord alloc] init];
        });
    }
    return _xzhARInstance;
}

//NSException
+ (instancetype)alloc {
    if (_xzhARInstance) {
        NSException *exception = [NSException exceptionWithName:@"Tips" reason:@"please use [XZhAudioRecord share]." userInfo:nil];
        [exception raise];
    }
    return [super alloc];
}

- (instancetype)init {
    if (self = [super init]) {
//        _opQueue = dispatch_queue_create("xzh_record_queue", DISPATCH_QUEUE_SERIAL);
        self.isMainThread = NO;
        [self resetDesc];
    }
    return self;
}

- (void)dealloc {
    AudioQueueDispose(_queueRef, true);
}

#pragma mark - private.

// 设置参数, 初始化缓冲队列
- (void)resetDesc {
    // 重置参数
    memset(&_basicDesc, 0, sizeof(_basicDesc));
    _basicDesc.mSampleRate = xzh_sample_rate;
    // 编码格式
    _basicDesc.mFormatID = kAudioFormatLinearPCM;
    _basicDesc.mFormatFlags = kLinearPCMFormatFlagIsSignedInteger | kLinearPCMFormatFlagIsPacked;
    // 每帧的字节数 / 每包的字节数
    _basicDesc.mBytesPerPacket = _basicDesc.mBytesPerFrame = (_basicDesc.mBitsPerChannel/8)*_basicDesc.mChannelsPerFrame;
    // 每帧的字节数
    _basicDesc.mFramesPerPacket = 1;
    // 声道数量
    _basicDesc.mChannelsPerFrame = xzh_channel_perframe;
    // 每采样点占用位数
    _basicDesc.mBitsPerChannel = xzh_bit_channel;
    //    _basicDesc.mReserved = 1;
}

- (void)resetInput {
    // 重新配置 mic 模式.(防止其他 API 修改)
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    [[AVAudioSession sharedInstance] setActive:YES error:nil];
    // 初始化音频输入队列
    OSStatus status = AudioQueueNewInput(&_basicDesc, pBufferHandler, (__bridge void *)self, NULL, NULL, 0, &_queueRef);
    if (status != kAudioSessionNoError) {
        [self callError:status message:@{@"message": [NSString stringWithFormat:@"line %d, %s init fail.", __LINE__, __func__]}];
        return;
    }
    // 计算估算c缓冲区大小(两种方式: 1. 固定cache_size; 2. 固定时间间隔, 需要计算缓冲器大小DeriveBufferSize)
    bufferByteSize = xzh_cache_size;
    // 创建缓冲器
    for (int i = 0; i < xzh_queue_buffer_size; i++) {
        status =  AudioQueueAllocateBuffer(_queueRef, bufferByteSize, &_queueBuffer[i]);
        if (status != kAudioSessionNoError) {
            [self callError:status message:@{@"message": [NSString stringWithFormat:@"line %d, %s init fail.", __LINE__, __func__]}];
            return;
        }
        status = AudioQueueEnqueueBuffer(_queueRef, _queueBuffer[i], 0, NULL);
        if (status != kAudioSessionNoError) {
            [self callError:status message:@{@"message": [NSString stringWithFormat:@"line %d, %s init fail.", __LINE__, __func__]}];
            return;
        }
    }
}

void pBufferHandler(void *inUserData, AudioQueueRef inAQ, AudioQueueBufferRef inBuffer, const AudioTimeStamp *inStartTime,UInt32 inNumPackets, const AudioStreamPacketDescription *inPacketDesc) {
    if (inNumPackets > 0) {
        _xzhARInstance = (__bridge XZhAudioRecord*)inUserData;
        [_xzhARInstance processAudioBuffer:inBuffer withQueue:inAQ];
    }
    if (_recording) {
        AudioQueueEnqueueBuffer(inAQ, inBuffer, 0, NULL);
    }
}

- (void)processAudioBuffer:(AudioQueueBufferRef )audioQueueBufferRef withQueue:(AudioQueueRef )audioQueueRef {
    NSData *data = [NSMutableData dataWithBytes:audioQueueBufferRef->mAudioData length:audioQueueBufferRef->mAudioDataByteSize];
    NSLog(@"recording status: %u, data length: %ld", _recording, data.length);
    // 处理长度小于bufferByteSize的情况. (补0 或者 缓存数据等待填充)
//    if (mData.length < bufferByteSize) {
//        Byte byte[] = {0x00};
//        NSData * zeroData = [[NSData alloc] initWithBytes:byte length:1];
//        for (NSUInteger i = mData.length; i < bufferByteSize; i++) {
//            [mData appendData:zeroData];
//        }
//    }
    if(delegateRespondsTo.xzhRecording){
        dispatch_async(_opQueue, ^{
            [self.delegate xzhRecording:data];
        });
    }
}

- (void)callError:(NSInteger)code message:(NSDictionary *)message {
    dispatch_async(_opQueue, ^{
        NSError *error = [NSError errorWithDomain:NSCocoaErrorDomain code:code userInfo:message];
        [self.delegate xzhRecordError:error];
    });
}

// 音量监听
//- (BOOL)enableUpdateLevelMetering {
//    UInt32 val = 1;
//    //kAudioQueueProperty_EnableLevelMetering的setter
//    OSStatus status = AudioQueueSetProperty(_queueRef, kAudioQueueProperty_EnableLevelMetering, &val, sizeof(UInt32));
//    if( status == kAudioSessionNoError ) {
//        return YES;
//    }
//    return NO;
//}

// 音量更新获取
//- (float)getCurrentPower {
//    UInt32 dataSize = sizeof(AudioQueueLevelMeterState) * recordFormat.mChannelsPerFrame;
//    AudioQueueLevelMeterState *levels = (AudioQueueLevelMeterState*)malloc(dataSize);
//    //kAudioQueueProperty_EnableLevelMetering的getter
//    OSStatus rc = AudioQueueGetProperty(audioQRef, kAudioQueueProperty_CurrentLevelMeter, levels, &dataSize);
//    if (rc) {
//        NSLog(@"NoiseLeveMeter>>takeSample - AudioQueueGetProperty(CurrentLevelMeter) returned %@", rc);
//    }
//
//    float channelAvg = 0;
//    for (int i = 0; i < recordFormat.mChannelsPerFrame; i++) {
//        channelAvg += levels[i].mPeakPower;  //取个平均值
//    }
//    free(levels);
//
//    // This works because in this particular case one channel always has an mAveragePower of 0.
//    return channelAvg;
//}

// 通过时间频率, 计算缓冲器大小.
//void DeriveBufferSize (AudioQueueRef                audioQueue,
//                       AudioStreamBasicDescription  ASBDescription,
//                       Float64                      seconds,
//                       UInt32                       *outBufferSize) {
//    static const int maxBufferSize = 0x50000;                 // 5
//
//    int maxPacketSize = ASBDescription.mBytesPerPacket;       // 6
//    if (maxPacketSize == 0) {                                 // 7
//        UInt32 maxVBRPacketSize = sizeof(maxPacketSize);
//        AudioQueueGetProperty (
//                               audioQueue,
//                               kAudioQueueProperty_MaximumOutputPacketSize,
//                               // in Mac OS X v10.5, instead use
//                               //   kAudioConverterPropertyMaximumOutputPacketSize
//                               &maxPacketSize,
//                               &maxVBRPacketSize
//                               );
//    }
//    Float64 numBytesForTime = ASBDescription.mSampleRate * maxPacketSize * seconds; // 8
//    *outBufferSize = (UInt32)(numBytesForTime < maxBufferSize ?
//                              numBytesForTime : maxBufferSize);                     // 9
//}

#pragma mark - public interface.

- (void)start {
    dispatch_async(_opQueue, ^{
        [self resetInput];
        OSStatus status = AudioQueueStart(self->_queueRef, NULL);
        NSLog(@"start status = %u", status);
        if (kAudioSessionNoError == status && 1 == self->delegateRespondsTo.xzhRecordStart) {
            _recording = YES;
            // 音量监听
//            [self enableUpdateLevelMetering];
            [self.delegate xzhRecordStart];
        } else if(kAudioSessionNoError != status && 1 == self->delegateRespondsTo.xzhRecordError) {
            [self callError:status message:@{@"message": [NSString stringWithFormat:@"line %d, %s fail.", __LINE__, __func__]}];
        }
    });
}

- (void)stop {
    dispatch_async(_opQueue, ^{
        if (_recording) {
            //停止录音队列和移除缓冲区,以及关闭session，这里无需考虑成功与否. true: 异步回调缓冲数据, false: 执行队列
            OSStatus status = AudioQueueStop(self->_queueRef, true);
            NSLog(@"stop status 1 = %u", status);
            if (kAudioSessionNoError != status && 1 == self->delegateRespondsTo.xzhRecordError) {
                [self callError:status message:@{@"message": [NSString stringWithFormat:@"line %d, %s fail.", __LINE__, __func__]}];
                return;
            }
            //移除缓冲区,true代表立即结束录制，false代表将缓冲区处理完再结束
            status = AudioQueueDispose(self->_queueRef, true);
            if (kAudioSessionNoError != status && 1 == self->delegateRespondsTo.xzhRecordError) {
                [self callError:status message:@{@"message": [NSString stringWithFormat:@"line %d, %s fail.", __LINE__, __func__]}];
                return;
            }
            NSLog(@"stop status 2 = %u", status);
            _recording = NO;
            if (kAudioSessionNoError == status && 1 == self->delegateRespondsTo.xzhRecordStart) {
                [self.delegate xzhRecordStop];
            }
        }
    });
}

- (void)setIsMainThread:(BOOL)isMainThread {
    _isMainThread = isMainThread;
    if (isMainThread) {
        _opQueue = dispatch_get_main_queue();
    } else {
        _opQueue = dispatch_queue_create("xzh_record_queue", DISPATCH_QUEUE_SERIAL);
    }
}

// cache delegate status.
- (void)setDelegate:(id<XZhRecordDelegate>)delegate {
    if (_delegate != delegate) {
        _delegate = delegate;
        delegateRespondsTo.xzhRecordStart = [delegate respondsToSelector:@selector(xzhRecordStart)];
        delegateRespondsTo.xzhRecording = [delegate respondsToSelector:@selector(xzhRecording:)];
        delegateRespondsTo.xzhRecordStop = [delegate respondsToSelector:@selector(xzhRecordStop)];
        delegateRespondsTo.xzhRecordError = [delegate respondsToSelector:@selector(xzhRecordError:)];
    }
}

- (BOOL)convertPCMFile:(NSString *)pcmFile toWavFile:(NSString *)wavFile {
//    NSString *wavFilePath = wavFile;  //wav文件的路径
//    NSLog(@"PCM file path : %@",pcmFile); //pcm文件的路径
    if (![[NSFileManager defaultManager] fileExistsAtPath:pcmFile]) {
        return NO;
    }
    FILE *fout;
    short NumChannels = 1;                      //录音通道数
    short BitsPerSample = xzh_bit_channel;      //线性采样位数
    int SamplingRate = xzh_sample_rate;         //录音采样率(Hz)
    int numOfSamples = (int)[[NSData dataWithContentsOfFile:pcmFile] length];
    
    int ByteRate = NumChannels*BitsPerSample*SamplingRate/8;
    short BlockAlign = NumChannels*BitsPerSample/8;
    int DataSize = NumChannels*numOfSamples*BitsPerSample/8;
    int chunkSize = 16;
    int totalSize = 46 + DataSize;
    short audioFormat = 1;
    if((fout = fopen([wavFile cStringUsingEncoding:1], "w")) == NULL)
    {
        printf("Error opening out file ");
    }
    
    fwrite("RIFF", sizeof(char), 4,fout);
    fwrite(&totalSize, sizeof(int), 1, fout);
    fwrite("WAVE", sizeof(char), 4, fout);
    fwrite("fmt ", sizeof(char), 4, fout);
    fwrite(&chunkSize, sizeof(int),1,fout);
    fwrite(&audioFormat, sizeof(short), 1, fout);
    fwrite(&NumChannels, sizeof(short),1,fout);
    fwrite(&SamplingRate, sizeof(int), 1, fout);
    fwrite(&ByteRate, sizeof(int), 1, fout);
    fwrite(&BlockAlign, sizeof(short), 1, fout);
    fwrite(&BitsPerSample, sizeof(short), 1, fout);
    fwrite("data", sizeof(char), 4, fout);
    fwrite(&DataSize, sizeof(int), 1, fout);
    
    fclose(fout);
    
    NSMutableData *pamdata = [NSMutableData dataWithContentsOfFile:pcmFile];
    NSFileHandle *handle;
    handle = [NSFileHandle fileHandleForUpdatingAtPath:wavFile];
    if (!handle) {
        return NO;
    }
    [handle seekToEndOfFile];
    [handle writeData:pamdata];
    [handle closeFile];
    return YES;
}

#pragma mark - getter

- (BOOL)isRecording {
    return _recording;
}

@end

//
//  XZhAudioRecord.h
//  XinzZengWheels
//
//  Created by 曾杏枝 on 2019/9/2.
//  Copyright © 2019 zengqinglong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XZhAudioConfig.h"

NS_ASSUME_NONNULL_BEGIN

@protocol XZhRecordDelegate <NSObject>
@optional
- (void)xzhRecordStart;
- (void)xzhRecordStop;
- (void)xzhRecordError:(NSError *)error;
- (void)xzhRecording:(NSData *)data;

@end

@interface XZhAudioRecord : NSObject

@property(nonatomic, assign, readonly) BOOL isRecording;
@property(nonatomic, assign) BOOL isMainThread;
@property(nonatomic, weak) id<XZhRecordDelegate> delegate;

+ (instancetype)share;

- (void)start;

- (void)stop;

- (BOOL)convertPCMFile:(NSString *)pcmFile toWavFile:(NSString *)wavFile;

@end

NS_ASSUME_NONNULL_END

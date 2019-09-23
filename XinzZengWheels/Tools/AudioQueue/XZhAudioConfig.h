//
//  XZhAudioConfig.h
//  XinzZengWheels
//
//  Created by 曾杏枝 on 2019/9/6.
//  Copyright © 2019 zengqinglong. All rights reserved.
//

#import <Foundation/Foundation.h>

extern const int xzh_sample_rate;          // 采样率
extern const int xzh_cache_size;            // 音频流缓冲区大小. 实际值 <= 1280
extern const int xzh_bit_channel;             // 每采样点占用位数
extern const int xzh_channel_perframe;         // 声道数

NS_ASSUME_NONNULL_BEGIN

@interface XZhAudioConfig : NSObject

@end

NS_ASSUME_NONNULL_END

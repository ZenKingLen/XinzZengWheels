//
//  XZhAudioConfig.m
//  XinzZengWheels
//
//  Created by 曾杏枝 on 2019/9/6.
//  Copyright © 2019 zengqinglong. All rights reserved.
//

#import "XZhAudioConfig.h"

const int xzh_sample_rate = 16000;          // 采样率
const int xzh_cache_size = 1280;            // 音频流缓冲区大小. 实际值 <= 1280
const int xzh_bit_channel = 16;             // 每采样点占用位数
const int xzh_channel_perframe = 1;         // 声道数

@implementation XZhAudioConfig

@end

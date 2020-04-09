//
//  NewOpuslib.h
//  XinzZengWheels
//
//  Created by 曾杏枝 on 2020/1/15.
//  Copyright © 2020 zengqinglong. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NewOpuslib : NSObject

- (NSData *)encodeWithPCM:(NSData *)data;

@end

NS_ASSUME_NONNULL_END

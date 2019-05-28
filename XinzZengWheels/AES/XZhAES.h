//
//  XZhAES.h
//  XinzZengWheels
//
//  Created by 曾杏枝 on 2019/5/29.
//  Copyright © 2019 zengqinglong. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface XZhAES : NSObject

+ (NSData *)xzh_dataWith128Decrypt:(NSData *)data withKey:(NSString *)key;

+ (NSData *)xzh_dataWith128Encrypt:(NSData *)data withKey:(NSString *)key;

@end

NS_ASSUME_NONNULL_END

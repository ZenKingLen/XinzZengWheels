//
//  NSData+XZhData.h
//  XinzZengWheels
//
//  Created by 曾杏枝 on 2019/5/29.
//  Copyright © 2019 zengqinglong. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSData (XZhData)
// aes 128 解密算法
- (NSData *)xzh_aes128DataDecryptWithKey:(NSString *)key;
// aes 128 加密算法
- (NSData *)xzh_aes128DataEncryptWithKey:(NSString *)key;
// 十六进制字符串转换为十六进制数
- (NSData *)xzh_dataWithHexString:(NSString *)hexString;

@end

NS_ASSUME_NONNULL_END

//
//  NSData+XZhData.m
//  XinzZengWheels
//
//  Created by 曾杏枝 on 2019/5/29.
//  Copyright © 2019 zengqinglong. All rights reserved.
//

#import "NSData+XZhData.h"
// MARK: - mark 1: use aes to add this system framework. -
#import <CommonCrypto/CommonCryptor.h>
// mark 1: end.

@implementation NSData (XZhData)

#pragma mark - aes 加密解密 -

/**
 aes128 加密

 @param key     key description
 @return return value description
 */
- (NSData *)xzh_aes128DataDecryptWithKey:(NSString *)key {
    if (!key || [key length]<1) {
        return nil;
    }
    // 填充方式 (自动填充)
    // 初始向量值 (ecb 无初始向量)
    // 加密模式 (ECB)
    // 长度
    char keyPtr[kCCKeySizeAES128 + 1];
    bzero(keyPtr, sizeof(keyPtr));
    [key getCString:keyPtr maxLength:sizeof(keyPtr) encoding:NSUTF8StringEncoding];
    NSUInteger dataLength = [self length];
    size_t bufferSize = dataLength + kCCBlockSizeAES128;
    void *buffer = malloc(bufferSize);
    size_t numBytesEncrypt = 0;
    CCCryptorStatus status = CCCrypt(kCCEncrypt,
                                     kCCAlgorithmAES128,
                                     kCCOptionECBMode | kCCOptionPKCS7Padding,
                                     keyPtr,
                                     kCCBlockSizeAES128,
                                     NULL,
                                     [self bytes],
                                     dataLength,
                                     buffer,
                                     bufferSize,
                                     &numBytesEncrypt);
    if (status == kCCSuccess) {
        return  [NSData dataWithBytesNoCopy:buffer length:numBytesEncrypt];
    }
    free(buffer);
    NSLog(@"decrypt fail. status: %d", status);
    return nil;
}

/**
 aes128 解密

 @param key key description
 @return return value description
 */
- (NSData *)xzh_aes128DataEncryptWithKey:(NSString *)key {
    if (!key || [key length]<1) {
        NSLog(@"key is nil.");
        return nil;
    }
    char keyPtr[kCCKeySizeAES128+1];
    bzero(keyPtr, sizeof(keyPtr));
    [key getCString:keyPtr maxLength:sizeof(keyPtr) encoding:NSUTF8StringEncoding];
    NSUInteger dataLength = [self length];
    size_t bufferSize = dataLength + kCCBlockSizeAES128;
    void *buffer = malloc(bufferSize);
    size_t numBytesDecrypted = 0;
    CCCryptorStatus status = CCCrypt(kCCDecrypt,
                                     kCCAlgorithmAES128,
                                     kCCOptionPKCS7Padding | kCCOptionECBMode,
                                     keyPtr,
                                     kCCBlockSizeAES128,
                                     NULL,
                                     [self bytes],
                                     dataLength,
                                     buffer,
                                     bufferSize,
                                     &numBytesDecrypted);
    if (status == kCCSuccess) {
        return [NSData dataWithBytesNoCopy:buffer length:numBytesDecrypted];
    }
    free(buffer);
    NSLog(@"encrypt fail. status: %d", status);
    return nil;
}

#pragma mark - 数据转换 data convertion.-

- (NSData *)xzh_dataWithHexString:(NSString *)hexString {
    if (!hexString || [hexString length] == 0) {
        return nil;
    }
    NSMutableData *hexData = [[NSMutableData alloc] initWithCapacity:8];
    NSRange range;
    if ([hexString length] % 2 == 0) {
        range = NSMakeRange(0, 2);
    } else {
        range = NSMakeRange(0, 1);
    }
    for (NSInteger i = range.location; i < [hexString length]; i += 2) {
        unsigned int anInt;
        NSString *hexCharString = [hexString substringWithRange:range];
        NSScanner *scanner = [[NSScanner alloc] initWithString:hexCharString];
        
        [scanner scanHexInt:&anInt];
        NSData *entity = [[NSData alloc] initWithBytes:&anInt length:1];
        [hexData appendData:entity];
        
        range.location += range.length;
        range.length = 2;
    }
    //    NSLog(@"hexdata: %@", hexData);
    return hexData;
}

@end

//
//  XZhAES.m
//  XinzZengWheels
//
//  Created by 曾杏枝 on 2019/5/29.
//  Copyright © 2019 zengqinglong. All rights reserved.
//

#import "XZhAES.h"
#import <CommonCrypto/CommonCryptor.h>

@implementation XZhAES

+ (NSData *)xzh_dataWith128Decrypt:(NSData *)data withKey:(NSString *)key {
    if ([key isEqualToString:@""] || !key) {
        return nil;
    }
    // 填充方式 (自动填充)
    // 初始向量值 (ecb 无初始向量)
    // 加密模式 (ECB)
    // 长度
    char keyPtr[kCCKeySizeAES128 + 1];
    bzero(keyPtr, sizeof(keyPtr));
    [key getCString:keyPtr maxLength:sizeof(keyPtr) encoding:NSUTF8StringEncoding];
    NSUInteger dataLength = data.length;
    size_t bufferSize = dataLength + kCCBlockSizeAES128;
    void *buffer = malloc(bufferSize);
    size_t numBytesEncrypt = 0;
    CCCryptorStatus status = CCCrypt(kCCEncrypt,
                                     kCCAlgorithmAES128,
                                     kCCOptionECBMode | kCCOptionPKCS7Padding,
                                     keyPtr,
                                     kCCBlockSizeAES128,
                                     NULL,
                                     data.bytes,
                                     dataLength,
                                     buffer,
                                     bufferSize,
                                     &numBytesEncrypt);
    if (status == kCCSuccess) {
        return  [NSData dataWithBytesNoCopy:buffer length:numBytesEncrypt];
    }
    NSLog(@"加密失败: %d", status);
    free(buffer);
    return nil;
}

+ (NSData *)xzh_dataWith128Encrypt:(NSData *)data withKey:(NSString *)key {
    if ([key isEqualToString:@""] || !key) {
        return nil;
    }
    char keyPtr[kCCKeySizeAES128+1];
    bzero(keyPtr, sizeof(keyPtr));
    [key getCString:keyPtr maxLength:sizeof(keyPtr) encoding:NSUTF8StringEncoding];
    NSUInteger dataLength = [data length];
    size_t bufferSize = dataLength + kCCBlockSizeAES128;
    void *buffer = malloc(bufferSize);
    size_t numBytesDecrypted = 0;
    CCCryptorStatus cryptStatus = CCCrypt(kCCDecrypt,
                                          kCCAlgorithmAES128,
                                          kCCOptionPKCS7Padding | kCCOptionECBMode,
                                          keyPtr,
                                          kCCBlockSizeAES128,
                                          NULL,
                                          [data bytes],
                                          dataLength,
                                          buffer,
                                          bufferSize,
                                          &numBytesDecrypted);
    if (cryptStatus == kCCSuccess) {
        return [NSData dataWithBytesNoCopy:buffer length:numBytesDecrypted];
    }
    free(buffer);
    return nil;
}

@end

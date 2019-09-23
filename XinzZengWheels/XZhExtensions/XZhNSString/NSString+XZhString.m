//
//  NSString+XZhString.m
//  XinzZengWheels
//
//  Created by 曾杏枝 on 2019/5/29.
//  Copyright © 2019 zengqinglong. All rights reserved.
//

#import "NSString+XZhString.h"

@implementation NSString (XZhString)
@dynamic xzh_hexDataString;

- (NSString * _Nonnull (^)(NSData * _Nonnull))xzh_hexDataString {
    return ^NSString *(NSData *data) {
        if (!data || [data length] == 0) {
            return @"";
        }
        NSMutableString *string = [[NSMutableString alloc] initWithCapacity:[data length]];
        [data enumerateByteRangesUsingBlock:^(const void *bytes, NSRange byteRange, BOOL *stop) {
            unsigned char *dataBytes = (unsigned char*)bytes;
            for (NSInteger i = 0; i < byteRange.length; i++) {
                NSString *hexString = [NSString stringWithFormat:@"%x", (dataBytes[i]) & 0xff];
                if ([hexString length] == 2) {
                    [string appendString:hexString];
                } else {
                    [string appendFormat:@"0%@", hexString];
                }
            }
        }];
        return string;
    };
}

- (void)setXzh_hexDataString:(NSString * _Nonnull (^)(NSData * _Nonnull))xzh_hexDataString {};


- (NSString *)xzh_stringWithHexData:(NSData *)data {
    if (!data || [data length] == 0) {
        return @"";
    }
    NSMutableString *string = [[NSMutableString alloc] initWithCapacity:[data length]];
    [data enumerateByteRangesUsingBlock:^(const void *bytes, NSRange byteRange, BOOL *stop) {
        unsigned char *dataBytes = (unsigned char*)bytes;
        for (NSInteger i = 0; i < byteRange.length; i++) {
            NSString *hexString = [NSString stringWithFormat:@"%x", (dataBytes[i]) & 0xff];
            if ([hexString length] == 2) {
                [string appendString:hexString];
            } else {
                [string appendFormat:@"0%@", hexString];
            }
        }
    }];
    return string;
}



@end

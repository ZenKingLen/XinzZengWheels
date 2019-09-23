//
//  NSString+XZhString.h
//  XinzZengWheels
//
//  Created by 曾杏枝 on 2019/5/29.
//  Copyright © 2019 zengqinglong. All rights reserved.
/**
 MARK:- 十六进制转换字符串十六进制
 */

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSString (XZhString)

#pragma mark - 链式调用 -
@property(nonatomic, copy) NSString *(^xzh_hexDataString)(NSData *data);

//- (NSString *)xzh_stringWithHexData:(NSData *)data;

@end

NS_ASSUME_NONNULL_END

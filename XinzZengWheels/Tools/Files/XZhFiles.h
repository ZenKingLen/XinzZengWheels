//
//  XZhFiles.h
//  XinzZengWheels
//
//  Created by 曾杏枝 on 2019/7/4.
//  Copyright © 2019 zengqinglong. All rights reserved.

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 MARK:- 通过文件后缀名, 查找文件夹中的所有文件
 */
@interface XZhFiles : NSObject

/**
 区分大小写获取文件夹指定文件类型信息
 
 params:
 @document: 文件夹路径
 @format: 文件格式
 
 return:
 区分大小写获取文件夹指定文件类型信息
 @"fileType":   文件类型
 @"fileName":   文件名称
 @"filePath":   文件路径
 */
+ (NSArray <NSDictionary *>*(^)(NSString *document, NSString *format))uniformtCaseFiles;

/**
 不区分大小写获取文件夹指定文件类型信息

 params:
 @document: 文件夹路径
 @format: 文件格式
 
 return:
 @"fileType":   文件类型
 @"fileName":   文件名称
 @"filePath":   文件路径
 */
+ (NSArray <NSDictionary *>*(^)(NSString *document, NSString *format))uniformtNoCaseFiles;

/**
 获取文件夹指定文件类型信息

 params:
 @document: 文件夹路径
 @format: 文件格式
 @isDifCase: 是否区分大小写. true= 区分, false= 不区分
 
 return:
 @"fileType":   文件类型
 @"fileName":   文件名称
 @"filePath":   文件路径
 */
+ (NSArray <NSDictionary *>*(^)(NSString *document, NSString *format, BOOL isDifCase))uniformtFiles;

/**
 获取文件夹文件信息

 params:
 @document: 文件夹路径
 
 return:
 @"fileType":   文件类型
 @"fileName":   文件名称
 @"filePath":   文件路径
 */
+ (NSArray <NSDictionary *>*(^)(NSString *document))documentFiles;

@end

/**
 MARK:- 文件io
 */
@interface XZhFiles (XZhFilesIO)

/**
 数据流持续写入文件. 文件不存在, 则自动生成.
 
 params:
 @data: 数据流
 @filePath: 文件路径
 
 return: YES = 成功, NO = 失败.
 */
+ (BOOL (^)(NSData *data, NSString *filePath))writeDataToFile;

@end

NS_ASSUME_NONNULL_END

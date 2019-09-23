//
//  XZhFiles.m
//  XinzZengWheels
//
//  Created by 曾杏枝 on 2019/7/4.
//  Copyright © 2019 zengqinglong. All rights reserved.
//

#import "XZhFiles.h"

@implementation XZhFiles

+ (NSArray <NSDictionary *>*(^)(NSString *document, NSString *format))uniformtCaseFiles {
    return ^NSArray <NSDictionary *>*(NSString *document, NSString *format){
        return XZhFiles.uniformtFiles(document, format, YES);
    };
}

+ (NSArray <NSDictionary *>*(^)(NSString *document, NSString *format))uniformtNoCaseFiles {
    return ^NSArray <NSDictionary *>*(NSString *document, NSString *format){
        return XZhFiles.uniformtFiles(document, format, NO);
    };
}

+ (NSArray <NSDictionary *>*(^)(NSString *document, NSString *format, BOOL isDifCase))uniformtFiles {
    return ^NSArray *(NSString *document, NSString *format, BOOL isDifCase){
        NSArray *allFiles = XZhFiles.documentFiles(document);
        NSMutableArray *formatFiles = [NSMutableArray array];
        for (NSDictionary *fileInfo in allFiles) {
            if ([fileInfo.allKeys containsObject:@"fileType"]) {
                NSString *fileType = fileInfo[@"fileType"];
                BOOL isType;
                if (isDifCase) {
                    isType = [format isEqualToString:fileType];
                } else{
                    isType = ([fileType compare: format
                                        options: NSCaseInsensitiveSearch|NSNumericSearch] == NSOrderedSame);
                }
                if (!isType) {
                    continue;
                }
                [formatFiles addObject:fileInfo];
            }
        }
        return formatFiles.copy;
    };
}

+ (NSArray <NSDictionary *>*(^)(NSString *document))documentFiles {
    return ^NSArray *(NSString *document){
        if (![[NSFileManager defaultManager] fileExistsAtPath:document]) {
            NSAssert(document, @"ducument is not exist.");
        }
        NSMutableArray *files = [NSMutableArray array];
        NSDirectoryEnumerator *dirEnumerator = [[NSFileManager defaultManager] enumeratorAtPath:document];
        NSString *filePath;
        while ((filePath = [dirEnumerator nextObject]) != nil) {
            NSString *fileType = [filePath componentsSeparatedByString:@"."].lastObject;
            NSString *fileName = [filePath componentsSeparatedByString:@"."].firstObject;
            filePath = [document stringByAppendingPathComponent:filePath];
            NSDictionary *fileInfo = @{@"fileType": fileType,
                                       @"fileName": fileName,
                                       @"filePath": filePath};
            [files addObject:fileInfo];
        }
        return files.copy;
    };
}


@end

@implementation XZhFiles (XZhFilesIO)

+ (BOOL (^)(NSData *data, NSString *filePath))writeDataToFile {
    return ^BOOL (NSData *data, NSString *filePath) {
        if (![[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
            if (![data writeToFile:filePath atomically:YES]) {
                NSLog(@"data writeToFile failed.");
                return NO;
            }
            return YES;
        }
        NSFileHandle *fileHandle = [NSFileHandle fileHandleForWritingAtPath:filePath];
        if(fileHandle == nil) {
            NSLog(@"fileHandleForWritingAtPath failed.");
            return NO;
        }
        [fileHandle seekToEndOfFile];
        [fileHandle writeData:data];
        [fileHandle closeFile];
        return YES;
    };
}

@end

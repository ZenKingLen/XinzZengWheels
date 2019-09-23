//
//  XZhAlertSheet.h
//  XinzZengWheels
//
//  Created by 曾杏枝 on 2019/6/30.
//  Copyright © 2019 zengqinglong. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum : NSUInteger {
    XZhAlertStyleAlert = 0,
    XZhAlertStyleSheet,
} XZhAlertStyle;

NS_ASSUME_NONNULL_BEGIN

@interface XZhAlertSheet : NSObject

@property(nonatomic, assign) XZhAlertStyle style;



@end

NS_ASSUME_NONNULL_END

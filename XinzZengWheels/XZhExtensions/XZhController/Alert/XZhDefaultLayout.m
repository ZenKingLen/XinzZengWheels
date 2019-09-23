//
//  XZhDefaultLayout.m
//  XinzZengWheels
//
//  Created by 曾杏枝 on 2019/7/1.
//  Copyright © 2019 zengqinglong. All rights reserved.
//

#import "XZhDefaultLayout.h"


//#define SCREEN_W [UIScreen mainScreen].bounds.size.width
//#define SCREEN_H [UIScreen mainScreen].bounds.size.height
//#define WIDTHSCALE(awidth) [UIScreen mainScreen].bounds.size.width / 375 * awidth
//#define HEIGHTSCALE(aheight) [[UIScreen mainScreen] bounds].size.height / 667 * aheight
//#define DEFAULT_COLOR [UIColor colorWithRed:0 green:0.48 blue:1 alpha:1]
//#define DEFAULT_LINECOLOR [UIColor colorWithRed:0 green:0 blue:0.31 alpha:0.05]
//#define ALERT_WIDTH 270
//#define left_X 10  //actionSheetView的x坐标
//#define label_X 16  //lable的x坐标
//#define MAX_Y 30    //actionSheet最大高度时的Y坐标

@interface XZhDefaultLayout ()

/**
 分割线颜色  default R:0 G:0 B:0.31 A:0.05
 */
@property (nonatomic, strong, nullable) UIColor *lineColor;

/**
 alertView分割线上部视图的背景颜色 default whiteColor
 */
@property (nonatomic, strong, nullable) UIColor *topViewBackgroundColor;

/**
 titleFont 默认为17 加粗
 */
@property (nonatomic, strong, nullable) UIFont *titleFont;

/**
 messageFont 默认为13 常规
 */
@property (nonatomic, strong, nullable) UIFont *messageFont;

/**
 titleColor default blackColor
 */
@property (nonatomic, strong, nullable) UIColor *titleColor;

/**
 messageTextColor default blackColor
 */
@property (nonatomic, strong, nullable) UIColor *messageColor;

/**
 style == default 按钮字体颜色 默认蓝色
 */
@property (nonatomic, strong, nullable) UIColor *defaultActionTitleColor;

/**
 style == cancel 按钮字体颜色 默认蓝色
 */
@property (nonatomic, strong, nullable) UIColor *cancelActionTitleColor;

/**
 style == done 按钮字体颜色 默认蓝色
 */
@property (nonatomic, strong, nullable) UIColor *doneActionTitleColor;

/**
 style == default 按钮字体大小 默认为17
 */
@property (nonatomic, strong, nullable) UIFont *defaultActionTitleFont;

/**
 style == cancel 按钮字体大小 默认为17
 */
@property (nonatomic, strong, nullable) UIFont *cancelActionTitleFont;

/**
 style == done 按钮字体大小 默认为17
 */
@property (nonatomic, strong, nullable) UIFont *doneActionTitleFont;

/**
 style == default 按钮背景颜色 default whiteColor
 */
@property (nonatomic, strong, nullable) UIColor *defaultActionBackgroundColor;

/**
 style == cancel 按钮背景颜色 default whiteColor
 */
@property (nonatomic, strong, nullable) UIColor *cancelActionBackgroundColor;

/**
 style == done 按钮背景颜色 default whiteColor
 */
@property (nonatomic, strong, nullable) UIColor *doneActionBackgroundColor;

@end

@implementation XZhDefaultLayout

+ (CGFloat)screenWidth {
    return [UIScreen mainScreen].bounds.size.width;
}

+ (CGFloat)screenHeight {
    return [UIScreen mainScreen].bounds.size.height;
}

+ (UIColor *)backgroundColor {
    return [UIColor colorWithRed:0 green:0.48 blue:1.0 alpha:1];
}

+ (UIColor *)lineColor {
    return [UIColor colorWithRed:0 green:0 blue:0 alpha:0.05];
}

- (instancetype)init {
    if (self = [super init]) {
        [self defaultProperties];
    }
    return self;
}

- (void)defaultProperties {
    CGFloat titleFontSize = 17.0;
    CGFloat actionTitleSizeDefault = 17.0;
    CGFloat actionTitleSizeCancel = 17.0;
    CGFloat actionTitleSizeDone = 17.0;
    UIColor *titleColor = [UIColor blackColor];
    UIColor *messageColor = [UIColor blackColor];
    self.lineColor = [XZhDefaultLayout lineColor];
    self.topViewBackgroundColor = [UIColor whiteColor];
    self.titleFont = [UIFont boldSystemFontOfSize:titleFontSize];
    self.messageFont = [UIFont systemFontOfSize:13.0];
    self.titleColor = titleColor;
    self.messageColor = messageColor;
    self.defaultActionTitleFont = [UIFont systemFontOfSize:actionTitleSizeDefault];
    self.cancelActionTitleFont = [UIFont boldSystemFontOfSize:actionTitleSizeCancel];
    self.doneActionTitleFont = [UIFont systemFontOfSize:actionTitleSizeDone];
    self.defaultActionTitleColor = [XZhDefaultLayout backgroundColor];
    self.cancelActionTitleColor = [XZhDefaultLayout backgroundColor];
    self.doneActionTitleColor = [XZhDefaultLayout backgroundColor];
    self.defaultActionBackgroundColor = [UIColor whiteColor];
    self.cancelActionBackgroundColor = [UIColor whiteColor];
    self.doneActionBackgroundColor = [UIColor whiteColor];
}

@end

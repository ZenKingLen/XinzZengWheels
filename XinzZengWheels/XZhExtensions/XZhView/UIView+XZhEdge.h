//
//  UIView+XZhEdge.h
//  XinzZengWheels
//
//  Created by 曾杏枝 on 2019/6/30.
//  Copyright © 2019 zengqinglong. All rights reserved.
/**
 MARK:- 分类, 通过 view.prop 直接读取坐标值.
 */

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIView (XZhEdge)

@property(nonatomic, assign) CGFloat x;
@property(nonatomic, assign) CGFloat y;
@property(nonatomic, assign) CGFloat width;
@property(nonatomic, assign) CGFloat height;
// x
@property (nonatomic, assign) CGFloat left;
// x+width
@property (nonatomic, assign, readonly) CGFloat right;
// y
@property (nonatomic, assign) CGFloat top;
// y+height
@property (nonatomic, assign, readonly) CGFloat bottom;
@property (nonatomic, assign) CGFloat centerX;
@property (nonatomic, assign) CGFloat centerY;

@property(nonatomic, assign) CGSize size;
@property(nonatomic, assign) CGPoint origin;

@end

NS_ASSUME_NONNULL_END

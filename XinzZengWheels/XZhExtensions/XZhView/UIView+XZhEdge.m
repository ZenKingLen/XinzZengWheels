//
//  UIView+XZhEdge.m
//  XinzZengWheels
//
//  Created by 曾杏枝 on 2019/6/30.
//  Copyright © 2019 zengqinglong. All rights reserved.
//

#import "UIView+XZhEdge.h"

@implementation UIView (XZhEdge)

- (void)setX:(CGFloat)x{
    CGRect frame = self.frame;
    frame.origin.x = x;
    self.frame = frame;
}

- (CGFloat)x{
    return self.frame.origin.x;
}

- (void)setY:(CGFloat)y{
    CGRect frmae = self.frame;
    frmae.origin.y = y;
    self.frame = frmae;
}

- (CGFloat)y{
    return self.frame.origin.y;
}

- (void)setWidth:(CGFloat)width{
    CGRect frame = self.frame;
    frame.size.width = width;
    self.frame = frame;
}

- (CGFloat)width{
    return self.frame.size.width;
}

- (void)setHeight:(CGFloat)height{
    CGRect frame = self.frame;
    frame.size.height = height;
    self.frame = frame;
}

- (CGFloat)height{
    return self.frame.size.height;
}

- (void)setLeft:(CGFloat)left{
    self.x = left;
}

- (CGFloat)left{
    return self.x;
}

- (CGFloat)right{
    return self.x + self.width;
}

- (void)setTop:(CGFloat)top{
    self.y = top;
}

- (CGFloat)top{
    return self.y;
}

- (CGFloat)bottom{
    return self.y + self.height;
}

- (void)setCenterX:(CGFloat)centerX{
    CGPoint center = self.center;
    center.x = centerX;
    self.center = center;
}

- (CGFloat)centerX{
    return self.center.x;
}

- (void)setCenterY:(CGFloat)centerY{
    CGPoint center = self.center;
    center.y = centerY;
    self.center = center;
}

- (CGFloat)centerY{
    return self.center.y;
}

- (void)setSize:(CGSize)size {
    self.width = size.width;
    self.height = size.height;
    self.size = size;
}

- (CGSize)size {
    return CGSizeMake(self.width, self.height);
}

- (void)setOrigin:(CGPoint)origin {
    self.x = origin.x;
    self.y = origin.y;
    self.origin = origin;
}

- (CGPoint)origin {
    return CGPointMake(self.x, self.y);
}

@end

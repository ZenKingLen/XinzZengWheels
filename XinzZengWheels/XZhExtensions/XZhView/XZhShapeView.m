//
//  XZhShapeView.m
//  XinzZengWheels
//
//  Created by 曾杏枝 on 2020/4/9.
//  Copyright © 2020 zengqinglong. All rights reserved.
// https://www.jianshu.com/p/6a90a1d431ef

#import "XZhShapeView.h"

@interface XZhShapeView ()<UIScrollViewDelegate>

@property(nonatomic, assign) CGFloat minScale;
@property(nonatomic, assign) CGFloat maxScale;

@end

@implementation XZhShapeView {
    UIImageView *_imageView;
    CGFloat _scaleRate;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setupSubView];
        [self setupGestureRecognizer];
    }
    return self;
}

- (void)setupSubView {
    BOOL hadFrame = (self.frame.size.width>0. && self.frame.size.height>0.);
    
    _imageView = [[UIImageView alloc] initWithFrame:hadFrame?self.bounds:CGRectZero];
    _imageView.image = [UIImage imageNamed:@"flower.jpg"];
    _imageView.contentMode = UIViewContentModeScaleAspectFit;
    _imageView.userInteractionEnabled = YES;
    [self addSubview:_imageView];
    
//    _scrollView.contentSize = _imageView.image.size;
//    _scrollView.delegate = self;
//    _scrollView.maximumZoomScale = self.maxScale;
//    _scrollView.minimumZoomScale = self.minScale;
//    _scrollView.showsVerticalScrollIndicator = NO;
//    _scrollView.showsHorizontalScrollIndicator = NO;
    
    _scaleRate = self.minScale;
}

- (void)setupGestureRecognizer {
    // double click
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleClicked:)];
    doubleTap.numberOfTouchesRequired = 2;
    [_imageView addGestureRecognizer:doubleTap];
}

- (void)doubleClicked:(UIGestureRecognizer *)sender {
    _scaleRate = _scaleRate==self.minScale?self.maxScale:self.minScale;
    CGRect scaleRect = [self rectToFitView:_imageView center:[sender locationInView:self] scale:_scaleRate];
    [UIView animateWithDuration:0.5 animations:^{
        self->_imageView.frame = scaleRect;
    }];
}

- (CGRect)rectToFitView:(UIView *)view center:(CGPoint)center scale:(CGFloat)scale {
    CGRect rect;
    rect.size.height = view.frame.size.height / scale;
    rect.size.width = view.frame.size.width / scale;
    rect.origin.x = center.x - (rect.size.width / 2.0);
    rect.origin.y = center.y - (rect.size.height / 2.0);
    return rect;
}

- (CGFloat)maxScale {
    return 2.0;
}

- (CGFloat)minScale {
    return 0.5;
}

@end

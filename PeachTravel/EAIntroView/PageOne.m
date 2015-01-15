//
//  PageOne.m
//  EAIntroView
//
//  Created by liangpengshuai on 1/6/15.
//  Copyright (c) 2015 SampleCorp. All rights reserved.
//

#import "PageOne.h"

@interface PageOne ()

@property (nonatomic) CGRect frame;
@property (nonatomic, strong) UIImageView *animationView;

@end

@implementation PageOne


- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super init];
    if (self) {
        _frame = frame;
    }
    return self;
}

- (UIImageView *)backGroundImageView
{
    if (!_backGroundImageView) {
        _backGroundImageView = [[UIImageView alloc] initWithFrame:self.frame];
        _backGroundImageView.backgroundColor = [UIColor whiteColor];
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ic_guide_phone.png"]];
        imageView.center = CGPointMake(_backGroundImageView.center.x, _backGroundImageView.center.y-24);
        [_backGroundImageView addSubview:imageView];
        UIImageView *dotImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ic_guide_dot1.png"]];
        dotImageView.center = CGPointMake(_backGroundImageView.center.x, imageView.frame.origin.y+imageView.frame.size.height+70);
        [_backGroundImageView addSubview:dotImageView];
        
        UIImageView *labelView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ic_guide_title_1.png"]];
        CGFloat y = imageView.frame.origin.y-20>120 ? 120:imageView.frame.origin.y-20;
        labelView.center = CGPointMake(_backGroundImageView.center.x, y);
        [_backGroundImageView addSubview:labelView];
        
        _backGroundImageView.image = [self capture:_backGroundImageView];
    }
    return _backGroundImageView;
}

- (UIImage *)capture:(UIView *)view
{
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, YES, 0.0);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
}

- (UIView *)titleView
{
    if (!_titleView) {
        _titleView = [[UIView alloc] initWithFrame: CGRectMake(0, 0, 185, 140)];
        _titleView.clipsToBounds = YES;
        UIImageView *imageView1 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ic_guide_plane.png"]];
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ic_guide_plan.png"]];
        _animationView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ic_guide_earth.png"]];
        _animationView.center = CGPointMake(_titleView.center.x, 125);
        imageView.center = CGPointMake(_titleView.center.x, 90);
        [_titleView addSubview:imageView1];
        [_titleView addSubview:_animationView];
        [_titleView addSubview:imageView];

    }
    return _titleView;
}

- (void)startAnimation
{
    CABasicAnimation* rotationAnimation;
    rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotationAnimation.toValue = [NSNumber numberWithFloat: M_PI * 2.0 * 1.0 ];
    rotationAnimation.duration = 3.0;
    rotationAnimation.cumulative = YES;
    rotationAnimation.repeatCount = HUGE_VALF;
    [_animationView.layer addAnimation:rotationAnimation forKey:@"rotationAnimation"];
}

- (void)stopAnimation
{
    [_animationView.layer removeAllAnimations];
}

@end







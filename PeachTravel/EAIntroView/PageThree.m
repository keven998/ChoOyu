//
//  PageThree.m
//  EAIntroView
//
//  Created by liangpengshuai on 1/6/15.
//  Copyright (c) 2015 SampleCorp. All rights reserved.
//

#import "PageThree.h"

@interface PageThree ()

@property (nonatomic) CGRect frame;
@property (nonatomic, strong) UIImageView *animationView;
@property (nonatomic) BOOL isFirstLaunch;
@end

@implementation PageThree


- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super init];
    if (self) {
        _frame = frame;
        _isFirstLaunch = YES;
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
        UIImageView *dotImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ic_guide_dot3.png"]];
        dotImageView.center = CGPointMake(_backGroundImageView.center.x, imageView.frame.origin.y+imageView.frame.size.height+70);
        [_backGroundImageView addSubview:dotImageView];
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
        _titleView = [[UIView alloc] initWithFrame: CGRectMake(0, 0, 185, 160)];
        _titleView.clipsToBounds = YES;
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ic_guide3_mark.png"]];
        imageView.center = CGPointMake(_titleView.center.x, 120);
        [_titleView addSubview:imageView];
        
    }
    return _titleView;
}

- (void)startAnimation
{
    if (_isFirstLaunch) {
        _isFirstLaunch = NO;
        UIImageView *imageView1 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ic_guide3_talk1"]];
        imageView1.frame = CGRectMake(_titleView.frame.size.width-imageView1.frame.size.width-5, 0, imageView1.frame.size.width, imageView1.frame.size.height);
        UIImageView *imageView2 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ic_guide3_talk2"]];
        imageView2.frame = CGRectMake(5, 30, imageView2.frame.size.width, imageView2.frame.size.height);

        UIImageView *imageView3 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ic_guide3_talk3"]];
        imageView3.frame = CGRectMake(_titleView.frame.size.width-imageView3.frame.size.width-5, 50, imageView3.frame.size.width, imageView3.frame.size.height);
        [_titleView addSubview:imageView1];
        [_titleView addSubview:imageView2];
        [_titleView addSubview:imageView3];

        imageView1.alpha = 0;
        imageView2.alpha = 0;
        imageView3.alpha = 0;
        [UIView animateWithDuration:0.5 animations:^{
            imageView1.alpha = 0.8;
        } completion:^(BOOL finished) {
            imageView1.alpha = 1;
            [UIView animateWithDuration:0.5 animations:^{
                imageView2.alpha = 0.8;
            } completion:^(BOOL finished) {
                imageView2.alpha = 1;
                [UIView animateWithDuration:0.5 animations:^{
                    imageView3.alpha = 0.8;
                } completion:^(BOOL finished) {
                    imageView3.alpha = 1;
                    
                }];
            }];
            
        }];
    }
}

- (void)stopAnimation
{
}

@end

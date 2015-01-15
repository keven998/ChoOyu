//
//  PageTwo.m
//  EAIntroView
//
//  Created by liangpengshuai on 1/6/15.
//  Copyright (c) 2015 SampleCorp. All rights reserved.
//

#import "PageTwo.h"

@interface PageTwo ()

@property (nonatomic) CGRect frame;
@property (nonatomic, strong) NSArray *animationViews;
@property (nonatomic) BOOL firstLaunch;

@end

@implementation PageTwo


- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super init];
    if (self) {
        _frame = frame;
        _firstLaunch = YES;
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
        UIImageView *imageView2 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ic_saturn.png"]];
        imageView2.frame = CGRectMake(imageView.frame.origin.x+10
                                      , imageView.frame.origin.y-10, imageView2.frame.size.width, imageView2.frame.size.height);
        [_backGroundImageView addSubview:imageView2];
        UIImageView *dotImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ic_guide_dot2.png"]];
        dotImageView.center = CGPointMake(_backGroundImageView.center.x, imageView.frame.origin.y+imageView.frame.size.height+70);
        
        UIImageView *labelView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ic_guide_title_2.png"]];
        CGFloat y = imageView.frame.origin.y-20>120 ? 120:imageView.frame.origin.y-20;
        labelView.center = CGPointMake(_backGroundImageView.center.x, y);
        [_backGroundImageView addSubview:labelView];
        
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
        _titleView = [[UIView alloc] initWithFrame: CGRectMake(0, 0, 185, 140)];
        _titleView.clipsToBounds = YES;
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ic_mountain.png"]];
        imageView.center = CGPointMake(_titleView.center.x, 120);
        [_titleView addSubview:imageView];
        NSMutableArray *array = [[NSMutableArray alloc] init];
        for (int i = 0; i<8; i++) {
            
            NSString *imageName = [NSString stringWithFormat:@"ic_guide2_%d_normal",i+1];
            UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:imageName]];
            [array addObject:imageView];
            imageView.alpha = 0;
            if (i<5) {
                imageView.center = CGPointMake((i)*33.5+25.5, 30);
            } else {
                imageView.center = CGPointMake((i-4)*33.5+25.5, 60);
            }
            [_titleView addSubview:imageView];
        }
        _animationViews = array;
    }
    return _titleView;
}

- (void)startAnimation
{
    if (_firstLaunch) {
        _firstLaunch = NO;
        for (int i=0; i<5; i++) {
            UIImageView *imageView = [_animationViews objectAtIndex:i];
            CGRect resetFrame = imageView.frame;
            imageView.frame = CGRectMake(imageView.center.x, imageView.center.y, 0, 0);
            [UIView animateWithDuration:0.6 animations:^{
                imageView.frame = resetFrame;
                imageView.alpha = 0.7;
            } completion:^(BOOL finished) {
                NSString *imageName = [NSString stringWithFormat:@"ic_guide2_%d_select",i+1];
                imageView.image = [UIImage imageNamed:imageName];
                imageView.alpha = 1.0;
                for (int i=5; i<8; i++) {
                    UIImageView *imageView = [_animationViews objectAtIndex:i];
                    CGRect resetFrame = imageView.frame;
                    imageView.frame = CGRectMake(imageView.center.x, imageView.center.y, 0, 0);
                    [UIView animateWithDuration:0.6 animations:^{
                        imageView.frame = resetFrame;
                        imageView.alpha = 0.7;
                    } completion:^(BOOL finished) {
                        NSString *imageName = [NSString stringWithFormat:@"ic_guide2_%d_select",i+1];
                        imageView.image = [UIImage imageNamed:imageName];
                        imageView.alpha = 1.0;
                    }];
                }
            }];
        }
    }
}

- (void)stopAnimation
{
}

@end







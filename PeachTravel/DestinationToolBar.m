//
//  DestinationToolBar.m
//  PeachTravelDemo
//
//  Created by liangpengshuai on 14/9/24.
//  Copyright (c) 2014年 com.aizou.www. All rights reserved.
//

#import "DestinationToolBar.h"


@interface DestinationToolBar ()

@end

@implementation DestinationToolBar

-(void)setHidden:(BOOL)hidden withAnimation:(BOOL)animation
{
    if (animation) {
        [self setHidden:hidden];
    } else {
        [self animationStop];
    }
}

-(void)setHidden:(BOOL)hidden
{
    if (hidden) {
        //隐藏时
        self.alpha= 1.0f;
        [UIView beginAnimations:@"fadeOut" context:nil];
        [UIView setAnimationDuration:0.4];
        [UIView setAnimationDelegate:self];//设置委托
        [UIView setAnimationDidStopSelector:@selector(animationStop)];//当动画结束时，我们还需要再将其隐藏
        self.alpha = 0.0f;
        [UIView commitAnimations];
    }
    else
    {
        self.alpha= 0.0f;
        [super setHidden:hidden];
        [UIView beginAnimations:@"fadeIn" context:nil];
        [UIView setAnimationDuration:0.4];
        self.alpha= 1.0f;
        [UIView commitAnimations];
    }
}

-(void)animationStop
{
    [super setHidden:!self.hidden];
}

@end







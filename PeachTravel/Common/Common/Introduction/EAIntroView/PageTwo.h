//
//  PageTwo.h
//  EAIntroView
//
//  Created by liangpengshuai on 1/6/15.
//  Copyright (c) 2015 SampleCorp. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PageTwo : NSObject

@property (nonatomic, strong) UIImageView *backGroundImageView;
@property (nonatomic, strong) UIView *titleView;


- (instancetype)initWithFrame:(CGRect)frame;

- (void)startAnimation;
- (void)stopAnimation;

@end

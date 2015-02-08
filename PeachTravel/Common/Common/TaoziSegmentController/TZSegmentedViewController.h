//
//  TZSegmentedViewController.h
//  PeachTravel
//
//  Created by liangpengshuai on 1/27/15.
//  Copyright (c) 2015 com.aizou.www. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TZSegmentedViewController : UIViewController

/**
 *  切换键的标题
 */
@property (nonatomic, strong) NSArray *segmentedTitles;

@property (nonatomic, strong) UIFont *segmentedTitleFont;

/**
 *  切换动画
 */
@property (nonatomic) UIViewAnimationOptions animationOptions;

@property (nonatomic) NSTimeInterval duration;

/**
 *  选中后的颜色
 */
@property (nonatomic, strong) UIColor *selectedColor;

/**
 *  未选中的颜色
 */
@property (nonatomic, strong) UIColor *normalColor;

/**
 *  切换键的图像
 */
@property (nonatomic, strong) NSArray *segmentedNormalImages;
@property (nonatomic, strong) NSArray *segmentedSelectedImages;

@property (nonatomic, strong) NSArray *viewControllers;
@property (nonatomic, strong) NSArray *segmentedBtns;

/**
 *  当前选中的界面
 */
@property (nonatomic) NSInteger selectedIndext;

/**
 *  结束切换界面
 */
- (void)finishSwithPages;

@end

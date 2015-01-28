//
//  TZSegmentedViewController.h
//  PeachTravel
//
//  Created by liangpengshuai on 1/27/15.
//  Copyright (c) 2015 com.aizou.www. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TZSegmentedViewController : TZViewController

@property (nonatomic, strong) NSArray *segmentedTitles;
@property (nonatomic, strong) NSArray *segmentedImages;
@property (nonatomic, strong) NSArray *viewControllers;
@property (nonatomic, strong) NSArray *segmentedBtns;

/**
 *  当前选中的界面
 */
@property (nonatomic) NSUInteger selectedIndext;

@end

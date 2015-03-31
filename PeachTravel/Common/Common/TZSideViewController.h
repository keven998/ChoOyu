//
//  TZSideViewController.h
//  PeachTravel
//
//  Created by liangpengshuai on 3/30/15.
//  Copyright (c) 2015 com.aizou.www. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TZSideViewController : UIViewController

/**
 *  具体要展示的Viewcontroller
 */
@property (nonatomic, strong) UIViewController *detailViewController;

- (id)initWithDetailViewFrame:(CGRect)rect;

/**
 *  弹出侧边view
 */
- (void)showSideDetailView;

/**
 *  隐藏侧边view
 */
- (void)hideSideDetailView;

@end

//
//  HomeViewController.h
//  PeachTravel
//
//  Created by Luo Yong on 14/12/1.
//  Copyright (c) 2014年 com.aizou.www. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Constants.h"

@interface HomeViewController : UITabBarController

/**
 *  跳转到 web 界面
 */
- (void)jumpToWebViewCtl;

@property (nonatomic) IM_CONNECT_STATE IMState;

@end

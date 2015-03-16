//
//  HomeViewController.h
//  PeachTravel
//
//  Created by Luo Yong on 14/12/1.
//  Copyright (c) 2014年 com.aizou.www. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RDVTabBarController.h"
#import "IMRootViewController.h"

@interface HomeViewController : UITabBarController

/**
 *  跳转到 web 界面
 */
- (void)jumpToWebViewCtl;

/**
 *  当程序启动的时候是否应该进入聊天列表界面
 */
@property (nonatomic)BOOL shouldJumpToChatListWhenAppLaunch;

@property (nonatomic, strong) IMRootViewController *IMRootCtl;

@end

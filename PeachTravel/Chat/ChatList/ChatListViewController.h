/************************************************************
  *  * EaseMob CONFIDENTIAL 
  * __________________ 
  * Copyright (C) 2013-2014 EaseMob Technologies. All rights reserved. 
  *  
  * NOTICE: All information contained herein is, and remains 
  * the property of EaseMob Technologies.
  * Dissemination of this information or reproduction of this material 
  * is strictly forbidden unless prior written permission is obtained
  * from EaseMob Technologies.
  */

#import <UIKit/UIKit.h>
#import "MHTabBarController.h"

@class IMRootViewController;

@interface ChatListViewController : MHChildViewController

- (void)refreshDataSource;

- (void)networkChanged:(EMConnectionState)connectionState;

@property (nonatomic, weak) UIViewController *rootCtl;

@end

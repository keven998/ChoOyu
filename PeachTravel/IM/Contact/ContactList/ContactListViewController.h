//
//  ContactListViewController.h
//  PeachTravel
//
//  Created by liangpengshuai on 14/10/30.
//  Copyright (c) 2014年 com.aizou.www. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MHTabBarController.h"

@interface ContactListViewController : UIViewController
@property (nonatomic, weak) UIViewController *rootCtl;

@property (nonatomic) NSUInteger numberOfUnreadFrendRequest;

@end

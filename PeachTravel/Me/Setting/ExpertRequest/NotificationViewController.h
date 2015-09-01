//
//  NotificationViewController.h
//  PeachTravel
//
//  Created by liangpengshuai on 8/28/15.
//  Copyright (c) 2015 com.aizou.www. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NotificationViewController : UIViewController

- (id)initWithTitle:(NSString *)title subtitle:(NSString *)subtitle andActionTitle:(NSString *)actionTitle;

- (void)showNotiViewInController:(UIViewController *)containerController dismissBlock:(void(^)())block;


@end

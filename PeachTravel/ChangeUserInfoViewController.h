//
//  ChangeUserInfoViewController.h
//  PeachTravel
//
//  Created by liangpengshuai on 14/10/15.
//  Copyright (c) 2014年 com.aizou.www. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChangeUserInfoViewController : UIViewController

@property (nonatomic) UserInfoChangeType changeType;
@property (copy, nonatomic) NSString *content;

@end

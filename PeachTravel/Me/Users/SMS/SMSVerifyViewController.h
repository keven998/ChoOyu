//
//  SMSVerifyViewController.h
//  PeachTravel
//
//  Created by liangpengshuai on 14/10/15.
//  Copyright (c) 2014年 com.aizou.www. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SMSVerifyViewController : TZViewController

@property (copy, nonatomic) NSString *phoneNumber;
@property (copy, nonatomic) NSString *inviteCode;
@property (copy, nonatomic) NSString *password;
@property (nonatomic) NSInteger coolDown;

@end

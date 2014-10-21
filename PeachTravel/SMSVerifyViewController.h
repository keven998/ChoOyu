//
//  SMSVerifyViewController.h
//  PeachTravel
//
//  Created by liangpengshuai on 14/10/15.
//  Copyright (c) 2014年 com.aizou.www. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SMSVerifyViewController : UIViewController

@property (copy, nonatomic) NSString *phoneNumber;
@property (copy, nonatomic) NSString *password;
@property (nonatomic) SMSType smsType;    //进入发送填写验证码界面的原因
@property (nonatomic) NSInteger coolDown;

@end

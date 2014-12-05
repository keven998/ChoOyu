//
//  ResetPasswordViewController.h
//  PeachTravel
//
//  Created by liangpengshuai on 14/10/23.
//  Copyright (c) 2014年 com.aizou.www. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ResetPasswordViewController : TZViewController

@property (nonatomic, copy) NSString *phoneNumber;
@property (nonatomic, copy) NSString *token;
@property (nonatomic) NSInteger userId;
@property (nonatomic) VerifyCaptchaType verifyCaptchaType;

@end

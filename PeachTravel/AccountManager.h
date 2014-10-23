//
//  AccountManager.h
//  PeachTravel
//
//  Created by liangpengshuai on 14/10/13.
//  Copyright (c) 2014年 com.aizou.www. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Account.h"

@interface AccountManager : NSObject

@property (nonatomic, strong) Account *account;

+ (AccountManager *)shareAccountManager;

- (BOOL)isLogin;

- (void)userDidLoginWithUserInfo:(id)userInfo;
- (void)easeMobDidLogin;
- (void)easeMobUnlogin;
- (void)logout;
- (BOOL)accountIsBindTel;    //账户是否绑定了手机号，返回 yes 是绑定了
- (void)updateUserInfo:(NSString *)changeContent withChangeType:(UserInfoChangeType)changeType;
@end

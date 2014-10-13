//
//  AccountManager.h
//  PeachTravel
//
//  Created by liangpengshuai on 14/10/13.
//  Copyright (c) 2014年 com.aizou.www. All rights reserved.
//

#import <Foundation/Foundation.h>
@class AccountBean;

@interface AccountManager : NSObject

@property (nonatomic, strong) AccountBean *account;

+ (AccountManager *)shareAccountManager;

- (BOOL)isLogin;

- (void)login;
- (void)logout;

@end

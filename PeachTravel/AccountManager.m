//
//  AccountManager.m
//  PeachTravel
//
//  Created by liangpengshuai on 14/10/13.
//  Copyright (c) 2014年 com.aizou.www. All rights reserved.
//

#import "AccountManager.h"

#define ACCOUNT_KEY  @"taozi_account"

@implementation AccountManager

+ (AccountManager *)shareAccountManager
{
    static AccountManager *accountManager;
    @synchronized(self) {
        if (!accountManager) {
            accountManager = [[AccountManager alloc] init];
        }
        return accountManager;
    }
}

- (AccountBean *)account
{
    if (!_account) {
        _account = [[TMCache sharedCache] objectForKey:ACCOUNT_KEY];
    }
    return _account;
}

- (BOOL)isLogin
{
    return self.account != nil;
}

- (void)logout
{
    [[TMCache sharedCache] removeObjectForKey:ACCOUNT_KEY];
    self.account = nil;
}

- (void)userDidLoginWithUserInfo:(id)userInfo
{
    _account = [[AccountBean alloc] initWithJson:userInfo];
    [[TMCache sharedCache] setObject:_account forKey:ACCOUNT_KEY];
}

@end

//
//  AccountManager.m
//  PeachTravel
//
//  Created by liangpengshuai on 14/10/13.
//  Copyright (c) 2014年 com.aizou.www. All rights reserved.
//

#import "AccountManager.h"
#import "AppDelegate.h"

#define ACCOUNT_KEY  @"taozi_account"

@interface AccountManager ()

@property (nonatomic, strong) NSManagedObjectContext *context;

@end

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

#pragma mark - setter & getter

- (Account *)account
{
    if (!_account) {
        NSError *error = nil;
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        request.entity = [NSEntityDescription entityForName:@"Account" inManagedObjectContext:self.context];
        NSArray *objs = [self.context executeFetchRequest:request error:&error];
        if (error) {
            [NSException raise:@"查询错误" format:@"%@", [error localizedDescription]];
        }
        _account = [objs firstObject];
    }
    return _account;
}

//用户是否登录
- (BOOL)isLogin
{
    return self.account != nil;
}

- (BOOL)accountIsBindTel
{
    return !([self.account.tel isEqualToString:@""] || self.account.tel == nil);
}

- (NSManagedObjectContext *)context
{
    if (!_context) {
        _context = [((AppDelegate *)[[UIApplication sharedApplication] delegate]) managedObjectContext];
    }
    return _context;
}

#pragma mark - Private Methods

//用户退出登录
- (void)logout
{
    [self.context deleteObject:self.account];
    NSError *error = nil;
    [self.context save:&error];
    if (error) {
        [NSException raise:@"用户退出登录发生错误" format:@"%@",[error localizedDescription]];
    }
    //退出环信聊天系统
    [[EaseMob sharedInstance].chatManager asyncLogoff];
    _account = nil;
}

//用户登录成功
- (void)userDidLoginWithUserInfo:(id)userInfo
{
    _account = [NSEntityDescription insertNewObjectForEntityForName:@"Account" inManagedObjectContext:self.context];
    [self loadUserInfo:userInfo];
}

//环信系统也登录成功
- (void)easeMobDidLogin
{
    NSError *error = nil;
    [self.context save:&error];
}

//环信系统登录失败
- (void)easeMobUnlogin
{
    _account = nil;
}

//用户更新了
- (void)updateUserInfo:(NSString *)changeContent withChangeType:(UserInfoChangeType)changeType
{
    switch (changeType) {
        case ChangeName:
            self.account.nickName = changeContent;
            break;
        
        case ChangeSignature:
            self.account.signature = changeContent;
            
        default:
            break;
    }
    NSError *error = nil;
    [self.context save:&error];
}

//解析从服务器上下载的用户信息
- (void)loadUserInfo:(id)json
{
    _account.userId = [NSNumber numberWithInteger:[[json objectForKey:@"userId"] integerValue]];
    _account.nickName = [json objectForKey:@"nickName"];
    _account.avatar = [json objectForKey:@"avatar"];
    _account.gender = [json objectForKey:@"gender"];
    _account.tel = [json objectForKey:@"tel"];
    _account.secToken = [json objectForKey:@"secToken"];
    _account.signature = [json objectForKey:@"signature"];
#warning 替换环信帐号密码
//    _account.easemobUser = [json objectForKey:@"easemobUser"];
//    _account.easemobPwd = [json objectForKey:@"easemobPwd"];
    _account.easemobUser = @"heheceo";
    _account.easemobPwd = @"james890526";
}

@end





//
//  AccountManager.m
//  PeachTravel
//
//  Created by liangpengshuai on 14/10/13.
//  Copyright (c) 2014年 com.aizou.www. All rights reserved.
//

#import "AccountManager.h"
#import "AppDelegate.h"
#import "pinyin.h"

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

//用户是否曾绑定过手机号
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

//用户桃子系统登录成功
- (void)userDidLoginWithUserInfo:(id)userInfo
{
    _account = [NSEntityDescription insertNewObjectForEntityForName:@"Account" inManagedObjectContext:self.context];
    [self loadUserInfo:userInfo];
}

//环信系统也登录成功，这时候才是真正的登录成功
- (void)easeMobDidLogin
{
    NSError *error = nil;
    [self.context save:&error];
    [self getContactsFromServer];
}

//环信系统登录失败
- (void)easeMobUnlogin
{
    _account = nil;
}

//更新用户信息
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
    _account.easemobUser = [json objectForKey:@"easemobUser"];
    _account.easemobPwd = [json objectForKey:@"easemobPwd"];
    
//        _account.easemobUser = @"18600441776";
//        _account.easemobPwd = @"james890526";

}

//从服务器上获取好友列表
- (void)getContactsFromServer
{
    NSLog(@"开始从服务器上加载好友列表");
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [manager.requestSerializer setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"%@", self.account.userId] forHTTPHeaderField:@"UserId"];
    
    [manager GET:API_GET_CONTACTS parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSInteger code = [[responseObject objectForKey:@"code"] integerValue];
        if (code == 0) {
            NSLog(@"已经完成从服务器上加载好友列表");
            
#warning 测试数据
//            [self analysisAndSaveContacts:[[responseObject objectForKey:@"result"] objectForKey:@"contacts"]];
            [self analysisAndSaveContacts:  @[@{@"userId":@100073, @"nickName":@"煎蛋小王子", @"gender":@"F",        @"memo":@"哈哈哈", @"easemobUser":@"dsdfs"
                                               , @"avatar":@"defalu"},
                                             @{@"userId":@100073, @"nickName":@"阮金明", @"gender":@"F", @"memo":@"哈哈哈", @"easemobUser":@"dsdfs", @"avatar":@"defalu"},
                                             @{@"userId":@100073, @"nickName":@"杨阳洋", @"gender":@"F", @"memo":@"哈哈哈", @"easemobUser":@"dsdfs"
                                               , @"avatar":@"defalu"},
                                             @{@"userId":@100073, @"nickName":@"贝尔", @"gender":@"F", @"memo":@"哈哈哈", @"easemobUser":@"dsdfs"
                                               , @"avatar":@"defalu"},
                                              @{@"userId":@100073, @"nickName":@"海子", @"gender":@"F", @"memo":@"哈哈哈", @"easemobUser":@"dsdfs"
                                                , @"avatar":@"defalu"},
                                              @{@"userId":@100073, @"nickName":@"博通", @"gender":@"F", @"memo":@"哈哈哈", @"easemobUser":@"dsdfs", @"avatar":@"defalu"},
                                              @{@"userId":@100073, @"nickName":@"骆驼", @"gender":@"F", @"memo":@"哈哈哈", @"easemobUser":@"dsdfs"
                                                , @"avatar":@"defalu"},
                                              @{@"userId":@100073, @"nickName":@"小明", @"gender":@"F", @"memo":@"哈哈哈", @"easemobUser":@"dsdfs"
                                                , @"avatar":@"defalu"},
                                              @{@"userId":@100073, @"nickName":@"速速", @"gender":@"F", @"memo":@"哈哈哈", @"easemobUser":@"dsdfs"
                                                , @"avatar":@"defalu"},
                                              @{@"userId":@100073, @"nickName":@"keven", @"gender":@"F", @"memo":@"哈哈哈", @"easemobUser":@"dsdfs", @"avatar":@"defalu"},
                                              @{@"userId":@100073, @"nickName":@"easy", @"gender":@"F", @"memo":@"哈哈哈", @"easemobUser":@"dsdfs"
                                                , @"avatar":@"defalu"},
                                              @{@"userId":@100073, @"nickName":@"西瓜", @"gender":@"F", @"memo":@"哈哈哈", @"easemobUser":@"dsdfs"
                                                , @"avatar":@"defalu"},
                                              @{@"userId":@100073, @"nickName":@"cc", @"gender":@"F", @"memo":@"哈哈哈", @"easemobUser":@"dsdfs"
                                                , @"avatar":@"defalu"},
                                              @{@"userId":@100073, @"nickName":@"jina", @"gender":@"F", @"memo":@"哈哈哈", @"easemobUser":@"dsdfs"
                                                , @"avatar":@"defalu"},
                                              @{@"userId":@100073, @"nickName":@"小水", @"gender":@"F", @"memo":@"哈哈哈", @"easemobUser":@"dsdfs"
                                               , @"avatar":@"defalu"},
                                              @{@"userId":@100073, @"nickName":@"煎蛋小王子", @"gender":@"F",        @"memo":@"哈哈哈", @"easemobUser":@"dsdfs"
                                                , @"avatar":@"defalu"},
                                              @{@"userId":@100073, @"nickName":@"阮金明", @"gender":@"F", @"memo":@"哈哈哈", @"easemobUser":@"dsdfs", @"avatar":@"defalu"},
                                              @{@"userId":@100073, @"nickName":@"杨阳洋", @"gender":@"F", @"memo":@"哈哈哈", @"easemobUser":@"dsdfs"
                                                , @"avatar":@"defalu"},
                                              @{@"userId":@100073, @"nickName":@"贝尔", @"gender":@"F", @"memo":@"哈哈哈", @"easemobUser":@"dsdfs"
                                                , @"avatar":@"defalu"},
                                              @{@"userId":@100073, @"nickName":@"海子", @"gender":@"F", @"memo":@"哈哈哈", @"easemobUser":@"dsdfs"
                                                , @"avatar":@"defalu"},
                                              @{@"userId":@100073, @"nickName":@"博通", @"gender":@"F", @"memo":@"哈哈哈", @"easemobUser":@"dsdfs", @"avatar":@"defalu"},
                                              @{@"userId":@100073, @"nickName":@"骆驼", @"gender":@"F", @"memo":@"哈哈哈", @"easemobUser":@"dsdfs"
                                                , @"avatar":@"defalu"},
                                              @{@"userId":@100073, @"nickName":@"小明", @"gender":@"F", @"memo":@"哈哈哈", @"easemobUser":@"dsdfs"
                                                , @"avatar":@"defalu"},
                                              @{@"userId":@100073, @"nickName":@"速速", @"gender":@"F", @"memo":@"哈哈哈", @"easemobUser":@"dsdfs"
                                                , @"avatar":@"defalu"},
                                              @{@"userId":@100073, @"nickName":@"keven", @"gender":@"F", @"memo":@"哈哈哈", @"easemobUser":@"dsdfs", @"avatar":@"defalu"},
                                              @{@"userId":@100073, @"nickName":@"easy", @"gender":@"F", @"memo":@"哈哈哈", @"easemobUser":@"dsdfs"
                                                , @"avatar":@"defalu"},
                                              @{@"userId":@100073, @"nickName":@"西瓜", @"gender":@"F", @"memo":@"哈哈哈", @"easemobUser":@"dsdfs"
                                                , @"avatar":@"defalu"},
                                              @{@"userId":@100073, @"nickName":@"cc", @"gender":@"F", @"memo":@"哈哈哈", @"easemobUser":@"dsdfs"
                                                , @"avatar":@"defalu"},
                                              @{@"userId":@100073, @"nickName":@"jina", @"gender":@"F", @"memo":@"哈哈哈", @"easemobUser":@"dsdfs"
                                                , @"avatar":@"defalu"},
                                              @{@"userId":@100073, @"nickName":@"小水", @"gender":@"F", @"memo":@"哈哈哈", @"easemobUser":@"dsdfs"
                                                , @"avatar":@"defalu"},
                                              @{@"userId":@100073, @"nickName":@"煎蛋小王子", @"gender":@"F",        @"memo":@"哈哈哈", @"easemobUser":@"dsdfs"
                                                , @"avatar":@"defalu"},
                                              @{@"userId":@100073, @"nickName":@"阮金明", @"gender":@"F", @"memo":@"哈哈哈", @"easemobUser":@"dsdfs", @"avatar":@"defalu"},
                                              @{@"userId":@100073, @"nickName":@"杨阳洋", @"gender":@"F", @"memo":@"哈哈哈", @"easemobUser":@"dsdfs"
                                                , @"avatar":@"defalu"},
                                              @{@"userId":@100073, @"nickName":@"贝尔", @"gender":@"F", @"memo":@"哈哈哈", @"easemobUser":@"dsdfs"
                                                , @"avatar":@"defalu"},
                                              @{@"userId":@100073, @"nickName":@"海子", @"gender":@"F", @"memo":@"哈哈哈", @"easemobUser":@"dsdfs"
                                                , @"avatar":@"defalu"},
                                              @{@"userId":@100073, @"nickName":@"博通", @"gender":@"F", @"memo":@"哈哈哈", @"easemobUser":@"dsdfs", @"avatar":@"defalu"},
                                              @{@"userId":@100073, @"nickName":@"骆驼", @"gender":@"F", @"memo":@"哈哈哈", @"easemobUser":@"dsdfs"
                                                , @"avatar":@"defalu"},
                                              @{@"userId":@100073, @"nickName":@"小明", @"gender":@"F", @"memo":@"哈哈哈", @"easemobUser":@"dsdfs"
                                                , @"avatar":@"defalu"},
                                              @{@"userId":@100073, @"nickName":@"速速", @"gender":@"F", @"memo":@"哈哈哈", @"easemobUser":@"dsdfs"
                                                , @"avatar":@"defalu"},
                                              @{@"userId":@100073, @"nickName":@"keven", @"gender":@"F", @"memo":@"哈哈哈", @"easemobUser":@"dsdfs", @"avatar":@"defalu"},
                                              @{@"userId":@100073, @"nickName":@"easy", @"gender":@"F", @"memo":@"哈哈哈", @"easemobUser":@"dsdfs"
                                                , @"avatar":@"defalu"},
                                              @{@"userId":@100073, @"nickName":@"西瓜", @"gender":@"F", @"memo":@"哈哈哈", @"easemobUser":@"dsdfs"
                                                , @"avatar":@"defalu"},
                                              @{@"userId":@100073, @"nickName":@"cc", @"gender":@"F", @"memo":@"哈哈哈", @"easemobUser":@"dsdfs"
                                                , @"avatar":@"defalu"},
                                              @{@"userId":@100073, @"nickName":@"jina", @"gender":@"F", @"memo":@"哈哈哈", @"easemobUser":@"dsdfs"
                                                , @"avatar":@"defalu"},
                                              @{@"userId":@100073, @"nickName":@"小水", @"gender":@"F", @"memo":@"哈哈哈", @"easemobUser":@"dsdfs"
                                                , @"avatar":@"defalu"},
                                              @{@"userId":@100073, @"nickName":@"煎蛋小王子", @"gender":@"F",        @"memo":@"哈哈哈", @"easemobUser":@"dsdfs"
                                                , @"avatar":@"defalu"},
                                              @{@"userId":@100073, @"nickName":@"阮金明", @"gender":@"F", @"memo":@"哈哈哈", @"easemobUser":@"dsdfs", @"avatar":@"defalu"},
                                              @{@"userId":@100073, @"nickName":@"杨阳洋", @"gender":@"F", @"memo":@"哈哈哈", @"easemobUser":@"dsdfs"
                                                , @"avatar":@"defalu"},
                                              @{@"userId":@100073, @"nickName":@"贝尔", @"gender":@"F", @"memo":@"哈哈哈", @"easemobUser":@"dsdfs"
                                                , @"avatar":@"defalu"},
                                              @{@"userId":@100073, @"nickName":@"海子", @"gender":@"F", @"memo":@"哈哈哈", @"easemobUser":@"dsdfs"
                                                , @"avatar":@"defalu"},
                                              @{@"userId":@100073, @"nickName":@"博通", @"gender":@"F", @"memo":@"哈哈哈", @"easemobUser":@"dsdfs", @"avatar":@"defalu"},
                                              @{@"userId":@100073, @"nickName":@"骆驼", @"gender":@"F", @"memo":@"哈哈哈", @"easemobUser":@"dsdfs"
                                                , @"avatar":@"defalu"},
                                              @{@"userId":@100073, @"nickName":@"小明", @"gender":@"F", @"memo":@"哈哈哈", @"easemobUser":@"dsdfs"
                                                , @"avatar":@"defalu"},
                                              @{@"userId":@100073, @"nickName":@"速速", @"gender":@"F", @"memo":@"哈哈哈", @"easemobUser":@"dsdfs"
                                                , @"avatar":@"defalu"},
                                              @{@"userId":@100073, @"nickName":@"keven", @"gender":@"F", @"memo":@"哈哈哈", @"easemobUser":@"dsdfs", @"avatar":@"defalu"},
                                              @{@"userId":@100073, @"nickName":@"easy", @"gender":@"F", @"memo":@"哈哈哈", @"easemobUser":@"dsdfs"
                                                , @"avatar":@"defalu"},
                                              @{@"userId":@100073, @"nickName":@"西瓜", @"gender":@"F", @"memo":@"哈哈哈", @"easemobUser":@"dsdfs"
                                                , @"avatar":@"defalu"},
                                              @{@"userId":@100073, @"nickName":@"cc", @"gender":@"F", @"memo":@"哈哈哈", @"easemobUser":@"dsdfs"
                                                , @"avatar":@"defalu"},
                                              @{@"userId":@100073, @"nickName":@"jina", @"gender":@"F", @"memo":@"哈哈哈", @"easemobUser":@"dsdfs"
                                                , @"avatar":@"defalu"},
                                              @{@"userId":@100073, @"nickName":@"小水", @"gender":@"F", @"memo":@"哈哈哈", @"easemobUser":@"dsdfs"
                                                , @"avatar":@"defalu"},
                                              @{@"userId":@100073, @"nickName":@"煎蛋小王子", @"gender":@"F",        @"memo":@"哈哈哈", @"easemobUser":@"dsdfs"
                                                , @"avatar":@"defalu"},
                                              @{@"userId":@100073, @"nickName":@"阮金明", @"gender":@"F", @"memo":@"哈哈哈", @"easemobUser":@"dsdfs", @"avatar":@"defalu"},
                                              @{@"userId":@100073, @"nickName":@"杨阳洋", @"gender":@"F", @"memo":@"哈哈哈", @"easemobUser":@"dsdfs"
                                                , @"avatar":@"defalu"},
                                              @{@"userId":@100073, @"nickName":@"贝尔", @"gender":@"F", @"memo":@"哈哈哈", @"easemobUser":@"dsdfs"
                                                , @"avatar":@"defalu"},
                                              @{@"userId":@100073, @"nickName":@"海子", @"gender":@"F", @"memo":@"哈哈哈", @"easemobUser":@"dsdfs"
                                                , @"avatar":@"defalu"},
                                              @{@"userId":@100073, @"nickName":@"博通", @"gender":@"F", @"memo":@"哈哈哈", @"easemobUser":@"dsdfs", @"avatar":@"defalu"},
                                              @{@"userId":@100073, @"nickName":@"骆驼", @"gender":@"F", @"memo":@"哈哈哈", @"easemobUser":@"dsdfs"
                                                , @"avatar":@"defalu"},
                                              @{@"userId":@100073, @"nickName":@"小明", @"gender":@"F", @"memo":@"哈哈哈", @"easemobUser":@"dsdfs"
                                                , @"avatar":@"defalu"},
                                              @{@"userId":@100073, @"nickName":@"速速", @"gender":@"F", @"memo":@"哈哈哈", @"easemobUser":@"dsdfs"
                                                , @"avatar":@"defalu"},
                                              @{@"userId":@100073, @"nickName":@"keven", @"gender":@"F", @"memo":@"哈哈哈", @"easemobUser":@"dsdfs", @"avatar":@"defalu"},
                                              @{@"userId":@100073, @"nickName":@"easy", @"gender":@"F", @"memo":@"哈哈哈", @"easemobUser":@"dsdfs"
                                                , @"avatar":@"defalu"},
                                              @{@"userId":@100073, @"nickName":@"西瓜", @"gender":@"F", @"memo":@"哈哈哈", @"easemobUser":@"dsdfs"
                                                , @"avatar":@"defalu"},
                                              @{@"userId":@100073, @"nickName":@"cc", @"gender":@"F", @"memo":@"哈哈哈", @"easemobUser":@"dsdfs"
                                                , @"avatar":@"defalu"},
                                              @{@"userId":@100073, @"nickName":@"jina", @"gender":@"F", @"memo":@"哈哈哈", @"easemobUser":@"dsdfs"
                                                , @"avatar":@"defalu"},
                                              @{@"userId":@100073, @"nickName":@"小水", @"gender":@"F", @"memo":@"哈哈哈", @"easemobUser":@"dsdfs"
                                                , @"avatar":@"defalu"},
                                              @{@"userId":@100073, @"nickName":@"煎蛋小王子", @"gender":@"F",        @"memo":@"哈哈哈", @"easemobUser":@"dsdfs"
                                                , @"avatar":@"defalu"},
                                              @{@"userId":@100073, @"nickName":@"阮金明", @"gender":@"F", @"memo":@"哈哈哈", @"easemobUser":@"dsdfs", @"avatar":@"defalu"},
                                              @{@"userId":@100073, @"nickName":@"杨阳洋", @"gender":@"F", @"memo":@"哈哈哈", @"easemobUser":@"dsdfs"
                                                , @"avatar":@"defalu"},
                                              @{@"userId":@100073, @"nickName":@"贝尔", @"gender":@"F", @"memo":@"哈哈哈", @"easemobUser":@"dsdfs"
                                                , @"avatar":@"defalu"},
                                              @{@"userId":@100073, @"nickName":@"海子", @"gender":@"F", @"memo":@"哈哈哈", @"easemobUser":@"dsdfs"
                                                , @"avatar":@"defalu"},
                                              @{@"userId":@100073, @"nickName":@"博通", @"gender":@"F", @"memo":@"哈哈哈", @"easemobUser":@"dsdfs", @"avatar":@"defalu"},
                                              @{@"userId":@100073, @"nickName":@"骆驼", @"gender":@"F", @"memo":@"哈哈哈", @"easemobUser":@"dsdfs"
                                                , @"avatar":@"defalu"},
                                              @{@"userId":@100073, @"nickName":@"小明", @"gender":@"F", @"memo":@"哈哈哈", @"easemobUser":@"dsdfs"
                                                , @"avatar":@"defalu"},
                                              @{@"userId":@100073, @"nickName":@"速速", @"gender":@"F", @"memo":@"哈哈哈", @"easemobUser":@"dsdfs"
                                                , @"avatar":@"defalu"},
                                              @{@"userId":@100073, @"nickName":@"keven", @"gender":@"F", @"memo":@"哈哈哈", @"easemobUser":@"dsdfs", @"avatar":@"defalu"},
                                              @{@"userId":@100073, @"nickName":@"easy", @"gender":@"F", @"memo":@"哈哈哈", @"easemobUser":@"dsdfs"
                                                , @"avatar":@"defalu"},
                                              @{@"userId":@100073, @"nickName":@"西瓜", @"gender":@"F", @"memo":@"哈哈哈", @"easemobUser":@"dsdfs"
                                                , @"avatar":@"defalu"},
                                              @{@"userId":@100073, @"nickName":@"cc", @"gender":@"F", @"memo":@"哈哈哈", @"easemobUser":@"dsdfs"
                                                , @"avatar":@"defalu"},
                                              @{@"userId":@100073, @"nickName":@"jina", @"gender":@"F", @"memo":@"哈哈哈", @"easemobUser":@"dsdfs"
                                                , @"avatar":@"defalu"},
                                              @{@"userId":@100073, @"nickName":@"小水", @"gender":@"F", @"memo":@"哈哈哈", @"easemobUser":@"dsdfs"
                                                , @"avatar":@"defalu"},
                                              @{@"userId":@100073, @"nickName":@"zz", @"gender":@"F", @"memo":@"哈哈哈", @"easemobUser":@"dsdfs"
                                                , @"avatar":@"defalu"}]];

        } else {
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@", error);
    }];
}

- (void)analysisAndSaveContacts:(NSArray *)contactList
{
    NSLog(@"开始解析联系人");
    NSMutableSet *contacts = [[NSMutableSet alloc] init];
    NSMutableSet *oldContacts = [[NSMutableSet alloc] init];
    //删除数据库已存在的联系人
    for (id oldContact in self.account.contacts) {
        [oldContacts addObject:oldContact];
    }
    
    [self.account removeContacts:oldContacts];
    for (id contactDic in contactList) {
        Contact *newContact = [NSEntityDescription insertNewObjectForEntityForName:@"Contact" inManagedObjectContext:self.context];
        newContact.userId = [contactDic objectForKey:@"userId"];
        newContact.userName = [contactDic objectForKey:@"nickName"];
        newContact.sex = [contactDic objectForKey:@"gender"];
        newContact.remark = [contactDic objectForKey:@"memo"];
        newContact.easemobUser = [contactDic objectForKey:@"easemobUser"];
        newContact.avatar = [contactDic objectForKey:@"avatar"];
        newContact.pinyin = [self chineseToPinyin:[contactDic objectForKey:@"nickName"]];
        [contacts addObject:newContact];
    }
    [self.account addContacts:contacts];
    NSError *error = nil;
    [self.context save:&error];
    NSLog(@"成功解析联系人");
}

//将每个汉字的第一个拼音字母组装起来
- (NSString *)chineseToPinyin:(NSString *)chinese
{
    NSLog(@"需要转换的汉字为：%@", chinese);
    if(![chinese isEqualToString:@""]){
        //join the pinYin
        NSString *pinYinResult = [NSString string];
        for(int j = 0;j < chinese.length; j++) {
            NSString *singlePinyinLetter = [[NSString stringWithFormat:@"%c",
                                             pinyinFirstLetter([chinese characterAtIndex:j])]uppercaseString];
            
            pinYinResult = [pinYinResult stringByAppendingString:singlePinyinLetter];
        }
        NSLog(@"转换完成的字符为：%@", pinYinResult);
        return pinYinResult;
    } else {
        return @"";
    }
}

- (NSDictionary *)contactsByPinyin
{
    NSMutableArray *chineseStringsArray = [[NSMutableArray alloc] init];
    for (id tempContact in self.account.contacts) {
        [chineseStringsArray addObject:tempContact];
    }
    NSMutableArray *sectionHeadsKeys = [[NSMutableArray alloc] init];
    //sort the ChineseStringArr by pinYin
    NSArray *sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"pinyin" ascending:YES]];
    [chineseStringsArray sortUsingDescriptors:sortDescriptors];
    
    NSMutableArray *arrayForArrays = [NSMutableArray array];
    BOOL checkValueAtIndex= NO;  //flag to check
    NSMutableArray *TempArrForGrouping = nil;
    
    for(int index = 0; index < [chineseStringsArray count]; index++)
    {
        Contact *contact = (Contact *)[chineseStringsArray objectAtIndex:index];
        NSMutableString *strchar= [NSMutableString stringWithString:contact.pinyin];
        NSString *sr= [strchar substringToIndex:1];
        if(![sectionHeadsKeys containsObject:[sr uppercaseString]])//here I'm checking whether the character already in the selection header keys or not
        {
            [sectionHeadsKeys addObject:[sr uppercaseString]];
            TempArrForGrouping = [[NSMutableArray alloc] initWithObjects:nil];
            checkValueAtIndex = NO;
        }
        if([sectionHeadsKeys containsObject:[sr uppercaseString]])
        {
            [TempArrForGrouping addObject:[chineseStringsArray objectAtIndex:index]];
            if(checkValueAtIndex == NO)
            {
                [arrayForArrays addObject:TempArrForGrouping];
                checkValueAtIndex = YES;
            }
        }
    }
    return @{@"headerKeys":sectionHeadsKeys, @"content":arrayForArrays};

}
@end








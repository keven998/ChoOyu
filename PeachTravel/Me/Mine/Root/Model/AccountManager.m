//
//  AccountManager.m
//  PeachTravel
//
//  Created by liangpengshuai on 14/10/13.
//  Copyright (c) 2014年 com.aizou.www. All rights reserved.
//

#import "AccountManager.h"
#import "AppDelegate.h"
#import "Group.h"

#define ACCOUNT_KEY  @"taozi_account"

@interface AccountManager ()

@property (nonatomic, strong) NSManagedObjectContext *context;

@end

@implementation AccountManager

+ (AccountManager *)shareAccountManager
{
    static AccountManager *accountManager;
    static dispatch_once_t token;
    dispatch_once(&token,^{
        //这里调用私有的initSingle方法
        accountManager = [[AccountManager alloc] init];
    });
    return accountManager;
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

- (void)save
{
    NSError *error = nil;
    [self.context save:&error];
}

//用户退出登录
- (void)asyncLogout:(void (^)(BOOL))completion
{
    __weak typeof(self) weakSelf = self;

    [[EaseMob sharedInstance].chatManager asyncLogoffWithUnbindDeviceToken:YES completion:^(NSDictionary *info, EMError *error) {
        NSLog(@"%@", [[EaseMob sharedInstance].chatManager loginInfo]);
        
        if (error && (error.errorCode != EMErrorServerNotLogin)) {
            NSLog(@"%@", error.description);
            completion(NO);
            return;
        }
        [weakSelf.context deleteObject:self.account];
        [weakSelf save];
        _account = nil;
        [[NSNotificationCenter defaultCenter] postNotificationName:userDidLogoutNoti object:nil];
        completion(YES);

    } onQueue:nil];
}

//用户桃子系统登录成功
- (void)userDidLoginWithUserInfo:(id)userInfo
{
    if (self.account) {
        [self.context deleteObject:self.account];
        [self save];
        _account = nil;
    }
    _account = [NSEntityDescription insertNewObjectForEntityForName:@"Account" inManagedObjectContext:self.context];
    [self loadUserInfo:userInfo];
}

//环信系统也登录成功，这时候才是真正的登录成功
- (void)easeMobDidLogin
{
    [self save];
    [self loadContactsFromServer];
}

//环信系统登录失败
- (void)easeMobUnlogin
{
    if (self.account) {
        [self.context deleteObject:self.account];
        [self save];
    }
    _account = nil;
}

- (void)loginEaseMobServer
{
    [self loginEaseMobServer:nil];
}

- (void)loginEaseMobServer:(void (^)(BOOL isSuccess))completion
{
    [self loginEaseMobServerWithUserName:self.account.easemobUser withPassword:self.account.easemobPwd withCompletion:completion];
}

/**
 *  使用用户名密码登录环信聊天系统,只有环信系统也登录成功才算登录成功
 *
 *  @param userName
 *  @param password
 */
- (void)loginEaseMobServerWithUserName:(NSString *)userName withPassword:(NSString *)password withCompletion:(void(^)(BOOL))completion
{
    if ([EaseMob sharedInstance].chatManager.isLoggedIn) {
        [[EaseMob sharedInstance].chatManager logoffWithUnbindDeviceToken:YES error:nil];
    }
    [[EaseMob sharedInstance].chatManager asyncLoginWithUsername:userName
                                                        password:password
                                                      completion:
     ^(NSDictionary *loginInfo, EMError *error) {
         if (loginInfo && !error) {
             [self easeMobDidLogin];
             [[NSNotificationCenter defaultCenter] postNotificationName:userDidLoginNoti object:nil];

             EMPushNotificationOptions *options = [[EMPushNotificationOptions alloc] init];
             options.displayStyle = ePushNotificationDisplayStyle_simpleBanner;
             [[EaseMob sharedInstance].chatManager asyncUpdatePushOptions:options];
             //设置环信自动登录
             [[EaseMob sharedInstance].chatManager setIsAutoLoginEnabled:YES];
             if (completion) {
                 completion(YES);
             }
         } else {
             [self easeMobUnlogin];
             if (completion) {
                 completion(NO);
             }
         }
     } onQueue:nil];
}

#pragma mark - 修改用户信息相关接口

- (void)asyncChangeUserName:(NSString *)newUsername completion:(void (^)(BOOL, UserInfoInputError, NSString *))completion
{
    //如果新的用户名和之前一样的话直接返回
    if ([newUsername isEqualToString:self.account.nickName]) {
        completion(YES, NoError, nil);
    } else if ([self checkUserinfo:newUsername andUserInfoType:ChangeName] != NoError) {
        completion(NO, [self checkUserinfo:newUsername andUserInfoType:ChangeName], nil);
    } else {
        [self asyncUpdateUserInfoToServer:newUsername andUserInfoType:ChangeName andKeyWord:@"nickName" completion:^(BOOL isSuccess, NSString *errStr) {
            if (isSuccess) {
                completion(YES, NoError, nil);
            } else {
                completion(NO, NoError, errStr);
            }
        }];
    }
}

- (void)asyncChangeSignature:(NSString *)newSignature completion:(void (^)(BOOL, UserInfoInputError, NSString *))completion
{
    //如果新的用户名和之前一样的话直接返回
    if ([newSignature isEqualToString:self.account.signature]) {
        completion(YES, NoError, nil);
        
    } else {
        [self asyncUpdateUserInfoToServer:newSignature andUserInfoType:ChangeSignature andKeyWord:@"signature" completion:^(BOOL isSuccess, NSString *errStr) {
            if (isSuccess) {
                completion(YES, NoError, nil);
            } else {
                completion(NO, NoError, errStr);
            }
        }];
    }
}

/**
 *  异步更新服务的用户信息
 *
 *  @param userInfo     用户信息，可以是昵称，签名等
 *  @param userInfoType 更改用户信息的类型
 *  @param keyWord      更改用户信息类型的关键字
 *  @param completion   完成后的回调, 回调信息包括：是否成功，错误的信息
 */
- (void)asyncUpdateUserInfoToServer:(NSString *)userInfo andUserInfoType:(UserInfoChangeType)userInfoType andKeyWord:(NSString *)keyWord completion:(void (^) (BOOL isSuccess, NSString *errStr)) completion
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    AppUtils *utils = [[AppUtils alloc] init];
    [manager.requestSerializer setValue:utils.appVersion forHTTPHeaderField:@"Version"];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"iOS %@",utils.systemVersion] forHTTPHeaderField:@"Platform"];
    
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [manager.requestSerializer setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"%@", self.account.userId] forHTTPHeaderField:@"UserId"];
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    
    [params setObject:userInfo forKey:keyWord];
    
    NSString *urlStr = [NSString stringWithFormat:@"%@%@", API_USERINFO, self.account.userId];
    
    [manager POST:urlStr parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSInteger code = [[responseObject objectForKey:@"code"] integerValue];
        if (code == 0) {
            [SVProgressHUD showHint:@"修改成功"];
            [self updateUserInfo:userInfo withChangeType:userInfoType];
            [[NSNotificationCenter defaultCenter] postNotificationName:updateUserInfoNoti object:nil];
            if (userInfoType == ChangeName) {
                [[EaseMob sharedInstance].chatManager setApnsNickname:userInfo];
            }
            completion(YES, nil);
            
        } else {
            completion(NO, [[responseObject objectForKey:@"err"] objectForKey:@"message"]);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        completion(NO, nil);
    }];

}

- (void)asyncChangeGender:(NSString *)newGender completion:(void (^)(BOOL, NSString *))completion
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    AppUtils *utils = [[AppUtils alloc] init];
    [manager.requestSerializer setValue:utils.appVersion forHTTPHeaderField:@"Version"];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"iOS %@",utils.systemVersion] forHTTPHeaderField:@"Platform"];
    
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [manager.requestSerializer setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"%@", self.account.userId] forHTTPHeaderField:@"UserId"];
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params safeSetObject:newGender forKey:@"gender"];
    
    NSString *urlStr = [NSString stringWithFormat:@"%@%@", API_USERINFO, self.account.userId];
    
    [manager POST:urlStr parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {

        NSInteger code = [[responseObject objectForKey:@"code"] integerValue];
        if (code == 0) {
            [self updateUserInfo:newGender withChangeType:ChangeGender];
            [[NSNotificationCenter defaultCenter] postNotificationName:updateUserInfoNoti object:nil];
            completion(YES, nil);
        } else {
            completion(NO, nil);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        completion(NO, nil);
    }];
}

- (void)asyncChangeLocation:(NSString *)location completion:(void (^)(BOOL, NSString *))completion
{
    
}

/**
 *  修改用户信息
 *
 *  @param changeContent 信息内容
 *  @param changeType    信息类型，电话，签名等
 */
- (void)updateUserInfo:(NSString *)changeContent withChangeType:(UserInfoChangeType)changeType
{
    switch (changeType) {
        case ChangeName:
            self.account.nickName = changeContent;
            break;
            
        case ChangeSignature:
            self.account.signature = changeContent;
            break;
            
        case ChangeTel:
            self.account.tel = changeContent;
            break;
            
        case ChangeGender:
            self.account.gender = changeContent;
            break;
            
        case ChangeAvatar:
            self.account.avatar = changeContent;
            break;
            
        case ChangeSmallAvatar:
            self.account.avatarSmall = changeContent;
            break;
            
        default:
            break;
    }
    [self save];
}

/**
 *  检测输入的用户信息是否合法
 *
 *  @param userInfo     用户信息
 *  @param userInfoType 用户信息类型
 *
 *  @return 错误码
 */
- (UserInfoInputError)checkUserinfo:(NSString *)userInfo andUserInfoType:(UserInfoChangeType)userInfoType
{
    if (userInfoType == ChangeName) {
        NSString *regex1 = @"^[\u4E00-\u9FA5|0-9a-zA-Z|_]{1,}$";
        NSString *regex2 = @"^[0-9]{6,}$";
        NSPredicate *pred1 = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex1];
        NSPredicate *pred2 = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex2];
        if (![pred1 evaluateWithObject:userInfo] || [pred2 evaluateWithObject:userInfo]) {
            return IllegalCharacterError;
        }
    }
    if (userInfoType == ChangeSignature) {
        NSString *regex1 = @"^[\u4E00-\u9FA5|0-9a-zA-Z|_]*$";
        NSPredicate *pred1 = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex1];
        if (![pred1 evaluateWithObject:userInfo] ||  ![pred1 evaluateWithObject:userInfo]) {
            NSLog(@"输入中含有非法字符串");
            return IllegalCharacterError;
        }
    }
    return NoError;
}


//解析从服务器上下载的用户信息
- (void)loadUserInfo:(id)json
{
    _account.userId = [NSNumber numberWithInteger:[[json objectForKey:@"userId"] integerValue]];
    _account.nickName = [json objectForKey:@"nickName"];
    _account.avatar = [json objectForKey:@"avatar"];
    _account.avatarSmall = [json objectForKey:@"avatarSmall"];
    _account.gender = [json objectForKey:@"gender"];
    if (!_account.gender) {
        _account.gender = @"U";
    }
    _account.tel = [json objectForKey:@"tel"];
    _account.secToken = [json objectForKey:@"secToken"];
    _account.signature = [json objectForKey:@"signature"];
    _account.easemobUser = [json objectForKey:@"easemobUser"];
    _account.easemobPwd = [json objectForKey:@"easemobPwd"];
}

//通过环信 id 取得用户的桃子信息
- (Contact *)TZContactByEasemobUser:(NSString *)easemobUser
{
    for (Contact *contact in self.account.contacts) {
        if ([contact.easemobUser isEqualToString:easemobUser]) {
            return contact;
        }
    }
    return nil;
}

- (BOOL)isMyFrend:(NSNumber *)userId
{
    for (Contact *contact in self.account.contacts) {
        if (contact.userId.integerValue == userId.integerValue) {
            return YES;
        }
    }
    return NO;
}

- (void)updateContact
{
    
}

//从服务器上获取好友列表
- (void)loadContactsFromServer
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    AppUtils *utils = [[AppUtils alloc] init];
    [manager.requestSerializer setValue:utils.appVersion forHTTPHeaderField:@"Version"];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"iOS %@",utils.systemVersion] forHTTPHeaderField:@"Platform"];
    
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [manager.requestSerializer setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"%@", self.account.userId] forHTTPHeaderField:@"UserId"];
    
    [manager GET:API_GET_CONTACTS parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSInteger code = [[responseObject objectForKey:@"code"] integerValue];
        if (code == 0) {
            NSLog(@"已经完成从服务器上加载好友列表");
            
            [self analysisAndSaveContacts:[[responseObject objectForKey:@"result"] objectForKey:@"contacts"]];
            [[NSNotificationCenter defaultCenter] postNotificationName:contactListNeedUpdateNoti object:nil];
        } else {
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@", error);
    }];
}


- (void)addContact:(id)contactDic
{
    NSLog(@"收到添加联系人，联系人的内容为：%@", contactDic);
    
       Contact *newContact = [NSEntityDescription insertNewObjectForEntityForName:@"Contact" inManagedObjectContext:self.context];
    
    if ([contactDic isKindOfClass:[FrendRequest class]]) {
        //如果已经是我的好友了，那我就没必要添加了。。

        if ([self isMyFrend:((FrendRequest *)contactDic).userId]) {
            return;
        }
        newContact.userId = ((FrendRequest *)contactDic).userId;
        newContact.nickName = ((FrendRequest *)contactDic).nickName;
        newContact.gender = ((FrendRequest *)contactDic).gender;
        newContact.memo = @"";
        newContact.easemobUser = ((FrendRequest *)contactDic).easemobUser;
        newContact.avatar = ((FrendRequest *)contactDic).avatar;
        newContact.avatarSmall = ((FrendRequest *)contactDic).avatarSmall;
        newContact.pinyin = [ConvertMethods chineseToPinyin:newContact.nickName];
        
    } else {
        //如果已经是我的好友了，那我就没必要添加了。。
        if ([self isMyFrend:[contactDic objectForKey:@"userId"]]) {
            return;
        }

        newContact.userId = [contactDic objectForKey:@"userId"];
        newContact.nickName = [contactDic objectForKey:@"nickName"];
        newContact.gender = [contactDic objectForKey:@"gender"];
        newContact.memo = [contactDic objectForKey:@"memo"];
        newContact.easemobUser = [contactDic objectForKey:@"easemobUser"];
        newContact.avatar = [contactDic objectForKey:@"avatar"];
        newContact.avatarSmall = [contactDic objectForKey:@"avatarSmall"];
        newContact.signature = [contactDic objectForKey:@"signature"];
        newContact.pinyin = [ConvertMethods chineseToPinyin:[contactDic objectForKey:@"nickName"]];
    }
    [self.account addContactsObject:newContact];
    [self save];
    [[NSNotificationCenter defaultCenter] postNotificationName:contactListNeedUpdateNoti object:nil];

}

//解析好友列表，然后存到数据库里
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
        newContact.nickName = [contactDic objectForKey:@"nickName"];
        newContact.gender = [contactDic objectForKey:@"gender"];
        newContact.memo = [contactDic objectForKey:@"memo"];
        newContact.easemobUser = [contactDic objectForKey:@"easemobUser"];
        newContact.avatar = [contactDic objectForKey:@"avatar"];
        newContact.avatarSmall = [contactDic objectForKey:@"avatarSmall"];
        newContact.pinyin = [ConvertMethods chineseToPinyin:[contactDic objectForKey:@"nickName"]];
        newContact.signature = [contactDic objectForKey:@"signature"];
        [contacts addObject:newContact];
    }
    [self.account addContacts:contacts];
    [self save];
    NSLog(@"成功解析联系人");
}

- (void)analysisAndSaveFrendRequest:(id)frendRequestDic
{
    NSLog(@"开始解析好友请求");
    
    FrendRequest *frendRequest = [NSEntityDescription insertNewObjectForEntityForName:@"FrendRequest" inManagedObjectContext:self.context];

    if ([frendRequestDic isKindOfClass:[NSDictionary class]]) {
        frendRequest.userId = [frendRequestDic objectForKey:@"userId"];
        frendRequest.nickName = [frendRequestDic objectForKey:@"nickName"];
        frendRequest.avatar = [frendRequestDic objectForKey:@"avatar"];
        frendRequest.avatarSmall = [frendRequestDic objectForKey:@"avatarSmall"];
        frendRequest.status = TZFrendDefault;
        frendRequest.gender = [frendRequestDic objectForKey:@"gender"];
        frendRequest.easemobUser = [frendRequestDic objectForKey:@"easemobUser"];
        frendRequest.attachMsg = [frendRequestDic objectForKey:@"attachMsg"];
        frendRequest.requestDate = [NSNumber numberWithDouble:[[NSDate date] timeIntervalSince1970]];
    }
    
    for (FrendRequest *request in self.account.frendrequestlist) {
        if ([request.userId integerValue] == [frendRequest.userId integerValue]) {
            [self.account removeFrendrequestlistObject:request];
            NSLog(@"这个好友请求信息数据库里已经存在了,已经将数据库里旧的数据删除了,\n之前的 id 是%@，新 ID 是%@",request.userId, frendRequest.userId);
            break;
        }
    }
    [self.account addFrendrequestlistObject:frendRequest];
    NSLog(@"收到好友请求，请求信息为：%@", frendRequest);
    [[NSNotificationCenter defaultCenter] postNotificationName:frendRequestListNeedUpdateNoti object:nil];
    [self save];
}

- (void)removeFrendRequest:(FrendRequest *)frendRequest
{
    [self.account removeFrendrequestlistObject:frendRequest];
    [self save];
    [[NSNotificationCenter defaultCenter] postNotificationName:frendRequestListNeedUpdateNoti object:nil];

}

- (void)agreeFrendRequest:(FrendRequest *)frendRequest
{
    //更新时间戳，
    frendRequest.requestDate = [NSNumber numberWithDouble:[[NSDate date] timeIntervalSince1970]];
    frendRequest.status = [NSNumber numberWithInteger:TZFrendAgree];
    [self save];
    [[NSNotificationCenter defaultCenter] postNotificationName:frendRequestListNeedUpdateNoti object:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:contactListNeedUpdateNoti object:nil];
}

- (void)removeContact:(NSNumber *)userId
{
    for (Contact *contact in self.account.contacts) {
        if ([contact.userId integerValue] == [userId integerValue]) {
            [self.account removeContactsObject:contact];
            [self save];
            break;
        }
    }
}

#pragma mark - ********群组相关操作******

- (Group *)groupWithGroupId:(NSString *)groupId
{
    for (Group *group in self.account.groupList) {
        if ([group.groupId isEqualToString:groupId]) {
            return group;
        }
    }
    return nil;
}

- (Group *)createGroupWithGroupId:(NSString *)groupId
                            owner:(NSString *)owner
                  groupSubject:(NSString *)subject
                     groupInfo:(NSString *)groupDescription
                       numbers:(NSSet *)numbers
{
    Group *group = [NSEntityDescription insertNewObjectForEntityForName:@"Group" inManagedObjectContext:self.context];
    group.owner = owner;
    group.numbers = numbers;
    group.groupId = groupId;
    group.groupSubject = subject;
    group.groupDescription = groupDescription;
    [self.account addGroupListObject:group];
    [self save];
    return group;
}

- (Group *)updateGroup:(NSString *)groupId withGroupOwner:(NSString *)owner groupSubject:(NSString *)subject groupInfo:(NSString *)groupDescription numbers:(id)numbersDic
{
    NSMutableSet *numbers = [[NSMutableSet alloc] init];
    for (id contactDic in numbersDic) {
        Contact *contact = [NSEntityDescription insertNewObjectForEntityForName:@"Contact" inManagedObjectContext:self.context];
        contact.userId = [contactDic objectForKey:@"userId"];
        contact.avatar = [contactDic objectForKey:@"avatar"];
        contact.avatarSmall = [contactDic objectForKey:@"avatarSmall"];
        contact.nickName = [contactDic objectForKey:@"nickName"];
        contact.signature= [contactDic objectForKey:@"signature"];
        contact.easemobUser = [contactDic objectForKey:@"easemobUser"];
        contact.gender = [contactDic objectForKey:@"gender"];
        contact.memo = [contactDic objectForKey:@"memo"];
        [numbers addObject:contact];
    }
    
    Group *tempGroup = [self groupWithGroupId:groupId];
    if (!tempGroup) {
        tempGroup = [self createGroupWithGroupId:groupId owner:owner groupSubject:subject groupInfo:groupDescription numbers:numbers];
    } else {
        tempGroup.groupId = groupId;
        tempGroup.groupSubject= subject;
        tempGroup.groupDescription = groupDescription;
        tempGroup.numbers = numbers;
        tempGroup.owner = owner;
    }
    [self save];
    return tempGroup;
}


- (Group *)updateGroup:(NSString *)groupId withGroupOwner:(NSString *)owner groupSubject:(NSString *)subject groupInfo:(NSString *)groupDescription
{
    Group *tempGroup = [self groupWithGroupId:groupId];
    if (!tempGroup) {
        tempGroup = [self createGroupWithGroupId:groupId owner:owner groupSubject:subject groupInfo:groupDescription numbers:nil];
    } else {
        tempGroup.groupId = groupId;
        tempGroup.groupSubject= subject;
        tempGroup.groupDescription = groupDescription;
        tempGroup.owner = owner;
    }
    [self save];
    return tempGroup;
}


- (void)addNumberToGroup:(NSString *)groupId
                 numbers:(NSSet *)numbers
{
    for (Group *group in self.account.groupList) {
        if ([group.groupId isEqualToString:groupId]) {
            [group addNumbers:numbers];
            [self save];
        }
    }
}

- (void)removeNumberToGroup:(NSString *)groupId numbers:(NSSet *)numbers
{
    for (Group *group in self.account.groupList) {
        if ([group.groupId isEqualToString:groupId]) {
            [group removeNumbers:numbers];
            [self save];
        }
    }
}

- (NSUInteger)numberOfUnReadFrendRequest
{
    NSUInteger ret = 0;
    for (FrendRequest *request in self.account.frendrequestlist) {
        if (request.status == 0) {
            ret++;
        }
    }
    return ret;
}

#pragma mark -
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
    
    NSMutableArray *arrayForArrays = [[NSMutableArray alloc] init];
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








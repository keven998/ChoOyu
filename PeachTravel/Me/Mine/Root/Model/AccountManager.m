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

- (AccountModel *)accountDetail
{
    if (!_accountDetail) {
        _accountDetail = [[AccountModel alloc] init];
        _accountDetail.basicUserInfo = self.account;
    }
    return _accountDetail;
}

- (NSString *)userChatAudioPath
{
    if (!_userChatAudioPath) {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentPath = [paths objectAtIndex:0];
        
        NSFileManager *fileManager =  [[NSFileManager alloc] init];
        NSString *audioPath = [documentPath stringByAppendingPathComponent:[NSString stringWithFormat: @"%@/ChatAudio/", [AccountManager shareAccountManager].account.userId]];
        if (![fileManager fileExistsAtPath: audioPath]) {
            [fileManager createDirectoryAtPath:audioPath withIntermediateDirectories:YES attributes:nil error:nil];
        }
        _userChatAudioPath = audioPath;
    }
    return _userChatAudioPath;
}

- (NSString *)userChatImagePath
{
    if (!_userChatImagePath) {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentPath = [paths objectAtIndex:0];
        
        NSFileManager *fileManager =  [[NSFileManager alloc] init];
        NSString *imagePath = [documentPath stringByAppendingPathComponent:[NSString stringWithFormat: @"%@/ChatImage/", [AccountManager shareAccountManager].account.userId]];

        if (![fileManager fileExistsAtPath: imagePath]) {
            [fileManager createDirectoryAtPath:imagePath withIntermediateDirectories:YES attributes:nil error:nil];
        }
        _userChatImagePath = imagePath;
    }
    return _userChatImagePath;
}

- (NSString *)userTempPath
{
    if (!_userTempPath) {
        NSString *tempPath = NSTemporaryDirectory();
        
        NSFileManager *fileManager =  [[NSFileManager alloc] init];
        NSString *retPath = [tempPath stringByAppendingPathComponent:[NSString stringWithFormat: @"%@/tempFile/", [AccountManager shareAccountManager].account.userId]];

        if (![fileManager fileExistsAtPath: retPath]) {
            [fileManager createDirectoryAtPath:retPath withIntermediateDirectories:YES attributes:nil error:nil];
        }
        _userTempPath = retPath;
    }
    return _userTempPath;
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
//        NSString *appDomain = [[NSBundle mainBundle] bundleIdentifier];
//        [[NSUserDefaults standardUserDefaults] removePersistentDomainForName:appDomain];
    } onQueue:nil];
}

//用户旅行派系统登录成功
- (void)userDidLoginWithUserInfo:(id)userInfo
{
    if (self.account) {
        [self.context deleteObject:self.account];
        [self save];
        _account = nil;
    }
    _account = [NSEntityDescription insertNewObjectForEntityForName:@"Account" inManagedObjectContext:self.context];
    [self loadUserInfo:userInfo];
    
    [self addPaipaiContact];
    [self save];
    IMClientManager *manager = [IMClientManager shareInstance];
    [manager userDidLogin];
    [self bindRegisterID2UserId];
    [[NSNotificationCenter defaultCenter] postNotificationName:userDidLoginNoti object:nil];

}

- (void)bindRegisterID2UserId
{
    ConnectionManager *connectionManager = [ConnectionManager shareInstance];
    if (!connectionManager.registionId) {
        return;
    }
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    AppUtils *utils = [[AppUtils alloc] init];
    [manager.requestSerializer setValue:utils.appVersion forHTTPHeaderField:@"Version"];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"iOS %@",utils.systemVersion] forHTTPHeaderField:@"Platform"];
    
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [manager.requestSerializer setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"%@", self.account.userId] forHTTPHeaderField:@"UserId"];
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    
    [params setObject:self.account.userId forKey:@"userId"];
    [params setObject:[ConnectionManager shareInstance].registionId forKey:@"regId"];
    
    NSString *loginUrl = @"http://hedy.zephyre.me/users/login";
    
    
    [manager POST:loginUrl parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSInteger code = [[responseObject objectForKey:@"code"] integerValue];
        if (code == 0) {
            
        } else {
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
    }];
}

/**
 *  默认添加 paipai 好友
 */
- (void)addPaipaiContact
{
    Contact *contact = [NSEntityDescription insertNewObjectForEntityForName:@"Contact" inManagedObjectContext:self.context];
    contact.userId = [NSNumber numberWithInt:10000];
    contact.nickName = @"派派";
    contact.easemobUser = @"gcounhhq0ckfjwotgp02c39vq40ewhxt";
    contact.pinyin = @"paipai";
    [self.account addContactsObject:contact];
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

- (void)asyncChangeResidence:(NSString *)residence completion:(void (^)(BOOL, NSString *))completion
{
    [self asyncUpdateUserInfoToServer:residence andUserInfoType:ChangeOtherInfo andKeyWord:@"residence" completion:^(BOOL isSuccess, NSString *errStr) {
        if (isSuccess) {
            self.accountDetail.residence =  residence;
            completion(YES, nil);
        } else {
            completion(NO, errStr);
        }
    }];
}

- (void)asyncChangeBirthday:(NSString *)birthday completion:(void (^)(BOOL, NSString *))completion
{
    [self asyncUpdateUserInfoToServer:birthday andUserInfoType:ChangeOtherInfo andKeyWord:@"birthday" completion:^(BOOL isSuccess, NSString *errStr) {
    if (isSuccess) {
        self.accountDetail.birthday =  birthday;
        completion(YES, nil);
    } else {
        completion(NO, errStr);
    }
}];
}

/**
 *  修改用户头像
 *
 *  @param albumImage
 *  @param completion
 */
- (void)asyncChangeUserAvatar:(AlbumImage *)albumImage completion:(void (^)(BOOL, NSString *))completion
{
    [self asyncUpdateUserInfoToServer:albumImage.imageId andUserInfoType:ChangeAvatar andKeyWord:@"avatar" completion:^(BOOL isSuccess, NSString *errStr) {
        if (isSuccess) {
            self.account.avatar =  albumImage.image.imageUrl;
            completion(YES, nil);
        } else {
            completion(NO, errStr);
        }
    }];
}

- (void)asyncDelegateUserAlbumImage:(AlbumImage *)albumImage completion:(void (^)(BOOL, NSString *))completion
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    AppUtils *utils = [[AppUtils alloc] init];
    [manager.requestSerializer setValue:utils.appVersion forHTTPHeaderField:@"Version"];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"iOS %@",utils.systemVersion] forHTTPHeaderField:@"Platform"];
    
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"%@", self.account.userId] forHTTPHeaderField:@"UserId"];
    
    NSString *urlStr = [NSString stringWithFormat:@"%@%@/albums/%@", API_USERINFO, self.account.userId, albumImage.imageId];
    
    [manager DELETE:urlStr parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSInteger code = [[responseObject objectForKey:@"code"] integerValue];
        if (code == 0) {
            [SVProgressHUD showHint:@"修改成功"];
            NSMutableArray *albums = [self.accountDetail.userAlbum mutableCopy];
            [albums removeObject:albumImage];
            self.accountDetail.userAlbum = albums;
            completion(YES, nil);
            [[NSNotificationCenter defaultCenter] postNotificationName:updateUserInfoNoti object:nil];
            
        } else {
            completion(NO, [[responseObject objectForKey:@"err"] objectForKey:@"message"]);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        completion(NO, nil);
    }];
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
            if (userInfoType == ChangeName) {
                [[EaseMob sharedInstance].chatManager setApnsNickname:userInfo];
            }
            completion(YES, nil);
            [[NSNotificationCenter defaultCenter] postNotificationName:updateUserInfoNoti object:nil];

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

- (void)asyncChangeStatus:(NSString *)newStatus completion:(void (^)(BOOL, NSString *))completion
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
    [params safeSetObject:newStatus forKey:@"travelStatus"];
    
    NSString *urlStr = [NSString stringWithFormat:@"%@%@", API_USERINFO, self.account.userId];
    
    [manager POST:urlStr parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSInteger code = [[responseObject objectForKey:@"code"] integerValue];
        if (code == 0) {
//            [self updateUserInfo:newStatus withChangeType:ChangeGender];
            self.accountDetail.travelStatus = newStatus;
            [[NSNotificationCenter defaultCenter] postNotificationName:updateUserInfoNoti object:nil];
            completion(YES, nil);
        } else {
            completion(NO, nil);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        completion(NO, nil);
    }];
}

/**
 *  更新用户信息
 *
 *  @param changeContent 信息内容
 */
- (void)updateUserInfo:(id)userInfo
{
    [self loadUserInfo:userInfo];
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

#pragma mark - **********好友相关操作********

/**
 *  通过环信 id 取得用户的旅行派信息
 *
 *  @param easemobUser 环信 id
 *
 *  @return
 */
- (Contact *)TZContactByEasemobUser:(NSString *)easemobUser
{
    for (Contact *contact in self.account.contacts) {
        if ([contact.easemobUser isEqualToString:easemobUser]) {
            return contact;
        }
    }
    return nil;
}

- (Contact *)TZContactByUserId:(NSNumber *)userId
{
    for (Contact *contact in self.account.contacts) {
        if (contact.userId.integerValue == userId.integerValue) {
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
    
    [self.accountDetail.frendList removeAllObjects];
    FrendManager *frendManager = [[FrendManager alloc] init];
    [frendManager deleteAllContacts];
    for (id contactDic in contactList) {
        FrendModel *newContact = [[FrendModel alloc] init];
        newContact.userId = [[contactDic objectForKey:@"userId"] integerValue];
        newContact.nickName = [contactDic objectForKey:@"nickName"];
        newContact.memo = [contactDic objectForKey:@"memo"];
        newContact.avatar = [contactDic objectForKey:@"avatar"];
        newContact.avatarSmall = [contactDic objectForKey:@"avatarSmall"];
        newContact.signature = [contactDic objectForKey:@"signature"];
        newContact.fullPY = [ConvertMethods chineseToPinyin:[contactDic objectForKey:@"nickName"]];
        newContact.type = IMFrendTypeFrend;
        [frendManager addFrend2DB:newContact];
        [self.accountDetail.frendList addObject:newContact];
    }

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

#pragma mark - ********修改用户好友信息

- (void)asyncChangeRemark:(NSString *)remark withUserId:(NSNumber *)userId completion:(void (^)(BOOL))completion
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
    [params safeSetObject:remark forKey:@"memo"];
    
    NSString *urlStr = [NSString stringWithFormat:@"%@%@/memo", API_USERINFO, userId];
    
    [manager POST:urlStr parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"result = %@", responseObject);
        NSInteger code = [[responseObject objectForKey:@"code"] integerValue];
        if (code == 0) {
            [self updateContactMemo:remark andUserId:userId];
            completion(YES);
        } else {
            completion(NO);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        completion(NO);
    }];

}

/**
 *  更新好友备注
 */
- (void)updateContactMemo:(NSString *)memo andUserId:(NSNumber *)userId
{
    Contact *contact = [self TZContactByUserId:userId];
    if (contact) {
        contact.memo = memo;
        NSError *error;
        [self.context save:&error];
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
    for (id tempContact in self.accountDetail.frendList) {
        [chineseStringsArray addObject:tempContact];
    }
    NSMutableArray *sectionHeadsKeys = [[NSMutableArray alloc] init];
    //sort the ChineseStringArr by pinYin
    NSArray *sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"fullPY" ascending:YES]];
    [chineseStringsArray sortUsingDescriptors:sortDescriptors];
    
    NSMutableArray *arrayForArrays = [[NSMutableArray alloc] init];
    BOOL checkValueAtIndex= NO;  //flag to check
    NSMutableArray *TempArrForGrouping = nil;
    
    for(int index = 0; index < [chineseStringsArray count]; index++)
    {
        FrendModel *contact = (FrendModel *)[chineseStringsArray objectAtIndex:index];
        NSMutableString *strchar= [NSMutableString stringWithString:contact.fullPY];
        NSString *sr= [strchar substringToIndex:1];
        if(![sectionHeadsKeys containsObject:[sr uppercaseString]]) {
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








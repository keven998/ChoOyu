//
//  AccountManager.m
//  PeachTravel
//
//  Created by liangpengshuai on 14/10/13.
//  Copyright (c) 2014年 com.aizou.www. All rights reserved.
//

#import "AccountManager.h"
#import "PeachTravel-swift.h"
#import "ConvertMethods.h"

#define ACCOUNT_KEY  @"taozi_account"

@interface AccountManager ()

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

- (AccountModel *)account {
    if (!_account) {
        AccountDaoHelper *accountDaoHelper = [AccountDaoHelper shareInstance];
        _account = [accountDaoHelper selectCurrentAccount];
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

- (void)asyncLoginWithWeChat:(NSString *)code completion:(void(^)(BOOL isSuccess, NSString *errorStr))completion
{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:code forKey:@"authCode"];
    [params setObject:@"weixin" forKey:@"provider"];
    
    //微信登录
    [LXPNetworking POST:API_SIGNIN parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"%@", responseObject);
        NSInteger code = [[responseObject objectForKey:@"code"] integerValue];
        if (code == 0) {
            AccountManager *accountManager = [AccountManager shareAccountManager];
            [accountManager userDidLoginWithUserInfo:[responseObject objectForKey:@"result"]];
            completion(YES, nil);
        } else {
            completion(NO, [NSString stringWithFormat:@"%@",[[responseObject objectForKey:@"err"] objectForKey:@"message"]]);
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        completion(NO, nil);
    }];
}


- (void)asyncLogin:(NSString *)userId password:(NSString *)password completion:(void(^)(BOOL isSuccess, NSString *errorStr))completion
{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:userId forKey:@"loginName"];
    [params setObject:password forKey:@"password"];
    
    //普通登录
    [LXPNetworking POST:API_SIGNIN parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"%@", responseObject);
        NSInteger code = [[responseObject objectForKey:@"code"] integerValue];
        if (code == 0) {
            AccountManager *accountManager = [AccountManager shareAccountManager];
            [accountManager userDidLoginWithUserInfo:[responseObject objectForKey:@"result"]];
            
            // 如果登录成功后将用户最后的登录信息UserId存起来
            [[TMCache sharedCache] setObject:userId forKey:@"last_account"];
            completion(YES, nil);
        } else {
            completion(NO, [NSString stringWithFormat:@"%@",[[responseObject objectForKey:@"err"] objectForKey:@"message"]]);
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (operation.response.statusCode == 401) {
            completion(NO,@"用户名或密码错误");
        } else {
            completion(NO, nil);
        }
    }];
}

//用户退出登录
- (void)asyncLogout:(void (^)(BOOL))completion
{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:[NSNumber numberWithInteger:_account.userId] forKey:@"userId"];
    
    [LXPNetworking POST:API_LOGOUT parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"%@", responseObject);
        NSInteger code = [[responseObject objectForKey:@"code"] integerValue];
        if (code == 0) {
            _account = nil;
            IMClientManager *clientManager = [IMClientManager shareInstance];
            [clientManager userDidLogout];
            AccountDaoHelper *daoHelper = [AccountDaoHelper shareInstance];
            [daoHelper deleteAccountInfoInDB];
            [[NSNotificationCenter defaultCenter] postNotificationName:userDidLogoutNoti object:nil];
            completion(YES);
        } else {
            completion(NO);
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        completion(NO);
    }];
}

//用户旅行派系统登录成功
- (void)userDidLoginWithUserInfo:(id)userInfo
{
    // 登录成功后需要将用户信息存储到数据库中
    _account =[[AccountModel alloc] initWithJson:userInfo];
    // 存储账户
    AccountDaoHelper *accountDaoHelper = [AccountDaoHelper shareInstance];
    [accountDaoHelper addAccount2DB:_account];
    
    IMClientManager *manager = [IMClientManager shareInstance];
    [manager userDidLogin:_account.userId];
    ConnectionManager *connectionManager = [ConnectionManager shareInstance];
    [connectionManager bindUserIdWithRegistionId:_account.userId];
    [[NSNotificationCenter defaultCenter] postNotificationName:userDidLoginNoti object:nil];
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
            self.account.residence =  residence;
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
        self.account.birthday =  birthday;
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
- (void)asyncChangeUserAvatar:(AlbumImageModel *)albumImage completion:(void (^)(BOOL, NSString *))completion
{
    [self asyncUpdateUserInfoToServer:albumImage.imageUrl andUserInfoType:ChangeAvatar andKeyWord:@"avatar" completion:^(BOOL isSuccess, NSString *errStr) {
        if (isSuccess) {
            self.account.avatar =  albumImage.imageUrl;
            self.account.avatarSmall =  albumImage.smallImageUrl;

            completion(YES, nil);
        } else {
            completion(NO, errStr);
        }
    }];
}

- (void)deleteUserAlbumImage:(NSString *)imageId
{
    for (AlbumImageModel *image in self.account.userAlbum) {
        if ([image.imageId isEqualToString:imageId]) {
            [self.account.userAlbum removeObject:image];
            return;
        }
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
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    
    [params setObject:userInfo forKey:keyWord];
    
    NSString *urlStr = [NSString stringWithFormat:@"%@%ld", API_USERS, (long)self.account.userId];
    
    [LXPNetworking PATCH:urlStr parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSInteger code = [[responseObject objectForKey:@"code"] integerValue];
        if (code == 0) {
            [SVProgressHUD showHint:@"修改成功"];
            [self updateUserInfo:userInfo withChangeType:userInfoType];
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
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params safeSetObject:newGender forKey:@"gender"];
    
    NSString *urlStr = [NSString stringWithFormat:@"%@%ld", API_USERS, (long)self.account.userId];
    
    NSLog(@"%@,%@",urlStr,params);
    
    [LXPNetworking PATCH:urlStr parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {

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

- (void)asyncBindTelephone:(NSString *)tel token:(NSString *)token completion:(void (^)(BOOL, NSString *))completion
{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:tel forKey:@"tel"];
    [params setObject:token forKey:@"token"];
    AccountManager *accountManager = [AccountManager shareAccountManager];
    [params setObject:[NSNumber numberWithInteger: accountManager.account.userId] forKey:@"userId"];
    
    NSString *urlStr = [NSString stringWithFormat:@"%@%ld/tel", API_USERS, accountManager.account.userId];
    //修改手机号
    [LXPNetworking PUT:urlStr parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"%@", responseObject);
        NSInteger code = [[responseObject objectForKey:@"code"] integerValue];
        if (code == 0) {
            [self updateUserInfo:tel withChangeType:ChangeTel];
            [[NSNotificationCenter defaultCenter] postNotificationName:updateUserInfoNoti object:nil];
            completion(YES, nil);
        } else {
            NSString *errorStr = [[responseObject objectForKey:@"err"] objectForKey:@"message"];
            completion(NO, [responseObject objectForKey:errorStr]);
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        completion(NO, nil);
    }];

}

- (void)asyncResetPassword:(NSString *)newPassword tel:(NSString *)tel toke:(NSString *)token completion:(void (^)(BOOL, NSString *))completion
{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params safeSetObject:newPassword forKey:@"newPassword"];
    [params safeSetObject:token forKey:@"token"];
    [params safeSetObject:tel forKey:@"tel"];

    NSString *urlStr = [NSString stringWithFormat:@"%@_/password", API_USERS];

    //完成修改
    [LXPNetworking PUT:urlStr parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSInteger code = [[responseObject objectForKey:@"code"] integerValue];
        if (code == 0) {
            completion(YES, nil);
        } else {
            NSString *errorStr;
           
            errorStr = [[responseObject objectForKey:@"err"] objectForKey:@"message"];
            completion(NO, errorStr);
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        completion(NO, nil);
    }];
}

- (void)asyncChangePassword:(NSString *)newPassword oldPassword:(NSString *)oldPassword completion:(void (^)(BOOL, NSString *))completion
{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params safeSetObject:newPassword forKey:@"newPassword"];
    [params safeSetObject:oldPassword forKey:@"oldPassword"];
    
    NSString *urlStr = [NSString stringWithFormat:@"%@%ld/password", API_USERS, (long)self.account.userId];
    
    [LXPNetworking PUT:urlStr parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSInteger code = [[responseObject objectForKey:@"code"] integerValue];
        if (code == 0) {
            completion(YES, nil);
        } else {
            NSString *errorStr = [[responseObject objectForKey:@"err"] objectForKey:@"message"];
            completion(NO, [responseObject objectForKey:errorStr]);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        completion(NO, nil);
    }];
}

- (void)asyncChangeStatus:(NSString *)newStatus completion:(void (^)(BOOL, NSString *))completion
{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params safeSetObject:newStatus forKey:@"travelStatus"];
    NSString *urlStr = [NSString stringWithFormat:@"%@%ld", API_USERS, (long)self.account.userId];
    
    [LXPNetworking POST:urlStr parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSInteger code = [[responseObject objectForKey:@"code"] integerValue];
        if (code == 0) {
            self.account.travelStatus = newStatus;
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
            if ([changeContent isEqualToString:@"F"]) {
                self.account.gender = Female;
            } else if ([changeContent isEqualToString:@"M"]) {
                self.account.gender = Male;
            } else if ([changeContent isEqualToString:@"S"]) {
                self.account.gender = Secret;
            } else if ([changeContent isEqualToString:@"B"]) {
                self.account.gender = Unknown;
            }
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
}

/**
 *  修改用户足迹
 *
 *  @param action        add:添加   del:删除
 *  @param tracks        足迹 CityDestinationPoi
 */
- (void)asyncChangeUserServerTracks:(NSString *)action withTracks:(NSArray *)poiIdArray completion:(void (^)(BOOL, NSString *))completion
{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params safeSetObject:action forKey:@"action"];
    [params safeSetObject:poiIdArray forKey:@"tracks"];
    
    NSString *urlStr = [NSString stringWithFormat:@"%@users/%ld/footprints", BASE_URL, (long)[AccountManager shareAccountManager].account.userId];
    [LXPNetworking POST:urlStr parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSInteger code = [[responseObject objectForKey:@"code"] integerValue];
        if (code == 0) {
            completion(YES, nil);
        } else {
            completion(NO, nil);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        completion(NO, nil);

    }];
}

/**
 *  更新 account 里的 track 数据
 *
 *  @param action        add:添加   del:删除
 *  @param tracks
 */
- (void)updataUserLocalTracks:(NSString *)action withTrack:(CityDestinationPoi *)poi;
{
    if ([action isEqualToString:@"del"]) {
        for (CityDestinationPoi *city in _account.footprints) {
            if ([poi.cityId isEqualToString :city.cityId]) {
                [_account.footprints removeObject:city];
                break;
            }
        }
    } else {
        [_account.footprints addObject:poi];
    }
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
//        NSString *regex1 = @"^[\u4E00-\u9FA5|0-9a-zA-Z|_]{1,}$";
//        NSString *regex2 = @"^[0-9]$";
        
        // 纯数字的正则表达式
        NSString *regex2 = @"^-?\\d+";
//        NSPredicate *pred1 = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex1];
        NSPredicate *pred2 = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex2];
//        ![pred1 evaluateWithObject:userInfo] || [pred2 evaluateWithObject:userInfo
        if ([pred2 evaluateWithObject:userInfo]) {
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

#pragma mark - **********好友相关操作********

//从服务器上获取好友列表
- (void)loadContactsFromServer
{
    NSString *url = [NSString stringWithFormat:@"%@%ld/contacts", API_USERS, self.account.userId];
    NSLog(@"%@",url);
    [LXPNetworking GET:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
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

/**
 通过数据库里的数据判断用户是否是我的好友
 
 :param: userId
 
 :returns:
 */
- (BOOL)frendIsMyContact:(NSInteger)userId
{
    for (FrendModel *frend in _account.frendList) {
        if (frend.userId == userId) {
            return YES;
        }
    }
    return NO;
}

- (void)removeContact:(FrendModel *)frend
{
    for (FrendModel *model in self.account.frendList) {
        if (model.userId == frend.userId) {
            [self.account.frendList removeObject:model];
            return;
        }
    }
}

//解析好友列表，然后存到数据库里
- (void)analysisAndSaveContacts:(NSArray *)contactList
{
    NSLog(@"开始解析联系人");
    [self.account.frendList removeAllObjects];
    FrendManager *frendManager = [IMClientManager shareInstance].frendManager;
    // 删除所有的联系人
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
        [frendManager insertOrUpdateFrendInfoInDB:newContact];
        NSLog(@"往数据库里添加好友 %@", newContact.nickName);
        [self.account.frendList addObject:newContact];
    }

    NSLog(@"成功解析联系人");
}

#pragma mark - ********修改用户好友信息

- (void)asyncChangeRemark:(NSString *)remark withUserId:(NSInteger)userId completion:(void (^)(BOOL))completion
{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params safeSetObject:remark forKey:@"memo"];

    // 修改备注需要提供自己的userId和好友的userId
    AccountManager * accountManager = [AccountManager shareAccountManager];

    NSString *urlStr = [NSString stringWithFormat:@"%@%ld/contacts/%ld/memo", API_USERS, accountManager.account.userId,userId];
    NSLog(@"%@",urlStr);
    
    [LXPNetworking PUT:urlStr parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"result = %@", responseObject);
        NSInteger code = [[responseObject objectForKey:@"code"] integerValue];
        if (code == 0) {
            FrendManager *frendManager = [IMClientManager shareInstance].frendManager;
            [frendManager updateContactMemoInDB:remark userId:userId];
            [self updateFrendMemoInContactList:remark userId:userId];
            completion(YES);
        } else {
            completion(NO);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        completion(NO);
        NSLog(@"%@",error);
    }];

}

- (NSUInteger)numberOfUnReadFrendRequest
{
    NSUInteger ret = 0;
    for (FrendRequest *request in self.account.frendRequest) {
        if (request.status == 0) {
            ret++;
        }
    }
    return ret;
}

- (void)updateFrendMemoInContactList:(NSString *)memo userId:(NSInteger)userId
{
    for (FrendModel *frend in self.account.frendList) {
        if (frend.userId == userId) {
            frend.memo = memo;
            return;
        }
    }
}

#pragma mark - 将从服务器获得的好友列表转换成拼音排序的列表
- (NSDictionary *)contactsByPinyin
{
    // 定义一个数组存储排序后的拼音数组
    NSMutableArray *chineseStringsArray = [[NSMutableArray alloc] init];
    for (id tempContact in self.account.frendList) {
        [chineseStringsArray addObject:tempContact];
    }
    
    NSMutableArray *sectionHeadsKeys = [[NSMutableArray alloc] init];
    //sort the ChineseStringArr by pinYin
    NSArray *sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"fullPY" ascending:YES]];
    [chineseStringsArray sortUsingDescriptors:sortDescriptors];
    
    NSMutableArray *arrayForArrays = [[NSMutableArray alloc] init];
    BOOL checkValueAtIndex= NO;  //flag to check
    NSMutableArray *tempArrForGrouping = nil;
    for(int index = 0; index < [chineseStringsArray count]; index++)
    {
        FrendModel *contact = (FrendModel *)[chineseStringsArray objectAtIndex:index];
        NSString *pingyin;
        
        if (contact.memo && ![contact.memo isEqualToString:@""]) {
            pingyin = [ConvertMethods chineseToPinyin:contact.memo];
            
        } else if (!contact.fullPY || [contact.fullPY isEqualToString: @""]) {
            pingyin = [ConvertMethods chineseToPinyin:contact.nickName];
        } else {
            pingyin = contact.fullPY;
        }
        NSMutableString *strchar= [NSMutableString stringWithString:pingyin];
        NSString *sr= [strchar substringToIndex:1];
        if(![sectionHeadsKeys containsObject:[sr uppercaseString]]) {
            [sectionHeadsKeys addObject:[sr uppercaseString]];
//            tempArrForGrouping = [[NSMutableArray alloc] initWithObjects:nil];
            tempArrForGrouping = [[NSMutableArray alloc] init];
            checkValueAtIndex = NO;
        }
        if([sectionHeadsKeys containsObject:[sr uppercaseString]])
        {
            [tempArrForGrouping addObject:[chineseStringsArray objectAtIndex:index]];
            if(checkValueAtIndex == NO)
            {
                [arrayForArrays addObject:tempArrForGrouping];
                checkValueAtIndex = YES;
            }
        }
    }
    return @{@"headerKeys":sectionHeadsKeys, @"content":arrayForArrays};
}

@end

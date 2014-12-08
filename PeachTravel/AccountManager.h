//
//  AccountManager.h
//  PeachTravel
//
//  Created by liangpengshuai on 14/10/13.
//  Copyright (c) 2014年 com.aizou.www. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Account.h"
#import "Contact.h"
#import "FrendRequest.h"

@interface AccountManager : NSObject

@property (nonatomic, strong) Account *account;

+ (AccountManager *)shareAccountManager;

- (BOOL)isLogin;

- (void)userDidLoginWithUserInfo:(id)userInfo;
- (void)easeMobDidLogin;
- (void)easeMobUnlogin;
- (void)logout;
- (BOOL)accountIsBindTel;    //账户是否绑定了手机号，返回 yes 是绑定了

/**
 *  登录环信服务器
 */
- (void)loginEaseMobServer;

- (void)loginEaseMobServer:(void (^)(BOOL isSuccess))completion;

/**
 *  修改用户信息
 *
 *  @param changeContent 信息内容
 *  @param changeType    信息类型，电话，签名等
 */
- (void)updateUserInfo:(NSString *)changeContent withChangeType:(UserInfoChangeType)changeType;

- (BOOL)isMyFrend:(NSNumber *)userId;       //判读是不是我的好友

//将好友加入到数据库当中
- (void)addContact:(id)userInfo;

/**
 *  从服务器上加载好友列表
 */
- (void)loadContactsFromServer;

//得到按照拼音区分的联系人列表，是以组的形式展现
- (NSDictionary *)contactsByPinyin;

//解析好友申请
- (void)analysisAndSaveFrendRequest:(NSDictionary *)frendRequestDic;

//移除好友申请
- (void)removeFrendRequest:(FrendRequest *)frendRequest;

//同意好友申请
- (void)agreeFrendRequest:(FrendRequest *)frendRequest;

//更新好友列表
- (void)updateContact;

//通过环信 id 删除好友
- (void)removeContact:(NSNumber *)userId;

//通过环信 id 获取桃子用户信息
- (Contact *)TZContactByEasemobUser:(NSString *)easemobUser;


#pragma mark *******群组相关信息******
- (Group *)groupWithGroupId:(NSString *)groupId;

- (Group *)updateGroup:(NSString *)groupId
        withGroupOwner:(NSString *)owner
          groupSubject:(NSString *)subject
             groupInfo:(NSString *)groupDescription
               numbers:(id)numbersDic;

- (void)addNumberToGroup:(NSString *)groupId
                 numbers:(NSSet *)numbers;

- (void)removeNumberToGroup:(NSString *)groupId
                 numbers:(NSSet *)numbers;


#pragma mark *****其他操作******

/**
 *  返回未读的好友请求的数量
 *
 *  @return 
 */
- (NSUInteger)numberOfUnReadFrendRequest;


@end

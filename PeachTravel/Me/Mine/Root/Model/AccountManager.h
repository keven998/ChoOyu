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

/**
 *  用户是否登录
 *
 *  @return
 */
- (BOOL)isLogin;

/**
 *  用户桃子系统登录成功
 *
 *  @param userInfo
 */
- (void)userDidLoginWithUserInfo:(id)userInfo;

/**
 *  环信系统已经登录成功
 */
- (void)easeMobDidLogin;

/**
 *  环信系统登录失败
 */
- (void)easeMobUnlogin;

/**
 *  异步退出登录
 */
- (void)asyncLogout:(void(^)(BOOL isSuccess))completion;

/**
 *  账户是否绑定了手机号，返回 yes 是绑定了
 *
 *  @return
 */
- (BOOL)accountIsBindTel;

/**
 *  登录环信服务器
 */
- (void)loginEaseMobServer;

- (void)loginEaseMobServer:(void (^)(BOOL isSuccess))completion;


/*******用户信息相关接口********/

/**
 *  修改用户信息
 *
 *  @param changeContent 信息内容
 *  @param changeType    信息类型，电话，签名等
 */
- (void)updateUserInfo:(NSString *)changeContent withChangeType:(UserInfoChangeType)changeType;

/**
 *  修改用户昵称
 *
 *  @param newUsername 新的用户昵称
 */
- (void)asyncChangeUserName:(NSString *)newUsername completion:(void (^)(BOOL isSuccess, UserInfoInputError error, NSString *errStr))completion;

/**
 *  修改用户签名
 *
 *  @param newSignature 新签名
 */

- (void)asyncChangeSignature:(NSString *)newSignature completion:(void (^)(BOOL isSuccess, UserInfoInputError error, NSString *errStr))completion;

/**
 *  修改用户居住地信息
 *
 *  @param location   居住地信息
 *  @param completion
 */
- (void)asyncChangeLocation:(NSString *)location completion:(void (^)(BOOL isSuccess, NSString *errStr))completion;




/**
 *  判读是不是我的好友
 *
 *  @param userId
 *
 *  @return
 */
- (BOOL)isMyFrend:(NSNumber *)userId;

/**
 *  将好友加入到数据库当中
 *
 *  @param userInfo
 */
- (void)addContact:(id)userInfo;

/**
 *  从服务器上加载好友列表
 */
- (void)loadContactsFromServer;

/**
 *  得到按照拼音区分的联系人列表，是以组的形式展现
 *
 *  @return
 */
- (NSDictionary *)contactsByPinyin;

/**
 *  解析好友申请
 *
 *  @param frendRequestDic
 */
- (void)analysisAndSaveFrendRequest:(NSDictionary *)frendRequestDic;

/**
 *  移除好友申请
 *
 *  @param frendRequest
 */
- (void)removeFrendRequest:(FrendRequest *)frendRequest;

/**
 *  同意好友申请
 *
 *  @param frendRequest
 */
- (void)agreeFrendRequest:(FrendRequest *)frendRequest;

/**
 *  更新好友列表
 */
- (void)updateContact;

/**
 *  通过环信 id 删除好友
 *
 *  @param userId
 */
- (void)removeContact:(NSNumber *)userId;

/**
 *  通过环信 id 获取桃子用户信息
 *
 *  @param easemobUser
 *
 *  @return
 */
- (Contact *)TZContactByEasemobUser:(NSString *)easemobUser;


#pragma mark *******群组相关信息******

/**
 *  通过群组 id 得到去租信息
 *
 *  @param groupId
 *
 *  @return
 */
- (Group *)groupWithGroupId:(NSString *)groupId;

- (Group *)updateGroup:(NSString *)groupId
        withGroupOwner:(NSString *)owner
          groupSubject:(NSString *)subject
             groupInfo:(NSString *)groupDescription
               numbers:(id)numbersDic;

/**
 *  更新群组信息,如果未存在则创建一个群组
 *
 *  @param groupId          群组 id
 *  @param owner            群组所有人
 *  @param subject          群组标题
 *  @param groupDescription 群组介绍
 *
 *  @return 更新后的群组
 */
- (Group *)updateGroup:(NSString *)groupId
        withGroupOwner:(NSString *)owner
          groupSubject:(NSString *)subject
             groupInfo:(NSString *)groupDescription;

/**
 *  添加一个成员到群组里
 *
 *  @param groupId
 *  @param numbers
 */
- (void)addNumberToGroup:(NSString *)groupId
                 numbers:(NSSet *)numbers;

/**
 *  从移除一个成员
 *
 *  @param groupId
 *  @param numbers
 */
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

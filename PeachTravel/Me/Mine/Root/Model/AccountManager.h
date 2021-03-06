//
//  AccountManager.h
//  PeachTravel
//
//  Created by liangpengshuai on 14/10/13.
//  Copyright (c) 2014年 com.aizou.www. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FrendRequest.h"
#import "AccountModel.h"

@class FrendModel;
@class CityDestinationPoi;

@interface AccountManager : NSObject

@property (nonatomic, strong) AccountModel *account;

+ (AccountManager *)shareAccountManager;

/**
 *  用户是否登录
 *
 *  @return
 */
- (BOOL)isLogin;

/**
 *  用户旅行派系统登录成功
 *
 *  @param userInfo
 */
- (void)asyncLogin:(NSString *)userId password:(NSString *)password completion:(void(^)(BOOL isSuccess, NSString *errorStr))completion;

/**
 *  微信登录
 *
 *  @param code
 *  @param completion 
 */
- (void)asyncLoginWithWeChat:(NSString *)code completion:(void(^)(BOOL isSuccess, NSString *errorStr))completion;

/**
 *  异步退出登录
 */
- (void)asyncLogout:(void(^)(BOOL isSuccess))completion;

- (void)userDidLoginWithUserInfo:(id)userInfo;

/**
 *  账户是否绑定了手机号，返回 yes 是绑定了
 *
 *  @return
 */
- (BOOL)accountIsBindTel;

/*******用户信息相关接口********/

- (void)asyncChangePassword:(NSString *)newPassword oldPassword:(NSString *)oldPassword completion:(void (^)(BOOL, NSString *))completion;

- (void)asyncBindTelephone:(NSString *)tel token:(NSString *)token completion:(void (^)(BOOL, NSString *))completion;

- (void)asyncResetPassword:(NSString *)newPassword tel:(NSString *)tel toke:(NSString *)token completion:(void (^)(BOOL, NSString *))completion;

/**
 *  修改用户信息
 *
 *  @param changeContent 信息内容
 *  @param changeType    信息类型，电话，签名等
 */
- (void)updateUserInfo:(NSString *)changeContent withChangeType:(UserInfoChangeType)changeType;

/**
 *  修改用户足迹
 *
 *  @param action        add:添加   del:删除
 *  @param tracks        足迹 @[poiid]
 */
- (void)asyncChangeUserServerTracks:(NSString *)action withTracks:(NSArray *)poiIdArray completion:(void (^)(BOOL, NSString *))completion;
/**
 *  修改用户名字
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
 *  @param residence   居住地信息
 *  @param completion
 */
- (void)asyncChangeResidence:(NSString *)residence completion:(void (^)(BOOL isSuccess, NSString *errStr))completion;

/**
 *  修改用户的性别
 *
 *  @param newGender  新的性别
 *  @param completion
 */
- (void)asyncChangeGender:(NSString *)newGender completion:(void (^)(BOOL isSuccess, NSString *errStr))completion;
/**
 *  修改用户的状态
 *
 *  @param newStatus  新的状态
 *  @param completion
 */
- (void)asyncChangeStatus:(NSString *)newStatus completion:(void (^)(BOOL isSuccess, NSString *errStr))completion;
/**
 *  修改用户的生日
 *
 *  @param newGender  新的生日
 *  @param completion
 */
- (void)asyncChangeBirthday:(NSString *)birthday completion:(void (^)(BOOL isSuccess, NSString *errStr))completion;

/**
 *  修改用户头像
 *
 *  @param albumImage
 *  @param completion 
 */
- (void)asyncChangeUserAvatar:(AlbumImage *)albumImage completion:(void (^)(BOOL, NSString *))completion;


/**
 *  删除用户相册里的某一张图片
 *
 *  @param albumImage
 *  @param completion 
 */
- (void)asyncDelegateUserAlbumImage:(AlbumImage *)albumImage completion:(void (^)(BOOL, NSString *))completion;


#pragma mark - 修改用户的好友信息

- (void)asyncChangeRemark:(NSString *)remark withUserId:(NSInteger)userId completion:(void (^)(BOOL isSuccess))completion;

/**
 *  判读是不是我的好友
 *
 *  @param userId
 *
 *  @return
 */
- (BOOL)frendIsMyContact:(NSInteger)userId;


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
 *  删除好友
 *
 *  @param userId
 */
- (void)removeContact:(FrendModel *)userId;


/**
 *  异步加载用户相册
 *
 *  @param userId     用户Id
 *  @param completion 完成后回调
 *
 *  @return 
 */
- (NSArray *)asyncLoadUserAlbum:(NSInteger)userId completion:(void (^)(BOOL, NSString *))completion;

@end

//
//  AccountModel.h
//  PeachTravel
//
//  Created by liangpengshuai on 4/1/15.
//  Copyright (c) 2015 com.aizou.www. All rights reserved.
//
//******用来保存从网络上加载的用户信息，只是临时存放的,不写入数据库的信息******/

#import <Foundation/Foundation.h>
typedef NS_ENUM(NSInteger, UserGender) {
    Secret = 1,
    Male,
    Female,
    Unknown
};
@interface AlbumImage : NSObject

@property (nonatomic, copy) NSString *imageId;
@property (nonatomic, strong) TaoziImage *image;
@property (nonatomic) long createTime;

- (id)initWithJson: (id)json;

@end

@interface AccountModel : NSObject

@property (nonatomic) NSInteger userId;
@property (nonatomic, strong) NSString * avatar;
@property (nonatomic, strong) NSString * avatarSmall;
@property (nonatomic) UserGender  gender;
@property (nonatomic, strong) NSString * nickName;
@property (nonatomic, strong) NSString * secToken;
@property (nonatomic, strong) NSString * signature;
@property (nonatomic, strong) NSString * tel;
@property (nonatomic, strong) NSMutableArray *frendRequest;

/**
 *  存在数据库里的用户基本信息,因此，从网上获取到用户新的数据后必须先更新数据库在读取
 */
//@property (nonatomic, strong) Account *basicUserInfo;

/**
 *  好友列表
 */
@property (nonatomic, strong) NSMutableArray *frendList;

/**
 *  用户居住地
 */
@property (nonatomic, copy) NSString *residence;
@property (nonatomic) NSInteger guideCnt;
@property (nonatomic, copy) NSString *birthday;
@property (nonatomic, copy) NSString *zodiac;
@property (nonatomic, copy) NSString *travelStatus;
@property (nonatomic, strong) NSMutableDictionary *tracks;

/**
 *  用户的图集
 */
@property (nonatomic, strong) NSArray *userAlbum;

- (id)initWithJson: (id)json;

- (void)loadUserInfoFromServer:(void (^)(bool isSuccess))completion;


@end

//
//  AccountModel.h
//  PeachTravel
//
//  Created by liangpengshuai on 4/1/15.
//  Copyright (c) 2015 com.aizou.www. All rights reserved.
//
//******用来保存从网络上加载的用户信息，只是临时存放的,不写入数据库的信息******/

#import <Foundation/Foundation.h>
#import "Account.h"

@interface AccountModel : NSObject

/**
 *  存在数据库里的用户基本信息,因此，从网上获取到用户新的数据后必须先更新数据库在读取
 */
@property (nonatomic, strong) Account *basicUserInfo;

- (void)loadUserInfoFromServer:(void (^)(bool isSuccess))completion;

/**
 *  用户居住地
 */
@property (nonatomic, copy) NSString *residence;

@property (nonatomic, copy) NSString *birthday;
@property (nonatomic, copy) NSString *zodiac;


@end
//
//  AccountBean.h
//  lvxingpai
//
//  Created by Luo Yong on 14-7-23.
//  Copyright (c) 2014年 aizou. All rights reserved.
//

#import <Foundation/Foundation.h>

enum ACCOUNT_TYPE {
    QQ = 1,
    WEIBO
};

@interface AccountBean : NSObject<NSCoding>

@property (nonatomic) NSInteger userId;
@property (nonatomic, copy) NSString *nickName;
@property (nonatomic, copy) NSString *avatar;
@property (nonatomic, copy) NSString *gender;
@property (nonatomic, copy) NSString *tel;
@property (nonatomic, copy) NSString *secToken;
@property (nonatomic, copy) NSString *signature;

- (id)initWithJson:(id)json;

@end

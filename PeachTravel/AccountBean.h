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

@property (nonatomic, copy) NSString *uid;
@property (nonatomic, copy) NSString *uname;
@property (nonatomic, copy) NSString *avatar;
@property (nonatomic, copy) NSString *gender;
@property (nonatomic, assign) int accountType;
@property (nonatomic, copy) NSString *platformToken;

@end

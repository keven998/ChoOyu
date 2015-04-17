//
//  UserProfile.h
//  PeachTravel
//
//  Created by Luo Yong on 15/4/17.
//  Copyright (c) 2015年 com.aizou.www. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserProfile : NSObject

@property (nonatomic, copy) NSString *avatarUrl;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *userId;
@property (nonatomic, copy) NSString *gender;
@property (nonatomic, copy) NSString *residence;
@property (nonatomic, assign) NSInteger level;
@property (nonatomic, copy) NSString *signature;
@property (nonatomic, copy) NSString *roles;

- (id) initWithJsonObject:(id)json;

@end

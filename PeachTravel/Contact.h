//
//  Contact.h
//  PeachTravel
//
//  Created by liangpengshuai on 14/11/6.
//  Copyright (c) 2014年 com.aizou.www. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Account, Group;

@interface Contact : NSManagedObject

@property (nonatomic, retain) NSString * avatar;
@property (nonatomic, retain) NSString * easemobUser;
@property (nonatomic, retain) NSString * gender;
@property (nonatomic, retain) NSString * memo;
@property (nonatomic, retain) NSString * nickName;
@property (nonatomic, retain) NSString * pinyin;
@property (nonatomic, retain) NSNumber * userId;
@property (nonatomic, retain) NSString * signature;
@property (nonatomic, retain) Account *relationship;
@property (nonatomic, retain) Account *relationship1;
@property (nonatomic, retain) Group *relationship2;

@end

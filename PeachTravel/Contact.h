//
//  Contact.h
//  PeachTravel
//
//  Created by liangpengshuai on 14/10/23.
//  Copyright (c) 2014年 com.aizou.www. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Account;

@interface Contact : NSManagedObject

@property (nonatomic, retain) NSString * userId;
@property (nonatomic, retain) NSString * userName;
@property (nonatomic, retain) NSString * avatar;
@property (nonatomic, retain) NSString * sex;
@property (nonatomic, retain) NSString * pinyin;
@property (nonatomic, retain) NSString * remark;
@property (nonatomic, retain) NSString * easemobUser;
@property (nonatomic, retain) Account *relationship;
@property (nonatomic, retain) Account *relationship1;

@end

//
//  FrendRequest.h
//  PeachTravel
//
//  Created by liangpengshuai on 2/3/15.
//  Copyright (c) 2015 com.aizou.www. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Account;

@interface FrendRequest : NSManagedObject

@property (nonatomic, retain) NSString * attachMsg;
@property (nonatomic, retain) NSString * avatar;
@property (nonatomic, retain) NSString * easemobUser;
@property (nonatomic, retain) NSString * gender;
@property (nonatomic, retain) NSString * nickName;
@property (nonatomic, retain) NSNumber * requestDate;
@property (nonatomic, retain) NSNumber * status;
@property (nonatomic, retain) NSNumber * userId;
@property (nonatomic, retain) NSString * avatarSmall;
@property (nonatomic, retain) Account *relationship;

@end

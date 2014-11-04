//
//  FrendRequest.h
//  PeachTravel
//
//  Created by liangpengshuai on 14/11/1.
//  Copyright (c) 2014年 com.aizou.www. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Account;

@interface FrendRequest : NSManagedObject

@property (nonatomic, retain) NSNumber * userId;
@property (nonatomic, retain) NSNumber * status;        //好友申请的状态，0未做任何操作，1同意，2拒绝
@property (nonatomic, retain) NSNumber * requestDate;  
@property (nonatomic, retain) NSString * nickName;
@property (nonatomic, retain) NSString * easemobUser;
@property (nonatomic, retain) NSString * gender;
@property (nonatomic, retain) NSString * avatar;
@property (nonatomic, retain) NSString * attachMsg;
@property (nonatomic, retain) Account *relationship;

@end

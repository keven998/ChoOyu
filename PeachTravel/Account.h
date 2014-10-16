//
//  Account.h
//  PeachTravel
//
//  Created by liangpengshuai on 14/10/16.
//  Copyright (c) 2014年 com.aizou.www. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Account : NSManagedObject

@property (nonatomic, retain) NSNumber * userId;
@property (nonatomic, retain) NSString * nickName;
@property (nonatomic, retain) NSString * avatar;
@property (nonatomic, retain) NSString * gender;
@property (nonatomic, retain) NSString * tel;
@property (nonatomic, retain) NSString * secToken;
@property (nonatomic, retain) NSString * signature;

@end

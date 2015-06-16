//
//  Account.h
//  PeachTravel
//
//  Created by liangpengshuai on 6/16/15.
//  Copyright (c) 2015 com.aizou.www. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class FrendRequest;

@interface Account : NSManagedObject

@property (nonatomic, retain) NSString * avatar;
@property (nonatomic, retain) NSString * avatarSmall;
@property (nonatomic, retain) NSString * gender;
@property (nonatomic, retain) NSString * nickName;
@property (nonatomic, retain) NSString * secToken;
@property (nonatomic, retain) NSString * signature;
@property (nonatomic, retain) NSString * tel;
@property (nonatomic, retain) NSNumber * userId;
@property (nonatomic, retain) NSSet *frendRequest;
@end

@interface Account (CoreDataGeneratedAccessors)

@property (nonatomic, strong) NSArray *contacts;

- (void)addFrendRequestObject:(FrendRequest *)value;
- (void)removeFrendRequestObject:(FrendRequest *)value;
- (void)addFrendRequest:(NSSet *)values;
- (void)removeFrendRequest:(NSSet *)values;

@end

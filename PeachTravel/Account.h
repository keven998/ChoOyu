//
//  Account.h
//  PeachTravel
//
//  Created by liangpengshuai on 14/10/23.
//  Copyright (c) 2014年 com.aizou.www. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Contact;

@interface Account : NSManagedObject

@property (nonatomic, retain) NSString * avatar;
@property (nonatomic, retain) NSString * gender;
@property (nonatomic, retain) NSString * nickName;
@property (nonatomic, retain) NSString * secToken;
@property (nonatomic, retain) NSString * signature;
@property (nonatomic, retain) NSString * tel;
@property (nonatomic, retain) NSNumber * userId;
@property (nonatomic, retain) NSString * easemobUser;
@property (nonatomic, retain) NSString * easemobPwd;
@property (nonatomic, retain) NSSet *contacts;
@property (nonatomic, retain) NSSet *blacklist;
@end

@interface Account (CoreDataGeneratedAccessors)

- (void)addContactsObject:(Contact *)value;
- (void)removeContactsObject:(Contact *)value;
- (void)addContacts:(NSSet *)values;
- (void)removeContacts:(NSSet *)values;

- (void)addBlacklistObject:(Contact *)value;
- (void)removeBlacklistObject:(Contact *)value;
- (void)addBlacklist:(NSSet *)values;
- (void)removeBlacklist:(NSSet *)values;

@end

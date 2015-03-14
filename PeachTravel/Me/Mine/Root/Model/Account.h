//
//  Account.h
//  PeachTravel
//
//  Created by liangpengshuai on 2/3/15.
//  Copyright (c) 2015 com.aizou.www. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Contact, FrendRequest, Group;

@interface Account : NSManagedObject

@property (nonatomic, retain) NSString * avatar;
@property (nonatomic, retain) NSString * easemobPwd;
@property (nonatomic, retain) NSString * easemobUser;
@property (nonatomic, retain) NSString * gender;
@property (nonatomic, retain) NSString * nickName;
@property (nonatomic, retain) NSString * secToken;
@property (nonatomic, retain) NSString * signature;
@property (nonatomic, retain) NSString * tel;
@property (nonatomic, retain) NSNumber * userId;
@property (nonatomic, retain) NSString * avatarSmall;
@property (nonatomic, retain) NSSet *blacklist;
@property (nonatomic, retain) NSSet *contacts;
@property (nonatomic, retain) NSSet *frendrequestlist;
@property (nonatomic, retain) NSSet *groupList;
@end

@interface Account (CoreDataGeneratedAccessors)

- (void)addBlacklistObject:(Contact *)value;
- (void)removeBlacklistObject:(Contact *)value;
- (void)addBlacklist:(NSSet *)values;
- (void)removeBlacklist:(NSSet *)values;

- (void)addContactsObject:(Contact *)value;
- (void)removeContactsObject:(Contact *)value;
- (void)addContacts:(NSSet *)values;
- (void)removeContacts:(NSSet *)values;

- (void)addFrendrequestlistObject:(FrendRequest *)value;
- (void)removeFrendrequestlistObject:(FrendRequest *)value;
- (void)addFrendrequestlist:(NSSet *)values;
- (void)removeFrendrequestlist:(NSSet *)values;

- (void)addGroupListObject:(Group *)value;
- (void)removeGroupListObject:(Group *)value;
- (void)addGroupList:(NSSet *)values;
- (void)removeGroupList:(NSSet *)values;

@end

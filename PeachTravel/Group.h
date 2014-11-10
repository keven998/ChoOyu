//
//  Group.h
//  PeachTravel
//
//  Created by liangpengshuai on 14/11/6.
//  Copyright (c) 2014年 com.aizou.www. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Account, Contact;

@interface Group : NSManagedObject

@property (nonatomic, retain) NSString * groupId;
@property (nonatomic, retain) NSString * groupDescription;
@property (nonatomic, retain) NSString * owner;
@property (nonatomic, retain) NSString * groupSubject;
@property (nonatomic, retain) NSSet *numbers;
@property (nonatomic, retain) Account *relationship;
@end

@interface Group (CoreDataGeneratedAccessors)

- (void)addNumbersObject:(Contact *)value;
- (void)removeNumbersObject:(Contact *)value;
- (void)addNumbers:(NSSet *)values;
- (void)removeNumbers:(NSSet *)values;

@end

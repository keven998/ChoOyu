//
//  ApplyEntity.h
//  PeachTravel
//
//  Created by liangpengshuai on 14/10/21.
//  Copyright (c) 2014年 com.aizou.www. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface ApplyEntity : NSManagedObject

@property (nonatomic, retain) NSString * applicantNick;
@property (nonatomic, retain) NSString * applicantUsername;
@property (nonatomic, retain) NSString * groupId;
@property (nonatomic, retain) NSString * groupSubject;
@property (nonatomic, retain) NSString * reason;
@property (nonatomic, retain) NSString * receiverNick;
@property (nonatomic, retain) NSString * receiverUsername;
@property (nonatomic, retain) NSNumber * style;

@end

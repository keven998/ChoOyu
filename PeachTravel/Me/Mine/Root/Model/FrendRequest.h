//
//  FrendRequest.h
//  PeachTravel
//
//  Created by liangpengshuai on 6/16/15.
//  Copyright (c) 2015 com.aizou.www. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FrendRequest : NSObject

@property (nonatomic, copy) NSString * attachMsg;
@property (nonatomic, copy) NSString * avatar;
@property (nonatomic, copy) NSString * gender;
@property (nonatomic, copy) NSString * nickName;
@property (nonatomic) double requestDate;
@property (nonatomic) TZFrendRequest status;
@property (nonatomic) NSInteger userId;

@end

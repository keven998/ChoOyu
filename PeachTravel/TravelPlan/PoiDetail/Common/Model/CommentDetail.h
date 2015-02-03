//
//  CommentDetail.h
//  PeachTravel
//
//  Created by liangpengshuai on 11/22/14.
//  Copyright (c) 2014 com.aizou.www. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CommentDetail : NSObject

@property (nonatomic, copy) NSString *avatar;
@property (nonatomic, copy) NSString *nickName;
@property (nonatomic) CGFloat rating;
@property (nonatomic, copy) NSString *commentDetails;
@property (nonatomic, copy) NSString *commentTime;
@property (nonatomic) long long commentLongTime;

- (id)initWithJson:(id)json;

- (id)enCodeToJson;

@end

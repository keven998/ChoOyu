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
@property (nonatomic, copy) NSString *commentDetails;
@property (nonatomic, copy) NSString *commentTime;

- (id)initWithJson:(id)json;

@end

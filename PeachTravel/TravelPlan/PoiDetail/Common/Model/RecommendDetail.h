//
//  RecommendDetail.h
//  PeachTravel
//
//  Created by liangpengshuai on 11/22/14.
//  Copyright (c) 2014 com.aizou.www. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RecommendDetail : NSObject

@property (nonatomic, copy) NSString *title;
@property (nonatomic, strong) NSArray *images;

- (id)initWithJson:(id)json;

- (id)enCodeToJson;

@end

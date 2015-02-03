//
//  RecommendsOfCity.h
//  PeachTravel
//
//  Created by liangpengshuai on 11/25/14.
//  Copyright (c) 2014 com.aizou.www. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RecommendsOfCity : NSObject

@property (nonatomic, copy) NSString *cityId;
@property (nonatomic, copy) NSString *zhName;
@property (nonatomic, copy) NSString *enName;
@property (nonatomic, copy) NSString *desc;
@property (nonatomic, strong) NSArray *images;
@property (nonatomic, strong) NSMutableArray *recommendList;
@property (nonatomic) float rating;

- (id)initWithJson:(id)json;

- (void)addRecommendList:(id)json;


@end

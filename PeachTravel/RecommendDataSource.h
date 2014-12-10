//
//  RecommendDataSource.h
//  PeachTravel
//
//  Created by liangpengshuai on 11/13/14.
//  Copyright (c) 2014 com.aizou.www. All rights reserved.
//

#import "SuperPoi.h"

typedef enum : NSUInteger {
    LinkNative = 1,
    LinkHtml,
    
} LinkType;

@interface RecommendDataSource : NSObject

@property (nonatomic, strong) id json;

@property (nonatomic, strong) NSString *typeName;
@property (nonatomic, strong) NSArray *localities;

- (id) initWithJsonData:(id)data;

@end


@interface Recommend : NSObject

@property (nonatomic, strong) NSString * recommondId;
@property (nonatomic, strong) NSString * zhName;
@property (nonatomic, strong) NSString * enName;
@property (nonatomic, strong) NSString * desc;
@property (nonatomic, strong) NSString * linkUrl;
@property (nonatomic) LinkType linkType;
@property (nonatomic, strong) NSString * cover;

- (id) initWithJsonData:(id)data;

@end

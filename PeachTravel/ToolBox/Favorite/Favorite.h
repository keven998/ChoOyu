//
//  Favorite.h
//  PeachTravel
//
//  Created by liangpengshuai on 12/4/14.
//  Copyright (c) 2014 com.aizou.www. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Favorite : NSObject

@property (nonatomic, copy) NSString *favoriteId;
@property (nonatomic, copy) NSString *itemId;
@property (nonatomic, copy) NSString *type;
@property (nonatomic, copy) NSString *zhName;
@property (nonatomic, copy) NSString *enName;
@property (nonatomic, strong) NSArray *images;
@property (nonatomic) long long createTime;

- (id)initWithJson:(id)json;

@end

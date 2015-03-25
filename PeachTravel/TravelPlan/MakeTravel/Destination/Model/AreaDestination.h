//
//  AreaDestination.h
//  PeachTravel
//
//  Created by liangpengshuai on 3/25/15.
//  Copyright (c) 2015 com.aizou.www. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AreaDestination : NSObject

@property (nonatomic, copy) NSString *areaId;
@property (nonatomic, copy) NSString *zhName;
@property (nonatomic, copy) NSString *enName;
@property (nonatomic, strong) NSArray *cities;
@property (nonatomic, copy) NSString *desc;
@property (nonatomic, strong) NSArray *images;

- (id)initWithJson:(id)json;

@end

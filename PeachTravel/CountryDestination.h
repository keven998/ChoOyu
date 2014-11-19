//
//  CountryDestination.h
//  PeachTravel
//
//  Created by liangpengshuai on 11/18/14.
//  Copyright (c) 2014 com.aizou.www. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CountryDestination : NSObject

@property (nonatomic, copy) NSString *countryId;
@property (nonatomic, copy) NSString *zhName;
@property (nonatomic, copy) NSString *enName;
@property (nonatomic, strong) NSArray *cities;
@property (nonatomic, copy) NSString *desc;
@property (nonatomic, strong) NSArray *images;

- (id) initWithJson:(id)json;
@end

//
//  CityDestinationPoi.h
//  PeachTravel
//
//  Created by liangpengshuai on 11/18/14.
//  Copyright (c) 2014 com.aizou.www. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CityDestinationPoi : NSObject

@property (nonatomic, copy) NSString *cityId;
@property (nonatomic, copy) NSString *zhName;
@property (nonatomic, copy) NSString *enName;
@property (nonatomic, copy) NSString *pinyin;
@property (nonatomic) float lat;
@property (nonatomic) float lng;
@property (nonatomic, strong) NSArray *images;
- (id)initWithJson:(id)json;

@end

//
//  Destinations.h
//  PeachTravelDemo
//
//  Created by liangpengshuai on 14/9/23.
//  Copyright (c) 2014年 com.aizou.www. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Destinations : NSObject

@property (nonatomic, strong) NSMutableArray *domesticCities;
@property (nonatomic, strong) NSMutableArray *foreignCountries;
@property (nonatomic, strong) NSMutableArray *destinationsSelected;

- (void)initDomesticCitiesWithJson:(id)json;
- (void)initForeignCountriesWithJson:(id)json;

- (NSDictionary *)destinationsGroupByPin;

@end

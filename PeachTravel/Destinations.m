//  Destinations.m
//  PeachTravelDemo
//
//  Created by liangpengshuai on 14/9/23.
//  Copyright (c) 2014年 com.aizou.www. All rights reserved.
//
/*
 *保存目的地界面所有目的地数据
 */

#import "Destinations.h"
#import "CityDestinationPoi.h"
#import "CountryDestination.h"

@implementation Destinations

- (void)initDomesticCitiesWithJson:(id)json
{
    if (!_domesticCities) {
        _domesticCities = [[NSMutableArray alloc] init];
    }
    for (id cityDic in json) {
        CityDestinationPoi *cityPoi = [[CityDestinationPoi alloc] initWithJson:cityDic];
        [_domesticCities addObject:cityPoi];
    }
}

- (void)initForeignCountriesWithJson:(id)json
{
    if (!_foreignCountries) {
        _foreignCountries = [[NSMutableArray alloc] init];
    }
    for (id CountryDic in json) {
        CountryDestination *country = [[CountryDestination alloc] initWithJson:CountryDic];
        [_foreignCountries addObject:country];
    }
}

- (NSMutableArray *)destinationsSelected
{
    if (!_destinationsSelected) {
        _destinationsSelected = [[NSMutableArray alloc] init];
    }
    return _destinationsSelected;
}
@end
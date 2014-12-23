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

- (NSDictionary *)destinationsGroupByPin
{
    NSMutableArray *chineseStringsArray = [[NSMutableArray alloc] init];
    for (id tempCity in self.domesticCities) {
        [chineseStringsArray addObject:tempCity];
    }
    NSMutableArray *sectionHeadsKeys = [[NSMutableArray alloc] init];
    //sort the ChineseStringArr by pinYin
    NSArray *sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"pinyin" ascending:YES]];
    [chineseStringsArray sortUsingDescriptors:sortDescriptors];
    
    NSMutableArray *arrayForArrays = [NSMutableArray array];
    BOOL checkValueAtIndex= NO;  //flag to check
    NSMutableArray *TempArrForGrouping = nil;
    
    for(int index = 0; index < [chineseStringsArray count]; index++)
    {
        CityDestinationPoi *city = (CityDestinationPoi *)[chineseStringsArray objectAtIndex:index];
        NSMutableString *strchar= [NSMutableString stringWithString:city.pinyin];
        NSString *sr= [strchar substringToIndex:1];
        if(![sectionHeadsKeys containsObject:[sr uppercaseString]])//here I'm checking whether the character already in the selection header keys or not
        {
            [sectionHeadsKeys addObject:[sr uppercaseString]];
            TempArrForGrouping = [[NSMutableArray alloc] initWithObjects:nil];
            checkValueAtIndex = NO;
        }
        if([sectionHeadsKeys containsObject:[sr uppercaseString]])
        {
            [TempArrForGrouping addObject:[chineseStringsArray objectAtIndex:index]];
            if(checkValueAtIndex == NO)
            {
                [arrayForArrays addObject:TempArrForGrouping];
                checkValueAtIndex = YES;
            }
        }
    }
    return @{@"headerKeys":sectionHeadsKeys, @"content":arrayForArrays};
}

@end



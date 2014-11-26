
//
//  TripDetail.m
//  PeachTravel
//
//  Created by liangpengshuai on 11/26/14.
//  Copyright (c) 2014 com.aizou.www. All rights reserved.
//

#import "TripDetail.h"
#import "CityDestinationPoi.h"

@implementation TripDetail

- (id)initWithJson:(id)json
{
    _backUpJson = json;
    _tripId = [json objectForKey:@"id"];
    _tripTitle = [json objectForKey:@"titile"];
    _dayCount = [[json objectForKey:@"itineraryDays"] integerValue];
    
#warning 测试数据
    CityDestinationPoi *poi = [[CityDestinationPoi alloc] init];
    poi.cityId = @"54756008d17491193832582d";
    poi.zhName = @"北京";
    CityDestinationPoi *poi1 = [[CityDestinationPoi alloc] init];
    poi1.cityId = @"5475b938d174911938325835";
    poi1.zhName = @"上海";
    _destinations = @[poi, poi1];
    
    _itineraryList = [self analysisItineraryData:[json objectForKey:@"itinerary"]];
    _restaurantsList = [self analysisRestaurantData:[json objectForKey:@"restaurant"]];
    _shoppingList = [self analysisShoppingData:[json objectForKey:@"shopping"]];
    
    return self;
}

- (void)saveTrip
{
    
}

- (NSMutableArray *)analysisItineraryData:(id)json
{
    NSMutableArray *retArray = [[NSMutableArray alloc] init];
    for (int i = 0; i < _dayCount; i++) {
        NSMutableArray *oneDayArray = [[NSMutableArray alloc] init];
        [retArray addObject:oneDayArray];
    }
    for (id oneDayDic in json) {
        NSMutableArray *currentDayArray = [retArray objectAtIndex:[[oneDayDic objectForKey:@"dayIndex"] integerValue]];
        [currentDayArray addObject:[[tripPoi alloc] initWithJson:[oneDayDic objectForKey:@"poi"]]];

    }
    return retArray;
}

- (NSMutableArray *)analysisRestaurantData:(id)json
{
    NSMutableArray *retArray = [[NSMutableArray alloc] init];
    for (id oneDayDic in json) {
        [retArray addObject:[[tripPoi alloc] initWithJson:oneDayDic]];
    }
    return retArray;

}

- (NSMutableArray *)analysisShoppingData:(id)json
{
    NSMutableArray *retArray = [[NSMutableArray alloc] init];
    for (id oneDayDic in json) {
        [retArray addObject:[[tripPoi alloc] initWithJson:oneDayDic]];
    }
    return retArray;
}

@end


@implementation tripPoi

- (id)initWithJson:(id)json
{
    if (self = [super init]) {
        _poiId = [json objectForKey:@"id"];
        if ([[json objectForKey:@"type"] isEqualToString:@"vs"]) {
            _poiType = TripSpotPoi;
        }
        if ([[json objectForKey:@"type"] isEqualToString:@"restaurant"]) {
            _poiType = TripRestaurantPoi;
        }
        if ([[json objectForKey:@"type"] isEqualToString:@"shopping"]) {
            _poiType = TripShoppingPoi;
        }
        if ([[json objectForKey:@"type"] isEqualToString:@"hotel"]) {
            _poiType = TripHotelPoi;
        }
        
        _zhName = [json objectForKey:@"zhName"];
        _enName = [json objectForKey:@"enName"];
        _desc = [json objectForKey:@"desc"];
        _priceDesc = [json objectForKey:@"priceDesc"];
        _address = [json objectForKey:@"address"];
        NSMutableArray *tempArray = [[NSMutableArray alloc] init];
        for (id imageDic in [json objectForKey:@"images"]) {
            TaoziImage *image = [[TaoziImage alloc] initWithJson:imageDic];
            [tempArray addObject:image];
        }
        _images = tempArray;
        _rating = [[json objectForKey:@"rating"] floatValue];
        _telephone = [json objectForKey:@"telephone"];
        _lng = [[[[json objectForKey:@"location"] objectForKey:@"coordinates"] firstObject] doubleValue];
        _lat = [[[[json objectForKey:@"location"] objectForKey:@"coordinates"] lastObject] doubleValue];
        NSMutableArray *tempLocArray = [[NSMutableArray alloc] init];
        for (id destinationDic in [json objectForKey:@"locList"]) {
            CityDestinationPoi *poi = [[CityDestinationPoi alloc] initWithJson:destinationDic];
            [tempLocArray addObject:poi];
        }
        _locList = tempLocArray;
        _timeCost = [json objectForKey:@"timeCost"];
    }
    return self;
}

@end

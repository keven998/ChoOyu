
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
    
    NSMutableArray *tempArray = [[NSMutableArray alloc] init];
    for (id destinationsDic in [json objectForKey:@"destinations"]) {
        CityDestinationPoi *poi = [[CityDestinationPoi alloc] initWithJson:destinationsDic];
        [tempArray addObject:poi];
    }
    _destinations = tempArray;
    
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
        [currentDayArray addObject:[[TripPoi alloc] initWithJson:[oneDayDic objectForKey:@"poi"]]];
    }
    return retArray;
}

- (NSMutableArray *)analysisRestaurantData:(id)json
{
    NSMutableArray *retArray = [[NSMutableArray alloc] init];
    for (id oneDayDic in json) {
        [retArray addObject:[[TripPoi alloc] initWithJson:oneDayDic]];
    }
    return retArray;

}

- (NSMutableArray *)analysisShoppingData:(id)json
{
    NSMutableArray *retArray = [[NSMutableArray alloc] init];
    for (id oneDayDic in json) {
        [retArray addObject:[[TripPoi alloc] initWithJson:oneDayDic]];
    }
    return retArray;
}

@end


@implementation TripPoi

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

//
//  CityPoi.m
//  PeachTravel
//
//  Created by liangpengshuai on 11/14/14.
//  Copyright (c) 2014 com.aizou.www. All rights reserved.
//

#import "CityPoi.h"
#import "TravelNote.h"

@implementation CityPoi

@synthesize restaurantsOfCity;
@synthesize shoppingOfCity;

- (id)initWithJson:(id)json
{
    if (self = [super init]) {
        _cityId = [json objectForKey:@"id"];
        _zhName = [json objectForKey:@"zhName"];
        _enName = [json objectForKey:@"enName"];
        _lng = [[[[json objectForKey:@"location"] objectForKey:@"coordinates"] firstObject] doubleValue];
        _lat = [[[[json objectForKey:@"location"] objectForKey:@"coordinates"] lastObject] doubleValue];
        _desc = [json objectForKey:@"desc"];
        NSMutableArray *tempArray = [[NSMutableArray alloc] init];
        for (id imageDic in [json objectForKey:@"images"]) {
            TaoziImage *image = [[TaoziImage alloc] initWithJson:imageDic];
            [tempArray addObject:image];
        }
        _images = tempArray;
        _timeCostDesc = [json objectForKey:@"timeCostDesc"];
        _travelMonth = [json objectForKey:@"travelMonth"];
        _imageCount = [[json objectForKey:@"imageCnt"] integerValue];
        _isMyFavorite = [[json objectForKey:@"isFavorite"] boolValue];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        _cityId = [aDecoder decodeObjectForKey:@"id"];
        _zhName = [aDecoder decodeObjectForKey:@"zhName"];
        _enName = [aDecoder decodeObjectForKey:@"enName"];
        _desc = [aDecoder decodeObjectForKey:@"desc"];
        _lng = [aDecoder decodeDoubleForKey:@"lng"];
        _lat = [aDecoder decodeDoubleForKey:@"lat"];
        _images = [aDecoder decodeObjectForKey:@"images"];
        _timeCostDesc = [aDecoder decodeObjectForKey:@"timeCostDesc"];
        _travelMonth = [aDecoder decodeObjectForKey:@"travelMonth"];
        _imageCount = [aDecoder decodeIntegerForKey:@"imageCnt"];
        _isMyFavorite = [aDecoder decodeBoolForKey:@"isFavorite"];
    }
    return self;
}

- (void) encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:_cityId forKey:@"id"];
    [aCoder encodeObject:_zhName forKey:@"zhName"];
    [aCoder encodeObject:_enName forKey:@"enName"];
    [aCoder encodeObject:_desc forKey:@"desc"];
    [aCoder encodeDouble:_lng forKey:@"lng"];
    [aCoder encodeDouble:_lat forKey:@"lat"];
    [aCoder encodeObject:_images forKey:@"images"];
    [aCoder encodeObject:_timeCostDesc forKey:@"timeCostDesc"];
    [aCoder encodeObject:_travelMonth forKey:@"travelMonth"];
    [aCoder encodeInteger:_imageCount forKey:@"imageCnt"];
    [aCoder encodeBool:_isMyFavorite forKey:@"isFavorite"];
}

- (void)setTravelNotes:(NSArray *)travelNotes
{
    NSMutableArray *tempTravelNotes = [[NSMutableArray alloc] init];
    for (id travelNoteJson in travelNotes) {
        TravelNote *travelNote = [[TravelNote alloc] initWithJson:travelNoteJson];
        [tempTravelNotes addObject:travelNote];
    }
    _travelNotes = tempTravelNotes;
}

- (RecommendsOfCity *)restaurantsOfCity
{
    if (!restaurantsOfCity) {
        restaurantsOfCity = [[RecommendsOfCity alloc] init];
    }
    return restaurantsOfCity;
}

- (RecommendsOfCity *)shoppingOfCity
{
    if (!shoppingOfCity) {
        shoppingOfCity = [[RecommendsOfCity alloc] init];
    }
    return shoppingOfCity;
}

- (void)setRestaurantsOfCity:(id)restaurantsOfCityDic
{
}


- (void)setShoppingOfCity:(id)shoppingDic
{
}


@end

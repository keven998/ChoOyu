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
    if (self = [super initWithJson:json]) {
        self.poiType = kCityPoi;
        self.typeDesc = @"locality";
        self.poiTypeName = @"城市";
        _playGuide = [json objectForKey:@"playGuide"];
        _timeCostDesc = [json objectForKey:@"timeCostDesc"];
        _travelMonth = [json objectForKey:@"travelMonth"];
        _shoppingTitles = [json objectForKey:@"shoppingTitles"];
        _diningTitles = [json objectForKey:@"diningTitles"];
        _like = [[json objectForKey:@"like"] boolValue];
        _traveled = [[json objectForKey:@"traveled"] boolValue];
        _imageCount = [[json objectForKey:@"imageCnt"] integerValue]>100 ? 100:[[json objectForKey:@"imageCnt"] integerValue];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        self.poiId = [aDecoder decodeObjectForKey:@"id"];
        self.zhName = [aDecoder decodeObjectForKey:@"zhName"];
        self.enName = [aDecoder decodeObjectForKey:@"enName"];
        self.desc = [aDecoder decodeObjectForKey:@"desc"];
        self.lng = [aDecoder decodeDoubleForKey:@"lng"];
        self.lat = [aDecoder decodeDoubleForKey:@"lat"];
        self.images = [aDecoder decodeObjectForKey:@"images"];
        _timeCostDesc = [aDecoder decodeObjectForKey:@"timeCostDesc"];
        _travelMonth = [aDecoder decodeObjectForKey:@"travelMonth"];
        _imageCount = [aDecoder decodeIntegerForKey:@"imageCnt"];
        self.isMyFavorite = [aDecoder decodeBoolForKey:@"isFavorite"];
    }
    return self;
}

- (void) encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.poiId forKey:@"id"];
    [aCoder encodeObject:self.zhName forKey:@"zhName"];
    [aCoder encodeObject:self.enName forKey:@"enName"];
    [aCoder encodeObject:self.desc forKey:@"desc"];
    [aCoder encodeDouble:self.lng forKey:@"lng"];
    [aCoder encodeDouble:self.lat forKey:@"lat"];
    [aCoder encodeObject:self.images forKey:@"images"];
    [aCoder encodeObject:_timeCostDesc forKey:@"timeCostDesc"];
    [aCoder encodeObject:_travelMonth forKey:@"travelMonth"];
    [aCoder encodeInteger:_imageCount forKey:@"imageCnt"];
    [aCoder encodeBool:self.isMyFavorite forKey:@"isFavorite"];
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

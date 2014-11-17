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

- (id)initWithJson:(id)json
{
    if (self = [super init]) {
        _cityId = [json objectForKey:@"id"];
        _name = [json objectForKey:@"name"];
        _enName = [json objectForKey:@"enName"];
        _lat = [[[json objectForKey:@"coords"] objectForKey:@"lat"] doubleValue];
        _lng = [[[json objectForKey:@"coords"] objectForKey:@"lng"] doubleValue];
        _desc = [json objectForKey:@"desc"];
        _timeCost = [[json objectForKey:@"timeCost"] doubleValue];
        _travelMonth = [json objectForKey:@"travelMonth"];
        _cover = [json objectForKey:@"cover"];
        _imageCount = [[json objectForKey:@"imageCount"] integerValue];
        NSMutableArray *tempTravelNotes = [[NSMutableArray alloc] init];
        for (id travelNoteJson in [json objectForKey:@"travelNote"]) {
            TravelNote *travelNote = [[TravelNote alloc] initWithJson:travelNoteJson];
            [tempTravelNotes addObject:travelNote];
        }
        _travelNotes = tempTravelNotes;
    }
    return self;
}

@end

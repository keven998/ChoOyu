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
        _imageCount = [[json objectForKey:@"imageCount"] integerValue];
        
    }
    return self;
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

@end

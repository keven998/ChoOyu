//
//  HotelPoi.m
//  PeachTravel
//
//  Created by liangpengshuai on 3/16/15.
//  Copyright (c) 2015 com.aizou.www. All rights reserved.
//

#import "HotelPoi.h"

@implementation HotelPoi

- (id)initWithJson:(id)json
{
    if (self = [super initWithJson:json]) {
        self.poiType = kHotelPoi;
        self.typeDesc = @"hotel";
        self.poiTypeName = @"酒店";
        _bookUrl = [json objectForKey:@"bookUrl"];
        _telephone = [json objectForKey:@"telephone"];
    }
    return self;
}

@end

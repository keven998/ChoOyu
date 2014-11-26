
//
//  TripDetail.m
//  PeachTravel
//
//  Created by liangpengshuai on 11/26/14.
//  Copyright (c) 2014 com.aizou.www. All rights reserved.
//

#import "TripDetail.h"

@implementation TripDetail

- (id)initWithJson:(id)json
{
    _backUpJson = json;
    
    _tripId = [json objectForKey:@"id"];
    _tripTitle = [json objectForKey:@"titile"];
    return self;
}

- (void)saveTrip
{
    
}

@end

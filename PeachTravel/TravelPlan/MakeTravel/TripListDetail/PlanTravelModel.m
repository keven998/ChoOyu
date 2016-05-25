//
//  PlanTravelModel.m
//  PeachTravel
//
//  Created by liangpengshuai on 5/19/16.
//  Copyright © 2016 com.aizou.www. All rights reserved.
//

#import "PlanTravelModel.h"

@implementation PlanTravelModel

- (id)initWithJson:(id)json
{
    if (self = [super init]) {
        _trafficName = [json objectForKey:@"desc"];
        _startDate = [json objectForKey:@"depTime"];
        _endDate = [json objectForKey:@"arrTime"];
        _startPointName = [json objectForKey:@"start"];
        _endPointName = [json objectForKey:@"end"];
        _type = [json objectForKey:@"category"];
    }
    return self;
}

@end

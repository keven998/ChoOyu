//
//  CountryDestination.m
//  PeachTravel
//
//  Created by liangpengshuai on 11/18/14.
//  Copyright (c) 2014 com.aizou.www. All rights reserved.
//

#import "CountryDestination.h"
#import "CityDestinationPoi.h"

@implementation CountryDestination

- (id)initWithJson:(id)json
{
    if (self = [super init]) {
        _countryId = [json objectForKey:@"id"];
        NSMutableArray *imagesArray = [[NSMutableArray alloc] init];
        for (id imageDic in [json objectForKey:@"images"]) {
            TaoziImage *image = [[TaoziImage alloc] initWithJson:imageDic];
            [imagesArray addObject:image];
        }
        _images = imagesArray;
        _zhName = [json objectForKey:@"zhName"];
        _enName = [json objectForKey:@"enName"];
        NSMutableArray *distinationsArray = [[NSMutableArray alloc] init];
        for (id distinationDic in [json objectForKey:@"destinations"]) {
            [distinationsArray addObject:[[CityDestinationPoi alloc] initWithJson:distinationDic]];
        }
        _cities = distinationsArray;
        _desc = [json objectForKey:@"desc"];
    }
    return self;
}

@end

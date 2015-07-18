//
//  CityDestinationPoi.m
//  PeachTravel
//
//  Created by liangpengshuai on 11/18/14.
//  Copyright (c) 2014 com.aizou.www. All rights reserved.
//

#import "CityDestinationPoi.h"

@implementation CityDestinationPoi

- (id)initWithJson:(id)json
{
    if (self = [super init]) {
        _cityId = [json objectForKey:@"id"];
        _zhName = [json objectForKey:@"zhName"];
        _enName = [json objectForKey:@"enName"];
        _pinyin = [json objectForKey:@"pinyin"];
        if ([json objectForKey:@"location"] != [NSNull null]) {
            _lng = [[[[json objectForKey:@"location"] objectForKey:@"coordinates"] firstObject] doubleValue];
            _lat = [[[[json objectForKey:@"location"] objectForKey:@"coordinates"] lastObject] doubleValue];
        }
        NSMutableArray *imagesArray = [[NSMutableArray alloc] init];
        for (id imageDic in [json objectForKey:@"images"]) {
            TaoziImage *image = [[TaoziImage alloc] initWithJson:imageDic];
            [imagesArray addObject:image];
        }
        _images = imagesArray;
        _country = [[CountryModel alloc] initWithJson:[json objectForKey:@"country"]];
    }
    return self;
}


@end


@implementation CountryModel

- (id)initWithJson:(id)json
{
    if (self = [super init]) {
        _coutryId = [json objectForKey:@"id"];
        _zhName = [json objectForKey:@"zhName"];
        _enName = [json objectForKey:@"enName"];
        NSMutableArray *imagesArray = [[NSMutableArray alloc] init];
        for (id imageDic in [json objectForKey:@"images"]) {
            TaoziImage *image = [[TaoziImage alloc] initWithJson:imageDic];
            [imagesArray addObject:image];
        }
        _images = imagesArray;
    }
    return self;
}


@end

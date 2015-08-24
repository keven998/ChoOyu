//
//  AreaDestination.m
//  PeachTravel
//
//  Created by liangpengshuai on 3/25/15.
//  Copyright (c) 2015 com.aizou.www. All rights reserved.
//

#import "AreaDestination.h"
#import "CityDestinationPoi.h"

@implementation AreaDestination

- (id)initWithJson:(id)json
{
    if (self = [super init]) {
        _areaId = [json objectForKey:@"id"];
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
            CityDestinationPoi *poi = [[CityDestinationPoi alloc] initWithJson:distinationDic];
            CountryModel *country = [[CountryModel alloc] init];
            country.coutryId = _areaId;
            country.zhName = _zhName;
            country.enName = _enName;
            poi.country = country;
            [distinationsArray addObject:poi];
        }
        _cities = distinationsArray;
        _desc = [json objectForKey:@"desc"];
    }
    return self;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _cities = [[NSArray alloc] init];
        _images = [[NSArray alloc] init];
    }
    return self;
}


@end

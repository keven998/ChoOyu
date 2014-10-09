//  Destinations.m
//  PeachTravelDemo
//
//  Created by liangpengshuai on 14/9/23.
//  Copyright (c) 2014年 com.aizou.www. All rights reserved.
//
/*
 *保存目的地界面所有目的地数据
 */

#import "Destinations.h"
#import "DestinationCityPoi.h"
#import "DestinationCountryPoi.h"

@implementation Destinations

- (NSMutableArray *)domesticDestinations
{
    if (!_domesticDestinations) {
        _domesticDestinations = [[NSMutableArray alloc] init];
        
        for (int i=0; i<3; i++) {
            NSMutableDictionary *testDic = [[NSMutableDictionary alloc] init];
            [testDic setObject:@"人山人海行" forKey:@"Title"];
            
            NSMutableArray *testArray = [[NSMutableArray alloc] init];
            DestinationCityPoi *cityPoi = [[DestinationCityPoi alloc] init];
            cityPoi.poiId = @"";
            cityPoi.poiName = @"北京";
            cityPoi.imageList = @[@"http://lvxingpai-img-store.qiniudn.com/assets/images/a1e64f400c3497dd56c05dd8f19110d5.jpg?imageView/1/w/800/h/600/q/85/format/jpg/interlace/1"];
            [testArray addObject:cityPoi];
            DestinationCityPoi *cityPoi1 = [[DestinationCityPoi alloc] init];
            cityPoi1.poiId = @"";
            cityPoi1.poiName = @"上海";
            cityPoi1.imageList = @[@"http://lvxingpai-img-store.qiniudn.com/assets/images/a1e64f400c3497dd56c05dd8f19110d5.jpg?imageView/1/w/800/h/600/q/85/format/jpg/interlace/1"];
            [testArray addObject:cityPoi1];
            
            DestinationCityPoi *cityPoi2 = [[DestinationCityPoi alloc] init];
            cityPoi2.poiId = @"";
            cityPoi2.poiName = @"杭州";
            cityPoi2.imageList = @[@"http://lvxingpai-img-store.qiniudn.com/assets/images/a1e64f400c3497dd56c05dd8f19110d5.jpg?imageView/1/w/800/h/600/q/85/format/jpg/interlace/1"];
            [testArray addObject:cityPoi2];
            
            DestinationCityPoi *cityPoi3 = [[DestinationCityPoi alloc] init];
            cityPoi3.poiId = @"";
            cityPoi3.poiName = @"烟台";
            cityPoi3.imageList = @[@"http://lvxingpai-img-store.qiniudn.com/assets/images/a1e64f400c3497dd56c05dd8f19110d5.jpg?imageView/1/w/800/h/600/q/85/format/jpg/interlace/1"];
            [testArray addObject:cityPoi3];
            
            [testDic setObject:testArray forKey:@"Pois"];
            
            [_domesticDestinations addObject:testDic];

        }
    }
    return _domesticDestinations;
}

- (NSMutableArray *)foreignDestinations
{
    if (!_foreignDestinations) {
        _foreignDestinations = [[NSMutableArray alloc] init];
        for (int i = 0; i<10; i++) {
            NSMutableDictionary *testDic = [[NSMutableDictionary alloc] init];
            [testDic setObject:@"人山人海行" forKey:@"Title"];
            
            DestinationCountryPoi *country = [[DestinationCountryPoi alloc] init];
            country.poiName = @"日本";
            country.imageList = @[@"http://lvxingpai-img-store.qiniudn.com/assets/images/a1e64f400c3497dd56c05dd8f19110d5.jpg?imageView/1/w/800/h/600/q/85/format/jpg/interlace/1"];
            
            [testDic setObject:country forKey:@"Poi"];
            [_foreignDestinations addObject:testDic];
        }
    }
    return _foreignDestinations;
}

- (NSMutableArray *)destinationsSelected
{
    if (!_destinationsSelected) {
        _destinationsSelected = [[NSMutableArray alloc] init];
    }
    return _destinationsSelected;
}
@end
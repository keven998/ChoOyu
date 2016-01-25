//
//  StoreDetailModel.m
//  PeachTravel
//
//  Created by liangpengshuai on 11/12/15.
//  Copyright © 2015 com.aizou.www. All rights reserved.
//

#import "StoreDetailModel.h"

@implementation StoreDetailModel

- (id)initWithJson:(id)json
{
    if (self = [super init]) {
        
        _storeId = [[json objectForKey:@"sellerId"] integerValue];
        _storeName = [json objectForKey:@"name"];
        _serviceTags = [json objectForKey:@"qualifications"];
        _languages = [json objectForKey:@"lang"];
        _serviceTags = [json objectForKey:@"services"];
        _qualifications = [json objectForKey:@"qualifications"];
        
        BusinessMoel *business = [[BusinessMoel alloc] init];
        business.userId = [[json objectForKey:@"sellerId"] integerValue];
        business.nickName = [json objectForKey:@"name"];
        _business = business;
        NSMutableArray *tempArray = [[NSMutableArray alloc] init];
        for (NSDictionary *dic in [json objectForKey:@"serviceZones"]) {
            [tempArray addObject:[[CityDestinationPoi alloc] initWithJson:dic]];
        }
        _serviceZone = tempArray;
        
//#warning test
        
//        _qualifications = @[@"认证卖家", @"如实描述", @"24小时内相应"];
//        _languages = @[@"中文", @"英文", @"当地语"];
//        _serviceTags = @[@"当地咨询", @"行程规划"];
//        CityDestinationPoi *poi = [[CityDestinationPoi alloc] init];
//        poi.zhName = @"北京";
//        _serviceZone = @[poi];
     }
    return self;
}

@end

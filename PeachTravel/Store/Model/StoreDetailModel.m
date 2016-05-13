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
        if ([[json objectForKey:@"user"] objectForKey:@"avatar"] != [NSNull null]) {
            business.avatar = [[[json objectForKey:@"user"] objectForKey:@"avatar"] objectForKey:@"url"];
        }
        _business = business;
        NSMutableArray *tempArray = [[NSMutableArray alloc] init];
        for (NSDictionary *dic in [json objectForKey:@"serviceZones"]) {
            [tempArray addObject:[[CityDestinationPoi alloc] initWithJson:dic]];
        }
        _serviceZone = tempArray;
        
        NSMutableArray *tempArray2 = [[NSMutableArray alloc] init];
        for (NSDictionary *dic in [json objectForKey:@"subLocalities"]) {
            [tempArray2 addObject:[[CityDestinationPoi alloc] initWithJson:dic]];
        }
        _planServiceCities = tempArray2;


        _totalOrderCnt = [[json objectForKey:@"totalOrderCnt"] integerValue];
        _totalSales = [[json objectForKey:@"totalSales"] floatValue];
        _pendingOrderCnt = [[json objectForKey:@"pendingOrderCnt"] floatValue];
    }
    return self;
}

- (NSString *)formatTotalSales
{
    NSString *priceStr;
    float primePrice = round(_totalSales*100)/100;
    if (!(primePrice - (int)primePrice)) {
        priceStr = [NSString stringWithFormat:@"%d", (int)primePrice];
    } else {
        NSString *tempPrice = [NSString stringWithFormat:@"%.1f", primePrice];
        if (!(primePrice - tempPrice.floatValue)) {
            priceStr = [NSString stringWithFormat:@"%.1f", primePrice];
        } else {
            priceStr = [NSString stringWithFormat:@"%.2f", primePrice];
        }
    }
    return priceStr;
}
@end

//
//  GoodsDetailModel.m
//  PeachTravel
//
//  Created by liangpengshuai on 11/12/15.
//  Copyright © 2015 com.aizou.www. All rights reserved.
//

#import "GoodsDetailModel.h"

@implementation GoodsDetailModel

- (id)initWithJson:(id)json {
    if (self = [super init]) {
        _goodsId = [[json objectForKey:@"commodityId"] integerValue];
        _primePrice = [[json objectForKey:@"marketPrice"] floatValue];
        _currentPrice = [[json objectForKey:@"price"] floatValue];
        _goodsName = [json objectForKey:@"title"];
        _rating = [[json objectForKey:@"rating"] floatValue]*100;
        if ([json objectForKey:@"cover"] != [NSNull null]) {
            _coverImage = [[TaoziImage alloc] initWithJson:[json objectForKey:@"cover"]];
        }
        _image = [[TaoziImage alloc] initWithJson:[[json objectForKey:@"images"] firstObject]];
        _saleCount = [[json objectForKey:@"salesVolume"] integerValue];
        if ([json objectForKey:@"locality"] != [NSNull null]) {
            _locality = [[CityDestinationPoi alloc] initWithJson:[json objectForKey:@"locality"]];
        }
        NSMutableArray *packageList = [[NSMutableArray alloc] init];
        for (NSDictionary *packageDic in [json objectForKey:@"plans"]) {
            GoodsPackageModel *package = [[GoodsPackageModel alloc] initWithJson:packageDic];
            [packageList addObject:package];
        }
        _packages = packageList;
        _store = [[StoreDetailModel alloc] initWithJson:[json objectForKey:@"seller"] ];
    }
    return self;
}

@end

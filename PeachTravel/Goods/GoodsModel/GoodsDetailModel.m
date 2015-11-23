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
        _primePrice = [[json objectForKey:@"marketPrice"] floatValue];
        _currentPrice = [[json objectForKey:@"price"] floatValue];
        _goodsName = [json objectForKey:@"title"];
        _rating = [[json objectForKey:@"rating"] floatValue]*5;
        _image = [[TaoziImage alloc] initWithJson:[[json objectForKey:@"images"] firstObject]];
        _saleCount = [[json objectForKey:@"salesVolume"] integerValue];
    }
    return self;
}

@end

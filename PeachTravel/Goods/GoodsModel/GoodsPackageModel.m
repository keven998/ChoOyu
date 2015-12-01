//
//  GoodsPackageModel.m
//  PeachTravel
//
//  Created by liangpengshuai on 11/12/15.
//  Copyright © 2015 com.aizou.www. All rights reserved.
//

#import "GoodsPackageModel.h"

@implementation GoodsPackageModel

- (id)initWithJson:(id)json {
    if (self = [super init]) {
        _packageDesc = [json objectForKey:@"desc"];
        _packageName = [json objectForKey:@"title"];
        _packageId = [json objectForKey:@"planId"];
        _primePrice = [[json objectForKey:@"marketPrice"] floatValue];
        _currentPrice = [[json objectForKey:@"price"] floatValue];
    }
    return self;
}

@end

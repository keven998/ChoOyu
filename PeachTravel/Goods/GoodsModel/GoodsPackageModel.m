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
        _priceList = [json objectForKey:@"pricing"];
        if ([[[_priceList firstObject] objectForKey:@"timeRange"] firstObject] != [NSNull null]) {
            _startPriceTimeInterval = [[[[_priceList firstObject] objectForKey:@"timeRange"] firstObject] doubleValue];

        }
        if ([[[_priceList lastObject] objectForKey:@"timeRange"] lastObject] != [NSNull null]) {
            _endPriceTimeInterval = [[[[_priceList lastObject] objectForKey:@"timeRange"] lastObject] doubleValue];
        }
        _startPriceDate = [NSDate dateWithTimeIntervalSince1970:_startPriceTimeInterval/1000];
        _endPriceDate = [NSDate dateWithTimeIntervalSince1970:_endPriceTimeInterval/1000];
    }
    return self;
}

- (NSString *)formatCurrentPrice
{
    NSString *priceStr;
    float currentPrice = round(_currentPrice*100)/100;
    if (!(currentPrice - (int)currentPrice)) {
        priceStr = [NSString stringWithFormat:@"%d", (int)currentPrice];
    } else {
        NSString *tempPrice = [NSString stringWithFormat:@"%.1f", currentPrice];
        if (!(_currentPrice - tempPrice.floatValue)) {
            priceStr = [NSString stringWithFormat:@"%.1f", currentPrice];
        } else {
            priceStr = [NSString stringWithFormat:@"%.2f", currentPrice];
        }
        
    }
    return priceStr;
}

- (NSString *)formatPrimePrice
{
    NSString *priceStr;
    float primePrice = round(_currentPrice*100)/100;
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
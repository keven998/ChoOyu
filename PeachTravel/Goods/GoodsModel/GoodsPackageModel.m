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
        
        NSMutableArray *priceList = [[NSMutableArray alloc] init];
        for (NSDictionary *pairceDic in [json objectForKey:@"pricing"]) {
            NSString *firstPriceStr = [[pairceDic objectForKey:@"timeRange"] firstObject];
            NSString *lastPriceStr = [[pairceDic objectForKey:@"timeRange"] lastObject];
            NSTimeInterval firstDateTimeInterval;
            if ([firstPriceStr isKindOfClass:[NSString class]]) {
                 firstDateTimeInterval = [[ConvertMethods stringToDate:[firstPriceStr substringWithRange:NSMakeRange(0, 10)] withFormat:@"yyyy-MM-dd" withTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]] timeIntervalSince1970];
            }
         
            NSTimeInterval lastDateTimeInterval;
            if ([lastPriceStr isKindOfClass:[NSString class]]) {
                lastDateTimeInterval = [[ConvertMethods stringToDate:[lastPriceStr substringWithRange:NSMakeRange(0, 10)] withFormat:@"yyyy-MM-dd" withTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]] timeIntervalSince1970];
            }
            
            while (firstDateTimeInterval <= lastDateTimeInterval) {
                NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
                [dic safeSetObject: [pairceDic objectForKey:@"price"] forKey:@"price"];
                NSDate *date = [NSDate dateWithTimeIntervalSince1970:firstDateTimeInterval];
                [dic setObject:date forKey:@"date"];
                firstDateTimeInterval += 60*60*24;
                [priceList addObject:dic];
            }
        }
        _priceList = priceList;
       
        _endPriceDate = [[_priceList lastObject] objectForKey:@"date"];
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

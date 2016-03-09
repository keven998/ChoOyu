//
//  BNGoodsDetailModel.m
//  PeachTravel
//
//  Created by liangpengshuai on 3/7/16.
//  Copyright © 2016 com.aizou.www. All rights reserved.
//

#import "BNGoodsDetailModel.h"

@implementation BNGoodsDetailModel

- (id)initWithJson:(id)json
{
    if (self = [super initWithJson:json]) {
        NSString *status = [json objectForKey:@"status"];
        if ([status isEqualToString:@"pub"]) {
            _goodsStatus = kOnSale;
            
        } else if ([status isEqualToString:@"review"]) {
            _goodsStatus = kReviewing;
            
        } else if ([status isEqualToString:@"disabled"]) {
            _goodsStatus = kOffSale;
        }
    }
    return self;
}

@end

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
        _qualifications = [json objectForKey:@"qualifications"];
    }
    return self;
}

@end

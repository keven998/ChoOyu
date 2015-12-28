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
        
#warning test
        _languages = @[@"中文", @"英文", @"当地语"];
        _serviceTags = @[@"行程规划", @"做攻略", @"语言服务"];
        _qualifications = @[@"认证卖家", @"如实描述", @"24小时响应"];

     }
    return self;
}

@end

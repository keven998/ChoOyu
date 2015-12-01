//
//  OrderContactInfoModel.m
//  PeachTravel
//
//  Created by liangpengshuai on 11/12/15.
//  Copyright © 2015 com.aizou.www. All rights reserved.
//

#import "OrderContactInfoModel.h"

@implementation OrderContactInfoModel

- (id)initWithJson:(id)json
{
    if (self = [super init]) {
        _firstName = [json objectForKey:@"givenName"];
        _lastName = [json objectForKey:@"surname"];
        _tel = [NSString stringWithFormat:@"+%@ %@", [[json objectForKey:@"tel"] objectForKey:@"dialCode"], [[json objectForKey:@"tel"] objectForKey:@"number"]];
    }
    return self;
}

@end

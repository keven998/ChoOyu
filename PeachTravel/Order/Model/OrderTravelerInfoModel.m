//
//  OrderTravelerInfoModel.m
//  PeachTravel
//
//  Created by liangpengshuai on 11/12/15.
//  Copyright © 2015 com.aizou.www. All rights reserved.
//

#import "OrderTravelerInfoModel.h"

@implementation OrderTravelerInfoModel

- (instancetype)init
{
    self = [super init];
    if (self) {
        _dialCode = @"86";
    }
    return self;
}

- (id)initWithJson:(id)json
{
    if (self = [super init]) {
        _firstName = [json objectForKey:@"givenName"];
        _lastName = [json objectForKey:@"surname"];
        _IDCategory = [[[json objectForKey:@"identities"] firstObject] objectForKey:@"idType"];
        _IDNumber = [[[json objectForKey:@"identities"] firstObject] objectForKey:@"number"];
        _dialCode = [NSString stringWithFormat:@"%@", [[json objectForKey:@"tel"] objectForKey:@"dialCode"]];
        _telNumber = [NSString stringWithFormat:@"%@",  [[json objectForKey:@"tel"] objectForKey:@"number"]];
    }
    return self;
}

- (NSString *)telDesc{
    if (_telNumber) {
        return [NSString stringWithFormat:@"+%@ %@", _dialCode, _telNumber];
    }
    return nil;
}

- (NSString *)IDCategoryDesc
{
    if ([_IDCategory isEqualToString:@"passport"]) {
        return @"护照";
    }
    if ([_IDCategory isEqualToString:@"chineseID"]) {
        return @"身份证";
    }
    return @"";
}

@end

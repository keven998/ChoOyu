//
//  PTDetailModel.m
//  PeachTravel
//
//  Created by liangpengshuai on 4/11/16.
//  Copyright © 2016 com.aizou.www. All rights reserved.
//

#import "PTDetailModel.h"

@implementation PTDetailModel

- (id)initWithJson:(id)json
{
    if (self = [super init]) {
        _itemId = [json objectForKey:@"itemId"];
        _service = [json objectForKey:@"service"];
        _topic = [json objectForKey:@"topic"];
        _topicList = [_topic componentsSeparatedByString:@","];
        _serviceList = [_service componentsSeparatedByString:@","];
        _departureDate = [json objectForKey:@"departureDate"];
        _createTime = [[json objectForKey:@"createTime"] longValue]/1000;
        _totalPrice = [[json objectForKey:@"totalPrice"] floatValue];
        _timeCost = [[json objectForKey:@"totalPrice"] integerValue];
        _budget = [[json objectForKey:@"budget"] floatValue];
        _paied = [[json objectForKey:@"paied"] boolValue];
        _memo = [json objectForKey:@"memo"];
        _contact = [[OrderTravelerInfoModel alloc] initWithJson:[[json objectForKey:@"contact"] firstObject]];
        NSMutableArray *array = [[NSMutableArray alloc] init];
        for (NSDictionary *dic in [json objectForKey:@"destination"]) {
            [array addObject:[[CityDestinationPoi alloc] initWithJson:dic]];
        }
        _destinations = array;
    }
    return self;
}

- (NSString *)topic
{
    if (!_topic) {
        if (_topicList) {
            NSMutableString *content = [[NSMutableString alloc] init];
            for (NSString *str in _topicList) {
                if ([str isEqualToString:[_topicList lastObject]]) {
                    [content appendString:str];
                } else {
                    [content appendFormat:@"%@,", str];
                }
                
            }
            _topic = content;
        }
    }
    return _topic;
}

- (NSString *)service
{
    if (!_service) {
        if (_serviceList) {
            NSMutableString *content = [[NSMutableString alloc] init];
            for (NSString *str in _serviceList) {
                if ([str isEqualToString:[_serviceList lastObject]]) {
                    [content appendString:str];
                } else {
                    [content appendFormat:@"%@,", str];
                }
                
            }
            _service = content;
        }
    }
    return _service;
}


- (NSString *)createTimeStr
{
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:_createTime];
    return [ConvertMethods dateToString:date withFormat:@"yyyy-MM-dd" withTimeZone:[NSTimeZone systemTimeZone]];
}

@end

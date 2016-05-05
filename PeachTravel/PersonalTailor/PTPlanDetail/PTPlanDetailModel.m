//
//  PTPlanDetailModel.m
//  PeachTravel
//
//  Created by liangpengshuai on 4/18/16.
//  Copyright © 2016 com.aizou.www. All rights reserved.
//

#import "PTPlanDetailModel.h"

@implementation PTPlanDetailModel

- (id)initWithJson:(id)json
{
    if (self = [super init]) {
        _planId = [[json objectForKey:@"itemId"] integerValue];
        _desc = [json objectForKey:@"desc"];
        _totalPrice = [[json objectForKey:@"price"] floatValue];
        _seller = [[FrendModel alloc] initWithJson:[[json objectForKey:@"seller"] objectForKey:@"user"]];
        _commitTime = [[json objectForKey:@"createTime"] longLongValue]/1000;
        
        NSMutableArray *temp = [[NSMutableArray alloc] init];
        if ([json objectForKey:@"guide"] != [NSNull null]) {
            if ([[json objectForKey:@"guide"] objectForKey:@"id"]) {
                [temp addObject:[[MyGuideSummary alloc] initWithJson:[json objectForKey:@"guide"]]];
            }
        }

        _dataSource = temp;
    }
    return self;
}

- (NSString *)commitTimeStr
{
    NSString *time = [ConvertMethods dateToString:[NSDate dateWithTimeIntervalSince1970:_commitTime] withFormat:@"yyyy-MM-dd HH:mm:ss" withTimeZone:[NSTimeZone systemTimeZone]];
    return time;
}

@end

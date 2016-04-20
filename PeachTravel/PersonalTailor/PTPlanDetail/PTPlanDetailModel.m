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
        _planId = [json objectForKey:@"bountyId"];
        _desc = [json objectForKey:@"desc"];
        _totalPrice = [[json objectForKey:@"totalPrice"] floatValue];
        _seller = [[FrendModel alloc] initWithJson:[json objectForKey:@"seller"]];
        _commitTime = [[json objectForKey:@"createTime"] longLongValue]/1000;
        
        NSMutableArray *temp = [[NSMutableArray alloc] init];
        for (NSDictionary *dic in [json objectForKey:@"plans"]) {
            [temp addObject:[[MyGuideSummary alloc] initWithJson:dic]];
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

//
//  SpotDetailBean.m
//  lvxingpai
//
//  Created by Luo Yong on 14-6-24.
//  Copyright (c) 2014年 aizou. All rights reserved.
//

#import "SpotDetailBean.h"

@implementation SpotDetailBean

@synthesize spotId;
@synthesize pictures;
@synthesize score;
@synthesize name;
@synthesize fee;
@synthesize feeDesc;
@synthesize favorCnt;
@synthesize checkinCnt;
@synthesize bestTime;
@synthesize costTime;
@synthesize openTime;
@synthesize infoUrl;
@synthesize tipsUrl;
@synthesize warningUrl;
@synthesize latitude;
@synthesize longitude;
@synthesize tags;
@synthesize intro;
@synthesize locationDesc;
@synthesize traffic;
@synthesize tips;

- (id) initWithData:(id)json {
    if (self = [super init]) {
        spotId = [json objectForKey:@"_id"];
        NSDictionary *ratings = [json objectForKey:@"ratings"];
        if (ratings && [ratings count] != 0) {
            score = [[ratings objectForKey:@"score"] integerValue];
            favorCnt = [[ratings objectForKey:@"favorCnt"] intValue];
            checkinCnt = [[ratings objectForKey:@"checkinCnt"] intValue];
        }
        name = [json objectForKey:@"name"];

        feeDesc = [self isBlankString:[json objectForKey:@"priceDesc"]] ? @"暂无" : [json objectForKey:@"priceDesc"];
        
        NSArray *bestMonths = [json objectForKey:@"travelMonth"];
        NSMutableString *bestMonthStr;
        if ([bestMonths count] == 0 || !bestMonths) {
            bestTime = @"全年";
        } else {
            bestMonthStr = [[NSMutableString alloc] initWithString:@"最佳月份 :"];
            for (id month in bestMonths) {
                [bestMonthStr appendString:[NSString stringWithFormat:@"%@ ", month]];
            }
            bestTime = bestMonthStr;
        }
        bestTime = [[json objectForKey:@"travelMonth"] count]==0 ? @"全年" : [json objectForKey:@"bestTime"];
        openTime = [self isBlankString:[json objectForKey:@"openTime"]] ? @"全天" : [json objectForKey:@"openTime"];
        intro = [self isBlankString:[json objectForKey:@"desc"]] ? @"" : [json objectForKey:@"desc"];
        costTime = [NSString stringWithFormat:@"%d", [[json objectForKey:@"timeCost"] intValue]];

        tags = [json objectForKey:@"tags"];
        
        latitude = [[[json objectForKey:@"addr"] objectForKey:@"lat"] doubleValue];
        longitude = [[[json objectForKey:@"addr"] objectForKey:@"lng"] doubleValue];
        
        id imgs = [json objectForKey:@"imageList"];
        if (imgs != nil && [imgs count] > 0) {
            pictures = [NSArray arrayWithArray:imgs];
        }
        locationDesc = [[json objectForKey:@"addr"] objectForKey:@"addr"];
        if (!locationDesc || locationDesc.length==0) {
            locationDesc = [NSString stringWithFormat:@"位于 %@", [[json objectForKey:@"addr"] objectForKey:@"locName"]];
        }
        
        id flag = [json objectForKey:@"descriptionFlag"];
        traffic = [[flag objectForKey:@"traffic"] intValue];
        tips = [[flag objectForKey:@"tips"] intValue];
    }
    return self;
}

- (NSData *)toData {
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:
                         spotId, @"spotId",
                         [NSString stringWithFormat:@"%d", score], @"score",
                         name, @"name",
                         tags, @"tags",
                         [pictures firstObject], @"picture",
                         intro, @"intro",
                         nil];
    
    NSMutableData *data = [[NSMutableData alloc] init];
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
    [archiver encodeObject:dic forKey:@"spot"];
    [archiver finishEncoding];
    return data;
}

- (BOOL)isBlankString:(NSString *)string {
    if (string == nil || string == NULL) {
        return YES;
    }
    if ([string isKindOfClass:[NSNull class]]) {
        return YES;
    }
    if ([string respondsToSelector:@selector(stringByTrimmingCharactersInSet:)]) {
        if ([[string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length]==0) {
            return YES;
        }
    }
    
    return NO;
}

@end

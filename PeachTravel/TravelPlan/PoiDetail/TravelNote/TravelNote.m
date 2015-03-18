//
//  TravelNote.m
//  PeachTravel
//
//  Created by liangpengshuai on 11/14/14.
//  Copyright (c) 2014 com.aizou.www. All rights reserved.
//

#import "TravelNote.h"

@implementation TravelNote

- (id)initWithJson:(id)json
{
    if (self = [super init]) {
        _travelNoteId = [json objectForKey:@"id"];
        _title = [json objectForKey:@"title"];
        
        /**
         *  因为取到的游记里有换行符，在这里取最长的那一行
         */
        NSString *summaryStr = [json objectForKey:@"summary"];
        NSArray *summaryList=[summaryStr componentsSeparatedByString:@"\n"];
        for (NSString *s in summaryList) {
            if (s.length > _summary.length) {
                _summary = s;
            }
        }
        NSMutableArray *tempArray = [[NSMutableArray alloc] init];
        for (id imageDic in [json objectForKey:@"images"]) {
            TaoziImage *image = [[TaoziImage alloc] initWithJson:imageDic];
            [tempArray addObject:image];
        }
        _images = tempArray;
        _authorName = [json objectForKey:@"authorName"];
        _authorAvatar = [json objectForKey:@"authorAvatar"];
        _source = [json objectForKey:@"source"];
        _detailUrl = [json objectForKey:@"detailUrl"];
        if ([json objectForKey:@"publishTime"] != [NSNull null]) {
            _publishDateStr = [ConvertMethods timeIntervalToString:([[json objectForKey:@"publishTime"] longLongValue]/1000) withFormat:@"yyyy-MM-dd" withTimeZone:[NSTimeZone systemTimeZone]];
        }
    }
    return self;
}

- (void)asyncFavorite:(NSString *)poiId poiType:(NSString *)type isFavorite:(BOOL)isFavorite completion:(void (^) (BOOL isSuccess))completion
{
    AccountManager *accountManager = [AccountManager shareAccountManager];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    AppUtils *utils = [[AppUtils alloc] init];
    [manager.requestSerializer setValue:utils.appVersion forHTTPHeaderField:@"Version"];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"iOS %@",utils.systemVersion] forHTTPHeaderField:@"Platform"];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"%@", accountManager.account.userId] forHTTPHeaderField:@"UserId"];
    
    if (isFavorite) {
        [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
        [manager.requestSerializer setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
        NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
        [params setObject:poiId forKey:@"itemId"];
        [params setObject:@"travelNote" forKey:@"type"];
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        [manager POST:API_FAVORITE parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSLog(@"%@", responseObject);
            NSInteger code = [[responseObject objectForKey:@"code"] integerValue];
            if (code == 0 || code == 401) {
                completion(YES);
            } else {
                completion(NO);
            }
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            completion(NO);
            
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        }];
        
    } else {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        NSString *urlStr = [NSString stringWithFormat:@"%@/%@", API_UNFAVORITE, poiId];
        [manager DELETE:urlStr parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSLog(@"%@", responseObject);
            NSInteger code = [[responseObject objectForKey:@"code"] integerValue];
            if (code == 0) {
                completion(YES);
            } else {
                completion(NO);
            }
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            completion(NO);
        }];
    }
    
}


@end

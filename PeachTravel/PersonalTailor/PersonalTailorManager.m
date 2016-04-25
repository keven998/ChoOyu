//
//  PersonalTailorManager.m
//  PeachTravel
//
//  Created by liangpengshuai on 4/11/16.
//  Copyright © 2016 com.aizou.www. All rights reserved.
//

#import "PersonalTailorManager.h"

@implementation PersonalTailorManager

+ (void)asyncLoadRecommendPersonalTailorDataWithStartIndex:(NSInteger)index pageCount:(NSInteger)count completionBlock:(void (^) (BOOL isSuccess, NSArray<PTDetailModel *> *resultList))completion;
{
    NSString *url = [NSString stringWithFormat:@"%@marketplace/bounties", BASE_URL];
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [dic safeSetObject:[NSNumber numberWithInteger:index] forKey:@"start"];
    [dic safeSetObject:[NSNumber numberWithInteger:count] forKey:@"count"];

    [LXPNetworking GET:url parameters:dic success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        NSInteger result = [[responseObject objectForKey:@"code"] integerValue];
        if (result == 0) {
            NSMutableArray *retArray = [[NSMutableArray alloc] init];
            for (NSDictionary *dic in [responseObject objectForKey:@"result"]) {
                [retArray addObject:[[PTDetailModel alloc] initWithJson:dic]];
            }
            completion(YES, retArray);
        } else {
            completion(NO, nil);
        }
        
    } failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
        completion(NO, nil);
    }];
}

+ (void)asyncMakePersonalTailorWithPTModel:(PTDetailModel *)ptDetailModel completionBlock:(void (^) (BOOL isSuccess, PTDetailModel *ptDetailModel))completion
{
    NSString *url = [NSString stringWithFormat:@"%@marketplace/bounties", BASE_URL];
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    NSMutableDictionary *contactDic = [[NSMutableDictionary alloc] init];
    NSMutableDictionary *telDic = [[NSMutableDictionary alloc] init];
    OrderTravelerInfoModel *contactInfo = ptDetailModel.contact;
    if (contactInfo.dialCode.integerValue == 0) {
        contactInfo.dialCode = @"86";
        
    }
    [telDic safeSetObject:[NSNumber numberWithInteger:contactInfo.dialCode.integerValue] forKey:@"dialCode"];
    [telDic safeSetObject:[NSNumber numberWithInteger:contactInfo.telNumber.integerValue] forKey:@"number"];
    [contactDic setObject:telDic forKey:@"tel"];
    [contactDic safeSetObject:contactInfo.firstName forKey:@"givenName"];
    [contactDic safeSetObject:contactInfo.lastName forKey:@"surname"];
    [contactDic safeSetObject:@"" forKey:@"email"];
    [contactDic safeSetObject:@"m" forKey:@"gender"];
    [params setObject:contactDic forKey:@"contact"];
    
    NSMutableArray *destinationArray = [[NSMutableArray alloc] init];
    for (CityDestinationPoi *poi in ptDetailModel.destinations) {
        NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
        [dic safeSetObject:poi.cityId forKey:@"id"];
        [dic safeSetObject:poi.zhName forKey:@"zhName"];
        [destinationArray addObject:dic];
    }
    [params setObject:destinationArray forKey:@"destination"];
    
    NSMutableDictionary *fromCityDic = [[NSMutableDictionary alloc] init];
    [fromCityDic safeSetObject:ptDetailModel.fromCity.cityId forKey:@"id"];
    [fromCityDic safeSetObject:ptDetailModel.fromCity.zhName forKey:@"zhName"];
    [params setObject:fromCityDic forKey:@"departure"];
    [params safeSetObject:ptDetailModel.departureDate forKey:@"departureDate"];
    
    [params safeSetObject:[NSNumber numberWithInteger:ptDetailModel.timeCost] forKey:@"timeCost"];
    [params safeSetObject:[NSNumber numberWithInteger:ptDetailModel.memberCount] forKey:@"participantCnt"];
    [params safeSetObject:[NSNumber numberWithFloat:ptDetailModel.earnestMoney] forKey:@"bountyPrice"];
    [params safeSetObject:[NSNumber numberWithFloat:ptDetailModel.totalPrice] forKey:@"totalPrice"];
    [params safeSetObject:[NSNumber numberWithFloat:ptDetailModel.totalPrice] forKey:@"budget"];
    if (ptDetailModel.memo.length) {
        [params safeSetObject:ptDetailModel.demand forKey:@"memo"];
    } else {
        [params safeSetObject:@"" forKey:@"memo"];
    }
    [params safeSetObject:ptDetailModel.topic forKey:@"topic"];
    [params safeSetObject:ptDetailModel.service forKey:@"service"];
    
    NSMutableArray *participants = [[NSMutableArray alloc] init];
    if (ptDetailModel.hasChild) {
        [participants addObject:@"children"];
    }
    if (ptDetailModel.hasOldMan) {
        [participants addObject:@"oldman"];
    }
    [params safeSetObject:participants forKey:@"participants"];

    [LXPNetworking POST:url parameters:params success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        NSInteger result = [[responseObject objectForKey:@"code"] integerValue];
        if (result == 0) {
            PTDetailModel *model = [[PTDetailModel alloc] initWithJson:[responseObject objectForKey:@"result"]];
            completion(YES, model);
        } else {
            completion(NO, nil);
        }
        
    } failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
        completion(NO, nil);
        
    }];
}

 + (void)asyncMakePlanForPTWithPtId:(NSString *)ptId content:(NSString *)content totalPrice:(NSInteger)price guideList:(NSArray *)guideList completionBlock:(void (^)(BOOL))completion
{
    NSString *url = [NSString stringWithFormat:@"%@marketplace/bounties/%@/schedules", BASE_URL, ptId];
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params safeSetObject:content forKey:@"desc"];
    [params safeSetObject:[NSNumber numberWithInteger:price] forKey:@"price"];
    [params safeSetObject:[guideList firstObject] forKey:@"guideId"];

    [LXPNetworking POST:url parameters:params success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        NSInteger result = [[responseObject objectForKey:@"code"] integerValue];
        if (result == 0) {
        
            completion(YES);
        } else {
            completion(NO);
        }
        
    } failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
        completion(NO);
        
    }];
}

+ (void)asyncLoadUsrePTDataWithUserId:(NSInteger)userId completionBlock:(void (^) (BOOL isSuccess, NSArray<PTDetailModel *> *resultList))completion
{
    NSString *url = [NSString stringWithFormat:@"%@marketplace/users/%ld/bounties", BASE_URL, userId];
    [LXPNetworking GET:url parameters:nil success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        NSInteger result = [[responseObject objectForKey:@"code"] integerValue];
        if (result == 0) {
            NSMutableArray *retArray = [[NSMutableArray alloc] init];
            for (NSDictionary *dic in [responseObject objectForKey:@"result"]) {
                [retArray addObject:[[PTDetailModel alloc] initWithJson:dic]];
            }
            completion(YES, retArray);
        } else {
            completion(NO, nil);
        }
        
    } failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
        completion(NO, nil);
    }];
}

+ (void)asyncLoadPTDetailDataWithItemId:(NSString *)itemId completionBlock:(void (^) (BOOL isSuccess, PTDetailModel *ptDetail))completion
{
    NSString *url = [NSString stringWithFormat:@"%@marketplace/bounties/%@", BASE_URL, itemId];
    [LXPNetworking GET:url parameters:nil success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        NSInteger result = [[responseObject objectForKey:@"code"] integerValue];
        if (result == 0) {
            PTDetailModel *ptDetail = [[PTDetailModel alloc] initWithJson:[responseObject objectForKey:@"result"]];
            completion(YES, ptDetail);
            
        } else {
            completion(NO, nil);
        }
        
    } failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
        completion(NO, nil);
    }];
}

+ (void)asyncTakePersonalTailor:(NSString *)itemId completionBlock:(void (^)(BOOL))completion
{
    NSString *url = [NSString stringWithFormat:@"%@marketplace/bounties/%@/bounty-takers", BASE_URL, itemId];
    NSDictionary *params = @{};
    [LXPNetworking POST:url parameters:params success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        NSInteger result = [[responseObject objectForKey:@"code"] integerValue];
        if (result == 0) {
           
            completion(YES);
            
        } else {
            completion(NO);
        }
        
    } failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
        completion(NO);
    }];
}

+ (void)asyncLoadSellerServerPTDataWithUserId:(NSInteger)userId completionBlock:(void (^) (BOOL isSuccess, NSArray<PTDetailModel *> *resultList))completion
{
    NSString *url = [NSString stringWithFormat:@"%@marketplace/sellers/%ld/schedules", BASE_URL, userId];
    [LXPNetworking GET:url parameters:nil success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        NSInteger result = [[responseObject objectForKey:@"code"] integerValue];
        if (result == 0) {
            NSMutableArray *retArray = [[NSMutableArray alloc] init];
            for (NSDictionary *dic in [responseObject objectForKey:@"result"]) {
                [retArray addObject:[[PTDetailModel alloc] initWithJson:dic]];
            }
            completion(YES, retArray);
        } else {
            completion(NO, nil);
            
        }
        
    } failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
        completion(NO, nil);
    }];
}


+ (void)asyncSelectPlan:(NSInteger)planId withPtId:(NSString *)ptId completionBlock:(void (^) (BOOL isSuccess))completion

{
    NSString *url = [NSString stringWithFormat:@"%@marketplace/bounties/%@/prepay", BASE_URL, ptId];
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [dic setObject:[NSNumber numberWithInteger:planId] forKey:@"scheduleId"];
    [LXPNetworking POST:url parameters:dic success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        NSInteger result = [[responseObject objectForKey:@"code"] integerValue];
        if (result == 0) {
            completion(YES);
            
        } else {
            completion(NO);
            
        }
        
    } failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
        completion(NO);
    }];
}
@end














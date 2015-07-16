//
//  SuperPoi.m
//  PeachTravel
//
//  Created by liangpengshuai on 3/16/15.
//  Copyright (c) 2015 com.aizou.www. All rights reserved.
//

#import "SuperPoi.h"
#import "CommentDetail.h"

@implementation SuperPoi

- (id)initWithJson:(id)json
{
    if (self = [super init]) {
        _poiId = [json objectForKey:@"id"];
        _zhName = [json objectForKey:@"zhName"];
        _enName = [json objectForKey:@"enName"];
        _desc = [json objectForKey:@"desc"];
        _priceDesc = [json objectForKey:@"priceDesc"];
        _openTime = [json objectForKey:@"openTime"];
        _address = [json objectForKey:@"address"];
        _descUrl = [json objectForKey:@"descUrl"];
        _telephone = [json objectForKey:@"telephone"];

        if ([[json objectForKey:@"type"] isEqualToString:@"vs"]) {
            _poiType = kSpotPoi;
        }
            
        if ([json objectForKey:@"rank"] != [NSNull null]) {
            _rank = [[json objectForKey:@"rank"] intValue];
        }
        
        if ([json objectForKey:@"locality"] != [NSNull null]) {
            _locality = [[CityDestinationPoi alloc] initWithJson:[json objectForKey:@"locality"]];
        }

        if ([json objectForKey:@"location"] != [NSNull null]) {
            _lng = [[[[json objectForKey:@"location"] objectForKey:@"coordinates"] firstObject] doubleValue];
            _lat = [[[[json objectForKey:@"location"] objectForKey:@"coordinates"] lastObject] doubleValue];
        }
        if ([json objectForKey:@"rating"] == [NSNull null] || ![json objectForKey:@"rating"]) {
            _rating = 3.5;
        } else  if ([[json objectForKey:@"rating"] floatValue] > 1){
            _rating = [[json objectForKey:@"rating"] floatValue];
        } else {
            _rating = [[json objectForKey:@"rating"] floatValue]*5;
        }
        
        NSMutableArray *tempArray = [[NSMutableArray alloc] init];
        for (id imageDic in [json objectForKey:@"images"]) {
            TaoziImage *image = [[TaoziImage alloc] initWithJson:imageDic];
            [tempArray addObject:image];
        }
        _images = tempArray;
        
        _moreCommentsUrl = [json objectForKey:@"moreCommentsUrl"];
        NSMutableArray *commnentArray = [[NSMutableArray alloc] init];
        for (id commentDic in [json objectForKey:@"comments"]) {
            CommentDetail *comment = [[CommentDetail alloc] initWithJson:commentDic];
            [commnentArray addObject:comment];
        }
        _comments = commnentArray;
        _isMyFavorite = [[json objectForKey:@"isFavorite"] boolValue];
    }
    return self;
}

/**
 *  保存时候用来上传的 只包含 id 和类型的路线信息
 *
 *  @return
 */
- (NSDictionary *)enCodeSummaryDataToDictionary
{
    NSMutableDictionary *retDic = [[NSMutableDictionary alloc] init];
    [retDic safeSetObject:_poiId forKey:@"id"];
    
    NSString *poiTypeStr;
    switch (_poiType) {
        case kSpotPoi:
            poiTypeStr = @"vs";
            break;
            
        case kRestaurantPoi:
            poiTypeStr = @"restaurant";
            break;
            
        case kShoppingPoi:
            poiTypeStr = @"shopping";
            break;
            
        case kHotelPoi:
            poiTypeStr = @"hotel";
            break;
            
        default:
            break;
    }
    
    [retDic safeSetObject:poiTypeStr forKey:@"type"];
    return retDic;
}


/**
 * 将所有的字段信息储存为 Dictionary 类型。虽然保存上传的时候只需要上传 id 和 type，但是这里之所以要把所有的字段都集合起来是为了更新“备份路线”
 *
 *  @return
 */
- (NSDictionary *)enCodeAllDataToDictionary
{
    NSMutableDictionary *retDic = [[NSMutableDictionary alloc] init];
    [retDic safeSetObject:_poiId forKey:@"id"];
    [retDic safeSetObject:_zhName forKey:@"zhName"];
    [retDic safeSetObject:_enName forKey:@"enName"];
    [retDic safeSetObject:_desc forKey:@"desc"];
    [retDic safeSetObject:_address forKey:@"address"];
    [retDic safeSetObject:[NSNumber numberWithFloat:_rating] forKey:@"rating"];
    [retDic safeSetObject:[NSNumber numberWithInt:_rank] forKey:@"rank"];
    
    NSString *poiTypeStr;
    
    switch (_poiType) {
        case kSpotPoi:
            poiTypeStr = @"vs";
            break;
            
        case kRestaurantPoi:
            poiTypeStr = @"restaurant";
            break;
            
        case kShoppingPoi:
            poiTypeStr = @"shopping";
            break;
            
        case kHotelPoi:
            poiTypeStr = @"hotel";
            break;
            
        default:
            break;
    }
    
    [retDic safeSetObject:poiTypeStr forKey:@"type"];
    
    NSMutableArray *coordinatesArray = [[NSMutableArray alloc] init];
    [coordinatesArray addObject:[NSNumber numberWithDouble:_lng]];
    [coordinatesArray addObject:[NSNumber numberWithDouble:_lat]];
    [retDic safeSetObject:@{@"coordinates":coordinatesArray} forKey:@"location"];
    
    NSMutableArray *imageArray = [[NSMutableArray alloc] init];
    for (TaoziImage *image in _images) {
        NSMutableDictionary *imageDic = [[NSMutableDictionary alloc] init];
        [imageDic safeSetObject:image.imageUrl forKey:@"url"];
        [imageArray addObject:imageDic];
    }
    
    [retDic safeSetObject:imageArray forKey:@"images"];
    
    NSMutableArray *comments = [[NSMutableArray alloc] init];
    for (CommentDetail *comment in _comments) {
        [comments addObject:[comment enCodeToJson]];
    }
    [retDic safeSetObject:comments forKey:@"comments"];
    
    
    NSMutableDictionary *destinationDic = [[NSMutableDictionary alloc] init];
    [destinationDic safeSetObject:_locality.cityId forKey:@"id"];
    [destinationDic safeSetObject:_locality.zhName forKey:@"zhName"];
    [destinationDic safeSetObject:_locality.enName forKey:@"enName"];
    
    [retDic safeSetObject:destinationDic forKey:@"locality"];
    
    return retDic;
}

- (void)asyncFavoritePoiWithCompletion:(void (^)(BOOL))completion;
{
    AccountManager *accountManager = [AccountManager shareAccountManager];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    AppUtils *utils = [[AppUtils alloc] init];
    [manager.requestSerializer setValue:utils.appVersion forHTTPHeaderField:@"Version"];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"iOS %@",utils.systemVersion] forHTTPHeaderField:@"Platform"];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"%ld", accountManager.account.userId] forHTTPHeaderField:@"UserId"];
    
    if (!self.isMyFavorite) {
        [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
        [manager.requestSerializer setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
        NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
        [params setObject:_poiId forKey:@"itemId"];
        [params setObject:_typeDesc forKey:@"type"];
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        [manager POST:API_FAVORITE parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSLog(@"%@", responseObject);
            NSInteger code = [[responseObject objectForKey:@"code"] integerValue];
            if (code == 0 || code == 401) {
                self.isMyFavorite = !self.isMyFavorite;
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
        NSString *urlStr = [NSString stringWithFormat:@"%@/%@", API_UNFAVORITE, _poiId];
        [manager DELETE:urlStr parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSLog(@"%@", responseObject);
            NSInteger code = [[responseObject objectForKey:@"code"] integerValue];
            if (code == 0) {
                self.isMyFavorite = !self.isMyFavorite;
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

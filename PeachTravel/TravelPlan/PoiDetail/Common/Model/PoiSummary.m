//
//  PoiSummary.m
//  PeachTravel
//
//  Created by liangpengshuai on 12/11/14.
//  Copyright (c) 2014 com.aizou.www. All rights reserved.
//

#import "PoiSummary.h"
#import "RecommendDetail.h"
#import "CommentDetail.h"

@implementation PoiSummary

- (id)initWithJson:(id)json
{
    if (self = [super init]) {
        
        _poiId = [json objectForKey:@"id"];
        _zhName = [json objectForKey:@"zhName"];
        _enName = [json objectForKey:@"enName"];
        _priceDesc = [json objectForKey:@"priceDesc"];
        _desc = [json objectForKey:@"desc"];
        _address = [json objectForKey:@"address"];
        
        if ([[json objectForKey:@"type"] isEqualToString:@"vs"]) {
            _poiType = kSpotPoi;
        }
        if ([[json objectForKey:@"type"] isEqualToString:@"restaurant"]) {
            _poiType = kRestaurantPoi;
        }
        if ([[json objectForKey:@"type"] isEqualToString:@"shopping"]) {
            _poiType = kShoppingPoi;
        }
        if ([[json objectForKey:@"type"] isEqualToString:@"hotel"]) {
            _poiType = kHotelPoi;
        }
        
        if ([[json objectForKey:@"tel"] isKindOfClass:[NSArray class]]) {
            _telephone = [[json objectForKey:@"tel"] firstObject];
        }
        if ([json objectForKey:@"locality"] != [NSNull null]) {
            _locality = [[CityDestinationPoi alloc] initWithJson:[json objectForKey:@"locality"]];
        }
        _timeCost = [json objectForKey:@"timeCostDesc"];
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
        NSMutableArray *recommendArray = [[NSMutableArray alloc] init];
        for (id recommendDic in [json objectForKey:@"recommends"]) {
            RecommendDetail *recommend = [[RecommendDetail alloc] initWithJson:recommendDic];
            [recommendArray addObject:recommend];
        }
        _recommends = recommendArray;
        
        NSMutableArray *commnentArray = [[NSMutableArray alloc] init];
        for (id commentDic in [json objectForKey:@"comments"]) {
            CommentDetail *comment = [[CommentDetail alloc] initWithJson:commentDic];
            [commnentArray addObject:comment];
        }
        _comments = commnentArray;
        _commentCount = [[json objectForKey:@"commentCnt"] integerValue];
        _isMyFavorite = [[json objectForKey:@"isFavorite"] boolValue];
    }
    return self;
}

- (void)setPoiType:(TZPoiType)poiType
{
    _poiType = poiType;
    switch (_poiType) {
        case kRestaurantPoi:
            _poiTypeDesc = @"restaurant";
            break;
            
        case kCityPoi:
            _poiTypeDesc = @"locality";
            break;
        
        case kSpotPoi:
            _poiTypeDesc = @"vs";
            break;
        
        case kHotelPoi:
            _poiTypeDesc = @"hotel";
            break;
            
        case kShoppingPoi:
            _poiTypeDesc = @"shopping";
            break;
            
        default:
            break;
    }
}

/**
 * 将所有的字段信息储存为 Dictionary 类型。虽然保存上传的时候只需要上传 id 和 type，但是这里之所以要把所有的字段都集合起来是为了更新“备份路线”
 *
 *  @return
 */
- (NSDictionary *)prepareAllDataForUpload
{
    NSMutableDictionary *retDic = [[NSMutableDictionary alloc] init];
    [retDic safeSetObject:_poiId forKey:@"id"];
    [retDic safeSetObject:_zhName forKey:@"zhName"];
    [retDic safeSetObject:_enName forKey:@"enName"];
    [retDic safeSetObject:_desc forKey:@"desc"];
    [retDic safeSetObject:_priceDesc forKey:@"priceDesc"];
    [retDic safeSetObject:_address forKey:@"address"];
    [retDic safeSetObject:[NSNumber numberWithFloat:_rating] forKey:@"rating"];
    [retDic safeSetObject:_telephone forKey:@"telephone"];
    [retDic safeSetObject:_timeCost forKey:@"timeCostDesc"];
    
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
    
    NSMutableArray *recommends = [[NSMutableArray alloc] init];
    for (RecommendDetail *recommend in _recommends) {
        [recommends addObject:[recommend enCodeToJson]];
    }
    [retDic safeSetObject:comments forKey:@"recommends"];

    
    NSMutableDictionary *destinationDic = [[NSMutableDictionary alloc] init];
    [destinationDic safeSetObject:_locality.cityId forKey:@"id"];
    [destinationDic safeSetObject:_locality.zhName forKey:@"zhName"];
    [destinationDic safeSetObject:_locality.enName forKey:@"enName"];
    
    [retDic safeSetObject:destinationDic forKey:@"locality"];
    
    return retDic;
}

/**
 *  保存时候用来上传的 只包含 id 和类型的路线信息
 *
 *  @return
 */
- (NSDictionary *)prepareSummaryDataForUpdateBackUpTrip
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


@end

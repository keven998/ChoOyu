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
        if ([[json objectForKey:@"tel"] isKindOfClass:[NSArray class]]) {
            _telephone = [[json objectForKey:@"tel"] firstObject];
        }
        _timeCost = [json objectForKey:@"timeCost"];
        _lng = [[[[json objectForKey:@"location"] objectForKey:@"coordinates"] firstObject] doubleValue];
        _lat = [[[[json objectForKey:@"location"] objectForKey:@"coordinates"] lastObject] doubleValue];
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

@end

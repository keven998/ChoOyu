//
//  RecommendDetail.m
//  PeachTravel
//
//  Created by liangpengshuai on 11/22/14.
//  Copyright (c) 2014 com.aizou.www. All rights reserved.
//

#import "RecommendDetail.h"
#import "TaoziImage.h"

@implementation RecommendDetail

- (id)initWithJson:(id)json
{
    if (self = [super init]) {
        _title = [json objectForKey:@"title"];
        NSMutableArray *tempArray = [[NSMutableArray alloc] init];
        for (id imageDic in [json objectForKey:@"images"]) {
            TaoziImage *image = [[TaoziImage alloc] initWithJson:imageDic];
            [tempArray addObject:image];
        }
        _images = tempArray;
    }
    return self;
}

- (id)enCodeToJson
{
    NSMutableDictionary *retDic = [[NSMutableDictionary alloc] init];
    [retDic safeSetObject:_title forKey:@"title"];
    NSMutableArray *imageArray = [[NSMutableArray alloc] init];
    for (TaoziImage *image in _images) {
        NSMutableDictionary *imageDic = [[NSMutableDictionary alloc] init];
        [imageDic safeSetObject:image.imageUrl forKey:@"url"];
        [imageArray addObject:imageDic];
    }
    
    [retDic safeSetObject:imageArray forKey:@"images"];
    return retDic;
}

@end

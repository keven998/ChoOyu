//
//  RestaurantPoi.m
//  PeachTravel
//
//  Created by liangpengshuai on 11/22/14.
//  Copyright (c) 2014 com.aizou.www. All rights reserved.
//

#import "RestaurantPoi.h"
#import "TaoziImage.h"
#import "RecommendDetail.h"
#import "CommentDetail.h"

@implementation RestaurantPoi


- (id)initWithJson:(id)json
{
    if (self = [super init]) {
        
        _restaurantId = [json objectForKey:@"restaurantId"];
        _zhName = [json objectForKey:@"zhName"];
        _enName = [json objectForKey:@"enName"];
        _priceDesc = [json objectForKey:@"priceDesc"];
        _desc = [json objectForKey:@"desc"];
        _address = [json objectForKey:@"address"];
        _telephone = [json objectForKey:@"telephone"];
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
    }
    return self;
}

@end



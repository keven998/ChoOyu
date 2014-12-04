//
//  Favorite.m
//  PeachTravel
//
//  Created by liangpengshuai on 12/4/14.
//  Copyright (c) 2014 com.aizou.www. All rights reserved.
//

#import "Favorite.h"

@implementation Favorite

- (id)initWithJson:(id)json
{
    if (self = [super init]) {
        _favoriteId = [json objectForKey:@"id"];
        _itemId = [json objectForKey:@"itemId"];
        _type = [json objectForKey:@"type"];
        _zhName = [json objectForKey:@"zhName"];
        _enName = [json objectForKey:@"enName"];
        NSMutableArray *imagesArray = [[NSMutableArray alloc] init];
        for (id imageDic in [json objectForKey:@"images"]) {
            [imagesArray addObject:[[TaoziImage alloc] initWithJson:imageDic]];
        }
        _images = imagesArray;
    }
    return self;
}

@end

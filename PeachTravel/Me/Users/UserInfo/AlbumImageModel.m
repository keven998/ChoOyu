//
//  AlbumImageModel.m
//  PeachTravel
//
//  Created by liangpengshuai on 9/21/15.
//  Copyright © 2015 com.aizou.www. All rights reserved.
//

#import "AlbumImageModel.h"

@implementation AlbumImageModel

- (id)initWithJson:(id)json
{
    if (self = [super init]) {
        _imageId = [json objectForKey:@"id"];
        if ([[json objectForKey:@"image"] objectForKey:@"caption"] != [NSNull null]) {
            _imageDesc = [[json objectForKey:@"image"] objectForKey:@"caption"];
        }
        _imageUrl = [[json objectForKey:@"image"] objectForKey:@"url"];
        _createTime = [[json objectForKey:@"cTime"] longValue];
    }
    return self;
}

@end

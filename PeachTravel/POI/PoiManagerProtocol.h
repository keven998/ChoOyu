//
//  PoiManagerProtocol.h
//  PeachTravel
//
//  Created by liangpengshuai on 3/18/15.
//  Copyright (c) 2015 com.aizou.www. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol PoiManagerProtocol <NSObject>

@optional

/**
 *  所有 poi 的收藏接口
 *
 *  @param isFavorite 是收藏还是取消收藏 yes ： 收藏    no：取消收藏
 *  @param completion 收藏回调
 */
- (void)asyncFavoritePoiWithCompletion:(void (^)(BOOL))completion;

@end

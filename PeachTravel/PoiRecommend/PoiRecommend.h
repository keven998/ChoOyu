//
//  PoiRecommend.h
//  PeachTravel
//
//  Created by liangpengshuai on 9/28/15.
//  Copyright © 2015 com.aizou.www. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PoiRecommend : NSObject

@property (nonatomic, copy) NSString *recommondId;
@property (nonatomic, copy) NSString *zhName;
@property (nonatomic, copy) NSString *enName;

@property (nonatomic, copy) NSString *desc;
@property (nonatomic, copy) NSString *linkUrl;
@property (nonatomic, copy) NSArray * images;
@property (nonatomic) TZPoiType poiType;

- (id) initWithJson:(id)data;

@end

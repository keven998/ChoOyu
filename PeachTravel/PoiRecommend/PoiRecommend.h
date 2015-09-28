//
//  PoiRecommend.h
//  PeachTravel
//
//  Created by liangpengshuai on 9/28/15.
//  Copyright © 2015 com.aizou.www. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PoiRecommend : NSObject

@property (nonatomic, strong) NSString *recommondId;
@property (nonatomic, strong) NSString *zhName;
@property (nonatomic, strong) NSString *desc;
@property (nonatomic, strong) NSString *linkUrl;
@property (nonatomic, strong) NSArray * images;
@property (nonatomic) TZPoiType poiType;

- (id) initWithJson:(id)data;

@end

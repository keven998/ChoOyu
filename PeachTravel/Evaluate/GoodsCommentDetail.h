//
//  GoodsCommentDetail.h
//  PeachTravel
//
//  Created by liangpengshuai on 1/22/16.
//  Copyright © 2016 com.aizou.www. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GoodsDetailModel.h"

@interface GoodsCommentDetail : NSObject

@property (nonatomic, strong) GoodsDetailModel *goodsDetail;  //评价的商品
@property (nonatomic, strong) NSArray <TaoziImage *>* images;
@property (nonatomic, copy) NSString *content;
@property (nonatomic, copy) NSString *publishTime;

- (id)initWithJson:(id)json;

@end

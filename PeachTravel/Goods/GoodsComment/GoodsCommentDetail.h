//
//  GoodsCommentDetail.h
//  PeachTravel
//
//  Created by liangpengshuai on 1/22/16.
//  Copyright © 2016 com.aizou.www. All rights reserved.
//

#import <Foundation/Foundation.h>

@class OrderDetailModel;

@interface GoodsCommentDetail : NSObject

@property (nonatomic, strong) OrderDetailModel *orderDetail;  //与此条评价相关的订单信息

@property (nonatomic, strong) NSArray <TaoziImage *>* images;
@property (nonatomic, copy) NSString *commentId;
@property (nonatomic, copy) NSString *contents;
@property (nonatomic) float rating;
@property (nonatomic) BOOL isAnonymous;
@property (nonatomic, copy) NSString *publishTime;
@property (nonatomic, strong) FrendModel *commentUser;   //评价人

- (id)initWithJson:(id)json;

@end

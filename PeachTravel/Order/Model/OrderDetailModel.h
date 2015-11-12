//
//  OrderDetailModel.h
//  PeachTravel
//
//  Created by liangpengshuai on 11/10/15.
//  Copyright © 2015 com.aizou.www. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OrderTravelerInfoModel.h"
#import "OrderContactInfoModel.h"

@interface OrderDetailModel : NSObject

@property (nonatomic, copy) NSString *orderId;
@property (nonatomic, copy) NSString *orderName;
@property (nonatomic) float totalPrice;             //总价格
@property (nonatomic, copy) NSString *goodsId;      //商品 ID
@property (nonatomic, copy) NSString *packageId;     //套餐 ID
@property (nonatomic) NSInteger count;          //订单数量
@property (nonatomic, strong) NSArray<OrderTravelerInfoModel *> *travelerList;    //旅客信息列表
@property (nonatomic, strong) OrderContactInfoModel *orderContact;       //订单的联系人

@end

//
//  BNOrderDetailModel.h
//  PeachTravel
//
//  Created by liangpengshuai on 3/10/16.
//  Copyright © 2016 com.aizou.www. All rights reserved.
//

#import "OrderDetailModel.h"

@interface BNOrderDetailModel : OrderDetailModel

//商家版本的订单状态描述
@property (nonatomic, copy, readonly) NSString *BNOrderStatusDesc;

@end

//
//  UserCouponDetail.h
//  PeachTravel
//
//  Created by liangpengshuai on 2/18/16.
//  Copyright © 2016 com.aizou.www. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserCouponDetail : NSObject

@property (nonatomic, copy) NSString *couponId;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *desc;
@property (nonatomic, copy) NSString *useDateDesc;
@property (nonatomic) float discount;
@property (nonatomic) float limitMoney;

- (id)initWithJson:(id)json;

@end

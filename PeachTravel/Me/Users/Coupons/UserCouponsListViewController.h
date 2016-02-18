//
//  UserCouponsListViewController.h
//  PeachTravel
//
//  Created by liangpengshuai on 2/18/16.
//  Copyright © 2016 com.aizou.www. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserCouponDetail.h"

@protocol UserCouponsListViewControllerDelegate <NSObject>

@optional
- (void)didSelectedCoupon:(UserCouponDetail *)coupon;

@end

@interface UserCouponsListViewController : TZViewController

@property (nonatomic) NSInteger userId;
@property (nonatomic) BOOL canSelect;  //是否可以选择

@property (nonatomic, weak) id<UserCouponsListViewControllerDelegate>delegate;

@property (nonatomic, strong) UserCouponDetail *selectedCoupon;  //已选中的优惠券

@end

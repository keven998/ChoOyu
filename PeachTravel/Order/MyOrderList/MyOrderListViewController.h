//
//  MyOrderListViewController.h
//  PeachTravel
//
//  Created by liangpengshuai on 11/18/15.
//  Copyright © 2015 com.aizou.www. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OrderDetailModel.h"

@interface MyOrderListViewController : UIViewController

//订单状态列表 空数组代表全部类型
@property (nonatomic, strong) NSArray *orderTypes;

@end

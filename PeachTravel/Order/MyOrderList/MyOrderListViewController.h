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

@property (nonatomic) OrderStatus orderType;

@property (nonatomic, strong) NSArray<OrderDetailModel *> *dataSource;

@end

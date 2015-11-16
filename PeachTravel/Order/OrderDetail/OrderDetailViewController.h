//
//  OrderDetailViewController.h
//  PeachTravel
//
//  Created by liangpengshuai on 11/13/15.
//  Copyright © 2015 com.aizou.www. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OrderDetailModel.h"

@interface OrderDetailViewController : TZViewController

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, strong) OrderDetailModel *orderDetail;

@end

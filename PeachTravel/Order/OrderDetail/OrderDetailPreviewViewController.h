//
//  OrderDetailPreviewViewController.h
//  PeachTravel
//
//  Created by liangpengshuai on 12/24/15.
//  Copyright © 2015 com.aizou.www. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OrderDetailModel.h"

@interface OrderDetailPreviewViewController : TZViewController

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, strong) OrderDetailModel *orderDetail;
@property (nonatomic) NSInteger orderId;

@end

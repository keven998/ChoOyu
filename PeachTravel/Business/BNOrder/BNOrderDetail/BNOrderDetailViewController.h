//
//  BNOrderDetailViewController.h
//  PeachTravel
//
//  Created by liangpengshuai on 3/16/16.
//  Copyright © 2016 com.aizou.www. All rights reserved.
//

#import "TZViewController.h"
#import "BNOrderDetailModel.h"

@interface BNOrderDetailViewController : TZViewController

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, strong) BNOrderDetailModel *orderDetail;

@property (nonatomic) NSInteger orderId;

@end

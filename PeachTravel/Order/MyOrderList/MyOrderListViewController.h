//
//  MyOrderListViewController.h
//  PeachTravel
//
//  Created by liangpengshuai on 12/11/15.
//  Copyright © 2015 com.aizou.www. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyOrderListViewController : TZViewController
@property (weak, nonatomic) IBOutlet UITableView *tableView;
//订单状态列表 空数组代表全部类型
@property (nonatomic, strong) NSArray *orderTypes;

@property (nonatomic, copy) NSString *titleStr;
@end

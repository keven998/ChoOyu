//
//  MyOrderListTableViewController.m
//  PeachTravel
//
//  Created by liangpengshuai on 11/18/15.
//  Copyright © 2015 com.aizou.www. All rights reserved.
//

#import "MyOrderListTableViewController.h"
#import "MyOrderTableViewCell.h"
#import "OrderDetailViewController.h"
#import "MJRefresh.h"
#import "OrderManager.h"

@interface MyOrderListTableViewController ()

@property (nonatomic, strong) NSArray<OrderDetailModel *> *dataSource;

@end

@implementation MyOrderListTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.rowHeight = 150.0;
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.tableView.backgroundColor = APP_PAGE_COLOR;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView registerNib:[UINib nibWithNibName:@"MyOrderTableViewCell" bundle:nil] forCellReuseIdentifier:@"myOrderCell"];
    NSMutableArray *statusArray = [[NSMutableArray alloc] init];
    for (NSNumber *status in _orderTypes) {
        NSString *orderServerStatus = [OrderManager orderServerStatusWithLocalStatus:[status integerValue]];
        [statusArray addObject:orderServerStatus];
    }
    [OrderManager asyncLoadOrdersFromServerOfUser:[AccountManager shareAccountManager].account.userId orderType:statusArray startIndex:_dataSource.count count:15 completionBlock:^(BOOL isSuccess, NSArray<OrderDetailModel *> *orderList) {
        if (isSuccess) {
            _dataSource = orderList;
            [self.tableView reloadData];
        }
    }];
    self.tableView.footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        
    }];
    self.tableView.tableHeaderView = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        
    }];
    
}

- (void)setDataSource:(NSArray *)dataSource
{
    _dataSource = dataSource;
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return _dataSource.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 10;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0.01;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    OrderDetailModel *order = [_dataSource objectAtIndex:indexPath.section];
    MyOrderTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"myOrderCell" forIndexPath:indexPath];
    cell.orderDetail = order;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    OrderDetailViewController *ctl = [[OrderDetailViewController alloc] init];
    ctl.orderDetail = [_dataSource objectAtIndex:indexPath.section];
    ctl.orderId = [_dataSource objectAtIndex:indexPath.section].orderId;
    [self.navigationController pushViewController:ctl animated:YES];
}

@end

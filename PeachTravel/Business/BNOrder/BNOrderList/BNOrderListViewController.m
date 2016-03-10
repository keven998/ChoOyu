//
//  BNOrderListViewController.m
//  PeachTravel
//
//  Created by liangpengshuai on 3/9/16.
//  Copyright © 2016 com.aizou.www. All rights reserved.
//

#import "BNOrderListViewController.h"
#import "BNOrderListTableViewCell.h"
#import "OrderManager+BNOrderManager.h"

@interface BNOrderListViewController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, strong) NSMutableArray *dataSource;

@end

@implementation BNOrderListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [_tableView registerNib:[UINib nibWithNibName:@"BNOrderListTableViewCell" bundle:nil] forCellReuseIdentifier:@"BNOrderListTableViewCell"];
    [OrderManager asyncLoadOrdersFromServerOfStore:[AccountManager shareAccountManager].account.userId orderType:@[] startIndex:0 count:15 completionBlock:^(BOOL isSuccess, NSArray<OrderDetailModel *> *orderList) {
        if (isSuccess) {
            _dataSource = [orderList mutableCopy];
            [_tableView reloadData];
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 10;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return CGFLOAT_MIN;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return _dataSource.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 180;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    BNOrderListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BNOrderListTableViewCell" forIndexPath:indexPath];
    cell.orderDetail = [_dataSource objectAtIndex:indexPath.section];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end

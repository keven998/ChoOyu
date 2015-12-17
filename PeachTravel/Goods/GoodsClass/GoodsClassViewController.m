//
//  GoodsClassViewController.m
//  PeachTravel
//
//  Created by liangpengshuai on 12/17/15.
//  Copyright © 2015 com.aizou.www. All rights reserved.
//

#import "GoodsClassViewController.h"
#import "GoodsListTableViewCell.h"
#import "GoodsDetailViewController.h"

@interface GoodsClassViewController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, strong) NSArray *dataSource;

@end

@implementation GoodsClassViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _tableView.delegate = self;
    _tableView.dataSource = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0.01;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.01;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _dataSource.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 108;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    GoodsListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"goodsListCell" forIndexPath:indexPath];
    cell.goodsDetail = [_dataSource objectAtIndex:indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    GoodsDetailViewController *ctl = [[GoodsDetailViewController alloc] init];
    GoodsDetailModel *goodsDetail = [_dataSource objectAtIndex:indexPath.row];
    ctl.goodsId = goodsDetail.goodsId;
    [self.navigationController pushViewController:ctl animated:YES];
}

@end

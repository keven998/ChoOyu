//
//  BNGoodsListViewController.m
//  PeachTravel
//
//  Created by liangpengshuai on 3/7/16.
//  Copyright © 2016 com.aizou.www. All rights reserved.
//

#import "BNGoodsListViewController.h"
#import "BNGoodsListTableViewCell.h"
#import "GoodsManager+BNGoodsManager.h"
#import "BNGoodsDetailViewController.h"

@interface BNGoodsListViewController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, strong) NSMutableArray<BNGoodsDetailModel *> *dataSource;

@end

@implementation BNGoodsListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.separatorColor = COLOR_LINE;
    [_tableView registerNib:[UINib nibWithNibName:@"BNGoodsListTableViewCell" bundle:nil] forCellReuseIdentifier:@"BNGoodsListTableViewCell"];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [GoodsManager asyncLoadGoodsOfStore:_storeId goodsStatus:_goodsStatus startIndex:-1 count:0 completionBlock:^(BOOL isSuccess, NSArray *goodsList) {
        _dataSource = [goodsList mutableCopy];
        [self.tableView reloadData];
    }];
}

//商品下架
- (void)disableGoodsAction:(UIButton *)sender
{
    [GoodsManager asyncDisableGoods:[_dataSource objectAtIndex:sender.tag].goodsId completionBlock:^(BOOL isSuccess, NSString *errDesc) {
        if (isSuccess) {
            [SVProgressHUD showHint:@"商品下架成功"];
            [_dataSource removeObjectAtIndex:sender.tag];
            [self.tableView reloadData];
        } else {
            [SVProgressHUD showHint:@"商品下架失败"];
        }
    }];
}

//商品上架
- (void)onSaleGoodsAction:(UIButton *)sender
{
    [GoodsManager asyncOnsaleGoods:[_dataSource objectAtIndex:sender.tag].goodsId completionBlock:^(BOOL isSuccess, NSString *errDesc) {
        if (isSuccess) {
            [SVProgressHUD showHint:@"商品上架成功"];
            [_dataSource removeObjectAtIndex:sender.tag];
            [self.tableView reloadData];

        } else {
            [SVProgressHUD showHint:@"商品上架失败"];
        }
    }];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 5;
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
    return 150;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    BNGoodsListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BNGoodsListTableViewCell" forIndexPath:indexPath];
    cell.actionButton.tag = indexPath.section;
    cell.goodsDetail = [_dataSource objectAtIndex:indexPath.section];
    if (cell.goodsDetail.goodsStatus == kOnSale) {
        [cell.actionButton addTarget:self action:@selector(disableGoodsAction:) forControlEvents:UIControlEventTouchUpInside];
        
    } else if (cell.goodsDetail.goodsStatus == kOffSale) {
        [cell.actionButton addTarget:self action:@selector(disableGoodsAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    BNGoodsDetailViewController *ctl = [[BNGoodsDetailViewController alloc] init];
    ctl.goodsId = [_dataSource objectAtIndex:indexPath.section].goodsId;
    [_containerCtl.navigationController pushViewController:ctl animated:YES];
}

@end

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

@interface BNGoodsListViewController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, strong) NSMutableArray *dataSource;

@end

@implementation BNGoodsListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.separatorColor = COLOR_LINE;
    [_tableView registerNib:[UINib nibWithNibName:@"BNGoodsListTableViewCell" bundle:nil] forCellReuseIdentifier:@"BNGoodsListTableViewCell"];
    
    _storeId = 100012;
    [GoodsManager asyncLoadGoodsOfStore:_storeId goodsStatus:_goodsStatus startIndex:0 count:15 completionBlock:^(BOOL isSuccess, NSArray *goodsList) {
        _dataSource = [goodsList mutableCopy];
        [self.tableView reloadData];
    }];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return CGFLOAT_MIN;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return CGFLOAT_MIN;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _dataSource.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 150;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    BNGoodsListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BNGoodsListTableViewCell" forIndexPath:indexPath];
    cell.goodsDetail = [_dataSource objectAtIndex:indexPath.row];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end

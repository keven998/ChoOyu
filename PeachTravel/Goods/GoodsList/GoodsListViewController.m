//
//  GoodsListViewController.m
//  PeachTravel
//
//  Created by liangpengshuai on 11/6/15.
//  Copyright © 2015 com.aizou.www. All rights reserved.
//

#import "GoodsListViewController.h"
#import "GoodsListTableViewCell.h"
#import "GoodsManager.h"
#import "MakeOrderViewController.h"
#import "MyOrderRootViewController.h"

@interface GoodsListViewController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UIButton *scroll2TopBtn;

@property (nonatomic, strong) NSArray *dataSource;

@end

@implementation GoodsListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"商品列表";
    self.automaticallyAdjustsScrollViewInsets = NO;
    [_tableView registerNib:[UINib nibWithNibName:@"GoodsListTableViewCell" bundle:nil] forCellReuseIdentifier:@"goodsListCell"];
    _tableView.separatorColor = COLOR_LINE;
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _tableView.bounds.size.width, 49)];
    _sortBtn.spaceWidth = 5;
    _categoryBtn.spaceWidth = 5;
    _sortBtn.imagePosition = IMAGE_AT_RIGHT;
    _categoryBtn.imagePosition = IMAGE_AT_RIGHT;
    _scroll2TopBtn.hidden = YES;
    [_scroll2TopBtn addTarget:self action:@selector(scroll2Top) forControlEvents:UIControlEventTouchUpInside];
    [GoodsManager asyncLoadGoodsOfCity:_cityId completionBlock:^(BOOL isSuccess, NSArray *goodsList) {
        _dataSource = goodsList;
        [self.tableView reloadData];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)scroll2Top
{
    [self.tableView setContentOffset:CGPointZero animated:YES];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
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
    if (indexPath.row == 0) {
        MakeOrderViewController *ctl = [[MakeOrderViewController alloc] init];
        ctl.goodsModel = [_dataSource objectAtIndex:indexPath.row];
        [self.navigationController pushViewController:ctl animated:YES];
    } else {
        MyOrderRootViewController *ctl = [[MyOrderRootViewController alloc] init];
        [self.navigationController pushViewController:ctl animated:YES];
    }
 
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView.contentOffset.y > scrollView.bounds.size.height) {
        _scroll2TopBtn.hidden = NO;
    } else {
        _scroll2TopBtn.hidden = YES;
    }
}
@end

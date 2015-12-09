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
#import "GoodsDetailViewController.h"
#import "DOPDropDownMenu.h"
#import "MJRefresh.h"

#define pageCount 15    //每页加载数量

@interface GoodsListViewController () <UITableViewDataSource, UITableViewDelegate, DOPDropDownMenuDataSource, DOPDropDownMenuDelegate>

@property (weak, nonatomic) IBOutlet UIButton *scroll2TopBtn;
@property (nonatomic, strong) DOPDropDownMenu *menu;

@property (nonatomic, strong) NSArray *dataSource;
@property (nonatomic, strong) NSArray *categoryDatasource;
@property (nonatomic, strong) NSArray *sortDataSource;
@property (nonatomic, copy) NSString *category;
@property (nonatomic, copy) NSString *sortTitle;
@property (nonatomic, copy) NSString *sortType;
@property (nonatomic, copy) NSString *sortValue;

@end

@implementation GoodsListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"商品列表";
    _sortDataSource = @[@"推荐排序", @"销量最高", @"价格最低", @"价格最高"];
    _categoryDatasource = @[@"全部"];
    [_tableView registerNib:[UINib nibWithNibName:@"GoodsListTableViewCell" bundle:nil] forCellReuseIdentifier:@"goodsListCell"];
    _tableView.separatorColor = COLOR_LINE;
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _scroll2TopBtn.hidden = YES;
    [_scroll2TopBtn addTarget:self action:@selector(scroll2Top) forControlEvents:UIControlEventTouchUpInside];
    [GoodsManager asyncLoadGoodsOfCity:_cityId category:_category sortBy:_sortType sortValue:_sortValue startIndex:0 count:pageCount completionBlock:^(BOOL isSuccess, NSArray *goodsList) {
        if (isSuccess) {
            NSMutableArray *tempArray = [[NSMutableArray alloc] initWithArray:_dataSource];
            [tempArray addObjectsFromArray:goodsList];
            _dataSource = tempArray;
            [_tableView reloadData];
        }
    }];
    DOPDropDownMenu *menu = [[DOPDropDownMenu alloc] initWithOrigin:CGPointMake(0, 64) andHeight:41];
    menu.separatorColor = COLOR_LINE;
    [self.view addSubview:menu];
    self.menu = menu;
    menu.dataSource = self;
    menu.delegate = self;
    [GoodsManager asyncLoadGoodsCategoryOfLocality:_cityId completionBlock:^(BOOL isSuccess, NSArray<NSString *> *categoryList) {
        _categoryDatasource = categoryList;
    }];
    
    UIView *spaceView = [[UIView alloc] initWithFrame:CGRectMake(menu.bounds.size.width/2, 5, 0.5, 30)];
    spaceView.backgroundColor = COLOR_LINE;
    [menu addSubview:spaceView];
    
    self.tableView.footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        [GoodsManager asyncLoadGoodsOfCity:_cityId category:_category sortBy:_sortType sortValue:_sortValue startIndex:[_dataSource count] count:pageCount completionBlock:^(BOOL isSuccess, NSArray *goodsList) {
            if (isSuccess) {
                NSMutableArray *tempArray = [[NSMutableArray alloc] initWithArray:_dataSource];
                [tempArray addObjectsFromArray:goodsList];
                _dataSource = tempArray;
                [_tableView reloadData];
                [_tableView.footer endRefreshing];
                if (goodsList.count < pageCount) {
                    [_tableView.footer endRefreshingWithNoMoreData];
                }
            }
        }];
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

#pragma mark - UISCrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView.contentOffset.y > scrollView.bounds.size.height) {
        _scroll2TopBtn.hidden = NO;
    } else {
        _scroll2TopBtn.hidden = YES;
    }
}

#pragma mark - DOPDropDownMenuDataSource

- (NSInteger)numberOfColumnsInMenu:(DOPDropDownMenu *)menu {
    return 2;
}

- (NSInteger)menu:(DOPDropDownMenu *)menu numberOfRowsInColumn:(NSInteger)column {
    if (column == 0) {
        return _categoryDatasource.count;
    } else {
        return _sortDataSource.count;
    }
}

- (NSString *)menu:(DOPDropDownMenu *)menu titleForRowAtIndexPath:(DOPIndexPath *)indexPath {
    if (indexPath.column == 0) {
        return _categoryDatasource[indexPath.row];
    } else {
        return _sortDataSource[indexPath.row];
    }
}

- (void)menu:(DOPDropDownMenu *)menu didSelectRowAtIndexPath:(DOPIndexPath *)indexPath {
    if (indexPath.column == 0) {
        if ([_category isEqualToString:[_categoryDatasource objectAtIndex:indexPath.row]]) {
            return;
        }
        _category = [_categoryDatasource objectAtIndex:indexPath.row];

    } else if (indexPath.column == 1) {
        if ([_sortTitle isEqualToString:[_sortDataSource objectAtIndex:indexPath.row]]) {
            return;
        }
        _sortTitle = [_sortDataSource objectAtIndex:indexPath.row];
        if (indexPath.row == 0) {
            _sortType = nil;
            _sortValue = nil;
        } else if (indexPath.row == 1) {
            _sortType = @"salesVolume";
            _sortValue = @"asc";
        } else if (indexPath.row == 1) {
            _sortType = @"price";
            _sortValue = @"desc";
        } else if (indexPath.row == 1) {
            _sortType = @"price";
            _sortValue = @"asc";
        }
    }
    _dataSource = @[];
    [self.tableView reloadData];
    [GoodsManager asyncLoadGoodsOfCity:_cityId category:_category sortBy:_sortType sortValue:_sortValue startIndex:[_dataSource count] count:pageCount completionBlock:^(BOOL isSuccess, NSArray *goodsList) {
        _dataSource = goodsList;
        [self.tableView reloadData];
    }];

}

@end


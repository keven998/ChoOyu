//
//  CityDetailViewController.m
//  PeachTravel
//
//  Created by liangpengshuai on 11/4/15.
//  Copyright © 2015 com.aizou.www. All rights reserved.
//

#import "CityDetailViewController.h"
#import "CityDetailHeaderView.h"
#import "GoodsOfCityTableViewCell.h"
#import "GoodsDetailViewController.h"
#import "AddPoiViewController.h"
#import "SuperWebViewController.h"
#import "PoisOfCityViewController.h"
#import "TravelNoteListViewController.h"
#import "PoiManager.h"
#import "GoodsManager.h"
#import "GoodsListViewController.h"

@interface CityDetailViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong)  CityDetailHeaderView *headerView;
@property (nonatomic, strong)  NSArray *dataSource;
@property (nonatomic, strong) CityPoi *poi;
@end

@implementation CityDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = _cityName;
    self.view.backgroundColor = [UIColor whiteColor];
    self.automaticallyAdjustsScrollViewInsets = NO;
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kWindowWidth, kWindowHeight)];
    [_tableView registerNib:[UINib nibWithNibName:@"GoodsOfCityTableViewCell" bundle:nil] forCellReuseIdentifier:@"goodsOfCityTableViewCell"];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _tableView.bounds.size.width, 49)];
    [self.view addSubview:_tableView];
    [PoiManager asyncLoadCityInfo:_cityId completionBlock:^(BOOL isSuccess, CityPoi *cityDetail) {
        if (isSuccess) {
            _poi = cityDetail;
            _headerView = [[CityDetailHeaderView alloc] initWithFrame:CGRectMake(0, 0, kWindowWidth, 460)];
            _headerView.cityPoi = _poi;
            _tableView.tableHeaderView = _headerView;
            _headerView.containerViewController = self;
        } else {
            [SVProgressHUD showHint:@"加载失败"];
        }
        
    }];
    [GoodsManager asyncLoadGoodsOfCity:_cityId completionBlock:^(BOOL isSuccess, NSArray *goodsList) {
        if (isSuccess) {
            _dataSource = goodsList;
            [_tableView reloadData];
        }
    }];
    [self setupToolBar];
}

- (void)setupToolBar
{
    UIButton *showAllGoodsButton = [[UIButton alloc] initWithFrame:CGRectMake(0, kWindowHeight-49, kWindowWidth, 49)];
    showAllGoodsButton.backgroundColor = [UIColor whiteColor];
    [showAllGoodsButton setTitle:@"查看全部玩乐" forState:UIControlStateNormal];
    [showAllGoodsButton setTitleColor:APP_THEME_COLOR forState:UIControlStateNormal];
    [showAllGoodsButton addTarget:self action:@selector(showAllGoodsAction) forControlEvents:UIControlEventTouchUpInside];
    
    UIView *spaceView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, showAllGoodsButton.bounds.size.width, 0.5)];
    spaceView.backgroundColor = COLOR_LINE;
    [showAllGoodsButton addSubview:spaceView];
    [self.view addSubview:showAllGoodsButton];
}

- (void)showAllGoodsAction
{
    GoodsListViewController *ctl = [[GoodsListViewController alloc] init];
    [self.navigationController pushViewController:ctl animated:YES];
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
    return 173.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 40.0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *sectionHeaderViedw = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 40)];
    UIView *spaceView = [[UIView alloc] initWithFrame:CGRectMake(0, 39.5, tableView.bounds.size.width, 0.5)];
    spaceView.backgroundColor = APP_THEME_COLOR;
    [sectionHeaderViedw addSubview:spaceView];
    UIView *topSpaceView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 0.5)];
    topSpaceView.backgroundColor = COLOR_LINE;
    [sectionHeaderViedw addSubview:topSpaceView];
    
    UIButton *headerBtn = [[UIButton alloc] initWithFrame:CGRectMake(10, 0, 200, 40)];
    [headerBtn setImage:[UIImage imageNamed:@"icon_cityDetail_goodsSection"] forState:UIControlStateNormal];
    headerBtn.titleEdgeInsets = UIEdgeInsetsMake(0, 15, 0, 0);
    headerBtn.titleLabel.font = [UIFont systemFontOfSize:16.0];
    [headerBtn setTitle:@"当地玩乐" forState:UIControlStateNormal];
    [headerBtn setTitleColor:COLOR_TEXT_I forState:UIControlStateNormal];
    headerBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [sectionHeaderViedw addSubview:headerBtn];
    return sectionHeaderViedw;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    GoodsOfCityTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"goodsOfCityTableViewCell" forIndexPath:indexPath];
    cell.goodsDetail = [_dataSource objectAtIndex:indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    GoodsDetailViewController *ctl = [[GoodsDetailViewController alloc] init];
    ctl.hidesBottomBarWhenPushed = YES;
    
    [self.navigationController pushViewController:ctl animated:YES];
}

@end

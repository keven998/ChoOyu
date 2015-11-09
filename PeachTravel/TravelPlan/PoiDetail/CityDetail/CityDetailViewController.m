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

@interface CityDetailViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong)  CityDetailHeaderView *headerView;

@end

@implementation CityDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.automaticallyAdjustsScrollViewInsets = NO;
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kWindowWidth, kWindowHeight)];
    [_tableView registerNib:[UINib nibWithNibName:@"GoodsOfCityTableViewCell" bundle:nil] forCellReuseIdentifier:@"goodsOfCityTableViewCell"];
    _headerView = [[CityDetailHeaderView alloc] initWithFrame:CGRectMake(0, 0, kWindowWidth, 460)];
    _tableView.tableHeaderView = _headerView;
    _tableView.delegate = self;
    _tableView.dataSource = self;
    self.navigationItem.title = @"北京";
    [self.view addSubview:_tableView];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 5;
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

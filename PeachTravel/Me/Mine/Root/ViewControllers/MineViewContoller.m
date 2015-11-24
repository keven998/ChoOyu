//
//  MineViewContoller.m
//  PeachTravel
//
//  Created by 王聪 on 15/9/1.
//  Copyright (c) 2015年 com.aizou.www. All rights reserved.
//

#import "MineViewContoller.h"
#import "MineProfileViewController.h"
#import "SettingHomeViewController.h"
#import "MineHeaderView.h"
#import "FavoriteViewController.h"
#import "PlansListTableViewController.h"
#import "ContactListViewController.h"
#import "TravelerListViewController.h"

@interface MineViewContoller () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) MineHeaderView *mineHeaderView;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *dataSource;


@end

@implementation MineViewContoller

#pragma mark - lifeCycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    _dataSource = @[
                    @[
                        @{@"title": @"我的收藏", @"image": @"icon_mine_favorite"},
                        @{@"title": @"我的旅行计划", @"image": @"icon_mine_guides"}
                        ],
                    @[
                        @{@"title": @"通讯录", @"image": @"icon_mine_contact"},
                        @{@"title": @"常用旅客信息", @"image": @"icon_mine_traveler"}
                        ],
                    ];

    self.view.backgroundColor = APP_PAGE_COLOR;

    self.automaticallyAdjustsScrollViewInsets = NO;
    _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    _tableView.backgroundColor = [UIColor clearColor];
    _tableView.separatorColor = COLOR_LINE;
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.rowHeight = 50;
    _tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kWindowWidth, 49)];

    [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
    [self.view addSubview:_tableView];
    _mineHeaderView = [[MineHeaderView alloc] initWithFrame:CGRectMake(0, 0, kWindowWidth, 310)];
    _mineHeaderView.containerViewController = self;
    _mineHeaderView.account = [AccountManager shareAccountManager].account;
    _tableView.tableHeaderView = _mineHeaderView;
    
    UIView *navigationBar = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 64)];
    [self.view addSubview:navigationBar];
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 44)];
    titleLabel.center = CGPointMake(navigationBar.bounds.size.width/2,42);
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.text = @"我的";
    [navigationBar addSubview:titleLabel];
    UIButton *settingButton = [[UIButton alloc] initWithFrame:CGRectMake(navigationBar.bounds.size.width-40, 20, 40, 44)];
    [settingButton setImage:[UIImage imageNamed:@"icon_mine_setting"] forState:UIControlStateNormal];
    [settingButton addTarget:self action:@selector(settingAction) forControlEvents:UIControlEventTouchUpInside];
    [navigationBar addSubview:settingButton];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if (self.navigationController.viewControllers.count > 1) {     //如果是 push 的情况下才显示 navibar ，没想到更好的解决办法
        [self.navigationController setNavigationBarHidden:NO animated:YES];
    }
}

- (void)settingAction
{
    SettingHomeViewController *ctl = [[SettingHomeViewController alloc] init];
    ctl.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:ctl animated:YES];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [_dataSource count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[_dataSource objectAtIndex:section] count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 10;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 10;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    NSDictionary *dic = [[_dataSource objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    NSString *title = [dic objectForKey:@"title"];
    NSString *imageStr = [dic objectForKey:@"image"];
    cell.textLabel.text = title;
    cell.imageView.image = [UIImage imageNamed:imageStr];
    cell.textLabel.textColor = COLOR_TEXT_II;
    cell.textLabel.font = [UIFont systemFontOfSize:15];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            FavoriteViewController *ctl = [[FavoriteViewController alloc] init];
            ctl.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:ctl animated:YES];
        } else {
            PlansListTableViewController *ctl = [[PlansListTableViewController alloc] init];
            ctl.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:ctl animated:YES];
        }
    } else if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            ContactListViewController *ctl = [[ContactListViewController alloc] init];
            ctl.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:ctl animated:YES];
        } else {
            TravelerListViewController *ctl = [[TravelerListViewController alloc] init];
            ctl.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:ctl animated:YES];
        }
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView.contentOffset.y < 0 && [scrollView isEqual:_tableView]) {
        scrollView.contentOffset = CGPointZero;
    }
}
@end

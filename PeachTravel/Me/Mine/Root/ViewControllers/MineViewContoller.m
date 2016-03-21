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
#import "GoodsFavoriteViewController.h"
#import "PlansListTableViewController.h"
#import "ContactListViewController.h"
#import "TravelerListViewController.h"
#import "UserCouponsListViewController.h"
#import "UserInviteCodeViewController.h"
#import "StoreManager.h"
#import "BusinessHomeViewController.h"

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
                        @{@"title": @"优惠券", @"image": @"icon_mine_coupon"},
                        @{@"title": @"我的邀请码", @"image": @"icon_mine_inviteCode"},
                        @{@"title": @"我的旅行计划", @"image": @"icon_mine_guides"},
                        ],
                    @[
                        @{@"title": @"常用旅客信息", @"image": @"icon_mine_traveler"},
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
    _mineHeaderView = [[MineHeaderView alloc] initWithFrame:CGRectMake(0, 0, kWindowWidth, 340)];
    _mineHeaderView.containerViewController = self;
    _tableView.tableHeaderView = _mineHeaderView;
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(mineProfileAction)];
    tapGesture.numberOfTapsRequired = 1;
    tapGesture.numberOfTouchesRequired = 1;
    [_mineHeaderView addGestureRecognizer:tapGesture];
    
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
    
    [[AccountManager shareAccountManager].account loadUserInfoFromServer:^(bool isSuccess) {
        
    }];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    _mineHeaderView.account = [AccountManager shareAccountManager].account;
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    
    [StoreManager asyncLoadStoreInfoWithStoreId:[AccountManager shareAccountManager].account.userId completionBlock:^(BOOL isSuccess, StoreDetailModel *storeDetail) {
        if (isSuccess && storeDetail) {
            _dataSource = @[
                            @[
                                @{@"title": @"我的店铺", @"image": @"icon_mine_stroe"},
                                @{@"title": @"我的收藏", @"image": @"icon_mine_favorite"},
                                @{@"title": @"优惠券", @"image": @"icon_mine_coupon"},
                                @{@"title": @"我的邀请码", @"image": @"icon_mine_inviteCode"},
                                @{@"title": @"我的旅行计划", @"image": @"icon_mine_guides"},
                                ],
                            @[
                                @{@"title": @"常用旅客信息", @"image": @"icon_mine_traveler"},
                                ],
                            ];
            [_tableView reloadData];
        } else {
            _dataSource = @[
                            @[
                                @{@"title": @"我的收藏", @"image": @"icon_mine_favorite"},
                                @{@"title": @"优惠券", @"image": @"icon_mine_coupon"},
                                @{@"title": @"我的邀请码", @"image": @"icon_mine_inviteCode"},
                                @{@"title": @"我的旅行计划", @"image": @"icon_mine_guides"},
                                ],
                            @[
                                @{@"title": @"常用旅客信息", @"image": @"icon_mine_traveler"},
                                ],
                            ];
            [_tableView reloadData];
        }
    }];
    [MobClick beginLogPageView:@"page_mine"];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if (self.navigationController.viewControllers.count > 1) {     //如果是 push 的情况下才显示 navibar ，没想到更好的解决办法
        if (![[self.navigationController.viewControllers lastObject]isKindOfClass:[BaseProfileViewController class]]) { //因为 profile 界面也不需要显示 navibar， 这个解决办法也不是很好
            [self.navigationController setNavigationBarHidden:NO animated:YES];
        }
    }
    [MobClick endLogPageView:@"page_mine"];

}

- (void)mineProfileAction
{
    MineProfileViewController *ctl = [[MineProfileViewController alloc] init];
    [self.navigationController pushViewController:ctl animated:YES];
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
        if ([[_dataSource objectAtIndex:indexPath.section] count] == 5) {
            if (indexPath.row == 0) {
                BusinessHomeViewController *ctl = [[BusinessHomeViewController alloc] init];
                ctl.hidesBottomBarWhenPushed = YES;
                [self.navigationController pushViewController:ctl animated:YES];
                
            } else if (indexPath.row == 1) {
                GoodsFavoriteViewController *ctl = [[GoodsFavoriteViewController alloc] init];
                ctl.hidesBottomBarWhenPushed = YES;
                [self.navigationController pushViewController:ctl animated:YES];
                
            } else if(indexPath.row == 2) {
                UserCouponsListViewController *ctl = [[UserCouponsListViewController alloc] init];
                ctl.userId = [AccountManager shareAccountManager].account.userId;
                ctl.hidesBottomBarWhenPushed = YES;
                ctl.userId = [AccountManager shareAccountManager].account.userId;
                [self.navigationController pushViewController:ctl animated:YES];
                
            } else if (indexPath.row == 3) {
                UserInviteCodeViewController *ctl = [[UserInviteCodeViewController alloc] init];
                ctl.hidesBottomBarWhenPushed = YES;
                [self.navigationController pushViewController:ctl animated:YES];
                
            } else if (indexPath.row == 4) {
                PlansListTableViewController *ctl = [[PlansListTableViewController alloc] initWithUserId:[AccountManager shareAccountManager].account.userId];
                ctl.hidesBottomBarWhenPushed = YES;
                [self.navigationController pushViewController:ctl animated:YES];
                
            }

            
        } else {
            if (indexPath.row == 0) {
                GoodsFavoriteViewController *ctl = [[GoodsFavoriteViewController alloc] init];
                ctl.hidesBottomBarWhenPushed = YES;
                [self.navigationController pushViewController:ctl animated:YES];
                
            } else if(indexPath.row == 1) {
                UserCouponsListViewController *ctl = [[UserCouponsListViewController alloc] init];
                ctl.userId = [AccountManager shareAccountManager].account.userId;
                ctl.hidesBottomBarWhenPushed = YES;
                ctl.userId = [AccountManager shareAccountManager].account.userId;
                [self.navigationController pushViewController:ctl animated:YES];
                
            } else if (indexPath.row == 2) {
                UserInviteCodeViewController *ctl = [[UserInviteCodeViewController alloc] init];
                ctl.hidesBottomBarWhenPushed = YES;
                [self.navigationController pushViewController:ctl animated:YES];
                
            } else if (indexPath.row == 3) {
                PlansListTableViewController *ctl = [[PlansListTableViewController alloc] initWithUserId:[AccountManager shareAccountManager].account.userId];
                ctl.hidesBottomBarWhenPushed = YES;
                [self.navigationController pushViewController:ctl animated:YES];
                
            }
        }
    } else if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            TravelerListViewController *ctl = [[TravelerListViewController alloc] init];
            ctl.hidesBottomBarWhenPushed = YES;
            ctl.isCheckMyTravelers = YES;
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

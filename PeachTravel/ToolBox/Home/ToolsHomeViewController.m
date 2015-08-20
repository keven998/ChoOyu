//
//  ToolsHomeViewController.m
//  PeachTravel
//
//  Created by Luo Yong on 15/6/15.
//  Copyright (c) 2015年 com.aizou.www. All rights reserved.
//

#import "ToolsHomeViewController.h"
#import "PlansListTableViewController.h"
#import "GuiderDistributeViewController.h"
#import "LoginViewController.h"
#import "SearchDestinationViewController.h"

@interface ToolsHomeViewController ()

@end

@implementation ToolsHomeViewController

#pragma mark - LifeCycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"旅行";
    self.view.backgroundColor = APP_PAGE_COLOR;
    
    // Do any additional setup after loading the view.
    CGFloat width = CGRectGetWidth(self.view.bounds);
    CGFloat height = 280*CGRectGetHeight(self.view.bounds)/736;
    
    UIButton *cardbg = [[UIButton alloc] initWithFrame:CGRectMake(10, 0, width - 20, height)];
    cardbg.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [cardbg setBackgroundImage:[[UIImage imageNamed:@"tools_home_card_bg_highlight.png"]
                                resizableImageWithCapInsets:UIEdgeInsetsMake(20,20,20,20)] forState:UIControlStateHighlighted];
    [cardbg addTarget:self action:@selector(lxpSearch:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:cardbg];

    UIImageView *lxpSearchBg = [[UIImageView alloc] initWithFrame:CGRectMake(10, 0, cardbg.frame.size.width - 20, height - 2)];
    lxpSearchBg.clipsToBounds = YES;
    lxpSearchBg.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    lxpSearchBg.image = [UIImage imageNamed:@"lxp_search_bg_normal.png"];
    [cardbg addSubview:lxpSearchBg];
    
    UIImageView *searchIC = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, height, height)];
    searchIC.image = [UIImage imageNamed:@"ic_lxp_search_homo.png"];
    searchIC.center = CGPointMake((width-20)/2.0, height/2.0 - 2.0);
    searchIC.contentMode = UIViewContentModeScaleAspectFit;
    [cardbg addSubview:searchIC];
    
    UILabel *searchText = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 108, 20)];
    searchText.textColor = COLOR_TEXT_II;
    searchText.font = [UIFont systemFontOfSize:16];
    searchText.text = @"~旅行·搜搜~";
    searchText.textAlignment = NSTextAlignmentCenter;
    searchText.center = CGPointMake((width-20)/2.0, height/2.0 - 23);
    [cardbg addSubview:searchText];
    
    CGFloat mxh = CGRectGetMaxY(lxpSearchBg.frame) + 6;
    CGFloat w = (width - 30) / 2;
    CGFloat h = 280*CGRectGetHeight(self.view.bounds)/736;
    UIButton *lxpHelper = [[UIButton alloc] initWithFrame:CGRectMake(10, mxh, w, h)];
    UIImageView *flag = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"lxp_expert_helper.png"]];
    flag.center = CGPointMake(w/2.0, h/2.0 - 12);
    [lxpHelper addSubview:flag];
    [lxpHelper setBackgroundImage:[UIImage imageNamed:@"tools_home_card_bg_normal.png"] forState:UIControlStateNormal];
    [lxpHelper setBackgroundImage:[UIImage imageNamed:@"tools_home_card_bg_highlight.png"] forState:UIControlStateHighlighted];
    [lxpHelper setTitle:@"达人指路" forState:UIControlStateNormal];
    [lxpHelper setTitleEdgeInsets:UIEdgeInsetsMake(flag.frame.size.height / 2.0, 0, -70, 0)];
    [lxpHelper setTitleColor:COLOR_TEXT_II forState:UIControlStateNormal];
    [lxpHelper setTitleColor:COLOR_TEXT_III forState:UIControlStateHighlighted];
    lxpHelper.titleLabel.font = [UIFont systemFontOfSize:16];
    [lxpHelper addTarget:self action:@selector(goLxpHelper) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:lxpHelper];
    
    UIButton *planHelper = [[UIButton alloc] initWithFrame:CGRectMake(w+20, mxh, w, h)];
    flag = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"lxp_plan_helper.png"]];
    flag.center = CGPointMake(w/2.0, h/2.0 - 12);
    [planHelper addSubview:flag];
    [planHelper setBackgroundImage:[UIImage imageNamed:@"tools_home_card_bg_normal.png"] forState:UIControlStateNormal];
    [planHelper setBackgroundImage:[UIImage imageNamed:@"tools_home_card_bg_highlight.png"] forState:UIControlStateHighlighted];
    [planHelper setTitle:@"我的计划" forState:UIControlStateNormal];
    [planHelper setTitleEdgeInsets:UIEdgeInsetsMake(flag.frame.size.height / 2.0, 0, -70, 0)];
    [planHelper setTitleColor:COLOR_TEXT_II forState:UIControlStateNormal];
    [planHelper setTitleColor:COLOR_TEXT_III forState:UIControlStateHighlighted];

    planHelper.titleLabel.font = [UIFont systemFontOfSize:16];
    [planHelper addTarget:self action:@selector(goMyPlan) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:planHelper];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [MobClick beginLogPageView:@"page_home_trip_tools"];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:@"page_home_trip_tools"];
}


#pragma mark - IBAction
/**
 *  跳转到达人咨询界面
 */
- (void)goLxpHelper {
    [MobClick event:@"card_item_lxp_guide"];
    GuilderDistributeViewController *gdvc = [[GuilderDistributeViewController alloc] init];
    gdvc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:gdvc animated:YES];
}

/**
 *  跳转到我的计划界面
 */
- (void)goMyPlan {
    [MobClick event:@"card_item_lxp_plan"];
    AccountManager *accountManager = [AccountManager shareAccountManager];
    if (!accountManager.isLogin) {
        LoginViewController *loginCtl = [[LoginViewController alloc] initWithCompletion:^(BOOL completed) {
            PlansListTableViewController *myGuidesCtl = [[PlansListTableViewController alloc] initWithUserId:accountManager.account.userId];
            myGuidesCtl.hidesBottomBarWhenPushed = YES;
            myGuidesCtl.userName = accountManager.account.nickName;
            [self.navigationController pushViewController:myGuidesCtl animated:YES];
        }];
        TZNavigationViewController *nctl = [[TZNavigationViewController alloc] initWithRootViewController:loginCtl];
        loginCtl.isPushed = NO;
        [self.navigationController presentViewController:nctl animated:YES completion:nil];
    } else {
        PlansListTableViewController *myGuidesCtl = [[PlansListTableViewController alloc] initWithUserId:accountManager.account.userId];
        myGuidesCtl.hidesBottomBarWhenPushed = YES;
        myGuidesCtl.userName = accountManager.account.nickName;
        [self.navigationController pushViewController:myGuidesCtl animated:YES];
    }
}

// 添加手势监听searchBar的搜索效果
- (void)lxpSearch:(UITapGestureRecognizer *)tap
{
    [MobClick event:@"card_item_lxp_search"];
    SearchDestinationViewController *searchCtl = [[SearchDestinationViewController alloc] init];
    searchCtl.hidesBottomBarWhenPushed = YES;
    [searchCtl setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];
    TZNavigationViewController *tznavc = [[TZNavigationViewController alloc] initWithRootViewController:searchCtl];
    [self presentViewController:tznavc animated:YES completion:nil];
}

@end

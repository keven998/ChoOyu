//
//  ToolsHomeViewController.m
//  PeachTravel
//
//  Created by Luo Yong on 15/6/15.
//  Copyright (c) 2015年 com.aizou.www. All rights reserved.
//

#import "ToolsHomeViewController.h"
#import "TravelersTableViewController.h"
#import "MyGuideListTableViewController.h"
#import "LoginViewController.h"
#import "SearchDestinationViewController.h"

@interface ToolsHomeViewController ()

@end

@implementation ToolsHomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"旅行";
    self.view.backgroundColor = APP_PAGE_COLOR;
    
    // Do any additional setup after loading the view.
    CGFloat width = CGRectGetWidth(self.view.bounds);
    CGFloat height = (width-20)*0.67;
    UIImageView *lxpSearchBg = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, width - 20, height)];
    lxpSearchBg.clipsToBounds = YES;
    lxpSearchBg.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    lxpSearchBg.backgroundColor = [UIColor whiteColor];
    lxpSearchBg.userInteractionEnabled = YES;
    lxpSearchBg.image = [UIImage imageNamed:@"lxp_search_bg_normal.png"];
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(lxpSearch:)];
    [lxpSearchBg addGestureRecognizer:tapGesture];
    [self.view addSubview:lxpSearchBg];
    
    UIImageView *searchIC = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, height, height - 20)];
    searchIC.image = [UIImage imageNamed:@"ic_lxp_search_homo.png"];
    searchIC.center = CGPointMake((width-20)/2.0, height/2.0 - 10);
    searchIC.contentMode = UIViewContentModeScaleAspectFit;
    [lxpSearchBg addSubview:searchIC];
    
    CGFloat mxh = CGRectGetMaxY(lxpSearchBg.frame) + 20;
    CGFloat w = (width - 30) / 2;
    UIButton *lxpHelper = [[UIButton alloc] initWithFrame:CGRectMake(10, mxh, w, w*1.67)];
    [lxpHelper setTitle:@"旅行达人" forState:UIControlStateNormal];
    [lxpHelper setTitleColor:COLOR_TEXT_I forState:UIControlStateNormal];
    lxpHelper.titleLabel.font = [UIFont systemFontOfSize:17];
    lxpHelper.backgroundColor = [UIColor whiteColor];
    [lxpHelper addTarget:self action:@selector(goLxpHelper) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:lxpHelper];
    
    UIButton *planHelper = [[UIButton alloc] initWithFrame:CGRectMake(w + 20, mxh, w, w*1.67)];
    [planHelper setTitle:@"我的计划" forState:UIControlStateNormal];
    [planHelper setTitleColor:COLOR_TEXT_I forState:UIControlStateNormal];
    planHelper.titleLabel.font = [UIFont systemFontOfSize:17];
    planHelper.backgroundColor = [UIColor whiteColor];
    [planHelper addTarget:self action:@selector(goMyPlan) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:planHelper];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - IBAction
- (void) goLxpHelper {
    TravelersTableViewController *ttvc = [[TravelersTableViewController alloc] init];
    ttvc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:ttvc animated:YES];
}

- (void)goMyPlan {
    [MobClick event:@"event_my_trip_plans"];
    
    AccountManager *accountManager = [AccountManager shareAccountManager];
    if (!accountManager.isLogin) {
        LoginViewController *loginCtl = [[LoginViewController alloc] initWithCompletion:^(BOOL completed) {
            MyGuideListTableViewController *myGuidesCtl = [[MyGuideListTableViewController alloc] init];
            myGuidesCtl.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:myGuidesCtl animated:YES];
        }];
        TZNavigationViewController *nctl = [[TZNavigationViewController alloc] initWithRootViewController:loginCtl];
        loginCtl.isPushed = NO;
        [self.navigationController presentViewController:nctl animated:YES completion:nil];
    } else {
        MyGuideListTableViewController *myGuidesCtl = [[MyGuideListTableViewController alloc] init];
        myGuidesCtl.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:myGuidesCtl animated:YES];
    }
}

- (void)lxpSearch:(UITapGestureRecognizer *)tap
{
    SearchDestinationViewController *searchCtl = [[SearchDestinationViewController alloc] init];
    searchCtl.hidesBottomBarWhenPushed = YES;
    [searchCtl setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];
    TZNavigationViewController *tznavc = [[TZNavigationViewController alloc] initWithRootViewController:searchCtl];
    [self presentViewController:tznavc animated:YES completion:nil];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

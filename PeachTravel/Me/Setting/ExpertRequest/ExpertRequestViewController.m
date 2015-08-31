//
//  ExpertRequestViewController.m
//  PeachTravel
//
//  Created by liangpengshuai on 8/28/15.
//  Copyright (c) 2015 com.aizou.www. All rights reserved.
//

#import "ExpertRequestViewController.h"
#import "NotificationViewController.h"

@interface ExpertRequestViewController ()

@end

@implementation ExpertRequestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = APP_PAGE_COLOR;
    _titleBkgImageView.image = [[UIImage imageNamed:@"textfield_bgk.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(5, 3, 5, 3)];
    self.navigationItem.title = @"达人∙申请";
    
    UIButton *commitBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    [commitBtn setTitle:@"提交" forState:UIControlStateNormal];
    [commitBtn setTitleColor:APP_THEME_COLOR forState:UIControlStateNormal];
    [commitBtn addTarget:self action:@selector(commitRequest:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:commitBtn];
    
    UIButton *backBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    [backBtn setTitle:@"取消" forState:UIControlStateNormal];
    [backBtn setTitleColor:COLOR_TEXT_II forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(goBack:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backBtn];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES]; //侧滑navigation bar 补丁
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:COLOR_TEXT_I, NSForegroundColorAttributeName, nil]];
    [self.navigationController.navigationBar setBackgroundImage:[ConvertMethods createImageWithColor:[UIColor whiteColor]] forBarMetrics:UIBarMetricsDefault];
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
    self.navigationController.navigationBar.shadowImage = [[UIImage alloc]init];
    
    self.navigationController.navigationBar.layer.shadowOffset = CGSizeMake(0, 1);
    self.navigationController.navigationBar.layer.shadowColor = COLOR_LINE.CGColor;
    self.navigationController.navigationBar.layer.shadowOpacity = 0.8;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor],NSForegroundColorAttributeName,nil]];
    [self.navigationController.navigationBar setBackgroundImage:[ConvertMethods createImageWithColor:APP_THEME_COLOR] forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:[UIImage imageNamed:@"bg_navigationbar_shadow.png"]];
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    
    self.navigationController.navigationBar.layer.shadowOffset = CGSizeZero;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)commitRequest:(id)sender
{
    NotificationViewController *ctl = [[NotificationViewController alloc] initWithTitle:@"您的申请已收到" subtitle:@"派派客服会尽快与您联系，请保持手机畅通" andActionTitle:@"知道了"];
    [ctl showNotiViewInController:self.navigationController];
}

- (void)goBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

@end

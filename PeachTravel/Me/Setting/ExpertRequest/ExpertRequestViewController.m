//
//  ExpertRequestViewController.m
//  PeachTravel
//
//  Created by liangpengshuai on 8/28/15.
//  Copyright (c) 2015 com.aizou.www. All rights reserved.
//

#import "ExpertRequestViewController.h"
#import "NotificationViewController.h"
#import "FormatCheck.h"
#import "ExpertManager.h"

@interface ExpertRequestViewController ()

@property (nonatomic, strong) UIButton *commitBtn;

@end

@implementation ExpertRequestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = APP_PAGE_COLOR;
    _titleBkgImageView.image = [[UIImage imageNamed:@"textfield_bgk.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(5, 3, 5, 3)];
    self.navigationItem.title = @"达人∙申请";
    
    _commitBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    [_commitBtn setTitle:@"提交" forState:UIControlStateNormal];
    [_commitBtn setTitleColor:APP_THEME_COLOR forState:UIControlStateNormal];
    [_commitBtn setTitleColor:[UIColor grayColor] forState:UIControlStateDisabled];
    [_commitBtn addTarget:self action:@selector(commitRequest:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:_commitBtn];
    _commitBtn.enabled = NO;

    
    UIButton *backBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    [backBtn setTitle:@"取消" forState:UIControlStateNormal];
    [backBtn setTitleColor:COLOR_TEXT_II forState:UIControlStateNormal];

    [backBtn addTarget:self action:@selector(goBack:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backBtn];
    
    [_contentTextField addTarget:self action:@selector(contentChanged:) forControlEvents:UIControlEventEditingChanged];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES]; //侧滑navigation bar 补丁
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)commitRequest:(id)sender
{
   [ExpertManager asyncRequest2BeAnExpert:_contentTextField.text completionBlock:^(BOOL isSuccess) {
       if (isSuccess) {
           NotificationViewController *ctl = [[NotificationViewController alloc] initWithTitle:@"您的申请已收到" subtitle:@"派派客服会尽快与您联系，\n请保持手机畅通" andActionTitle:@"知道了"];
           __weak ExpertRequestViewController *weakSelf = self;
           [ctl showNotiViewInController:self.navigationController dismissBlock:^{
               [weakSelf performSelector:@selector(goBack:) withObject:nil afterDelay:0.3];
           }];
       }
   }];
}

- (void)goBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - action methods

- (void)contentChanged:(id)sender
{
    if ([FormatCheck isMobileFormat:_contentTextField.text]) {
        _commitBtn.enabled = YES;
    } else {
        _commitBtn.enabled = NO;
    }
}

@end




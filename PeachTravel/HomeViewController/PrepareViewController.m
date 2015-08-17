//
//  PrepareViewController.m
//  PeachTravel
//
//  Created by liangpengshuai on 4/11/15.
//  Copyright (c) 2015 com.aizou.www. All rights reserved.
//

#import "PrepareViewController.h"
#import "LoginViewController.h"
#import "RegisterViewController.h"
#import "HomeViewController.h"
#import "UserInfoTableViewController.h"
@interface PrepareViewController ()

@end

@implementation PrepareViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 增加监听用户选择注册和跳过通知对象
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userDidRegisted:) name:userDidRegistedNoti object:nil];

    UIImageView *backgroundImg = [[UIImageView alloc]initWithFrame:self.view.bounds];
    if (IS_IPHONE_4) {
        backgroundImg.image = [UIImage imageNamed:@"Default@2x"];
    }else if (IS_IPHONE_5) {
        backgroundImg.image = [UIImage imageNamed:@"Default-568h"];
    }else if (IS_IPHONE_6P) {
        backgroundImg.image = [UIImage imageNamed:@"Default-414w-736h@3x~iphone"];
    }else {
        backgroundImg.image = [UIImage imageNamed:@"Default-375w-667h@2x~iphone"];
    }
    [self.view addSubview:backgroundImg];
    
    UIButton *loginBtn = [[UIButton alloc]initWithFrame:CGRectMake(13, self.view.bounds.size.height - 190, self.view.bounds.size.width-26, 50)];
    loginBtn.titleLabel.font = [UIFont boldSystemFontOfSize:16];
    [loginBtn setTitle:@"登录" forState:UIControlStateNormal];
    [loginBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [loginBtn setTitleColor:COLOR_DISABLE forState:UIControlStateHighlighted];
    loginBtn.layer.cornerRadius = 5;
    loginBtn.layer.borderColor = [UIColor whiteColor].CGColor;
    loginBtn.layer.borderWidth = 1.0;
    loginBtn.clipsToBounds = YES;
    [loginBtn addTarget:self action:@selector(login:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:loginBtn];
    
    UIButton *registerBtn = [[UIButton alloc]initWithFrame:CGRectMake(13, self.view.bounds.size.height - 124, self.view.bounds.size.width-26, 50)];
    [registerBtn setTitle:@"注册" forState:UIControlStateNormal];
    registerBtn.titleLabel.font = [UIFont boldSystemFontOfSize:16];
    [registerBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [registerBtn setTitleColor:COLOR_DISABLE forState:UIControlStateHighlighted];
    registerBtn.layer.cornerRadius = 5;
    registerBtn.layer.borderColor = [UIColor whiteColor].CGColor;
    registerBtn.layer.borderWidth = 1.0;
    registerBtn.clipsToBounds = YES;
    [registerBtn addTarget:self action:@selector(registerAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:registerBtn];

    
    UIButton *skipBtn = [[UIButton alloc]initWithFrame:CGRectMake(13, self.view.bounds.size.height - 50, self.view.bounds.size.width-26, 30)];
    skipBtn.titleLabel.font = [UIFont systemFontOfSize:13];
    [skipBtn setTitle:@"跳过" forState:UIControlStateNormal];
    [skipBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [skipBtn setTitleColor:COLOR_DISABLE forState:UIControlStateHighlighted];
    [skipBtn addTarget:self action:@selector(skip:) forControlEvents:UIControlEventTouchUpInside];

    [self.view addSubview:skipBtn];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    _rootViewController = nil;
}

- (void)login:(id)sender {
    LoginViewController *loginCtl = [[LoginViewController alloc] initWithCompletion:^(BOOL completed) {
        HomeViewController *hvc = (HomeViewController *)_rootViewController;
        [hvc setSelectedIndex:0];
        [self willMoveToParentViewController:nil];
        [self.view removeFromSuperview];
        [self removeFromParentViewController];
        _rootViewController = nil;
    }];
    TZNavigationViewController *nctl = [[TZNavigationViewController alloc] initWithRootViewController:loginCtl];
    loginCtl.isPushed = NO;
    [_rootViewController presentViewController:nctl animated:YES completion:nil];
}

- (void)registerAction:(id)sender {
    RegisterViewController *loginCtl = [[RegisterViewController alloc] init];
    TZNavigationViewController *nctl = [[TZNavigationViewController alloc] initWithRootViewController:loginCtl];
    [_rootViewController presentViewController:nctl animated:YES completion:nil];
}

- (void)skip:(id)sender {
    HomeViewController *hvc = (HomeViewController *)_rootViewController;
    [hvc setSelectedIndex:1];
    [self willMoveToParentViewController:nil];
    [self.view removeFromSuperview];
    [self removeFromParentViewController];
    _rootViewController = nil;
}

- (void)userDidRegisted:(NSNotification *)noti {
    UIViewController *ctl = [noti.userInfo objectForKey:@"poster"];
    [ctl.navigationController dismissViewControllerAnimated:YES completion:^{
        HomeViewController *hvc = (HomeViewController *)_rootViewController;
        [hvc setSelectedIndex:0];
        [self willMoveToParentViewController:nil];
        [self.view removeFromSuperview];
        [self removeFromParentViewController];
        [self performSelector:@selector(pushToUserInfo) withObject:nil afterDelay:0.2];
        _rootViewController = nil;
    }];
}

- (void)pushToUserInfo
{
    UserInfoTableViewController *userInfo = [[UserInfoTableViewController alloc]init];
    [self.navigationController pushViewController:userInfo animated:YES];

}


@end

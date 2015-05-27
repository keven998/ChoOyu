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

@interface PrepareViewController ()

@end

@implementation PrepareViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UIImageView *backgroundImg = [[UIImageView alloc]initWithFrame:self.view.bounds];
    backgroundImg.image = [UIImage imageNamed:@"ic_prepare_place"];
    [self.view addSubview:backgroundImg];
    
    UIImageView *btnBg = [[UIImageView alloc]initWithFrame:CGRectMake(0, SCREEN_HEIGHT-62, SCREEN_WIDTH, 62)];
    btnBg.image = [UIImage imageNamed:@"ic_prepare_ImgBg"];
    btnBg.userInteractionEnabled = YES;
    [self.view addSubview:btnBg];
    
    UIButton *registerBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 60, 30)];
    registerBtn.center = CGPointMake(SCREEN_WIDTH * 0.22, 31);
    [registerBtn setTitle:@"注册" forState:UIControlStateNormal];
    [registerBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    registerBtn.backgroundColor = UIColorFromRGB(0x272727);
    registerBtn.layer.cornerRadius = 5;
    registerBtn.clipsToBounds = YES;
    [btnBg addSubview:registerBtn];
    [registerBtn addTarget:self action:@selector(registerAction:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *loginBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 60, 30)];
    loginBtn.center = CGPointMake(SCREEN_WIDTH/2, 31);
    [loginBtn setTitle:@"登录" forState:UIControlStateNormal];
    [loginBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    loginBtn.backgroundColor = UIColorFromRGB(0x272727);
    loginBtn.layer.cornerRadius = 5;
    loginBtn.clipsToBounds = YES;
    [btnBg addSubview:loginBtn];
    [loginBtn addTarget:self action:@selector(login:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *skipBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 17, 12)];
    skipBtn.center = CGPointMake(0.82 * SCREEN_WIDTH, 31);
    [skipBtn setBackgroundImage:[UIImage imageNamed:@"ic_tiaoguo"] forState:UIControlStateNormal];
    [btnBg addSubview:skipBtn];
    [skipBtn addTarget:self action:@selector(skip:) forControlEvents:UIControlEventTouchUpInside];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

- (void)login:(id)sender {
    LoginViewController *loginCtl = [[LoginViewController alloc] init];
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
}
@end

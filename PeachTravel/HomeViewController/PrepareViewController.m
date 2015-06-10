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
    
    UIImageView *btnBg = [[UIImageView alloc]initWithFrame:CGRectMake(0, SCREEN_HEIGHT-62, SCREEN_WIDTH, 62)];
    btnBg.image = [UIImage imageNamed:@"ic_prepare_ImgBg"];
    btnBg.userInteractionEnabled = YES;
    [self.view addSubview:btnBg];
    
    UIButton *registerBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 60, 30)];
    registerBtn.center = CGPointMake(SCREEN_WIDTH * 0.22, 31);
    [registerBtn setTitle:@"注册" forState:UIControlStateNormal];
    registerBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    [registerBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    registerBtn.backgroundColor = UIColorFromRGB(0x656565);
    registerBtn.layer.cornerRadius = 5;
    registerBtn.clipsToBounds = YES;
    [btnBg addSubview:registerBtn];
    [registerBtn addTarget:self action:@selector(registerAction:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *loginBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 60, 30)];
    loginBtn.center = CGPointMake(SCREEN_WIDTH/2, 31);
    loginBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    [loginBtn setTitle:@"登录" forState:UIControlStateNormal];
    [loginBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    loginBtn.backgroundColor = UIColorFromRGB(0x656565);
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

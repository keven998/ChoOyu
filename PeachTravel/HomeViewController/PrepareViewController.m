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
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)login:(id)sender {
    LoginViewController *loginCtl = [[LoginViewController alloc] init];
    TZNavigationViewController *nctl = [[TZNavigationViewController alloc] initWithRootViewController:loginCtl];
    loginCtl.isPushed = NO;
    [_rootViewController presentViewController:nctl animated:YES completion:nil];
}

- (IBAction)registerAction:(id)sender {
    RegisterViewController *loginCtl = [[RegisterViewController alloc] init];
    TZNavigationViewController *nctl = [[TZNavigationViewController alloc] initWithRootViewController:loginCtl];
    [_rootViewController presentViewController:nctl animated:YES completion:nil];
}

- (IBAction)skip:(id)sender {
    HomeViewController *hvc = (HomeViewController *)_rootViewController;
    [hvc setSelectedIndex:1];
    [self willMoveToParentViewController:nil];
    [self.view removeFromSuperview];
    [self removeFromParentViewController];
}
@end

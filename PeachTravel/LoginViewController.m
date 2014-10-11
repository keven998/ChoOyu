//
//  LoginViewController.m
//  PeachTravel
//
//  Created by liangpengshuai on 14/10/11.
//  Copyright (c) 2014年 com.aizou.www. All rights reserved.
//

#import "LoginViewController.h"

@interface LoginViewController ()

@property (weak, nonatomic) IBOutlet UITextField *userNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;

@property (weak, nonatomic) IBOutlet UIButton *loginBtn;
@property (weak, nonatomic) IBOutlet UIButton *losePassworkBtn;

@end

@implementation LoginViewController

#pragma mark - LifeCycle

- (void)viewDidLoad {
    [super viewDidLoad];
    _userNameTextField.layer.borderColor = [UIColor grayColor].CGColor;
    _userNameTextField.layer.borderWidth = 1.0;
    _passwordTextField.layer.borderColor = [UIColor grayColor].CGColor;
    _passwordTextField.layer.borderWidth = 1.0;
    
    UIButton *registerBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 60, 30)];
    registerBtn.titleLabel.font = [UIFont systemFontOfSize:17.];
    [registerBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [registerBtn setTitle:@"注册" forState:UIControlStateNormal];
    [registerBtn addTarget:self action:@selector(userRegister:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *registerItem = [[UIBarButtonItem alloc] initWithCustomView:registerBtn];
    self.navigationItem.rightBarButtonItem = registerItem;
    
    UITapGestureRecognizer *tapBackground = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapBackground:)];
    tapBackground.numberOfTapsRequired = 1;
    tapBackground.numberOfTouchesRequired = 1;
    [self.view addGestureRecognizer:tapBackground];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.tabBarController.tabBar.hidden = YES;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.tabBarController.tabBar.hidden = NO;
}

#pragma mark - IBAction Methods

- (IBAction)userRegister:(id)sender
{
    
}

- (void)tapBackground:(id)sender
{
    if ([_userNameTextField isFirstResponder]) {
        [_userNameTextField resignFirstResponder];
    } else if ([_passwordTextField isFirstResponder]) {
        [_passwordTextField resignFirstResponder];
    }
}

@end




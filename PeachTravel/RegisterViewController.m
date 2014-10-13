//
//  RegisterViewController.m
//  PeachTravel
//
//  Created by liangpengshuai on 14/10/13.
//  Copyright (c) 2014年 com.aizou.www. All rights reserved.
//

#import "RegisterViewController.h"

@interface RegisterViewController ()

@property (weak, nonatomic) IBOutlet UITextField *phoneLabel;
@property (weak, nonatomic) IBOutlet UITextField *passwordLabel;
@end

@implementation RegisterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"注册";
    
    _phoneLabel.layer.borderColor = [UIColor grayColor].CGColor;
    _phoneLabel.layer.borderWidth = 1.0;
    _passwordLabel.layer.borderColor = [UIColor grayColor].CGColor;
    _passwordLabel.layer.borderWidth = 1.0;
    
    UITapGestureRecognizer *tapBackground = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapBackground:)];
    tapBackground.numberOfTapsRequired = 1;
    tapBackground.numberOfTouchesRequired = 1;
    [self.view addGestureRecognizer:tapBackground];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - IBAction Methods

- (void)tapBackground:(id)sender
{
    if ([_phoneLabel isFirstResponder]) {
        [_phoneLabel resignFirstResponder];
    } else if ([_passwordLabel isFirstResponder]) {
        [_passwordLabel resignFirstResponder];
    }
}


@end

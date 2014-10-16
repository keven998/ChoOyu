//
//  ChangeUserInfoViewController.m
//  PeachTravel
//
//  Created by liangpengshuai on 14/10/15.
//  Copyright (c) 2014年 com.aizou.www. All rights reserved.
//

#import "ChangeUserInfoViewController.h"

@interface ChangeUserInfoViewController ()

@property (weak, nonatomic) IBOutlet UITextField *contentTextField;


@end

@implementation ChangeUserInfoViewController

#pragma mark - LifeCycle

- (void)viewDidLoad {
    [super viewDidLoad];
    if (_changeType == ChangeName) {
        self.navigationItem.title = @"昵称";
    }
    if (_changeType == ChangeSignature) {
        self.navigationItem.title = @"个性签名";
    }
    _contentTextField.text = _content;
    UIButton *registerBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 60, 30)];
    registerBtn.titleLabel.font = [UIFont systemFontOfSize:17.];
    [registerBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [registerBtn setTitle:@"保存" forState:UIControlStateNormal];
    [registerBtn addTarget:self action:@selector(saveChange:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *registerItem = [[UIBarButtonItem alloc] initWithCustomView:registerBtn];
    self.navigationItem.rightBarButtonItem = registerItem;
}

#pragma mark - IBAction Methods

-(IBAction)saveChange:(id)sender
{
    
}


@end

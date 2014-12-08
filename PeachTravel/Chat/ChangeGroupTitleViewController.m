//
//  ChangeGroupTitleViewController.m
//  PeachTravel
//
//  Created by liangpengshuai on 14/11/5.
//  Copyright (c) 2014年 com.aizou.www. All rights reserved.
//

#import "ChangeGroupTitleViewController.h"

@interface ChangeGroupTitleViewController ()

@property (weak, nonatomic) IBOutlet UITextField *titleLable;

@end

@implementation ChangeGroupTitleViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _titleLable.text = _oldTitle;
    self.navigationItem.title = @"修改群名称";
    UIButton *addBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    [addBtn setTitle:@"确定" forState:UIControlStateNormal];
    addBtn.titleLabel.font = [UIFont systemFontOfSize:16];
    [addBtn setTitleColor:APP_THEME_COLOR forState:UIControlStateNormal];
    [addBtn addTarget:self action:@selector(confirm:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:addBtn];
    
    _titleLable.layer.borderColor = UIColorFromRGB(0xdcdcdc).CGColor;
    _titleLable.layer.borderWidth = 0.5;
    UIView *sv = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10.0, 20.0)];
    sv.backgroundColor = [UIColor whiteColor];
    _titleLable.leftView = sv;
    _titleLable.leftViewMode = UITextFieldViewModeAlways;
    [_titleLable becomeFirstResponder];
    
}

- (void)dealloc
{
    [SVProgressHUD dismiss];
}

- (IBAction)confirm:(id)sender
{
    NSString *title = [_titleLable.text stringByReplacingOccurrencesOfString:@" " withString:@""];
    if (title.length == 0) {
        [SVProgressHUD showErrorWithStatus:@"群标题不能为空"];
    } else {
        [SVProgressHUD show];
        [[EaseMob sharedInstance].chatManager asyncChangeGroupSubject:_titleLable.text
                                                             forGroup:_groupId];
    }
    
    [[EaseMob sharedInstance].chatManager asyncChangeGroupSubject:_titleLable.text forGroup:_groupId completion:^(EMGroup *group, EMError *error) {
        [SVProgressHUD showSuccessWithStatus:@"修改成功"];
        [self.navigationController popViewControllerAnimated:YES];
    } onQueue:nil];
}

- (void)updateSuccess
{
    
}

@end

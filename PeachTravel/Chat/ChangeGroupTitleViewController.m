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
    UIButton *addBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    [addBtn setTitle:@"确定" forState:UIControlStateNormal];
    addBtn.titleLabel.font = [UIFont systemFontOfSize:12];
    [addBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [addBtn addTarget:self action:@selector(confirm:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:addBtn];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateSuccess) name:@"groupDidUpdateInfo" object:nil];
}

- (void)dealloc
{
    [SVProgressHUD dismiss];
}

- (IBAction)confirm:(id)sender
{
    NSString *title = [_titleLable.text stringByReplacingOccurrencesOfString:@" " withString:@""];
    if (title.length == 0) {
        [SVProgressHUD showErrorWithStatus:@"小组标题不能为空"];
    } else {
        [SVProgressHUD show];
        [[EaseMob sharedInstance].chatManager asyncChangeGroupSubject:_titleLable.text
                                                             forGroup:_groupId];
    }
}

- (void)updateSuccess
{
    [SVProgressHUD showSuccessWithStatus:@"修改成功"];
    [self.navigationController popViewControllerAnimated:YES];
}

@end

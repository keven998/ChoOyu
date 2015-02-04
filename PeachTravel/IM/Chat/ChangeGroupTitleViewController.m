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
    
    UIBarButtonItem * addBtn = [[UIBarButtonItem alloc]initWithTitle:@"确定 " style:UIBarButtonItemStyleBordered target:self action:@selector(confirm:)];
    addBtn.tintColor = APP_THEME_COLOR;
    self.navigationItem.rightBarButtonItem = addBtn;
    
    _titleLable.layer.borderColor = UIColorFromRGB(0xdcdcdc).CGColor;
    _titleLable.layer.borderWidth = 0.5;
    UIView *sv = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10.0, 20.0)];
    sv.backgroundColor = [UIColor whiteColor];
    _titleLable.leftView = sv;
    _titleLable.leftViewMode = UITextFieldViewModeAlways;
    [_titleLable becomeFirstResponder];
    
}

- (void)goBack
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)dealloc
{
}

- (IBAction)confirm:(id)sender
{
    TZProgressHUD *hud;
    [_titleLable resignFirstResponder];
    NSString *title = [_titleLable.text stringByReplacingOccurrencesOfString:@" " withString:@""];
    if (title.length == 0) {
        [SVProgressHUD showHint:@"群标题不能为空"];
    } else {
        __weak typeof(ChangeGroupTitleViewController *)weakSelf = self;
        hud = [[TZProgressHUD alloc] init];
        [hud showHUDInViewController:weakSelf];
        [[EaseMob sharedInstance].chatManager asyncChangeGroupSubject:_titleLable.text
                                                             forGroup:_groupId];
    }
    
    [[EaseMob sharedInstance].chatManager asyncChangeGroupSubject:_titleLable.text forGroup:_groupId completion:^(EMGroup *group, EMError *error) {
        [hud hideTZHUD];
        [SVProgressHUD showHint:@"修改成功"];
        [self performSelector:@selector(goBack) withObject:nil afterDelay:0.4];
    } onQueue:nil];
}

- (void)updateSuccess
{
    
}

@end
//
//  ChangeRemarkViewController.m
//  PeachTravel
//
//  Created by liangpengshuai on 4/7/15.
//  Copyright (c) 2015 com.aizou.www. All rights reserved.
//

#import "ChangeRemarkViewController.h"
#import "AccountManager.h"

@interface ChangeRemarkViewController ()

@property (weak, nonatomic) IBOutlet UITextField *remarkTextField;

@end

@implementation ChangeRemarkViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UILabel *leftLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 60, 45)];
    leftLabel.text = @"备注:";
    leftLabel.textColor = TEXT_COLOR_TITLE;
    leftLabel.textAlignment = NSTextAlignmentCenter;
    leftLabel.font = [UIFont systemFontOfSize:17.0];
    _remarkTextField.leftView = leftLabel;
    _remarkTextField.leftViewMode = UITextFieldViewModeAlways;
    _remarkTextField.text = _contact.memo;
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithTitle:@"完成" style:UIBarButtonItemStylePlain target:self action:@selector(confirmChange:)];
    self.navigationItem.rightBarButtonItem = rightItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)confirmChange:(id)sender
{
    TZProgressHUD *hud = [[TZProgressHUD alloc] init];
    [hud showHUD];
    AccountManager *accountManager = [AccountManager shareAccountManager];
    [accountManager asyncChangeRemark:_remarkTextField.text withUserId:_contact.userId completion:^(BOOL isSuccess) {
        [hud hideTZHUD];
        if (isSuccess) {
            [SVProgressHUD showHint:@"修改成功"];
            [[NSNotificationCenter defaultCenter] postNotificationName:contactListNeedUpdateNoti object:nil];
        } else {
            [SVProgressHUD showHint:@"修改失败"];
        }
    }];
}

@end

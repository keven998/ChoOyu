//
//  ChangeUserInfoViewController.m
//  PeachTravel
//
//  Created by liangpengshuai on 14/10/15.
//  Copyright (c) 2014年 com.aizou.www. All rights reserved.
//

#import "ChangeUserInfoViewController.h"
#import "AccountManager.h"

@interface ChangeUserInfoViewController ()<UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *contentTextField;

@end

@implementation ChangeUserInfoViewController

#pragma mark - LifeCycle

- (void)viewDidLoad {
    [super viewDidLoad];
    if (_changeType == ChangeName) {
        self.navigationItem.title = @"修改昵称";
    }
    if (_changeType == ChangeSignature) {
        self.navigationItem.title = @"旅行签名";
    }
    
    _contentTextField.layer.borderColor = UIColorFromRGB(0xdcdcdc).CGColor;
    _contentTextField.layer.borderWidth = 0.5;
    _contentTextField.delegate = self;
    UIView *sv = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10.0, 20.0)];
    sv.backgroundColor = [UIColor whiteColor];
    _contentTextField.leftView = sv;
    _contentTextField.leftViewMode = UITextFieldViewModeAlways;
    [_contentTextField becomeFirstResponder];
    _contentTextField.font = [UIFont systemFontOfSize:14.0];
    _contentTextField.text = _content;
    

    UIBarButtonItem * registerBtn = [[UIBarButtonItem alloc]initWithTitle:@"保存 " style:UIBarButtonItemStyleBordered target:self action:@selector(saveChange:)];
    registerBtn.tintColor = APP_THEME_COLOR;
    self.navigationItem.rightBarButtonItem = registerBtn;
}

/**
 *  重写父类的返回方法
 */
- (void)goBack
{
    if (![_content isEqualToString:_contentTextField.text]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"不需要保存吗" delegate:self cancelButtonTitle:@"直接返回" otherButtonTitles:@"先保存", nil];
        [alert showAlertViewWithBlock:^(NSInteger buttonIndex) {
            if (buttonIndex == 0) {
                [self dismiss];
            } else {
                [self saveChange:nil];
            }
        }];
    } else {
        [self dismiss];
    }
}

- (void)dismiss
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == _contentTextField) {
        [textField resignFirstResponder];
    }
    return YES;
}

#pragma mark - IBAction Methods

- (IBAction)saveChange:(id)sender
{
    AccountManager *accountManager = [AccountManager shareAccountManager];

    __weak typeof(ChangeUserInfoViewController *)weakSelf = self;
    TZProgressHUD *hud = [[TZProgressHUD alloc] init];
    [hud showHUDInViewController:weakSelf];

    [self.view endEditing:YES];
    if (_changeType == ChangeName) {
        [accountManager asyncChangeUserName:_contentTextField.text completion:^(BOOL isSuccess, UserInfoInputError error, NSString *errStr) {
            [hud hideTZHUD];
            if (isSuccess) {
                [SVProgressHUD showHint:@"修改成功"];
                [self performSelector:@selector(dismiss) withObject:nil afterDelay:0.4];
                
            } else if (error != NoError){
                [SVProgressHUD showHint:@"纯数字或有特殊字符都是不行的哦"];
            } else if (errStr){
                [SVProgressHUD showHint:errStr];
            } else {
                [SVProgressHUD showHint:@"呃～好像没找到网络"];
            }
        }];
        
    } else if (_changeType == ChangeSignature) {
        [accountManager asyncChangeSignature:_contentTextField.text completion:^(BOOL isSuccess, UserInfoInputError error, NSString *errStr) {
            [hud hideTZHUD];
            if (isSuccess) {
                [SVProgressHUD showHint:@"修改成功"];
                [self performSelector:@selector(dismiss) withObject:nil afterDelay:0.4];
           
            } else if (errStr){
                [SVProgressHUD showHint:errStr];
                
            } else {
                [SVProgressHUD showHint:@"呃～好像没找到网络"];
            }
        }];
        
    }
    
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
    [super touchesEnded:touches withEvent:event];
}



@end

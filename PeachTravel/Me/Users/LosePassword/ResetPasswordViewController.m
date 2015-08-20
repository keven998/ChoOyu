//
//  ResetPasswordViewController.m
//  PeachTravel
//
//  Created by liangpengshuai on 14/10/23.
//  Copyright (c) 2014年 com.aizou.www. All rights reserved.
//

#import "ResetPasswordViewController.h"
#import "AccountManager.h"

@interface ResetPasswordViewController ()
//@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UITextField *passwordLabel;

@end

@implementation ResetPasswordViewController

#pragma mark - lifeCycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIBarButtonItem *registerBtn = [[UIBarButtonItem alloc]initWithTitle:@"完成 " style:UIBarButtonItemStylePlain target:self action:@selector(confirm:)];
    registerBtn.tintColor = [UIColor whiteColor];
    self.navigationItem.rightBarButtonItem = registerBtn;
    
    //如果是绑定手机号进行到最后一步，进行设置密码
    if (_verifyCaptchaType == UserBindTel) {
        self.navigationItem.title = @"设置密码";
        UILabel *ul = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 76.0, _passwordLabel.bounds.size.height - 16.0)];
        ul.text = @" 设置密码:";
        ul.textColor = TEXT_COLOR_TITLE;
        ul.font = [UIFont systemFontOfSize:14.0];
        ul.textAlignment = NSTextAlignmentCenter;
        _passwordLabel.leftView = ul;
        _passwordLabel.leftViewMode = UITextFieldViewModeAlways;
        _passwordLabel.placeholder = @"给账户设置一个密码";
        [_passwordLabel becomeFirstResponder];
    } else {
        self.navigationItem.title = @"重置密码";
        UILabel *ul = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 64.0, _passwordLabel.bounds.size.height - 16.0)];
        ul.text = @" 新密码:";
        ul.textColor = TEXT_COLOR_TITLE;
        ul.font = [UIFont systemFontOfSize:14.0];
        ul.textAlignment = NSTextAlignmentCenter;
        _passwordLabel.leftView = ul;
        _passwordLabel.leftViewMode = UITextFieldViewModeAlways;
        [_passwordLabel becomeFirstResponder];
    }
}

#pragma mark - IBAction Methods

- (IBAction)confirm:(UIButton *)sender {
    
    NSString * regex = @"^[A-Za-z0-9]{6,16}$";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    if (![pred evaluateWithObject:_passwordLabel.text]) {
        [self showHint:@"密码只能为6-16位数字，字母"];
        return;
    }
    
    AccountManager *accountManager = [AccountManager shareAccountManager];
    __weak typeof(ResetPasswordViewController *)weakSelf = self;
    TZProgressHUD *hud = [[TZProgressHUD alloc] init];
    [hud showHUDInViewController:weakSelf content:64];
       
    [accountManager asyncResetPassword:_passwordLabel.text tel: _phoneNumber toke:_token completion:^(BOOL isSuccess, NSString *errorStr) {
        if (isSuccess) {
            [SVProgressHUD showHint:@"修改成功"];
            if (_verifyCaptchaType == UserBindTel) {
                [self.navigationController dismissViewControllerAnimated:YES completion:nil];
            } else {
                [self performSelector:@selector(dismissCtl) withObject:nil afterDelay:0.4];
            }
            
        } else {
            [hud hideTZHUD];
            if (errorStr) {
                [SVProgressHUD showHint:errorStr];
            } else {
                
                if (self.isShowing) {
                    [SVProgressHUD showHint:HTTP_FAILED_HINT];
                }
            }
        }
    }];
   
    _passwordLabel.layer.borderColor = UIColorFromRGB(0xdddddd).CGColor;
    _passwordLabel.layer.borderWidth = 1.0;

    UILabel *ul = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 52.0, _passwordLabel.bounds.size.height - 16.0)];
    ul.text = @"新密码:";
    ul.textColor = TEXT_COLOR_TITLE;
    ul.font = [UIFont systemFontOfSize:15.0];
    ul.textAlignment = NSTextAlignmentCenter;
    _passwordLabel.leftView = ul;
    _passwordLabel.leftViewMode = UITextFieldViewModeAlways;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
    [super touchesEnded:touches withEvent:event];
}

- (void)dismissCtl
{
    [self.navigationController popToRootViewControllerAnimated:YES];

}

@end

//
//  ChangePasswordViewController.m
//  PeachTravel
//
//  Created by liangpengshuai on 14/10/14.
//  Copyright (c) 2014年 com.aizou.www. All rights reserved.
//

#import "ChangePasswordViewController.h"
#import "AccountManager.h"

@interface ChangePasswordViewController ()<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *oldPasswordLabel;
@property (weak, nonatomic) IBOutlet UITextField *presentPasswordLabel;
@property (weak, nonatomic) IBOutlet UITextField *confirmPasswordLabel;

@end

@implementation ChangePasswordViewController

#pragma mark - LifeCycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"修改密码";

    _oldPasswordLabel.delegate = self;
    _presentPasswordLabel.delegate = self;
    _confirmPasswordLabel.delegate = self;
    
    UILabel *ul = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 90, _oldPasswordLabel.bounds.size.height - 16.0)];
    ul.text = @"当前密码:";
    ul.textColor = COLOR_TEXT_I;
    ul.font = [UIFont systemFontOfSize:13.0];
    ul.textAlignment = NSTextAlignmentCenter;
    _oldPasswordLabel.leftView = ul;
    _oldPasswordLabel.leftViewMode = UITextFieldViewModeAlways;
    
    UILabel *pl = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 90, _presentPasswordLabel.bounds.size.height - 16.0)];
    pl.text = @"新的密码:";
    pl.textColor = COLOR_TEXT_I;
    pl.font = [UIFont systemFontOfSize:13.0];
    pl.textAlignment = NSTextAlignmentCenter;
    _presentPasswordLabel.leftView = pl;
    _presentPasswordLabel.leftViewMode = UITextFieldViewModeAlways;
    [_presentPasswordLabel addTarget:self action:@selector(textChanged:) forControlEvents:UIControlEventEditingChanged];
    
    UILabel *npl = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 90, _presentPasswordLabel.bounds.size.height - 16.0)];
    npl.text = @"再次输入:";
    npl.textColor = COLOR_TEXT_I;
    npl.font = [UIFont systemFontOfSize:13.0];
    npl.textAlignment = NSTextAlignmentCenter;
    _confirmPasswordLabel.leftView = npl;
    _confirmPasswordLabel.leftViewMode = UITextFieldViewModeAlways;
    [_confirmPasswordLabel addTarget:self action:@selector(textChanged:) forControlEvents:UIControlEventEditingChanged];
    
    UIBarButtonItem *leftBtn = [[UIBarButtonItem alloc]initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(goBack)];
    self.navigationItem.leftBarButtonItem = leftBtn;
    
    UIBarButtonItem *registerBtn = [[UIBarButtonItem alloc]initWithTitle:@"确定 " style:UIBarButtonItemStylePlain target:self action:@selector(changePassword:)];
    registerBtn.tintColor = [UIColor whiteColor];
    self.navigationItem.rightBarButtonItem = registerBtn;
    self.navigationItem.rightBarButtonItem.enabled = NO;
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == _confirmPasswordLabel) {
        [textField resignFirstResponder];
    } else if (textField == _oldPasswordLabel) {
        [_presentPasswordLabel becomeFirstResponder];
    } else if (textField == _presentPasswordLabel) {
        [_confirmPasswordLabel becomeFirstResponder];
    }
    return YES;
}

- (void) textChanged:(UITextField *)textField {
    if (![_confirmPasswordLabel.text isEqualToString:@""] && ![_presentPasswordLabel.text isEqualToString:@""]) {
        self.navigationItem.rightBarButtonItem.enabled = YES;
    }
}

#pragma mark - Private Methods

- (UserInfoInputError)checkInput
{
    NSString * regex = @"^[A-Za-z0-9]{6,16}$";

    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    if (![pred evaluateWithObject:_oldPasswordLabel.text]) {
        return PasswordError;
    }
    if (![pred evaluateWithObject:_presentPasswordLabel.text]) {
        return PresentPasswordError;
    }
    if (![pred evaluateWithObject:_confirmPasswordLabel.text]) {
        return ConfirmPasswordError;
    }
    if (![_presentPasswordLabel.text isEqualToString:_confirmPasswordLabel.text]) {
        return PasswordNotMatchedError;
    }
    return NoError;
}

- (void)changePassword
{
    __weak typeof(ChangePasswordViewController *)weakSelf = self;
    TZProgressHUD *hud = [[TZProgressHUD alloc] init];
    [hud showHUDInViewController:weakSelf content:64];
    [[AccountManager shareAccountManager] asyncChangePassword:_presentPasswordLabel.text oldPassword:_oldPasswordLabel.text completion:^(BOOL isSuccess, NSString *errorStr) {
        if (isSuccess) {
            [self showHint:@"修改成功"];
            [self performSelector:@selector(goBack) withObject:nil afterDelay:0.4];
        } else {
            [hud hideTZHUD];
            if (errorStr) {
                [SVProgressHUD showHint:errorStr];
            } else {
                [SVProgressHUD showHint:@"呃～好像没找到网络"];
            }
        }
    }];
}

#pragma mark - IBActiong Methods

- (IBAction)changePassword:(UIButton *)sender {
    UserInfoInputError errorCode = [self checkInput];
    if (errorCode == NoError) {
        [self changePassword];
    } else {
        if (errorCode == PasswordNotMatchedError) {
//            [SVProgressHUD showErrorWithStatus:@"两次新密码输入不一致"];
            [self showHint:@"两次新密码输入不一致"];
            return;
        } else {
//            [SVProgressHUD showErrorWithStatus:@"请正确输入6～16位数字、字母"];
            [self showHint:@"请正确输入6～16位密码"];
            return;
        }
    }
    
    
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
    [super touchesEnded:touches withEvent:event];
}

@end




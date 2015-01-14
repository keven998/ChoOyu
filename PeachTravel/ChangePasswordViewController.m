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
    
    UILabel *ul = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 90.0, _oldPasswordLabel.bounds.size.height - 16.0)];
    ul.text = @"当前密码:";
    ul.textColor = TEXT_COLOR_TITLE;
    ul.font = [UIFont systemFontOfSize:14.0];
    ul.textAlignment = NSTextAlignmentCenter;
    _oldPasswordLabel.leftView = ul;
    _oldPasswordLabel.leftViewMode = UITextFieldViewModeAlways;
    
    UILabel *pl = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 90.0, _presentPasswordLabel.bounds.size.height - 16.0)];
    pl.text = @"新密码:";
    pl.textColor = TEXT_COLOR_TITLE;
    pl.font = [UIFont systemFontOfSize:14.0];
    pl.textAlignment = NSTextAlignmentCenter;
    _presentPasswordLabel.leftView = pl;
    _presentPasswordLabel.leftViewMode = UITextFieldViewModeAlways;
    
    UILabel *npl = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 90.0, _presentPasswordLabel.bounds.size.height - 16.0)];
    npl.text = @"确认新密码:";
    npl.textColor = TEXT_COLOR_TITLE;
    npl.font = [UIFont systemFontOfSize:12.0];
    npl.textAlignment = NSTextAlignmentCenter;
    _confirmPasswordLabel.leftView = npl;
    _confirmPasswordLabel.leftViewMode = UITextFieldViewModeAlways;
    
    UIBarButtonItem * registerBtn = [[UIBarButtonItem alloc]initWithTitle:@"确定 " style:UIBarButtonItemStyleBordered target:self action:@selector(changePassword:)];
    registerBtn.tintColor = APP_THEME_COLOR;
    self.navigationItem.rightBarButtonItem = registerBtn;
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

#pragma mark - Private Methods

- (void)goBack
{
    [self.navigationController popViewControllerAnimated:YES];
}

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
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    AppUtils *utils = [[AppUtils alloc] init];
    [manager.requestSerializer setValue:utils.appVersion forHTTPHeaderField:@"Version"];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"iOS %@",utils.systemVersion] forHTTPHeaderField:@"Platform"];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [manager.requestSerializer setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    AccountManager *accountManager = [AccountManager shareAccountManager];
    if ([accountManager isLogin]) {
        [manager.requestSerializer setValue:[NSString stringWithFormat:@"%@", accountManager.account.userId] forHTTPHeaderField:@"UserId"];
    }
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params safeSetObject:_oldPasswordLabel.text forKey:@"oldPwd"];
    [params safeSetObject:_presentPasswordLabel.text forKey:@"newPwd"];
    [params safeSetObject:accountManager.account.userId forKey:@"userId"];
    
    __weak typeof(ChangePasswordViewController *)weakSelf = self;
    TZProgressHUD *hud = [[TZProgressHUD alloc] init];
    [hud showHUDInViewController:weakSelf];
    
    [manager POST:API_CHANGE_PWD parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [hud hideTZHUD];
        NSInteger code = [[responseObject objectForKey:@"code"] integerValue];
        if (code == 0) {
            [self showHint:@"修改成功"];
            [self performSelector:@selector(goBack) withObject:nil afterDelay:0.4];
        } else {
            [SVProgressHUD showHint:[[responseObject objectForKey:@"err"] objectForKey:@"message"]];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [hud hideTZHUD];
        if (self.isShowing) {
            [SVProgressHUD showHint:@"呃～好像没找到网络"];
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




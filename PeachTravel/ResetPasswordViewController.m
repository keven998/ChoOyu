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

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIBarButtonItem *registerBtn = [[UIBarButtonItem alloc]initWithTitle:@"完成 " style:UIBarButtonItemStyleBordered target:self action:@selector(confirm:)];
    registerBtn.tintColor = APP_THEME_COLOR;
    self.navigationItem.rightBarButtonItem = registerBtn;
    
    self.navigationItem.title = @"设置新密码";
    
    UILabel *ul = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 64.0, _passwordLabel.bounds.size.height - 16.0)];
    ul.text = @" 新密码:";
    ul.textColor = TEXT_COLOR_TITLE;
    ul.font = [UIFont systemFontOfSize:14.0];
    ul.textAlignment = NSTextAlignmentCenter;
    _passwordLabel.leftView = ul;
    _passwordLabel.leftViewMode = UITextFieldViewModeAlways;
    [_passwordLabel becomeFirstResponder];
}

#pragma mark - IBAction Methods

- (IBAction)confirm:(UIButton *)sender {
    
    NSString * regex = @"^[A-Za-z0-9]{6,16}$";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    if (![pred evaluateWithObject:_passwordLabel.text]) {
        [self showHint:@"密码只能为6-16位数字，字母"];
        return;
    }
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [manager.requestSerializer setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params safeSetObject:_phoneNumber forKey:@"tel"];
    [params safeSetObject:_passwordLabel.text forKey:@"pwd"];
    [params safeSetObject:_token forKey:@"token"];
    NSString *urlStr;
    
    if (_verifyCaptchaType == UserBindTel) {
        AccountManager *accountManager = [AccountManager shareAccountManager];
        [params setObject:accountManager.account.userId forKey:@"userId"];
        urlStr = API_BINDTEL;
    } else {
        urlStr = API_RESET_PWD;
    }
    
     __weak typeof(ResetPasswordViewController *)weakSelf = self;
    TZProgressHUD *hud = [[TZProgressHUD alloc] init];
    [hud showHUDInViewController:weakSelf.navigationController];

    //完成修改
    [manager POST:urlStr parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSInteger code = [[responseObject objectForKey:@"code"] integerValue];
        [hud hideTZHUD];
        if (code == 0) {
            if (_verifyCaptchaType == UserBindTel) {     //如果是绑定手机号过程中的设置密码
                [SVProgressHUD showHint:@"OK~成功设置"];
                AccountManager *accountManager = [AccountManager shareAccountManager];
                [accountManager updateUserInfo:_phoneNumber withChangeType:ChangeTel];
                [[NSNotificationCenter defaultCenter] postNotificationName:updateUserInfoNoti object:nil];
                [self performSelector:@selector(dismissCtl) withObject:nil afterDelay:0.3];
            } else {
                [SVProgressHUD showHint:@"OK~成功修改"];
                AccountManager *accountManager = [AccountManager shareAccountManager];
                [accountManager userDidLoginWithUserInfo:[responseObject objectForKey:@"result"]];
                [[NSNotificationCenter defaultCenter] postNotificationName:userDidLoginNoti object:nil];
                [[NSNotificationCenter defaultCenter] postNotificationName:userDidResetPWDNoti object:nil];
            }
        } else {
            [SVProgressHUD showHint:[[responseObject objectForKey:@"err"] objectForKey:@"message"]];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@", error);
        [hud hideTZHUD];
        [SVProgressHUD showHint:@"呃～好像没找到网络"];
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

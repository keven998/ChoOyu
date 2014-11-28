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
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UITextField *passwordLabel;
@property (weak, nonatomic) IBOutlet UIButton *confirmBtn;

@end

@implementation ResetPasswordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

#pragma mark - IBAction Methods

- (IBAction)confirm:(UIButton *)sender {
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [manager.requestSerializer setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:_phoneNumber forKey:@"tel"];
    [params setObject:_passwordLabel.text forKey:@"pwd"];
    [params setObject:_token forKey:@"token"];
    NSString *urlStr;
    
    if (_verifyCaptchaType == UserBindTel) {
        AccountManager *accountManager = [AccountManager shareAccountManager];
        [params setObject:accountManager.account.userId forKey:@"userId"];
        urlStr = API_BINDTEL;
    } else {
        urlStr = API_RESET_PWD;
    }
    
    [SVProgressHUD show];

    //完成修改
    [manager POST:urlStr parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSInteger code = [[responseObject objectForKey:@"code"] integerValue];
        if (code == 0) {
            if (_verifyCaptchaType == UserBindTel) {     //如果是绑定手机号过程中的设置密码
                [SVProgressHUD showSuccessWithStatus:@"设置成功"];
                AccountManager *accountManager = [AccountManager shareAccountManager];
                [accountManager updateUserInfo:_phoneNumber withChangeType:ChangeTel];
                [[NSNotificationCenter defaultCenter] postNotificationName:updateUserInfoNoti object:nil];
                [self performSelector:@selector(dismissCtl) withObject:nil afterDelay:0.3];
            } else {
                [SVProgressHUD showSuccessWithStatus:@"修改成功"];
                AccountManager *accountManager = [AccountManager shareAccountManager];
                [accountManager userDidLoginWithUserInfo:[responseObject objectForKey:@"result"]];
                [[NSNotificationCenter defaultCenter] postNotificationName:userDidLoginNoti object:nil];
                [[NSNotificationCenter defaultCenter] postNotificationName:userDidResetPWDNoti object:nil];
            }
        } else {
            [SVProgressHUD showErrorWithStatus:[[responseObject objectForKey:@"err"] objectForKey:@"message"]];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@", error);
        if (_verifyCaptchaType == UserBindTel) {     //如果是绑定手机号过程中的设置密码
            [SVProgressHUD showErrorWithStatus:@"设置失败"];
        } else {
            [SVProgressHUD showErrorWithStatus:@"修改失败"];
        }
    }];
    
    _passwordLabel.layer.borderColor = UIColorFromRGB(0xdddddd).CGColor;
    _passwordLabel.layer.borderWidth = 1.0;

    UILabel *ul = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 52.0, _passwordLabel.bounds.size.height - 14.0)];
    ul.text = @"新密码:";
    ul.textColor = UIColorFromRGB(0x393939);
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

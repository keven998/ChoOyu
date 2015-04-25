//
//  RegisterViewController.m
//  PeachTravel
//
//  Created by liangpengshuai on 14/10/13.
//  Copyright (c) 2014年 com.aizou.www. All rights reserved.
//

#import "RegisterViewController.h"
#import "SMSVerifyViewController.h"
#import "SuperWebViewController.h"

typedef void(^loginCompletion)(BOOL completed);

@interface RegisterViewController ()<UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *phoneLabel;
@property (weak, nonatomic) IBOutlet UITextField *passwordLabel;
@property (weak, nonatomic) IBOutlet UIButton *registerBtn;

@end

@implementation RegisterViewController

#pragma mark - LifeCycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    UIBarButtonItem *navBack = [[UIBarButtonItem alloc]initWithTitle:@" 取消" style:UIBarButtonItemStylePlain target:self action:@selector(goBack)];
//    navBack.tintColor = APP_THEME_COLOR;
//    self.navigationItem.leftBarButtonItem = navBack;
    
    UIBarButtonItem *registerBtn = [[UIBarButtonItem alloc]initWithTitle:@"提交 " style:UIBarButtonItemStylePlain target:self action:@selector(confirmRegister:)];
    registerBtn.tintColor = APP_THEME_COLOR;
    self.navigationItem.rightBarButtonItem = registerBtn;
    
    self.navigationItem.title = @"注册";
    
    _passwordLabel.delegate = self;
    
    UILabel *ul = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 64.0, _phoneLabel.bounds.size.height - 16.0)];
    ul.text = @"手机:";
    ul.textColor = TEXT_COLOR_TITLE;
    ul.font = [UIFont systemFontOfSize:14.0];
    ul.textAlignment = NSTextAlignmentCenter;
    _phoneLabel.leftView = ul;
    _phoneLabel.leftViewMode = UITextFieldViewModeAlways;
    _phoneLabel.text = _defaultPhone;
    
    UILabel *pl = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 64.0, _passwordLabel.bounds.size.height - 16.0)];
    pl.text = @"密码:";
    pl.textColor = TEXT_COLOR_TITLE;
    pl.font = [UIFont systemFontOfSize:14.0];
    pl.textAlignment = NSTextAlignmentCenter;
    _passwordLabel.leftView = pl;
    _passwordLabel.leftViewMode = UITextFieldViewModeAlways;
    _passwordLabel.text = _defaultPassword;

    _registerBtn.layer.cornerRadius = 4.0;
    _registerBtn.clipsToBounds = YES;
    [_registerBtn setBackgroundImage:[ConvertMethods createImageWithColor:APP_THEME_COLOR] forState:UIControlStateNormal];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [MobClick beginLogPageView:@"page_register"];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:@"page_register"];
}

- (void)goBack {
    if (self.navigationController.childViewControllers.count > 1) {
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == _passwordLabel) {
        [textField resignFirstResponder];
    }
    return YES;
}

#pragma mark - IBAction Methods

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
    [super touchesEnded:touches withEvent:event];
}

- (IBAction)confirmRegister:(UIButton *)sender {
    [self.view endEditing:YES];
    switch ([self checkInput]) {
        case NoError: {
            [self getCaptcha];
            _registerBtn.userInteractionEnabled = NO;
        }
            break;
            
        case PhoneNumberError:
            [self showHint:@"手机号输错了"];
            break;
            
        case PasswordError:
            [self showHint:@"密码是6-16位的数字或字母"];
            break;
            
        default:
            break;
    }
}

#pragma mark - Private Methods

- (UserInfoInputError)checkInput
{
    NSString * regex0 = @"^1\\d{10}$";
    NSPredicate *pred0 = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex0];
    if (![pred0 evaluateWithObject:_phoneLabel.text]) {
        return PhoneNumberError;
    }
    
    NSString * regex = @"^[A-Za-z0-9]{6,16}$";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    if (![pred evaluateWithObject:_passwordLabel.text]) {
        return PasswordError;
    }

    return NoError;
}

- (void)getCaptcha
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    AppUtils *utils = [[AppUtils alloc] init];
    [manager.requestSerializer setValue:utils.appVersion forHTTPHeaderField:@"Version"];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"iOS %@",utils.systemVersion] forHTTPHeaderField:@"Platform"];
    
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [manager.requestSerializer setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:_phoneLabel.text forKey:@"tel"];
    [params setObject:kUserRegister forKey:@"actionCode"];
     __weak typeof(RegisterViewController *)weakSelf = self;
    TZProgressHUD *hud = [[TZProgressHUD alloc] init];
    [hud showHUDInViewController:weakSelf];

    //获取注册码
    [manager POST:API_GET_CAPTCHA parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [hud hideTZHUD];
        NSInteger code = [[responseObject objectForKey:@"code"] integerValue];
        _registerBtn.userInteractionEnabled = YES;
        if (code == 0) {
            SMSVerifyViewController *smsVerifyCtl = [[SMSVerifyViewController alloc] init];
            smsVerifyCtl.phoneNumber = self.phoneLabel.text;
            smsVerifyCtl.password = self.passwordLabel.text;
            smsVerifyCtl.coolDown = [[[responseObject objectForKey:@"result"] objectForKey:@"coolDown"] integerValue];
            [self.navigationController pushViewController:smsVerifyCtl animated:YES];
        } else {
            if ([[responseObject objectForKey:@"err"] objectForKey:@"message"]) {
                [SVProgressHUD showHint:[[responseObject objectForKey:@"err"] objectForKey:@"message"]];
            } else {
                [SVProgressHUD showHint:@"验证码获取失败~"];
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@", error);
        [hud hideTZHUD];
        _registerBtn.userInteractionEnabled = YES;
        if (self.isShowing) {
            [SVProgressHUD showHint:@"呃～好像没找到网络"];
        }
    }];
}
- (IBAction)goProtocolWebView:(UIButton *)sender {
    SuperWebViewController *webViewCtl = [[SuperWebViewController alloc] init];
    webViewCtl.urlStr = APP_AGREEMENT;
    webViewCtl.titleStr = @"用户注册协议";
    [self.navigationController pushViewController:webViewCtl animated:YES];
}

@end




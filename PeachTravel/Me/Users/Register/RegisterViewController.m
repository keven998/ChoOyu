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

@property (strong, nonatomic)  UITextField *phoneLabel;
@property (strong, nonatomic)  UITextField *passwordLabel;
@property (strong, nonatomic)  UIButton *registerBtn;

@end

@implementation RegisterViewController

#pragma mark - LifeCycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = APP_PAGE_COLOR;
    
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    backBtn.frame = CGRectMake(0, 0, 64, 64);
    [backBtn setImage:[UIImage imageNamed:@"login_back_defaut"] forState:UIControlStateNormal];
    [backBtn setImage:[UIImage imageNamed:@"common_icon_navigation_back_highlight"] forState:UIControlStateHighlighted];
    [backBtn addTarget:self action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];
    backBtn.contentVerticalAlignment = UIControlContentVerticalAlignmentTop;
    backBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [backBtn setImageEdgeInsets:UIEdgeInsetsMake(34, 14, 0, 0)];
    [self.view addSubview:backBtn];
    
    [self createUI];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear: animated];

}

- (void)createUI
{
    UIImageView *iconImage = [[UIImageView alloc]initWithFrame:CGRectMake(489/3 * kWindowWidth/414, 216/3 *kWindowHeight/736, 87*kWindowHeight/736, 87*kWindowHeight/736)];
    iconImage.image = [UIImage imageNamed:@"icon_little"];
    [self.view addSubview:iconImage];
    
    
    UIView *textFieldBg = [[UIView alloc]initWithFrame:CGRectMake(13, CGRectGetMaxY(iconImage.frame) + 40, kWindowWidth - 26, 121 * kWindowHeight/736)];
    textFieldBg.layer.borderColor = APP_THEME_COLOR.CGColor;
    textFieldBg.layer.borderWidth = 1;
    textFieldBg.layer.cornerRadius = 5;
    [self.view addSubview:textFieldBg];
    
    UIView *devide = [[UIView alloc]initWithFrame:CGRectMake(0, 60 *kWindowHeight/736 , kWindowWidth - 26, 1)];
    devide.backgroundColor = APP_THEME_COLOR;
    [textFieldBg addSubview:devide];
    
    _phoneLabel = [[UITextField alloc]initWithFrame:CGRectMake(10, 0, kWindowWidth - 50, 60 * kWindowHeight / 736)];
    UILabel *ul = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 64.0, _phoneLabel.bounds.size.height - 16.0)];
    ul.text = @"手机:";
    ul.textColor = COLOR_TEXT_I;
    ul.font = [UIFont systemFontOfSize:13.0];
    ul.textAlignment = NSTextAlignmentCenter;
    _phoneLabel.leftView = ul;
    _phoneLabel.placeholder = @"手机号";
    _phoneLabel.leftViewMode = UITextFieldViewModeAlways;
    _phoneLabel.text = _defaultPhone;
    _phoneLabel.textColor = COLOR_TEXT_I;
    _phoneLabel.font = [UIFont systemFontOfSize:15.0];
    _phoneLabel.delegate = self;
    _phoneLabel.keyboardType = UIKeyboardTypePhonePad;
    [textFieldBg addSubview:_phoneLabel];
    
    _passwordLabel = [[UITextField alloc]initWithFrame:CGRectMake(10, 60 * kWindowHeight / 736, kWindowWidth - 50, 60 * kWindowHeight / 736)];
    
    UILabel *pl = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 64.0, _passwordLabel.bounds.size.height - 16.0)];
    pl.text = @"密码:";
    pl.textColor = COLOR_TEXT_I;
    pl.font = [UIFont systemFontOfSize:13.0];
    pl.textAlignment = NSTextAlignmentCenter;
    _passwordLabel.leftView = pl;
    _passwordLabel.placeholder = @"设置密码";
    _passwordLabel.leftViewMode = UITextFieldViewModeAlways;
    _passwordLabel.text = _defaultPassword;
    _passwordLabel.font = [UIFont systemFontOfSize:15.0];
    _passwordLabel.delegate = self;
    _passwordLabel.textColor = COLOR_TEXT_I;
    _passwordLabel.secureTextEntry = YES;
    [textFieldBg addSubview:_passwordLabel];
    
    _registerBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    _registerBtn.frame = CGRectMake(13, CGRectGetMaxY(textFieldBg.frame) + 5, kWindowWidth - 26, 56 * kWindowHeight/736);
    [_registerBtn setTitle:@"下一步" forState:UIControlStateNormal];
    _registerBtn.layer.cornerRadius = 5.0;
    _registerBtn.clipsToBounds = YES;
    _registerBtn.titleLabel.font = [UIFont systemFontOfSize:16.0];
    [_registerBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_registerBtn setTitleColor:APP_THEME_COLOR forState:UIControlStateHighlighted];
    [_registerBtn setBackgroundImage:[ConvertMethods createImageWithColor:APP_THEME_COLOR] forState:UIControlStateNormal];
    [self.view addSubview:_registerBtn];
    [_registerBtn addTarget:self action:@selector(confirmRegister:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *label = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 100, 32)];
    label.titleLabel.font = [UIFont systemFontOfSize:13.0];
    [label setTitleColor:APP_THEME_COLOR forState:UIControlStateNormal];
    [label setTitleColor:APP_THEME_COLOR_HIGHLIGHT forState:UIControlStateHighlighted];
    label.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;\
    [label setTitle:@"注册协议" forState:UIControlStateNormal];
    [label addTarget:self action:@selector(goProtocolWebView:) forControlEvents:UIControlEventTouchUpInside];
    label.center = CGPointMake(CGRectGetWidth(self.view.bounds)/2.0, CGRectGetHeight(self.view.bounds) - 44);
    [self.view addSubview:label];
    
}

- (void)goBack
{
    if (self.navigationController.childViewControllers.count > 1) {
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == _passwordLabel) {
        [textField resignFirstResponder];
    }
    return YES;
}

#pragma mark - IBAction Methods

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
    [super touchesEnded:touches withEvent:event];
}

- (IBAction)confirmRegister:(UIButton *)sender
{
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

/**
 *  获得验证码
 */
- (void)getCaptcha
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    AppUtils *utils = [[AppUtils alloc] init];
    [manager.requestSerializer setValue:utils.appVersion forHTTPHeaderField:@"Version"];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"iOS %@",utils.systemVersion] forHTTPHeaderField:@"Platform"];
    
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:_phoneLabel.text forKey:@"tel"];
    [params setObject:[NSNumber numberWithInt:1] forKey:@"action"];
    [params setObject:[NSNumber numberWithInt:86] forKey:@"dialCode"];

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
            [self.navigationController setNavigationBarHidden:NO animated:YES];
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
        if (operation.response.statusCode == 403) {
            [SVProgressHUD showHint:@"获取验证码过于频繁"];
        } else if (operation.response.statusCode == 409) {
            [SVProgressHUD showHint:@"号码已注册"];
            
        } else {
            [SVProgressHUD showHint:HTTP_FAILED_HINT];

        }
    }];
}

- (IBAction)goProtocolWebView:(UIButton *)sender
{
    SuperWebViewController *webViewCtl = [[SuperWebViewController alloc] init];
    webViewCtl.urlStr = APP_AGREEMENT;
    webViewCtl.titleStr = @"用户注册协议";
    webViewCtl.hideToolBar = YES;
    [self.navigationController pushViewController:webViewCtl animated:YES];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

@end




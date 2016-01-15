//
//  LoginViewController.m
//  PeachTravel
//
//  Created by liangpengshuai on 14/10/11.
//  Copyright (c) 2014年 com.aizou.www. All rights reserved.
//

#import "LoginViewController.h"
#import "RegisterViewController.h"
#import "VerifyCaptchaViewController.h"
#import "AccountManager.h"
#import "WXApi.h"
#import "UIImage+resized.h"
#define Width kWindowWidth
#define Height kWindowHeight

@interface LoginViewController ()<UITextFieldDelegate>

@property (strong, nonatomic) UITextField *userNameTextField;
@property (strong, nonatomic) UITextField *passwordTextField;
@property (strong, nonatomic) UIButton *loginBtn;
@property (strong, nonatomic) UIButton *losePassworkBtn;
@property (strong, nonatomic) UIButton *weiChatBtn;
@property (strong, nonatomic) UIView *backView;
@property (strong, nonatomic) UILabel *wechatLabel;
@property (strong, nonatomic) UIButton *registerBtn;
@property (strong, nonatomic) UIImageView *iconImageView;

//disappear 的时候是不是应该显示出 navigationbar
@property (nonatomic) BOOL shouldNotShowNavigationBarWhenDisappear;

@property (nonatomic, copy) void (^loginCompletion)(BOOL completed);

@end

@implementation LoginViewController

#pragma mark - LifeCycle

- (id) initWithCompletion:(loginCompletion)completion
{
    if (self = [super init]) {
        self.loginCompletion = completion;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
    imageView.image = [UIImage imageNamed:@"icon_login_bg"];
    imageView.userInteractionEnabled = YES;
    [self.view addSubview:imageView];
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    backBtn.frame = CGRectMake(0, 20, 70, 64);
    [backBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [backBtn setTitle:@"取消" forState:UIControlStateNormal];
    backBtn.titleLabel.font = [UIFont systemFontOfSize:16.0];
    [backBtn addTarget:self action:@selector(dismissCtl) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backBtn];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userDidRegisted) name:userDidRegistedNoti object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userDidRegisted) name:userDidResetPWDNoti object:nil];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(dismissCtl)];
    
    [self createUI];
    
    [[TMCache sharedCache] objectForKey:@"last_account" block:^(TMCache *cache, NSString *key, id object)  {
        if (object != nil) {
            _userNameTextField.text = object;
        }
    }];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(weixinDidLogin:) name:weixinDidLoginNoti object:nil];
    
    if (![WXApi isWXAppInstalled]) {
        _wechatLabel.hidden = YES;
    } else {
        _wechatLabel.hidden = NO;
    }
    
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:weixinDidLoginNoti object:nil];
    
    if (!_shouldNotShowNavigationBarWhenDisappear) {
        [self.navigationController setNavigationBarHidden:NO animated:YES];
    }
    _shouldNotShowNavigationBarWhenDisappear = NO;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)createUI
{
    _iconImageView = [[UIImageView alloc]initWithFrame:CGRectMake((Width - 300/3 *Height/736)/2, 300/3 * Height/736, 300/3 *Height/736 , 300/3 *Height/736)];
    _iconImageView.image = [UIImage imageNamed:@"icon_login_avatar"];
    [self.view addSubview:_iconImageView];
    
    UIView *leftViewOne = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
    _userNameTextField = [[UITextField alloc]initWithFrame:CGRectMake(12, CGRectGetMaxY(_iconImageView.frame) + 40, Width-25, 55 * Height / 736)];
    _userNameTextField.leftView = leftViewOne;
    _userNameTextField.placeholder = @"手机/名字/ID";
    _userNameTextField.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.65];
    _userNameTextField.textColor = [UIColor blackColor];
    [_userNameTextField setValue:[UIColor whiteColor] forKeyPath:@"_placeholderLabel.textColor"];
    _userNameTextField.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
    _userNameTextField.font = [UIFont systemFontOfSize:15.0];
    _userNameTextField.leftViewMode = UITextFieldViewModeAlways;
    _userNameTextField.delegate = self;
    _userNameTextField.layer.cornerRadius = 3.0;
    [self.view addSubview:_userNameTextField];
    
    UIView *leftViewTwo = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
    _passwordTextField = [[UITextField alloc]initWithFrame:CGRectMake(12, CGRectGetMaxY(_userNameTextField.frame)+10, Width-25, 60 * Height / 736)];
    _passwordTextField.leftView = leftViewTwo;

    _passwordTextField.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.65];
    _passwordTextField.placeholder = @"请输入密码";
    _passwordTextField.leftViewMode = UITextFieldViewModeAlways;
    _passwordTextField.textColor = [UIColor blackColor];
    [_passwordTextField setValue:[UIColor whiteColor] forKeyPath:@"_placeholderLabel.textColor"];

    _passwordTextField.font = [UIFont systemFontOfSize:15.0];
    _passwordTextField.secureTextEntry = YES;
    _passwordTextField.delegate = self;
    _passwordTextField.layer.cornerRadius = 3.0;
    [self.view addSubview:_passwordTextField];
    
    _loginBtn = [[UIButton alloc]initWithFrame:CGRectMake(13, CGRectGetMaxY(_passwordTextField.frame) + 15, Width - 26, 55 * Height/736)];
    [_loginBtn setBackgroundImage:[ConvertMethods createImageWithColor:[APP_THEME_COLOR colorWithAlphaComponent:0.8]] forState:UIControlStateNormal];
    [_loginBtn setBackgroundImage:[ConvertMethods createImageWithColor:[APP_THEME_COLOR colorWithAlphaComponent:0.5]] forState:UIControlStateHighlighted];
    _loginBtn.layer.cornerRadius = 5;
    _loginBtn.clipsToBounds = YES;
    _loginBtn.titleLabel.font = [UIFont systemFontOfSize:16.0];
    [_loginBtn setTitle:@"登录" forState:UIControlStateNormal];
    [_loginBtn setTitleColor:COLOR_TEXT_I forState:UIControlStateNormal];
    [_loginBtn setTitleColor:APP_THEME_COLOR forState:UIControlStateHighlighted];
    [_loginBtn addTarget:self action:@selector(login:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_loginBtn];
    
    _losePassworkBtn = [[UIButton alloc]initWithFrame:CGRectMake(20, Height-60, 70, 36)];
    [_losePassworkBtn setTitle:@"忘记密码" forState:UIControlStateNormal];
    [_losePassworkBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_losePassworkBtn setTitleColor:COLOR_DISABLE forState:UIControlStateHighlighted];
    _losePassworkBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    [_losePassworkBtn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    [_losePassworkBtn addTarget:self action:@selector(losePassword:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_losePassworkBtn];
    
    _registerBtn = [[UIButton alloc]initWithFrame:CGRectMake(CGRectGetWidth(self.view.frame) - 100, Height-60, 80, 36)];
    [_registerBtn setTitle:@"新用户注册" forState:UIControlStateNormal];
    [_registerBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_registerBtn setTitleColor:COLOR_DISABLE forState:UIControlStateHighlighted];
    _registerBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    [_registerBtn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
    [_registerBtn addTarget:self action:@selector(userRegister:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_registerBtn];
  
    // 下面代码是微信登陆
    _weiChatBtn = [[TZButton alloc] init];
    _weiChatBtn.frame = CGRectMake(0, 0, 100, 40);
    _weiChatBtn.center = CGPointMake(Width/2, CGRectGetMaxY(_registerBtn.frame) + 40);
    [_weiChatBtn setImage:[UIImage imageNamed:@"icon_wechat_login"] forState:UIControlStateNormal];
    [_weiChatBtn setTitle:@"微信登录" forState:UIControlStateNormal];
    [_weiChatBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_weiChatBtn setTitleColor:COLOR_DISABLE forState:UIControlStateHighlighted];
    ((TZButton *)_weiChatBtn).spaceHight = 15;
    [self.view addSubview:_weiChatBtn];
    [_weiChatBtn addTarget:self action:@selector(weixinLogin:) forControlEvents:UIControlEventTouchUpInside];
    _weiChatBtn.titleLabel.font = [UIFont systemFontOfSize:17];
    
    // 没有安装微信,则隐藏
    if (![WXApi isWXAppInstalled]) {
        _weiChatBtn.hidden = YES;
    }
}

#pragma mark - IBAction Methods

- (IBAction)userRegister:(id)sender
{
    _shouldNotShowNavigationBarWhenDisappear = YES;
    RegisterViewController *registerCtl = [[RegisterViewController alloc] init];
    registerCtl.defaultPhone = _userNameTextField.text;
    registerCtl.defaultPassword = _passwordTextField.text;
    [self.navigationController pushViewController:registerCtl animated:YES];
}

/**
 *  忘记密码
 *
 *  @param sender
 */
- (IBAction)losePassword:(UIButton *)sender
{
    VerifyCaptchaViewController *losePasswordCtl = [[VerifyCaptchaViewController alloc] init];
    losePasswordCtl.verifyCaptchaType = UserLosePassword;
    [self.navigationController pushViewController:losePasswordCtl animated:YES];
}

//帐号密码登录
- (IBAction)login:(UIButton *)sender
{
    [self.view endEditing:YES];
    if (!(([_userNameTextField.text stringByReplacingOccurrencesOfString:@" " withString:@""].length!=0) && ([_passwordTextField.text stringByReplacingOccurrencesOfString:@" " withString:@""].length != 0)) ) {
        //        [self showHint:@"不输帐号或密码，是没法登录滴"];
        [SVProgressHUD showHint:@"请输入账号和密码"];
        return;
    }
    
    // 正则表达式判断用户输入是否合法
    NSString * regex0 = @"^1\\d{10}$";
    NSPredicate *pred0 = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex0];
    if (![pred0 evaluateWithObject:_userNameTextField.text]) {
        [self showHint:@"手机号输错了"];
        return;
    }
    __weak typeof(LoginViewController *)weakSelf = self;
    TZProgressHUD *hud = [[TZProgressHUD alloc] init];
    [hud showHUDInViewController:weakSelf content:64];
    /**
     *  登录是调用AccountManager的异步登录方法,
     *
     *  @param isSuccess 登录是否成功
     *  @param errorStr  错误信息
     */
    [[AccountManager shareAccountManager] asyncLogin:_userNameTextField.text password:_passwordTextField.text completion:^(BOOL isSuccess, NSString *errorStr) {
        if (isSuccess) {
            [self performSelector:@selector(dismissCtl) withObject:nil afterDelay:0.3];
            if (self.loginCompletion) {
                self.loginCompletion(YES);
            }
        } else {
            [hud hideTZHUD];
            if (self.isShowing) {
                if (errorStr) {
                    [SVProgressHUD showHint:errorStr];
                } else {
                    [SVProgressHUD showHint:HTTP_FAILED_HINT];
                }
            }
        }
    }];
}

//微信登录
- (IBAction)weixinLogin:(UIButton *)sender
{
    [self sendAuthRequest];
}

#pragma mark - private methods

- (void)sendAuthRequest
{
    //构造SendAuthReq结构体
    SendAuthReq* req =[[SendAuthReq alloc] init];
    req.scope = @"snsapi_userinfo" ;

    req.state = @"lvxingpai";
    //第三方向微信终端发送一个SendAuthReq消息结构
    [WXApi sendReq:req];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    
    if (textField == _userNameTextField) {
        [_passwordTextField becomeFirstResponder];
    } else if (textField == _passwordTextField) {
        [textField resignFirstResponder];
    }
    
    return YES;
}


- (void)weixinDidLogin:(NSNotification *)noti
{
    NSString *code = [noti.userInfo objectForKey:@"code"];
    __weak typeof(LoginViewController *)weakSelf = self;
    TZProgressHUD *hud = [[TZProgressHUD alloc] init];
    [hud showHUDInViewController:weakSelf content:64];
    
    [[AccountManager shareAccountManager] asyncLoginWithWeChat:code completion:^(BOOL isSuccess, NSString *errorStr) {
        if (isSuccess) {
            [self performSelector:@selector(dismissCtl) withObject:nil afterDelay:0.3];
            if (self.loginCompletion) {
                self.loginCompletion(YES);
            }
        } else {
            [hud hideTZHUD];
            if (self.isShowing) {
                if (errorStr) {
                    [SVProgressHUD showHint:errorStr];
                } else {
                    [SVProgressHUD showHint:HTTP_FAILED_HINT];
                }
            }
        }
    }];
}

- (void)userDidRegisted
{
    [self performSelector:@selector(dismissCtl) withObject:nil afterDelay:0.3];
    if (self.loginCompletion) {
        self.loginCompletion(YES);
    }
}

- (void)dismissCtl
{
    _shouldNotShowNavigationBarWhenDisappear = YES;
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end




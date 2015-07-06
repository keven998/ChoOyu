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
#define Width SCREEN_WIDTH
#define Height SCREEN_HEIGHT

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
@property (strong, nonatomic) UIView *textFieldBg;

@property (nonatomic, copy) void (^completion)(BOOL completed);

@end

@implementation LoginViewController

#pragma mark - LifeCycle

- (id) initWithCompletion:(loginCompletion)completion {
    if (self = [super init]) {
        self.completion = completion;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    backBtn.frame = CGRectMake(0, 0, 64, 64);
    [backBtn setImage:[UIImage imageNamed:@"common_icon_navigaiton_back"] forState:UIControlStateNormal];
    [backBtn setImage:[UIImage imageNamed:@"common_icon_navigaiton_back_highlight"] forState:UIControlStateHighlighted];
    [backBtn addTarget:self action:@selector(dismissCtl) forControlEvents:UIControlEventTouchUpInside];
    backBtn.contentVerticalAlignment = UIControlContentVerticalAlignmentTop;
    backBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [backBtn setImageEdgeInsets:UIEdgeInsetsMake(34, 14, 0, 0)];
    [self.view addSubview:backBtn];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userDidRegisted) name:userDidRegistedNoti object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userDidRegisted) name:userDidResetPWDNoti object:nil];
    
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(dismissCtl)];
    
    self.view.backgroundColor = APP_THEME_COLOR;
    
    [self createUI];
    
    [[TMCache sharedCache] objectForKey:@"last_account" block:^(TMCache *cache, NSString *key, id object)  {
        if (object != nil) {
            _userNameTextField.text = object;
        }
    }];
}
- (void)createUI
{
    _iconImageView = [[UIImageView alloc]initWithFrame:CGRectMake((Width - 483/3 *Height/736)/2, 282/3 * Height/736, 483/3 *Height/736 , 483/3 *Height/736)];
    _iconImageView.image = [UIImage imageNamed:@"icon"];
    [self.view addSubview:_iconImageView];
    
    _textFieldBg = [[UIView alloc]initWithFrame:CGRectMake(13, CGRectGetMaxY(_iconImageView.frame) + 40, Width - 26, 122 * Height / 736)];
    _textFieldBg.backgroundColor = [UIColor whiteColor];
    _textFieldBg.layer.cornerRadius = 5;
    _textFieldBg.userInteractionEnabled = YES;
    [self.view addSubview:_textFieldBg];
    UIView *textFieldDevide = [[UIView alloc]initWithFrame:CGRectMake(0, 60 * Height/736, Width - 26, 2)];
    textFieldDevide.backgroundColor = APP_THEME_COLOR;
    [_textFieldBg addSubview:textFieldDevide];
    
    _userNameTextField = [[UITextField alloc]initWithFrame:CGRectMake(12, 0* Height / 736, Width-25, CGRectGetHeight(_textFieldBg.frame)/2)];
    UILabel *ul = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 64.0, _userNameTextField.bounds.size.height - 16.0)];
    ul.text = @" 账号:";
    ul.textColor = COLOR_TEXT_I;
    ul.font = [UIFont systemFontOfSize:13.0];
    ul.textAlignment = NSTextAlignmentCenter;
    _userNameTextField.placeholder = @"手机/名字/ID";
    _userNameTextField.leftView = ul;
    _userNameTextField.textColor = COLOR_TEXT_I;
    _userNameTextField.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
    _userNameTextField.font = [UIFont systemFontOfSize:15.0];
    _userNameTextField.leftViewMode = UITextFieldViewModeAlways;
    _userNameTextField.delegate = self;
    [_textFieldBg addSubview:_userNameTextField];
    
    _passwordTextField = [[UITextField alloc]initWithFrame:CGRectMake(12, 60 * Height / 736, Width-25, CGRectGetHeight(_textFieldBg.frame)/2)];
    UILabel *pl = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 64.0, _userNameTextField.bounds.size.height - 16.0)];
    pl.text = @" 密码:";
    pl.textColor = COLOR_TEXT_I;
    pl.font = [UIFont systemFontOfSize:13.0];
    pl.textAlignment = NSTextAlignmentCenter;
    _passwordTextField.leftView = pl;
    _passwordTextField.placeholder = @"请输入密码";
    _passwordTextField.leftViewMode = UITextFieldViewModeAlways;
    _passwordTextField.textColor = COLOR_TEXT_I;
    _passwordTextField.font = [UIFont systemFontOfSize:15.0];
    _passwordTextField.secureTextEntry = YES;
    _passwordTextField.delegate = self;
    [_textFieldBg addSubview:_passwordTextField];
    
    _loginBtn = [[UIButton alloc]initWithFrame:CGRectMake(13, CGRectGetMaxY(_textFieldBg.frame) + 5, Width - 26, 62 * Height/736)];
    [_loginBtn setBackgroundImage:[ConvertMethods createImageWithColor:[UIColor whiteColor]] forState:UIControlStateNormal];
    [_loginBtn setBackgroundImage:[ConvertMethods createImageWithColor:APP_PAGE_COLOR] forState:UIControlStateHighlighted];
    _loginBtn.layer.cornerRadius = 5;
    _loginBtn.clipsToBounds = YES;
    _loginBtn.titleLabel.font = [UIFont systemFontOfSize:16.0];
    [_loginBtn setTitle:@"登录" forState:UIControlStateNormal];
    [_loginBtn setTitleColor:COLOR_TEXT_I forState:UIControlStateNormal];
    [_loginBtn setTitleColor:APP_THEME_COLOR forState:UIControlStateHighlighted];
    [_loginBtn addTarget:self action:@selector(login:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_loginBtn];
    
    _losePassworkBtn = [[UIButton alloc]initWithFrame:CGRectMake(20, CGRectGetMaxY(_loginBtn.frame) + 15, 70, 36)];
    [_losePassworkBtn setTitle:@"忘记密码" forState:UIControlStateNormal];
    [_losePassworkBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_losePassworkBtn setTitleColor:COLOR_DISABLE forState:UIControlStateHighlighted];
    _losePassworkBtn.titleLabel.font = [UIFont systemFontOfSize:12];
    [_losePassworkBtn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    [_losePassworkBtn addTarget:self action:@selector(losePassword:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_losePassworkBtn];
    
    _registerBtn = [[UIButton alloc]initWithFrame:CGRectMake(CGRectGetWidth(self.view.frame) - 100, CGRectGetMaxY(_loginBtn.frame) + 15, 80, 36)];
    [_registerBtn setTitle:@"新用户注册" forState:UIControlStateNormal];
    [_registerBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_registerBtn setTitleColor:COLOR_DISABLE forState:UIControlStateHighlighted];
    _registerBtn.titleLabel.font = [UIFont systemFontOfSize:12];
    [_registerBtn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
    [_registerBtn addTarget:self action:@selector(userRegister:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_registerBtn];
    
    _weiChatBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    _weiChatBtn.frame = CGRectMake(0, 0, 100, 40);
    _weiChatBtn.center = CGPointMake(Width/2, CGRectGetMaxY(_registerBtn.frame) + 40);
    [_weiChatBtn setTitle:@"微信登陆" forState:UIControlStateNormal];
    [_weiChatBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_weiChatBtn setTitleColor:COLOR_DISABLE forState:UIControlStateHighlighted];    [self.view addSubview:_weiChatBtn];
    [_weiChatBtn addTarget:self action:@selector(weixinLogin:) forControlEvents:UIControlEventTouchUpInside];
    _weiChatBtn.titleLabel.font = [UIFont systemFontOfSize:20];
    
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [MobClick beginLogPageView:@"page_login"];
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
    [MobClick endLogPageView:@"page_login"];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:weixinDidLoginNoti object:nil];
[self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - IBAction Methods

- (IBAction)userRegister:(id)sender
{
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
- (IBAction)losePassword:(UIButton *)sender {
    VerifyCaptchaViewController *losePasswordCtl = [[VerifyCaptchaViewController alloc] init];
    [self.navigationController pushViewController:losePasswordCtl animated:YES];
}

//帐号密码登录
- (IBAction)login:(UIButton *)sender {
    [UIView animateWithDuration:0.2 animations:^{
        _iconImageView.frame = CGRectMake((Width - 483/3 *Height/736)/2, 282/3 * Height/736, 483/3 *Height/736 , 483/3 *Height/736);
        _textFieldBg.frame = CGRectMake(13, CGRectGetMaxY(_iconImageView.frame) + 40, Width - 26, 122 * Height / 736);
        _loginBtn.frame = CGRectMake(13, CGRectGetMaxY(_textFieldBg.frame) + 5, Width - 26, 62 * Height/736);
    }];

    [self.view endEditing:YES];
    if (!(([_userNameTextField.text stringByReplacingOccurrencesOfString:@" " withString:@""].length!=0) && ([_passwordTextField.text stringByReplacingOccurrencesOfString:@" " withString:@""].length != 0)) ) {
        //        [self showHint:@"不输帐号或密码，是没法登录滴"];
        [SVProgressHUD showHint:@"请输入账号和密码"];
        return;
    }
    
    NSString * regex0 = @"^1\\d{10}$";
    NSPredicate *pred0 = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex0];
    if (![pred0 evaluateWithObject:_userNameTextField.text]) {
        [self showHint:@"手机号输错了"];
        return;
    }
    __weak typeof(LoginViewController *)weakSelf = self;
    TZProgressHUD *hud = [[TZProgressHUD alloc] init];
    [hud showHUDInViewController:weakSelf content:64];
    [[AccountManager shareAccountManager] asyncLogin:_userNameTextField.text password:_passwordTextField.text completion:^(BOOL isSuccess, NSString *errorStr) {
        if (isSuccess) {
            [self performSelector:@selector(dismissCtl) withObject:nil afterDelay:0.3];
            if (self.completion) {
                self.completion(YES);
            }
        } else {
            [hud hideTZHUD];
            if (self.isShowing) {
                if (errorStr) {
                    [SVProgressHUD showHint:errorStr];
                } else {
                    [SVProgressHUD showHint:@"呃～好像没找到网络"];
                }
            }
        }
    }];
}

//微信登录
- (IBAction)weixinLogin:(UIButton *)sender {
    [MobClick event:@"event_login_with_weichat_account"];
    [self sendAuthRequest];
}

#pragma mark - private methods

-(void)sendAuthRequest
{
    //构造SendAuthReq结构体
    SendAuthReq* req =[[SendAuthReq alloc] init];
    req.scope = @"snsapi_userinfo" ;

    req.state = @"lvxingpai";
    //第三方向微信终端发送一个SendAuthReq消息结构
    [WXApi sendReq:req];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    if (textField == _userNameTextField) {
        [_passwordTextField becomeFirstResponder];
    } else if (textField == _passwordTextField) {
        [textField resignFirstResponder];
    }
    
    return YES;
}
-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    [UIView animateWithDuration:0.2 animations:^{
        _iconImageView.frame = CGRectMake((Width - 483/3 *Height/736)/2, 282/3 * Height/736 - 88 *Height / 736, 483/3 *Height/736 , 483/3 *Height/736);
        _textFieldBg.frame = CGRectMake(13, CGRectGetMaxY(_iconImageView.frame) + 40, Width - 26, 122 * Height / 736);
        _loginBtn.frame = CGRectMake(13, CGRectGetMaxY(_textFieldBg.frame) + 5, Width - 26, 62 * Height/736);
    }];
    
}
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    
    [UIView animateWithDuration:0.2 animations:^{
        _iconImageView.frame = CGRectMake((Width - 483/3 *Height/736)/2, 282/3 * Height/736, 483/3 *Height/736 , 483/3 *Height/736);
        _textFieldBg.frame = CGRectMake(13, CGRectGetMaxY(_iconImageView.frame) + 40, Width - 26, 122 * Height / 736);
        _loginBtn.frame = CGRectMake(13, CGRectGetMaxY(_textFieldBg.frame) + 5, Width - 26, 62 * Height/736);
    }];
    
    
    [self.view endEditing:YES];
    [super touchesEnded:touches withEvent:event];
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
            if (self.completion) {
                self.completion(YES);
            }
        } else {
            [hud hideTZHUD];
            if (self.isShowing) {
                if (errorStr) {
                    [SVProgressHUD showHint:errorStr];
                } else {
                    [SVProgressHUD showHint:@"呃～好像没找到网络"];
                }
            }
        }
    }];
}

- (void)userDidRegisted
{
    [self performSelector:@selector(dismissCtl) withObject:nil afterDelay:0.3];
    if (self.completion) {
        self.completion(YES);
    }
}

- (void)dismissCtl
{
    if (self.navigationController.viewControllers.count > 1) {
        [self.navigationController popToRootViewControllerAnimated:YES];
    } else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

@end




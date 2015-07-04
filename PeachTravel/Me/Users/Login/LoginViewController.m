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
@property (strong, nonatomic) UIButton *supportLoginButton;
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
    
    self.navigationItem.title = @"登录";
    
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    backBtn.frame = CGRectMake(13, 34, 15, 15);
    [backBtn setImage:[UIImage imageNamed:@"common_icon_navigaiton_back"] forState:UIControlStateNormal];
    [backBtn setImage:[UIImage imageNamed:@"common_icon_navigaiton_back_highlight"] forState:UIControlStateHighlighted];
    [self.view addSubview:backBtn];
    [backBtn addTarget:self action:@selector(dismissCtl) forControlEvents:UIControlEventTouchUpInside];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userDidRegisted) name:userDidRegistedNoti object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userDidRegisted) name:userDidResetPWDNoti object:nil];


    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(dismissCtl)];

    self.view.backgroundColor = APP_THEME_COLOR;
    
    [self createUI];
    
   
    [_weiChatBtn addTarget:self action:@selector(weixinLogin:) forControlEvents:UIControlEventTouchUpInside];
    
    
    
    [_supportLoginButton setImage:[UIImage imageNamed:@"ic_login_weixin.png"] forState:UIControlStateNormal];
    [_supportLoginButton setImage:[UIImage imageNamed:@"ic_login_weixin_highlight.png"] forState:UIControlStateHighlighted];
    
    UIBarButtonItem * registerBtn = [[UIBarButtonItem alloc]initWithTitle:@"新用户" style:UIBarButtonItemStylePlain target:self action:@selector(userRegister:)];
    registerBtn.tintColor = [UIColor whiteColor];
    self.navigationItem.rightBarButtonItem = registerBtn;

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
    
    _textFieldBg = [[UIView alloc]initWithFrame:CGRectMake(13, 986/3 * Height / 736, Width - 26, 122 * Height / 736)];
    _textFieldBg.backgroundColor = [UIColor whiteColor];
    _textFieldBg.layer.cornerRadius = 5;
    _textFieldBg.userInteractionEnabled = YES;
    [self.view addSubview:_textFieldBg];
    UIView *textFieldDevide = [[UIView alloc]initWithFrame:CGRectMake(0, 60 * Height/736, Width - 26, 2)];
    textFieldDevide.backgroundColor = APP_THEME_COLOR;
    [_textFieldBg addSubview:textFieldDevide];
    
    _userNameTextField = [[UITextField alloc]initWithFrame:CGRectMake(12, 0* Height / 736, Width-25, 66*Height/736)];
    UILabel *ul = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 64.0, _userNameTextField.bounds.size.height - 16.0)];
    ul.text = @" 账户:";
    ul.textColor = TEXT_COLOR_TITLE;
    ul.font = [UIFont systemFontOfSize:14.0];
    ul.textAlignment = NSTextAlignmentCenter;
    _userNameTextField.leftView = ul;
    _userNameTextField.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
    _userNameTextField.leftViewMode = UITextFieldViewModeAlways;
    _userNameTextField.delegate = self;
    [_textFieldBg addSubview:_userNameTextField];
    
    
    _passwordTextField = [[UITextField alloc]initWithFrame:CGRectMake(12, 60 * Height / 736, Width-25, 66*Height/736)];
    UILabel *pl = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 64.0, _userNameTextField.bounds.size.height - 16.0)];
    pl.text = @" 密码:";
    pl.textColor = TEXT_COLOR_TITLE;
    pl.font = [UIFont systemFontOfSize:14.0];
    pl.textAlignment = NSTextAlignmentCenter;
    _passwordTextField.leftView = pl;
    _passwordTextField.leftViewMode = UITextFieldViewModeAlways;
    _passwordTextField.secureTextEntry = YES;
    _passwordTextField.delegate = self;
    [_textFieldBg addSubview:_passwordTextField];
    
    _loginBtn = [[UIButton alloc]initWithFrame:CGRectMake(13, 1370/3 * Height / 736, Width - 26, 62 * Height/736)];
    _loginBtn.backgroundColor = [UIColor whiteColor];
    _loginBtn.layer.cornerRadius = 5;
    [_loginBtn setTitle:@"登陆" forState:UIControlStateNormal];
    [_loginBtn setTitleColor:TEXT_COLOR_TITLE_SUBTITLE forState:UIControlStateNormal];
    [_loginBtn addTarget:self action:@selector(login:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_loginBtn];
    
    _losePassworkBtn = [[UIButton alloc]initWithFrame:CGRectMake(12, 1629/3 *Height/736, 70, 30)];
    [_losePassworkBtn setTitle:@"忘记密码" forState:UIControlStateNormal];
    _losePassworkBtn.titleLabel.font = [UIFont systemFontOfSize:12];
    [_losePassworkBtn addTarget:self action:@selector(losePassword:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_losePassworkBtn];
    
    _registerBtn = [[UIButton alloc]initWithFrame:CGRectMake(941/3 * Width/414, 1629/3 *Height/736, 70, 30)];
    [_registerBtn setTitle:@"注册新用户" forState:UIControlStateNormal];
    _registerBtn.titleLabel.font = [UIFont systemFontOfSize:12];
    [_registerBtn addTarget:self action:@selector(userRegister:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_registerBtn];
    
    _weiChatBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    _weiChatBtn.frame = CGRectMake(0, 0, 100, 25);
    _weiChatBtn.center = CGPointMake(Width/2, 1927/3 * Height/736);
    [_weiChatBtn setTitle:@"微信登陆" forState:UIControlStateNormal];
    [_weiChatBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.view addSubview:_weiChatBtn];
    [_weiChatBtn addTarget:self action:@selector(weixinLogin:) forControlEvents:UIControlEventTouchUpInside];
    
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [MobClick beginLogPageView:@"page_login"];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(weixinDidLogin:) name:weixinDidLoginNoti object:nil];
    
    if (![WXApi isWXAppInstalled]) {
        _wechatLabel.hidden = YES;
        _supportLoginButton.hidden = YES;
    } else {
        _wechatLabel.hidden = NO;
        _supportLoginButton.hidden = NO;
    }
    
    self.navigationController.navigationBarHidden = YES;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:@"page_login"];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:weixinDidLoginNoti object:nil];
    self.navigationController.navigationBarHidden = NO;
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
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    AppUtils *utils = [[AppUtils alloc] init];
    [manager.requestSerializer setValue:utils.appVersion forHTTPHeaderField:@"Version"];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"iOS %@",utils.systemVersion] forHTTPHeaderField:@"Platform"];
    
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [manager.requestSerializer setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:_userNameTextField.text forKey:@"loginName"];
    [params setObject:_passwordTextField.text forKey:@"pwd"];
    
     __weak typeof(LoginViewController *)weakSelf = self;
    TZProgressHUD *hud = [[TZProgressHUD alloc] init];
    [hud showHUDInViewController:weakSelf content:64];
    
    //普通登录
    [manager POST:API_SIGNIN parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"%@", responseObject);
        NSInteger code = [[responseObject objectForKey:@"code"] integerValue];
        if (code == 0) {
            AccountManager *accountManager = [AccountManager shareAccountManager];
            [accountManager userDidLoginWithUserInfo:[responseObject objectForKey:@"result"]];
            [self performSelector:@selector(dismissCtl) withObject:nil afterDelay:0.3];
            [[TMCache sharedCache] setObject:_userNameTextField.text forKey:@"last_account"];
            if (self.completion) {
                self.completion(YES);
            }
        } else {
            [hud hideTZHUD];
            if (self.isShowing) {
                [SVProgressHUD showHint:[NSString stringWithFormat:@"%@",[[responseObject objectForKey:@"err"] objectForKey:@"message"]]];
            }
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@", error);
        [hud hideTZHUD];
        if (self.isShowing) {
            [SVProgressHUD showHint:@"呃～好像没找到网络"];
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
    req.scope = @"snsAPI_USERS";
    req.state = @"peachtravel";
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
        _textFieldBg.frame = CGRectMake(13, 986/3 * Height/736 - 88 * Height/736, Width - 26, 122 * Height / 736);
        _loginBtn.frame = CGRectMake(13, 1370/3 * Height / 736 - 88 * Height/736, Width - 26, 62 * Height/736);

    }];
    
}
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    
    [UIView animateWithDuration:0.2 animations:^{
        _iconImageView.frame = CGRectMake((Width - 483/3 *Height/736)/2, 282/3 * Height/736, 483/3 *Height/736 , 483/3 *Height/736);
        _textFieldBg.frame = CGRectMake(13, 986/3 * Height/736, Width - 26, 122 * Height / 736);
        _loginBtn.frame = CGRectMake(13, 1370/3 * Height / 736, Width - 26, 62 * Height/736);
    }];
    

    [self.view endEditing:YES];
    [super touchesEnded:touches withEvent:event];
}

- (void)weixinDidLogin:(NSNotification *)noti
{
    NSString *code = [noti.userInfo objectForKey:@"code"];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    AppUtils *utils = [[AppUtils alloc] init];
    [manager.requestSerializer setValue:utils.appVersion forHTTPHeaderField:@"Version"];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"iOS %@",utils.systemVersion] forHTTPHeaderField:@"Platform"];
    
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [manager.requestSerializer setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:code forKey:@"code"];
    
     __weak typeof(LoginViewController *)weakSelf = self;
    TZProgressHUD *hud = [[TZProgressHUD alloc] init];
    [hud showHUDInViewController:weakSelf];

    //微信登录
    [manager POST:API_WEIXIN_LOGIN parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"%@", responseObject);
        NSInteger code = [[responseObject objectForKey:@"code"] integerValue];
        if (code == 0) {
            NSLog(@"%@", responseObject);
            AccountManager *accountManager = [AccountManager shareAccountManager];
            [accountManager userDidLoginWithUserInfo:[responseObject objectForKey:@"result"]];
            [self performSelector:@selector(dismissCtl) withObject:nil afterDelay:0.3];
            if (self.completion) {
                self.completion(YES);
            }
            
        } else {
            [hud hideTZHUD];
            [self showHint:[[responseObject objectForKey:@"err"] objectForKey:@"message"]];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (self.isShowing) {
            [hud hideTZHUD];
            [SVProgressHUD showHint:@"呃～好像没找到网络"];
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




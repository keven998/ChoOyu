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

#import "EMChatServiceDefs.h"
#import "EMPushNotificationOptions.h"

@interface LoginViewController ()<UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *userNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UIButton *loginBtn;
@property (weak, nonatomic) IBOutlet UIButton *losePassworkBtn;
@property (weak, nonatomic) IBOutlet UIButton *supportLoginButton;

@end

@implementation LoginViewController

#pragma mark - LifeCycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"登录";
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userDidRegisted) name:userDidRegistedNoti object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userDidRegisted) name:userDidResetPWDNoti object:nil];
    
    if (!self.isPushed) {
        UIBarButtonItem *backBtn = [[UIBarButtonItem alloc]initWithTitle:nil style:UIBarButtonItemStyleBordered target:self action:@selector(dismissCtl)];
        [backBtn setImage:[UIImage imageNamed:@"ic_navigation_back.png"]];
        self.navigationItem.leftBarButtonItem = backBtn;
    }
    _userNameTextField.delegate = self;
    _passwordTextField.delegate = self;
    
    UILabel *ul = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 64.0, _userNameTextField.bounds.size.height - 16.0)];
    ul.text = @" 账户:";
    ul.textColor = TEXT_COLOR_TITLE;
    ul.font = [UIFont systemFontOfSize:14.0];
    ul.textAlignment = NSTextAlignmentCenter;
    _userNameTextField.leftView = ul;
    _userNameTextField.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
    _userNameTextField.leftViewMode = UITextFieldViewModeAlways;
    
    UILabel *pl = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 64.0, _userNameTextField.bounds.size.height - 16.0)];
    pl.text = @" 密码:";
    pl.textColor = TEXT_COLOR_TITLE;
    pl.font = [UIFont systemFontOfSize:14.0];
    pl.textAlignment = NSTextAlignmentCenter;
    _passwordTextField.leftView = pl;
    _passwordTextField.leftViewMode = UITextFieldViewModeAlways;
    
    [_loginBtn setBackgroundImage:[UIImage imageNamed:@"theme_btn_normal.png"] forState:UIControlStateNormal];
    [_loginBtn setBackgroundImage:[UIImage imageNamed:@"theme_btn_highlight.png"] forState:UIControlStateHighlighted];
    
    [_supportLoginButton setImage:[UIImage imageNamed:@"ic_login_weixin.png"] forState:UIControlStateNormal];
    [_supportLoginButton setImage:[UIImage imageNamed:@"ic_login_weixin_highlight.png"] forState:UIControlStateHighlighted];
    
    UIBarButtonItem * registerBtn = [[UIBarButtonItem alloc]initWithTitle:@"注册 " style:UIBarButtonItemStyleBordered target:self action:@selector(userRegister:)];
    registerBtn.tintColor = APP_THEME_COLOR;
    self.navigationItem.rightBarButtonItem = registerBtn;
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(weixinDidLogin:) name:weixinDidLoginNoti object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:weixinDidLoginNoti object:nil];
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
        [SVProgressHUD showHint:@"我要账号和密码"];
        return;
    }
    
    NSString * regex0 = @"^1\\d{10}$";
    NSPredicate *pred0 = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex0];
    if (![pred0 evaluateWithObject:_userNameTextField.text]) {
        [self showHint:@"手机号输错了"];
        return;
    }
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [manager.requestSerializer setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:_userNameTextField.text forKey:@"loginName"];
    [params setObject:_passwordTextField.text forKey:@"pwd"];
    
     __weak typeof(LoginViewController *)weakSelf = self;
    TZProgressHUD *hud = [[TZProgressHUD alloc] init];
    [hud showHUDInViewController:weakSelf.navigationController];
    
    //普通登录
    [manager POST:API_SIGNIN parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"%@", responseObject);
        NSInteger code = [[responseObject objectForKey:@"code"] integerValue];
        if (code == 0) {
            AccountManager *accountManager = [AccountManager shareAccountManager];
            [accountManager userDidLoginWithUserInfo:[responseObject objectForKey:@"result"]];
            [accountManager loginEaseMobServer:^(BOOL isSuccess) {
                [hud hideTZHUD];
                if (isSuccess) {
                    [self performSelector:@selector(dismissCtl) withObject:nil afterDelay:0.3];
                    [SVProgressHUD showHint:@"欢迎回到桃子旅行"];
                } else {
                    [SVProgressHUD showHint:@"登录失败"];
                }
            }];
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
    [self sendAuthRequest];
}

#pragma mark - private methods

-(void)sendAuthRequest
{
    //构造SendAuthReq结构体
    SendAuthReq* req =[[SendAuthReq alloc] init];
    req.scope = @"snsapi_userinfo";
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

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
    [super touchesEnded:touches withEvent:event];
}

- (void)weixinDidLogin:(NSNotification *)noti
{
    NSString *code = [noti.userInfo objectForKey:@"code"];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
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
            [accountManager loginEaseMobServer:^(BOOL isSuccess) {
                [hud hideTZHUD];
                if (isSuccess) {
                    [self performSelector:@selector(dismissCtl) withObject:nil afterDelay:0.3];
                    [SVProgressHUD showHint:@"欢迎回到桃子旅行"];
                } else {
                    [SVProgressHUD showHint:@"登录失败"];
                }
            }];
            
        } else {
            [hud hideTZHUD];
            [self showHint:[[responseObject objectForKey:@"err"] objectForKey:@"message"]];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [hud hideTZHUD];
        if (self.isShowing) {
            [SVProgressHUD showHint:@"呃～好像没找到网络"];
        }
    }];
}

- (void)userDidRegisted
{
    [self performSelector:@selector(dismissCtl) withObject:nil afterDelay:0.3];
}

- (void)dismissCtl
{
    if (self.isPushed) {
        [self.navigationController popToRootViewControllerAnimated:YES];
    
    } else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    
}

@end




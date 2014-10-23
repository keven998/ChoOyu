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

@interface LoginViewController ()

@property (weak, nonatomic) IBOutlet UITextField *userNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UIButton *loginBtn;
@property (weak, nonatomic) IBOutlet UIButton *losePassworkBtn;

@end

@implementation LoginViewController

#pragma mark - LifeCycle

- (void)viewDidLoad {
    [super viewDidLoad];
    _userNameTextField.layer.borderColor = [UIColor grayColor].CGColor;
    _userNameTextField.layer.borderWidth = 1.0;
    _passwordTextField.layer.borderColor = [UIColor grayColor].CGColor;
    _passwordTextField.layer.borderWidth = 1.0;
    
    UIButton *registerBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 60, 30)];
    registerBtn.titleLabel.font = [UIFont systemFontOfSize:17.];
    [registerBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [registerBtn setTitle:@"注册" forState:UIControlStateNormal];
    [registerBtn addTarget:self action:@selector(userRegister:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *registerItem = [[UIBarButtonItem alloc] initWithCustomView:registerBtn];
    self.navigationItem.rightBarButtonItem = registerItem;
    
    UITapGestureRecognizer *tapBackground = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapBackground:)];
    tapBackground.numberOfTapsRequired = 1;
    tapBackground.numberOfTouchesRequired = 1;
    [self.view addGestureRecognizer:tapBackground];
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

#pragma mark - IBAction Methods

- (IBAction)userRegister:(id)sender
{
    RegisterViewController *registerCtl = [[RegisterViewController alloc] init];
    [self.navigationController pushViewController:registerCtl animated:YES];
}

- (IBAction)losePassword:(UIButton *)sender {
    VerifyCaptchaViewController *losePasswordCtl = [[VerifyCaptchaViewController alloc] init];
    [self.navigationController pushViewController:losePasswordCtl animated:YES];
}

//普通登录
- (IBAction)login:(UIButton *)sender {
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [manager.requestSerializer setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:_userNameTextField.text forKey:@"loginName"];
    [params setObject:_passwordTextField.text forKey:@"pwd"];
    
    [SVProgressHUD show];
    
    //普通登录
    [manager POST:API_SIGNIN parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSInteger code = [[responseObject objectForKey:@"code"] integerValue];
        if (code == 0) {
            AccountManager *accountManager = [AccountManager shareAccountManager];
            [accountManager userDidLoginWithUserInfo:[responseObject objectForKey:@"result"]];
            [self loginWithUserName:accountManager.account.easemobUser withPassword:accountManager.account.easemobPwd];
        }
        [SVProgressHUD dismiss];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@", error);
        [SVProgressHUD dismiss];
    }];
}

//微信登录
- (IBAction)weixinLogin:(UIButton *)sender {
    [self sendAuthRequest];
}

- (void)tapBackground:(id)sender
{
    if ([_userNameTextField isFirstResponder]) {
        [_userNameTextField resignFirstResponder];
    } else if ([_passwordTextField isFirstResponder]) {
        [_passwordTextField resignFirstResponder];
    }
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

- (void)weixinDidLogin:(NSNotification *)noti
{
    NSString *code = [noti.userInfo objectForKey:@"code"];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [manager.requestSerializer setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:code forKey:@"code"];
    
    [SVProgressHUD show];
    
    //微信登录
    [manager POST:API_WEIXIN_LOGIN parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSInteger code = [[responseObject objectForKey:@"code"] integerValue];
        if (code == 0) {
            AccountManager *accountManager = [AccountManager shareAccountManager];
            [accountManager userDidLoginWithUserInfo:[responseObject objectForKey:@"result"]];
            [self loginWithUserName:accountManager.account.easemobUser withPassword:accountManager.account.easemobPwd];
        } else {
            [SVProgressHUD showErrorWithStatus:[[responseObject objectForKey:@"err"] objectForKey:@"msg"]];
        }

        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [SVProgressHUD dismiss];
    }];
}

//使用用户名密码登录环信聊天系统,只有环信系统也登录成功才算登录成功
- (void)loginWithUserName:(NSString *)userName withPassword:(NSString *)password
{
    AccountManager *accountManager = [AccountManager shareAccountManager];
    [[EaseMob sharedInstance].chatManager asyncLoginWithUsername:accountManager.account.easemobUser
                                                        password:accountManager.account.easemobPwd
                                                      completion:
     ^(NSDictionary *loginInfo, EMError *error) {
         [self hideHud];
         if (loginInfo && !error) {
             [SVProgressHUD showSuccessWithStatus:@"登录成功"];
             AccountManager *accountManager = [AccountManager shareAccountManager];
             [accountManager easeMobDidLogin];
             [[NSNotificationCenter defaultCenter] postNotificationName:userDidLoginNoti object:nil];
             
             [self performSelector:@selector(dismissCtl) withObject:nil afterDelay:0.5];
             
         }else {
             
             [accountManager easeMobUnlogin];

             switch (error.errorCode) {
                 case EMErrorServerNotReachable:
                     [SVProgressHUD showErrorWithStatus:(@"连接服务器失败!")];
                     break;
                 case EMErrorServerAuthenticationFailure:
                     [SVProgressHUD showErrorWithStatus:(@"用户名或密码错误!")];
                     break;
                 case EMErrorServerTimeout:
                     [SVProgressHUD showErrorWithStatus:(@"连接服务器超时!")];
                     break;
                 default:
                     [SVProgressHUD showErrorWithStatus:(@"登录失败!")];
                     break;
             }
         }
     } onQueue:nil];
}

- (void)dismissCtl
{
    [self.navigationController popViewControllerAnimated:YES];
}

@end




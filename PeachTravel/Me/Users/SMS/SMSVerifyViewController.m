//
//  SMSVerifyViewController.m
//  PeachTravel
//
//  Created by liangpengshuai on 14/10/15.
//  Copyright (c) 2014年 com.aizou.www. All rights reserved.
//

#import "SMSVerifyViewController.h"
#import "UserInfoTableViewController.h"
#import "AccountManager.h"

@interface SMSVerifyViewController () {
    NSTimer *timer;
    NSInteger count;
}

@property (strong, nonatomic)  UILabel *titleLabel;
@property (strong, nonatomic)  UITextField *verifyCodeTextField;
@property (strong, nonatomic)  UIButton *verifyCodeBtn;
@property (nonatomic, strong)  UILabel *statusLabel;

@end

@implementation SMSVerifyViewController

#pragma mark - LifeCycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = APP_PAGE_COLOR;
    
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    backBtn.frame = CGRectMake(0, 0, 64, 64);
    [backBtn setImage:[UIImage imageNamed:@"login_back_defaut"] forState:UIControlStateNormal];
    [backBtn setImage:[UIImage imageNamed:@"common_icon_navigaiton_back_highlight"] forState:UIControlStateHighlighted];
    [backBtn addTarget:self action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];
    backBtn.contentVerticalAlignment = UIControlContentVerticalAlignmentTop;
    backBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [backBtn setImageEdgeInsets:UIEdgeInsetsMake(34, 14, 0, 0)];
    [self.view addSubview:backBtn];
    
    count = _coolDown;
    
    UIImageView *iconImage = [[UIImageView alloc]initWithFrame:CGRectMake(489/3 * SCREEN_WIDTH/414, 216/3 *SCREEN_HEIGHT/736, 87*SCREEN_HEIGHT/736, 87*SCREEN_HEIGHT/736)];
    iconImage.image = [UIImage imageNamed:@"icon_little"];
    [self.view addSubview:iconImage];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, CGRectGetMaxY(iconImage.frame) + 32, CGRectGetWidth(self.view.bounds)-20, 34)];
    label.textColor = COLOR_TEXT_II;
    label.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    label.font = [UIFont systemFontOfSize:11.0];
    label.textAlignment = NSTextAlignmentCenter;
    label.numberOfLines = 2;
    label.text = [NSString stringWithFormat:@"验证码已发至:%@\n网络有延迟，请稍候", _phoneNumber];
    [self.view addSubview:label];
    _statusLabel = label;
    
    UIView *textFieldBg = [[UIView alloc]initWithFrame:CGRectMake(13, CGRectGetMaxY(label.frame) + 7, SCREEN_WIDTH-26, 60 * SCREEN_HEIGHT/736)];
    textFieldBg.layer.borderColor = APP_THEME_COLOR.CGColor;
    textFieldBg.layer.borderWidth = 1;
    textFieldBg.layer.cornerRadius = 5;
    textFieldBg.clipsToBounds = YES;
    [self.view addSubview:textFieldBg];
    UIView *devide2 = [[UIView alloc]initWithFrame:CGRectMake(772/3 *SCREEN_WIDTH/414, 0 *SCREEN_HEIGHT / 736, 1, 60 * SCREEN_HEIGHT/736)];
    devide2.backgroundColor = APP_THEME_COLOR;
    [textFieldBg addSubview:devide2];
    
    _verifyCodeBtn = [[UIButton alloc]initWithFrame:CGRectMake(775/3 *SCREEN_WIDTH/414, 0, 395/3 * SCREEN_WIDTH/414, 59* SCREEN_HEIGHT/736)];
    [_verifyCodeBtn setTitle:@"重新获取" forState:UIControlStateNormal];
    [_verifyCodeBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_verifyCodeBtn setBackgroundImage:[ConvertMethods createImageWithColor:APP_THEME_COLOR] forState:UIControlStateNormal];
    [_verifyCodeBtn setBackgroundImage:[ConvertMethods createImageWithColor:APP_THEME_COLOR_HIGHLIGHT] forState:UIControlStateHighlighted];
    _verifyCodeBtn.clipsToBounds = YES;
    [_verifyCodeBtn setTitle:[NSString stringWithFormat:@"%lds后重发",(long)count] forState:UIControlStateDisabled];
    [_verifyCodeBtn setBackgroundImage:[ConvertMethods createImageWithColor:APP_PAGE_COLOR] forState:UIControlStateDisabled];
    [_verifyCodeBtn setTitleColor:COLOR_TEXT_III forState:UIControlStateDisabled];
    _verifyCodeBtn.titleLabel.font = [UIFont systemFontOfSize:13];
    _verifyCodeBtn.titleEdgeInsets = UIEdgeInsetsMake(0, -4, 0, 0);
    _verifyCodeBtn.enabled = NO;
    [_verifyCodeBtn addTarget:self action:@selector(reloadVerifyCode:) forControlEvents:UIControlEventTouchUpInside];
    [self startTimer];
    
    _verifyCodeTextField = [[UITextField alloc]initWithFrame:CGRectMake(10, 0, SCREEN_WIDTH - 50 - CGRectGetWidth(_verifyCodeBtn.frame), 60 * SCREEN_HEIGHT / 736)];
    UILabel *ul = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 58.0, _verifyCodeTextField.bounds.size.height - 16.0)];
    ul.text = @" 验证码:";
    ul.textColor = COLOR_TEXT_I;
    ul.font = [UIFont systemFontOfSize:13.0];
    ul.textAlignment = NSTextAlignmentCenter;
    _verifyCodeTextField.leftView = ul;
    _verifyCodeTextField.leftViewMode = UITextFieldViewModeAlways;
    [_verifyCodeTextField becomeFirstResponder];
    _verifyCodeTextField.font = [UIFont systemFontOfSize:16.0];
    _verifyCodeTextField.textColor = COLOR_TEXT_I;
    _verifyCodeTextField.placeholder = @"短信验证码";
    _verifyCodeTextField.keyboardType = UIKeyboardTypeNumberPad;
    [textFieldBg addSubview:_verifyCodeBtn];
    [textFieldBg addSubview:_verifyCodeTextField];
    
    UIButton *nextBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    nextBtn.frame = CGRectMake(13, CGRectGetMaxY(textFieldBg.frame) + 5, SCREEN_WIDTH - 26, 56 * SCREEN_HEIGHT/736);
    [nextBtn setTitle:@"完成" forState:UIControlStateNormal];
    nextBtn.layer.cornerRadius = 5.0;
    nextBtn.clipsToBounds = YES;
    nextBtn.titleLabel.font = [UIFont systemFontOfSize:16.0];
    [nextBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [nextBtn setTitleColor:APP_THEME_COLOR forState:UIControlStateHighlighted];
    [nextBtn setBackgroundImage:[ConvertMethods createImageWithColor:APP_THEME_COLOR] forState:UIControlStateNormal];
    [self.view addSubview:nextBtn];
    [nextBtn addTarget:self action:@selector(confirm:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [self stopTimer];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
}

- (void)dealloc {
}

#pragma mark - Private Methods

- (void)startTimer
{
    if (timer != nil) {
        [self stopTimer];
    }
    timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(calculateTime) userInfo:nil repeats:YES];
}

- (void)stopTimer
{
    if (timer) {
        if ([timer isValid]) {
            [timer invalidate];
            timer = nil;
        }
        count = 0;
    }
}

- (void)calculateTime
{
    if (count <= 1) {
        [self stopTimer];
        _verifyCodeBtn.enabled = YES;
    } else {
        count--;
        [_verifyCodeBtn setTitle:[NSString stringWithFormat:@"%lds后重发",(long)count] forState:UIControlStateDisabled];
    }
}

#pragma mark - IBAction Methods

//重新获取验证码
- (IBAction)reloadVerifyCode:(UIButton *)sender {
    [self getCaptcha];
}

- (IBAction)confirm:(UIButton *)sender {
    [self.view endEditing:YES];
    if (_verifyCodeTextField.text == nil || [_verifyCodeTextField.text isEqualToString:@""]) {
        [SVProgressHUD showSuccessWithStatus:@"请输入验证码"];
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
    [params setObject:_phoneNumber forKey:@"tel"];
    [params setObject:_password forKey:@"pwd"];
    
    [params setObject:_verifyCodeTextField.text forKey:@"captcha"];
    
    __weak typeof(SMSVerifyViewController *)weakSelf = self;
    TZProgressHUD *hud = [[TZProgressHUD alloc] init];
    [hud showHUDInViewController:weakSelf withStatus:@"正在注册..."];
    
    //确定注册
    [manager POST:API_SIGNUP parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSInteger code = [[responseObject objectForKey:@"code"] integerValue];
        [hud hideTZHUD];
        if (code == 0) {
            __weak SMSVerifyViewController *weakSelf = self;
            [[NSNotificationCenter defaultCenter] postNotificationName:userDidRegistedNoti object:nil userInfo:@{@"poster":weakSelf}];
            AccountManager *accountManager = [AccountManager shareAccountManager];
            [accountManager userDidLoginWithUserInfo:[responseObject objectForKey:@"result"]];
            
        } else {
            [SVProgressHUD showHint:[NSString stringWithFormat:@"%@", [[responseObject objectForKey:@"err"] objectForKey:@"message"]]];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [hud hideTZHUD];
        NSLog(@"%@", error);
        if (self.isShowing) {
            if (operation.response.statusCode == 401) {
                [SVProgressHUD showHint:@"验证码输入错误"];
            } else {
                    [SVProgressHUD showHint:HTTP_FAILED_HINT];
            }
        }
    }];
}

/**
 *  获取验证码
 */
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
    [params setObject:_phoneNumber forKey:@"tel"];
    [params setObject:kUserRegister forKey:@"action"];
    __weak typeof(SMSVerifyViewController *)weakSelf = self;
    TZProgressHUD *hud = [[TZProgressHUD alloc] init];
    [hud showHUDInViewController:weakSelf content:64];
    
    //获取注册码
    [manager POST:API_GET_CAPTCHA parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [hud hideTZHUD];
        NSInteger code = [[responseObject objectForKey:@"code"] integerValue];
        if (code == 0) {
            //获取成功开始计时
            count = _coolDown;
            [_verifyCodeBtn setTitle:[NSString stringWithFormat:@"%lds后重发",(long)count] forState:UIControlStateDisabled];
            [self startTimer];
            _verifyCodeBtn.enabled = NO;
            _statusLabel.text = [NSString stringWithFormat:@"验证码已发至:%@\n网络有延迟，请稍候", _phoneNumber];
        } else {
            [SVProgressHUD showHint:[[responseObject objectForKey:@"err"] objectForKey:@"message"]];
            _statusLabel.text = @"验证码发送失败，请重试";
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [hud hideTZHUD];
        if (self.isShowing) {
            [SVProgressHUD showHint:HTTP_FAILED_HINT];
        }
        _statusLabel.text = @"验证码发送失败，请重试";
    }];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
    [super touchesEnded:touches withEvent:event];
}
- (void)goBack {
    if (self.navigationController.childViewControllers.count > 1) {
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}
@end


//
//  LosePasswordViewController.m
//  PeachTravel
//
//  Created by liangpengshuai on 14/10/13.
//  Copyright (c) 2014年 com.aizou.www. All rights reserved.
//

#import "VerifyCaptchaViewController.h"
#import "ResetPasswordViewController.h"
#import "AccountManager.h"

@interface VerifyCaptchaViewController ()
{
    NSTimer *timer;
    NSInteger count;
}

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UITextField *phoneLabel;
@property (weak, nonatomic) IBOutlet UITextField *captchaLabel;
@property (weak, nonatomic) IBOutlet UILabel *tipsLabel;
@property (weak, nonatomic) IBOutlet UIButton *captchaBtn;
@property (nonatomic) BOOL shouldSetPasswordWhenBindTel;   //标记当验证成功手机号后是否需要跳转到下一个页面设置密码
@property (nonatomic, strong) UIButton *registerBtn;

@end

@implementation VerifyCaptchaViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIBarButtonItem *leftBtn = [[UIBarButtonItem alloc]initWithTitle:@" 取消" style:UIBarButtonItemStylePlain target:self action:@selector(goBack)];
    self.navigationItem.leftBarButtonItem = leftBtn;

    UIBarButtonItem *addBtn = [[UIBarButtonItem alloc]initWithTitle:nil style:UIBarButtonItemStylePlain target:self action:@selector(nextStep:)];
    addBtn.tintColor = [UIColor whiteColor];
    self.navigationItem.rightBarButtonItem = addBtn;
    AccountManager *accountManager = [AccountManager shareAccountManager];
    _shouldSetPasswordWhenBindTel = !accountManager.accountIsBindTel;    //如果之前账户已经有手机号了那么不需要进入下一页面设置密码了
    
    if (_verifyCaptchaType == UserBindTel) {
        if (_shouldSetPasswordWhenBindTel) {
            self.navigationItem.title = @"安全设置";
            _titleLabel.text = @"为了账户安全和使用方便，强烈建议您绑定手机号";
        } else {
            self.navigationItem.title = @"绑定设置";
            _titleLabel.text = [NSString stringWithFormat:@"已绑定手机号：%@", accountManager.account.tel];
        }
       
    } else {
        self.navigationItem.title = @"用户验证";
        _phoneLabel.placeholder = @"请输入手机号";
    }
    
    self.navigationItem.rightBarButtonItem.title = @"提交 ";
    self.navigationItem.rightBarButtonItem.enabled = NO;
    
    UILabel *ul = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 64.0, _phoneLabel.bounds.size.height - 16.0)];
    ul.text = @"手机号:";
    ul.textColor = COLOR_TEXT_I;
    ul.font = [UIFont systemFontOfSize:13.0];
    ul.textAlignment = NSTextAlignmentCenter;
    _phoneLabel.leftView = ul;
    _phoneLabel.leftViewMode = UITextFieldViewModeAlways;
    
    UILabel *pl = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 64.0, _captchaLabel.bounds.size.height - 16.0)];
    pl.text = @"验证码:";
    pl.textColor = COLOR_TEXT_I;
    pl.font = [UIFont systemFontOfSize:13.0];
    pl.textAlignment = NSTextAlignmentCenter;
    _captchaLabel.leftView = pl;
    _captchaLabel.leftViewMode = UITextFieldViewModeAlways;
    _captchaLabel.keyboardType = UIKeyboardTypeNumberPad;
    [_captchaLabel addTarget:self action:@selector(textChanged:) forControlEvents:UIControlEventEditingChanged];
    
    _captchaBtn.layer.cornerRadius = 4.0;
    _captchaBtn.clipsToBounds = YES;
    [_captchaBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_captchaBtn setTitleColor:COLOR_TEXT_III forState:UIControlStateDisabled];
    _captchaBtn.titleLabel.font = [UIFont systemFontOfSize:11.0];
    [_captchaBtn setBackgroundImage:[ConvertMethods createImageWithColor:APP_THEME_COLOR] forState:UIControlStateNormal];
    [_captchaBtn setBackgroundImage:[ConvertMethods createImageWithColor:APP_THEME_COLOR_HIGHLIGHT] forState:UIControlStateHighlighted];
    [_captchaBtn setBackgroundImage:[ConvertMethods createImageWithColor:COLOR_DISABLE] forState:UIControlStateDisabled];
    _captchaBtn.enabled = YES;
}

//- (void)viewDidLayoutSubviews
//{
//    _phoneLabel.frame = CGRectMake(0, 30, self.view.bounds.size.width, 64*kWindowHeight/736);
//    _captchaBtn.center = CGPointMake(self.view.bounds.size.width-20-_captchaBtn.bounds.size.width/2, _phoneLabel.center.y);
//    _captchaLabel.frame = CGRectMake(0, 30+64*kWindowHeight/736+1, self.view.bounds.size.width, 64*kWindowHeight/736);
//    _tipsLabel.frame = CGRectMake(20, 30+64*kWindowHeight/736*2+15, self.view.bounds.size.width-40, 20);
//}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [MobClick beginLogPageView:@"page_verify_phone"];
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:@"page_verify_phone"];
    
    
}

#pragma mark - Private Methods

- (UserInfoInputError)checkInput
{
    if (_phoneLabel.text.length != 11) {
        return PhoneNumberError;
    }
    return NoError;
}

- (void)startTimer
{
    _captchaBtn.enabled = NO;
    dispatch_async(dispatch_get_main_queue(), ^{
        if (timer != nil) {
            [self stopTimer];
        }
        timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(calculateTime) userInfo:nil repeats:YES];
    });
}

- (void)stopTimer
{
    if (timer) {
        if ([timer isValid]) {
            [timer invalidate];
            timer = nil;
        }
    }
    _captchaBtn.enabled = YES;
}

- (void)calculateTime
{
    if (count <= 1) {
        [self stopTimer];
        _captchaBtn.enabled = YES;
        [_captchaBtn setTitle:@"重新获取" forState:UIControlStateNormal];
    } else {
        count--;
        [_captchaBtn setTitle:[NSString stringWithFormat:@"%lds后重发",(long)count] forState:UIControlStateDisabled];

    }
}

/**
 *  获取验证吗
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
    [params setObject:_phoneLabel.text forKey:@"tel"];
    if (_verifyCaptchaType == UserBindTel) {
        [params setObject:kUserBindTel forKey:@"actionCode"];
        AccountManager *accountManager = [AccountManager shareAccountManager];
        [params setObject:[NSNumber numberWithInteger: accountManager.account.userId] forKey:@"userId"];
    } else {
        [params setObject:kUserLosePassword forKey:@"actionCode"];
    }

     __weak typeof(VerifyCaptchaViewController *)weakSelf = self;
    TZProgressHUD *hud = [[TZProgressHUD alloc] init];
    [hud showHUDInViewController:weakSelf content:64];

    //获取注册码
    [manager POST:API_GET_CAPTCHA parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSInteger code = [[responseObject objectForKey:@"code"] integerValue];
        [hud hideTZHUD];
        if (code == 0) {
            count = [[[responseObject objectForKey:@"result"] objectForKey:@"coolDown"] integerValue];
            [self startTimer];
            [SVProgressHUD showHint:@"已发送验证码，请稍候"];
        } else {
            _captchaBtn.enabled = YES;

            [SVProgressHUD showHint:[[responseObject objectForKey:@"err"] objectForKey:@"message"]];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [hud hideTZHUD];
        _captchaBtn.enabled = YES;
        if (self.isShowing) {
            [SVProgressHUD showHint:HTTP_FAILED_HINT];
        }
    }];
}

- (void)virifyCaptcha
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
    if (_verifyCaptchaType == UserBindTel) {
        [params setObject:kUserBindTel forKey:@"actionCode"];
        AccountManager *accountManager = [AccountManager shareAccountManager];
        [params setObject:[NSNumber numberWithInteger: accountManager.account.userId] forKey:@"userId"];
    } else {
        [params setObject:kUserLosePassword forKey:@"actionCode"];
    }
    [params setObject:_captchaLabel.text forKey:@"captcha"];
     __weak typeof(VerifyCaptchaViewController *)weakSelf = self;
    TZProgressHUD *hud = [[TZProgressHUD alloc] init];
    [hud showHUDInViewController:weakSelf content:64];
    //验证注册码
    [manager POST:API_VERIFY_CAPTCHA parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSInteger code = [[responseObject objectForKey:@"code"] integerValue];
        [hud hideTZHUD];
        if (code == 0) {
            ResetPasswordViewController *resetPasswordCtl = [[ResetPasswordViewController alloc] init];
            resetPasswordCtl.token = [[responseObject objectForKey:@"result"] objectForKey:@"token"];
            resetPasswordCtl.phoneNumber = _phoneLabel.text;
            
            if (_verifyCaptchaType == UserBindTel) {
                AccountManager *accountManager = [AccountManager shareAccountManager];
                resetPasswordCtl.userId = accountManager.account.userId;
                //如果用户不是首次绑定手机号,则不进入下一个界面进行设置密码。而是直接退出次界面
                if (!_shouldSetPasswordWhenBindTel) {
                    [self bindTelwithToken:[[responseObject objectForKey:@"result"] objectForKey:@"token"]];
                    return;
                }
            }
            resetPasswordCtl.verifyCaptchaType = _verifyCaptchaType;
            [self.navigationController pushViewController:resetPasswordCtl animated:YES];
        } else {
            [SVProgressHUD showHint:[[responseObject objectForKey:@"err"] objectForKey:@"message"]];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [hud hideTZHUD];
        if (self.isShowing) {
            [SVProgressHUD showHint:HTTP_FAILED_HINT];
        }
    }];
}

//修改手机号
- (void)bindTelwithToken:(NSString *)token
{
    __weak typeof(VerifyCaptchaViewController *)weakSelf = self;
    TZProgressHUD *hud = [[TZProgressHUD alloc] init];
    [hud showHUDInViewController:weakSelf content:64];

    [[AccountManager shareAccountManager] asyncBindTelephone:_phoneLabel.text token:token completion:^(BOOL isSuccess, NSString *errorStr) {
        if (isSuccess) {
            [self performSelector:@selector(goBack) withObject:nil afterDelay:0.4];
        } else {
            [hud hideTZHUD];
            if (errorStr) {
                [SVProgressHUD showHint:errorStr];
            } else {
                _captchaBtn.enabled = YES;
                if (self.isShowing) {
                    [SVProgressHUD showHint:HTTP_FAILED_HINT];
                }
            }
        }
    }];
}

#pragma mark - IBAction Methods

- (IBAction)receiveVerifyCode:(UIButton *)sender {
    [self.view endEditing:YES];
    if ([self checkInput] == PhoneNumberError) {
        [self showHint:@"请输入手机号"];
    } else {
        _captchaBtn.enabled =  NO;
        [_captchaBtn setTitle:@"请稍候" forState:UIControlStateDisabled];

        [self getCaptcha];
    }
}

- (IBAction)nextStep:(UIButton *)sender {
    if ([_captchaLabel.text stringByReplacingOccurrencesOfString:@" " withString:@""].length == 0) {
        [self showHint:@"请输入验证码"];
        return;
    }
    [self.view endEditing:YES];
    [self stopTimer];
    [self virifyCaptcha];
    [MobClick event:@"event_submit"];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
    [super touchesEnded:touches withEvent:event];
}

- (void) textChanged:(UITextField *)textField {
    self.navigationItem.rightBarButtonItem.enabled = ![textField.text isEqualToString:@""];
}
@end




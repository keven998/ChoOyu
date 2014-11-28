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

@interface VerifyCaptchaViewController () {
    NSTimer *timer;
    NSInteger count;
}

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UITextField *phoneLabel;
@property (weak, nonatomic) IBOutlet UITextField *captchaLabel;
@property (weak, nonatomic) IBOutlet UIButton *captchaBtn;
@property (nonatomic) BOOL shouldSetPasswordWhenBindTel;   //标记当验证成功手机号后是否需要跳转到下一个页面设置密码

@end

@implementation VerifyCaptchaViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIButton *registerBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 60.0, 30)];
    registerBtn.titleLabel.font = [UIFont systemFontOfSize:17.];
    [registerBtn setTitleColor:APP_THEME_COLOR forState:UIControlStateNormal];
    UIBarButtonItem *registerItem = [[UIBarButtonItem alloc] initWithCustomView:registerBtn];
    [registerBtn addTarget:self action:@selector(nextStep:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = registerItem;
    
    AccountManager *accountManager = [AccountManager shareAccountManager];
    _shouldSetPasswordWhenBindTel = !accountManager.accountIsBindTel;    //如果之前账户已经有手机号了那么不需要进入下一页面设置密码了
    
    if (_verifyCaptchaType == UserBindTel) {
        if (_shouldSetPasswordWhenBindTel) {
            self.navigationItem.title = @"安全设置";
            _titleLabel.text = @"为了账户安全和使用方便,强烈建议你绑定手机号";
            [registerBtn setTitle:@"绑定" forState:UIControlStateNormal];
        } else {
            self.navigationItem.title = @"更换手机";
            _titleLabel.text = @"真羡慕有两个手机的美眉";
            [registerBtn setTitle:@"更换" forState:UIControlStateNormal];
        }
       
    } else {
        self.navigationItem.title = @"找回密码";
        [registerBtn setTitle:@"下一步" forState:UIControlStateNormal];
        
    }
    
    UILabel *ul = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 64.0, _phoneLabel.bounds.size.height - 14.0)];
    ul.text = @"手机号:";
    ul.textColor = TEXT_COLOR_TITLE;
    ul.font = [UIFont systemFontOfSize:14.0];
    ul.textAlignment = NSTextAlignmentCenter;
    _phoneLabel.leftView = ul;
    _phoneLabel.leftViewMode = UITextFieldViewModeAlways;
    
    UILabel *pl = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 64.0, _captchaLabel.bounds.size.height - 14.0)];
    pl.text = @"验证码:";
    pl.textColor = TEXT_COLOR_TITLE;
    pl.font = [UIFont systemFontOfSize:14.0];
    pl.textAlignment = NSTextAlignmentCenter;
    _captchaLabel.leftView = pl;
    _captchaLabel.leftViewMode = UITextFieldViewModeAlways;
}

#pragma mark - Private Methods

- (UserInfoInputError)checkInput
{
    NSLog(@"%d", _phoneLabel.text.length);
    if (_phoneLabel.text.length != 11) {
        return PhoneNumberError;
    }
    return NoError;
}

- (void)startTimer
{
    timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(calculateTime) userInfo:nil repeats:YES];
}

- (void)stopTimer
{
    if (timer) {
        if ([timer isValid]) {
            [timer invalidate];
            timer = nil;
        }
    }
}

- (void)calculateTime
{
    if (count == 0) {
        [self stopTimer];
        _captchaBtn.userInteractionEnabled = YES;
        [_captchaBtn setTitle:@"重新获取" forState:UIControlStateNormal];
    } else {
        count--;
        _captchaBtn.titleLabel.text = [NSString stringWithFormat:@"%dS",count];
        [_captchaBtn setTitle:[NSString stringWithFormat:@"%dS",count] forState:UIControlStateNormal];
    }
}

- (void)getCaptcha
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [manager.requestSerializer setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:_phoneLabel.text forKey:@"tel"];
    if (_verifyCaptchaType == UserBindTel) {
        [params setObject:kUserBindTel forKey:@"actionCode"];
        AccountManager *accountManager = [AccountManager shareAccountManager];
        [params setObject:accountManager.account.userId forKey:@"userId"];
    } else {
        [params setObject:kUserLosePassword forKey:@"actionCode"];
    }

    [SVProgressHUD show];
    //获取注册码
    [manager POST:API_GET_CAPTCHA parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"%@", responseObject);
        NSInteger code = [[responseObject objectForKey:@"code"] integerValue];
        if (code == 0) {
            count = [[[responseObject objectForKey:@"result"] objectForKey:@"coolDown"] integerValue];
            [self startTimer];
            [SVProgressHUD showSuccessWithStatus:@"验证码发送成功"];
            
        } else {
            [SVProgressHUD showErrorWithStatus:@"验证码发送失败"];
            _captchaBtn.userInteractionEnabled = YES;
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [SVProgressHUD dismiss];
        _captchaBtn.userInteractionEnabled = YES;
    }];
}

- (void)virifyCaptcha
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [manager.requestSerializer setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:_phoneLabel.text forKey:@"tel"];
    if (_verifyCaptchaType == UserBindTel) {
        [params setObject:kUserBindTel forKey:@"actionCode"];
        AccountManager *accountManager = [AccountManager shareAccountManager];
        [params setObject:accountManager.account.userId forKey:@"userId"];
    } else {
        [params setObject:kUserLosePassword forKey:@"actionCode"];
    }
    [params setObject:_captchaLabel.text forKey:@"captcha"];
    [SVProgressHUD show];
    //验证注册码
    [manager POST:API_VERIFY_CAPTCHA parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSInteger code = [[responseObject objectForKey:@"code"] integerValue];
        if (code == 0) {
            ResetPasswordViewController *resetPasswordCtl = [[ResetPasswordViewController alloc] init];
            resetPasswordCtl.token = [[responseObject objectForKey:@"result"] objectForKey:@"token"];
            resetPasswordCtl.phoneNumber = _phoneLabel.text;
            
            if (_verifyCaptchaType == UserBindTel) {
                AccountManager *accountManager = [AccountManager shareAccountManager];
                resetPasswordCtl.userId = [accountManager.account.userId integerValue];
                //如果用户不是首次绑定手机号,则不进入下一个界面进行设置密码。而是直接退出次界面
                if (!_shouldSetPasswordWhenBindTel) {
                    [self bindTelwithToken:[[responseObject objectForKey:@"result"] objectForKey:@"token"]];
                    return;
                }
            }
            resetPasswordCtl.verifyCaptchaType = _verifyCaptchaType;
            [self.navigationController pushViewController:resetPasswordCtl animated:YES];
            
        } else {
            [SVProgressHUD showErrorWithStatus:[[responseObject objectForKey:@"err"] objectForKey:@"msg"]];
        }
        [SVProgressHUD dismiss];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [SVProgressHUD dismiss];
    }];
}

//绑定手机号
- (void)bindTelwithToken:(NSString *)token
{
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [manager.requestSerializer setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:_phoneLabel.text forKey:@"tel"];
    [params setObject:token forKey:@"token"];
    AccountManager *accountManager = [AccountManager shareAccountManager];
    [params setObject:accountManager.account.userId forKey:@"userId"];
    
    [SVProgressHUD show];
    //获取注册码
    [manager POST:API_BINDTEL parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSInteger code = [[responseObject objectForKey:@"code"] integerValue];
        if (code == 0) {
            [SVProgressHUD showSuccessWithStatus:@"绑定成功"];
        } else {
            
        }
        [SVProgressHUD dismiss];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [SVProgressHUD showErrorWithStatus:@"绑定失败"];
        NSLog(@"%@", error);
        _captchaBtn.userInteractionEnabled = YES;
    }];
    
}

#pragma mark - IBAction Methods

- (IBAction)receiveVerifyCode:(UIButton *)sender {
    if ([self checkInput] == PhoneNumberError) {
        NSLog(@"手机号码错误");
    } else {
        _captchaBtn.userInteractionEnabled = NO;
        [self getCaptcha];
    }
}

- (IBAction)nextStep:(UIButton *)sender {
    [self stopTimer];
    [self virifyCaptcha];
}

//- (void)tapBackground:(id)sender
//{
//    if ([_phoneLabel isFirstResponder]) {
//        [_phoneLabel resignFirstResponder];
//    } else if ([_captchaLabel isFirstResponder]) {
//        [_captchaLabel resignFirstResponder];
//    }
//}


- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
    [super touchesEnded:touches withEvent:event];
}

@end




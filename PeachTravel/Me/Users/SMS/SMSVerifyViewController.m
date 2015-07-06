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
//@property (weak, nonatomic) IBOutlet UIButton *confirmBtn;

@end

@implementation SMSVerifyViewController

#pragma mark - LifeCycle

- (void)viewDidLoad {
    [super viewDidLoad];
 
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    backBtn.frame = CGRectMake(13, 34, 15, 15);
    [backBtn setImage:[UIImage imageNamed:@"login_back_defaut"] forState:UIControlStateNormal];
    [backBtn setImage:[UIImage imageNamed:@"common_icon_navigaiton_back_highlight"] forState:UIControlStateHighlighted];
    [self.view addSubview:backBtn];
    [backBtn addTarget:self action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];
    
    
    
    self.view.backgroundColor = [UIColor whiteColor];
    count = _coolDown;
    self.navigationItem.title = @"验证";
    
    UIImageView *iconImage = [[UIImageView alloc]initWithFrame:CGRectMake(489/3 * SCREEN_WIDTH/414, 216/3 *SCREEN_HEIGHT/736, 87*SCREEN_HEIGHT/736, 87*SCREEN_HEIGHT/736)];
    iconImage.image = [UIImage imageNamed:@"icon_little"];
    [self.view addSubview:iconImage];

    UIView *textFieldBg = [[UIView alloc]initWithFrame:CGRectMake(13, 890/3 *SCREEN_HEIGHT/736, SCREEN_WIDTH-26, 60 * SCREEN_HEIGHT/736)];
    textFieldBg.layer.borderColor = APP_THEME_COLOR.CGColor;
    textFieldBg.layer.borderWidth = 1;
    textFieldBg.layer.cornerRadius = 5;
    textFieldBg.clipsToBounds = YES;
    [self.view addSubview:textFieldBg];
    UIView *devide2 = [[UIView alloc]initWithFrame:CGRectMake(772/3 *SCREEN_WIDTH/414, 0 *SCREEN_HEIGHT / 736, 1, 60 * SCREEN_HEIGHT/736)];
    devide2.backgroundColor = APP_THEME_COLOR;
    [textFieldBg addSubview:devide2];
    
    
    _verifyCodeBtn = [[UIButton alloc]initWithFrame:CGRectMake(775/3 *SCREEN_WIDTH/414, 0, 395/3 * SCREEN_WIDTH/414, 59* SCREEN_HEIGHT/736)];
    [_verifyCodeBtn setTitle:[NSString stringWithFormat:@"%ldS",(long)count] forState:UIControlStateNormal];
    [_verifyCodeBtn setBackgroundImage:[ConvertMethods createImageWithColor:UIColorFromRGB(0xfafaf9)]forState:UIControlStateNormal];
    _verifyCodeBtn.clipsToBounds = YES;
    [_verifyCodeBtn setBackgroundImage:[ConvertMethods createImageWithColor:[UIColor whiteColor]] forState:UIControlStateDisabled];
    _verifyCodeBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    [_verifyCodeBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_verifyCodeBtn setTitleColor:TEXT_COLOR_TITLE_SUBTITLE forState:UIControlStateDisabled];
    _verifyCodeBtn.enabled = NO;
    _verifyCodeBtn.layer.cornerRadius = 2.0;
    [self startTimer];
    
    _verifyCodeTextField = [[UITextField alloc]initWithFrame:CGRectMake(10, 0, SCREEN_WIDTH - 50, 60 * SCREEN_HEIGHT / 736)];
    UILabel *ul = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 64.0, _verifyCodeTextField.bounds.size.height - 16.0)];
    ul.text = @" 验证码:";
    ul.textColor = TEXT_COLOR_TITLE;
    ul.font = [UIFont systemFontOfSize:14.0];
    ul.textAlignment = NSTextAlignmentCenter;
    _verifyCodeTextField.leftView = ul;
    _verifyCodeTextField.leftViewMode = UITextFieldViewModeAlways;
    [_verifyCodeTextField becomeFirstResponder];
    [textFieldBg addSubview:_verifyCodeBtn];
    [textFieldBg addSubview:_verifyCodeTextField];
    
    UIButton *nextBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    nextBtn.frame = CGRectMake(13, 1107/3 * SCREEN_HEIGHT/736, SCREEN_WIDTH - 26, 62 * SCREEN_HEIGHT/736);
    [nextBtn setTitle:@"下一步" forState:UIControlStateNormal];
    nextBtn.layer.cornerRadius = 4.0;
    nextBtn.clipsToBounds = YES;
    [nextBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [nextBtn setBackgroundImage:[ConvertMethods createImageWithColor:APP_THEME_COLOR] forState:UIControlStateNormal];
    [self.view addSubview:nextBtn];
    [nextBtn addTarget:self action:@selector(confirm:) forControlEvents:UIControlEventTouchUpInside];
    
}
- (void)viewWillAppear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [self stopTimer];
}

#pragma mark - Private Methods

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
        _verifyCodeBtn.enabled = YES;
        [_verifyCodeBtn setTitle:@"重新获取" forState:UIControlStateNormal];
    } else {
        count--;
        _verifyCodeBtn.titleLabel.text = [NSString stringWithFormat:@"%lds",(long)count];
        [_verifyCodeBtn setTitle:[NSString stringWithFormat:@"%lds",(long)count] forState:UIControlStateNormal];
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
        if (code == 0) {
            __weak SMSVerifyViewController *weakSelf = self;
            [[NSNotificationCenter defaultCenter] postNotificationName:userDidRegistedNoti object:nil userInfo:@{@"poster":weakSelf}];
            AccountManager *accountManager = [AccountManager shareAccountManager];
            [accountManager userDidLoginWithUserInfo:[responseObject objectForKey:@"result"]];
            [hud hideTZHUD];

        } else {
            [hud hideTZHUD];
            [SVProgressHUD showHint:[NSString stringWithFormat:@"%@", [[responseObject objectForKey:@"err"] objectForKey:@"message"]]];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [hud hideTZHUD];
        NSLog(@"%@", error);
        if (self.isShowing) {
            [SVProgressHUD showHint:@"呃～好像没找到网络"];
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
    [params setObject:kUserRegister forKey:@"actionCode"];
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
            [_verifyCodeBtn setTitle:[NSString stringWithFormat:@"%ldS",(long)count] forState:UIControlStateNormal];
            [self startTimer];
//            _verifyCodeBtn.userInteractionEnabled = NO;
            _verifyCodeBtn.enabled = NO;
            
        } else {
            [SVProgressHUD showHint:[[responseObject objectForKey:@"err"] objectForKey:@"message"]];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [hud hideTZHUD];
        if (self.isShowing) {
            [SVProgressHUD showHint:@"呃～好像没找到网络"];
        }
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


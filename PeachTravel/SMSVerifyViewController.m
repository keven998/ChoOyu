//
//  SMSVerifyViewController.m
//  PeachTravel
//
//  Created by liangpengshuai on 14/10/15.
//  Copyright (c) 2014年 com.aizou.www. All rights reserved.
//

#import "SMSVerifyViewController.h"
#import "AccountManager.h"

@interface SMSVerifyViewController () {
    NSTimer *timer;
    NSInteger count;
}

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UITextField *verifyCodeTextField;
@property (weak, nonatomic) IBOutlet UIButton *verifyCodeBtn;
@property (weak, nonatomic) IBOutlet UIButton *confirmBtn;

@end

@implementation SMSVerifyViewController

#pragma mark - LifeCycle

- (void)viewDidLoad {
    [super viewDidLoad];
    count = _coolDown;
    self.navigationItem.title = @"验证";
    _titleLabel.text = [NSString stringWithFormat:@"已发送短信验证码至%@", _phoneNumber];
    [_verifyCodeBtn setTitle:[NSString stringWithFormat:@"%dS",count] forState:UIControlStateNormal];
    _verifyCodeBtn.userInteractionEnabled = NO;
    [self startTimer];
    
    UITapGestureRecognizer *tapBackground = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapBackground:)];
    tapBackground.numberOfTapsRequired = 1;
    tapBackground.numberOfTouchesRequired = 1;
    [self.view addGestureRecognizer:tapBackground];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
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
        _verifyCodeBtn.userInteractionEnabled = YES;
        [_verifyCodeBtn setTitle:@"重新获取" forState:UIControlStateNormal];
    } else {
        count--;
        _verifyCodeBtn.titleLabel.text = [NSString stringWithFormat:@"%dS",count];
        [_verifyCodeBtn setTitle:[NSString stringWithFormat:@"%dS",count] forState:UIControlStateNormal];
    }
}

#pragma mark - IBAction Methods

//重新获取验证码
- (IBAction)reloadVerifyCode:(UIButton *)sender {
    count = _coolDown;
    [_verifyCodeBtn setTitle:[NSString stringWithFormat:@"%dS",count] forState:UIControlStateNormal];
    [self startTimer];
    _verifyCodeBtn.userInteractionEnabled = NO;
}

- (IBAction)confirm:(UIButton *)sender {
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [manager.requestSerializer setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:_phoneNumber forKey:@"tel"];
    [params setObject:_password forKey:@"pwd"];

    [params setObject:_verifyCodeTextField.text forKey:@"captcha"];
    
    //获取用户信息
    [manager POST:API_SIGNUP parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSInteger code = [[responseObject objectForKey:@"code"] integerValue];
        if (code == 0) {
            AccountManager *accountManager = [AccountManager shareAccountManager];
            [accountManager userDidLoginWithUserInfo:[responseObject objectForKey:@"result"]];
            [[NSNotificationCenter defaultCenter] postNotificationName:userDidLoginNoti object:nil];
            [[EaseMob sharedInstance].chatManager setNickname:[[responseObject objectForKey:@"result"] objectForKey:@"nickName"]];

        } else {
            [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"%@", [[responseObject objectForKey:@"err"] objectForKey:@"message"]]];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@", error);
    }];
}

- (void)tapBackground:(id)sender
{
    if ([_verifyCodeTextField isFirstResponder]) {
        [_verifyCodeTextField resignFirstResponder];
    }
}


@end


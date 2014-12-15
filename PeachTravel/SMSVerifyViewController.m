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
//@property (weak, nonatomic) IBOutlet UIButton *confirmBtn;

@end

@implementation SMSVerifyViewController

#pragma mark - LifeCycle

- (void)viewDidLoad {
    [super viewDidLoad];
 
    UIBarButtonItem *registerBtn = [[UIBarButtonItem alloc]initWithTitle:@"确认 " style:UIBarButtonItemStyleBordered target:self action:@selector(confirm:)];
    registerBtn.tintColor = APP_THEME_COLOR;
    self.navigationItem.rightBarButtonItem = registerBtn;
    
    count = _coolDown;
    self.navigationItem.title = @"验证";
    _titleLabel.text = [NSString stringWithFormat:@"已发送验证码短信至%@\n网络有延迟，请耐心等待", _phoneNumber];
    [_verifyCodeBtn setTitle:[NSString stringWithFormat:@"%dS",count] forState:UIControlStateNormal];
    _verifyCodeBtn.userInteractionEnabled = NO;
    _verifyCodeBtn.layer.cornerRadius = 2.0;
    [self startTimer];
    
//    _verifyCodeTextField.layer.borderColor = UIColorFromRGB(0xdddddd).CGColor;
//    _verifyCodeTextField.layer.borderWidth = 1.0;
    UILabel *ul = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 64.0, _verifyCodeTextField.bounds.size.height - 16.0)];
    ul.text = @" 验证码:";
    ul.textColor = TEXT_COLOR_TITLE;
    ul.font = [UIFont systemFontOfSize:14.0];
    ul.textAlignment = NSTextAlignmentCenter;
    _verifyCodeTextField.leftView = ul;
    _verifyCodeTextField.leftViewMode = UITextFieldViewModeAlways;
    [_verifyCodeTextField becomeFirstResponder];

//    [_confirmBtn setBackgroundImage:[UIImage imageNamed:@"theme_btn_normal.png"] forState:UIControlStateNormal];
//    [_confirmBtn setBackgroundImage:[UIImage imageNamed:@"theme_btn_highlight.png"] forState:UIControlStateHighlighted];
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
    if (_verifyCodeTextField.text == nil || [_verifyCodeTextField.text isEqualToString:@""]) {
        [SVProgressHUD showSuccessWithStatus:@"请输入验证码"];
        return;
    }
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [manager.requestSerializer setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:_phoneNumber forKey:@"tel"];
    [params setObject:_password forKey:@"pwd"];

    [params setObject:_verifyCodeTextField.text forKey:@"captcha"];
    
    [SVProgressHUD show];
    
    //获取用户信息
    [manager POST:API_SIGNUP parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSInteger code = [[responseObject objectForKey:@"code"] integerValue];
        if (code == 0) {
            AccountManager *accountManager = [AccountManager shareAccountManager];
            [accountManager userDidLoginWithUserInfo:[responseObject objectForKey:@"result"]];
            [[NSNotificationCenter defaultCenter] postNotificationName:userDidLoginNoti object:nil];
            __weak SMSVerifyViewController *weakSelf = self;
            //注册完成后要登录环信
            [accountManager loginEaseMobServer:^(BOOL isSuccess) {
                if (isSuccess) {
                    [[NSNotificationCenter defaultCenter] postNotificationName:userDidRegistedNoti object:nil userInfo:@{@"poster":weakSelf}];
                    [[EaseMob sharedInstance].chatManager setNickname:[[responseObject objectForKey:@"result"] objectForKey:@"nickName"]];
                    [SVProgressHUD showSuccessWithStatus:@"注册成功"];
                }
            }];
            

        } else {
            [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"%@", [[responseObject objectForKey:@"err"] objectForKey:@"message"]]];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@", error);
    }];
}

//- (void)tapBackground:(id)sender
//{
//    if ([_verifyCodeTextField isFirstResponder]) {
//        [_verifyCodeTextField resignFirstResponder];
//    }
//}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
    [super touchesEnded:touches withEvent:event];
}

@end


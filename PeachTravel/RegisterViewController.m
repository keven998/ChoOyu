//
//  RegisterViewController.m
//  PeachTravel
//
//  Created by liangpengshuai on 14/10/13.
//  Copyright (c) 2014年 com.aizou.www. All rights reserved.
//

#import "RegisterViewController.h"
#import "SMSVerifyViewController.h"

@interface RegisterViewController ()<UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *phoneLabel;
@property (weak, nonatomic) IBOutlet UITextField *passwordLabel;
@property (weak, nonatomic) IBOutlet UIButton *registerBtn;

@end

@implementation RegisterViewController

#pragma mark - LifeCycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIBarButtonItem *registerBtn = [[UIBarButtonItem alloc]initWithTitle:@"提交 " style:UIBarButtonItemStyleBordered target:self action:@selector(confirmRegister:)];
    registerBtn.tintColor = APP_THEME_COLOR;
    self.navigationItem.rightBarButtonItem = registerBtn;
    
    self.navigationItem.title = @"注册";
    
    _passwordLabel.delegate = self;
    
    UILabel *ul = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 64.0, _phoneLabel.bounds.size.height - 16.0)];
    ul.text = @"手机号:";
    ul.textColor = TEXT_COLOR_TITLE;
    ul.font = [UIFont systemFontOfSize:13.0];
    ul.textAlignment = NSTextAlignmentCenter;
    _phoneLabel.leftView = ul;
    _phoneLabel.leftViewMode = UITextFieldViewModeAlways;
    _phoneLabel.text = _defaultPhone;
    
    UILabel *pl = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 64.0, _passwordLabel.bounds.size.height - 16.0)];
    pl.text = @" 密码:";
    pl.textColor = TEXT_COLOR_TITLE;
    pl.font = [UIFont systemFontOfSize:14.0];
    pl.textAlignment = NSTextAlignmentCenter;
    _passwordLabel.leftView = pl;
    _passwordLabel.leftViewMode = UITextFieldViewModeAlways;
    _passwordLabel.text = _defaultPassword;

    [_registerBtn setBackgroundImage:[UIImage imageNamed:@"theme_btn_normal.png"] forState:UIControlStateNormal];
    [_registerBtn setBackgroundImage:[UIImage imageNamed:@"theme_btn_highlight.png"] forState:UIControlStateHighlighted];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == _passwordLabel) {
        [textField resignFirstResponder];
    }
    return YES;
}

#pragma mark - IBAction Methods

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
    [super touchesEnded:touches withEvent:event];
}

- (IBAction)confirmRegister:(UIButton *)sender {
    switch ([self checkInput]) {
        case NoError: {
            [self getCaptcha];
            _registerBtn.userInteractionEnabled = NO;
        }
            break;
            
        case PhoneNumberError:
            [self showHint:@"手机号输错了"];
            break;
            
        case PasswordError:
            [self showHint:@"密码只能是6-16位的数字或字母"];
            break;
            
        default:
            break;
    }
}

#pragma mark - Private Methods

- (UserInfoInputError)checkInput
{
    NSString * regex0 = @"^1\\d{10}$";
    NSPredicate *pred0 = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex0];
    if (![pred0 evaluateWithObject:_phoneLabel.text]) {
        return PhoneNumberError;
    }
    
    NSString * regex = @"^[A-Za-z0-9]{6,16}$";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    if (![pred evaluateWithObject:_passwordLabel.text]) {
        return PasswordError;
    }

    return NoError;
}

- (void)getCaptcha
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [manager.requestSerializer setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:_phoneLabel.text forKey:@"tel"];
    [params setObject:kUserRegister forKey:@"actionCode"];
    [SVProgressHUD show];
    //获取注册码
    [manager POST:API_GET_CAPTCHA parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSInteger code = [[responseObject objectForKey:@"code"] integerValue];
        _registerBtn.userInteractionEnabled = YES;
        [SVProgressHUD dismiss];
        if (code == 0) {
            SMSVerifyViewController *smsVerifyCtl = [[SMSVerifyViewController alloc] init];
            smsVerifyCtl.phoneNumber = self.phoneLabel.text;
            smsVerifyCtl.password = self.passwordLabel.text;
            smsVerifyCtl.coolDown = [[[responseObject objectForKey:@"result"] objectForKey:@"coolDown"] integerValue];
            [self.navigationController pushViewController:smsVerifyCtl animated:YES];
        } else {
//            [SVProgressHUD showErrorWithStatus:[[responseObject objectForKey:@"err"] objectForKey:@"message"]];
            [self showHint:[[responseObject objectForKey:@"err"] objectForKey:@"message"]];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//        [SVProgressHUD showErrorWithStatus:@"注册失败,是我们的原因"];
        NSLog(@"%@", error);
        [SVProgressHUD dismiss];
        _registerBtn.userInteractionEnabled = YES;
        [self showHint:@"呃～好像没找到网络"];
    }];
}

@end




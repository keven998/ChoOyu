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
    
    self.navigationItem.title = @"注册";
    
//    _phoneLabel.layer.borderColor = UIColorFromRGB(0xdddddd).CGColor;
//    _phoneLabel.layer.borderWidth = 1.0;
//    _passwordLabel.layer.borderColor = UIColorFromRGB(0xdddddd).CGColor;
//    _passwordLabel.layer.borderWidth = 1.0;
    _passwordLabel.delegate = self;
    
    UILabel *ul = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 64.0, _phoneLabel.bounds.size.height - 16.0)];
    ul.text = @" 账户:";
    ul.textColor = TEXT_COLOR_TITLE;
    ul.font = [UIFont systemFontOfSize:14.0];
    ul.textAlignment = NSTextAlignmentCenter;
    _phoneLabel.leftView = ul;
    _phoneLabel.leftViewMode = UITextFieldViewModeAlways;
    
    UILabel *pl = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 64.0, _passwordLabel.bounds.size.height - 16.0)];
    pl.text = @" 密码:";
    pl.textColor = TEXT_COLOR_TITLE;
    pl.font = [UIFont systemFontOfSize:14.0];
    pl.textAlignment = NSTextAlignmentCenter;
    _passwordLabel.leftView = pl;
    _passwordLabel.leftViewMode = UITextFieldViewModeAlways;

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
            NSLog(@"手机号输入非法");
            break;
            
        case PasswordError:
            NSLog(@"密码输入非法");
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
        if (code == 0) {
            SMSVerifyViewController *smsVerifyCtl = [[SMSVerifyViewController alloc] init];
            smsVerifyCtl.phoneNumber = self.phoneLabel.text;
            smsVerifyCtl.password = self.passwordLabel.text;
            smsVerifyCtl.coolDown = [[[responseObject objectForKey:@"result"] objectForKey:@"coolDown"] integerValue];
            [self.navigationController pushViewController:smsVerifyCtl animated:YES];
            [SVProgressHUD dismiss];
            
        } else {
            [SVProgressHUD showErrorWithStatus:[[responseObject objectForKey:@"err"] objectForKey:@"message"]];
            _registerBtn.userInteractionEnabled = YES;
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [SVProgressHUD dismiss];
        NSLog(@"%@", error);
        _registerBtn.userInteractionEnabled = YES;
    }];
}

@end




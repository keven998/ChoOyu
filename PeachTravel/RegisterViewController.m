//
//  RegisterViewController.m
//  PeachTravel
//
//  Created by liangpengshuai on 14/10/13.
//  Copyright (c) 2014年 com.aizou.www. All rights reserved.
//

#import "RegisterViewController.h"
#import "SMSVerifyViewController.h"

@interface RegisterViewController ()

@property (weak, nonatomic) IBOutlet UITextField *phoneLabel;
@property (weak, nonatomic) IBOutlet UITextField *passwordLabel;
@property (weak, nonatomic) IBOutlet UIButton *registerBtn;

@end

@implementation RegisterViewController

#pragma mark - LifeCycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"注册";
    
    _phoneLabel.layer.borderColor = [UIColor grayColor].CGColor;
    _phoneLabel.layer.borderWidth = 1.0;
    _passwordLabel.layer.borderColor = [UIColor grayColor].CGColor;
    _passwordLabel.layer.borderWidth = 1.0;
    
    UITapGestureRecognizer *tapBackground = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapBackground:)];
    tapBackground.numberOfTapsRequired = 1;
    tapBackground.numberOfTouchesRequired = 1;
    [self.view addGestureRecognizer:tapBackground];
}

#pragma mark - IBAction Methods

- (void)tapBackground:(id)sender
{
    if ([_phoneLabel isFirstResponder]) {
        [_phoneLabel resignFirstResponder];
    } else if ([_passwordLabel isFirstResponder]) {
        [_passwordLabel resignFirstResponder];
    }
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
    [params setObject:[NSNumber numberWithInt:1] forKey:@"actionCode"];
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
        } else {
            [SVProgressHUD showErrorWithStatus:[[responseObject objectForKey:@"err"] objectForKey:@"msg"]];
            _registerBtn.userInteractionEnabled = YES;
        }
        
        [SVProgressHUD dismiss];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [SVProgressHUD dismiss];
        _registerBtn.userInteractionEnabled = YES;
    }];
}

@end




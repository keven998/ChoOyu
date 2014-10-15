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

//- (void)viewWillAppear:(BOOL)animated
//{
//    [super viewWillAppear:animated];
//    self.tabBarController.tabBar.hidden = YES;
//}
//
//- (void)viewWillDisappear:(BOOL)animated {
//    [super viewWillDisappear:animated];
//    self.tabBarController.tabBar.hidden = NO;
//}

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
            NSLog(@"输入合法");
            SMSVerifyViewController *smsVerifyCtl = [[SMSVerifyViewController alloc] init];
            smsVerifyCtl.phoneNumber = self.phoneLabel.text;
            [self.navigationController pushViewController:smsVerifyCtl animated:YES];
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
    NSLog(@"%d", _phoneLabel.text.length);
    if (_phoneLabel.text.length != 11) {
        return PhoneNumberError;
    }
    
    NSString * regex = @"^[A-Za-z0-9]{6,16}$";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    if (![pred evaluateWithObject:_passwordLabel.text]) {
        return PasswordError;
    }

    return NoError;
}

@end

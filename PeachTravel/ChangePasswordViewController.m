//
//  ChangePasswordViewController.m
//  PeachTravel
//
//  Created by liangpengshuai on 14/10/14.
//  Copyright (c) 2014年 com.aizou.www. All rights reserved.
//

#import "ChangePasswordViewController.h"
#import "AccountManager.h"

@interface ChangePasswordViewController ()<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *oldPasswordLabel;
@property (weak, nonatomic) IBOutlet UITextField *presentPasswordLabel;
@property (weak, nonatomic) IBOutlet UITextField *confirmPasswordLabel;

@end

@implementation ChangePasswordViewController

#pragma mark - LifeCycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"修改密码";

//    _oldPasswordLabel.layer.borderColor = UIColorFromRGB(0xdddddd).CGColor;
//    _oldPasswordLabel.layer.borderWidth = 1.0;
    _oldPasswordLabel.delegate = self;
//    _presentPasswordLabel.layer.borderColor = UIColorFromRGB(0xdddddd).CGColor;
//    _presentPasswordLabel.layer.borderWidth = 1.0;
    _presentPasswordLabel.delegate = self;
//    _confirmPasswordLabel.layer.borderColor = UIColorFromRGB(0xdddddd).CGColor;
//    _confirmPasswordLabel.layer.borderWidth = 1.0;
    _confirmPasswordLabel.delegate = self;
    
    UILabel *ul = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 90.0, _oldPasswordLabel.bounds.size.height - 16.0)];
    ul.text = @"当前密码:";
    ul.textColor = TEXT_COLOR_TITLE;
    ul.font = [UIFont systemFontOfSize:14.0];
    ul.textAlignment = NSTextAlignmentCenter;
    _oldPasswordLabel.leftView = ul;
    _oldPasswordLabel.leftViewMode = UITextFieldViewModeAlways;
    
    UILabel *pl = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 90.0, _presentPasswordLabel.bounds.size.height - 16.0)];
    pl.text = @"新密码:";
    pl.textColor = TEXT_COLOR_TITLE;
    pl.font = [UIFont systemFontOfSize:14.0];
    pl.textAlignment = NSTextAlignmentCenter;
    _presentPasswordLabel.leftView = pl;
    _presentPasswordLabel.leftViewMode = UITextFieldViewModeAlways;
    
    UILabel *npl = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 90.0, _presentPasswordLabel.bounds.size.height - 16.0)];
    npl.text = @"确认新密码:";
    npl.textColor = TEXT_COLOR_TITLE;
    npl.font = [UIFont systemFontOfSize:12.0];
    npl.textAlignment = NSTextAlignmentCenter;
    _confirmPasswordLabel.leftView = npl;
    _confirmPasswordLabel.leftViewMode = UITextFieldViewModeAlways;
    
    UIBarButtonItem * registerBtn = [[UIBarButtonItem alloc]initWithTitle:@"确定" style:UIBarButtonItemStyleBordered target:self action:@selector(changePassword:)];
    registerBtn.tintColor = APP_THEME_COLOR;
    self.navigationItem.rightBarButtonItem = registerBtn;
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == _confirmPasswordLabel) {
        [textField resignFirstResponder];
    } else if (textField == _oldPasswordLabel) {
        [_presentPasswordLabel becomeFirstResponder];
    } else if (textField == _presentPasswordLabel) {
        [_confirmPasswordLabel becomeFirstResponder];
    }
    return YES;
}

#pragma mark - Private Methods

- (UserInfoInputError)checkInput
{
    NSString * regex = @"^[A-Za-z0-9]{6,16}$";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    if (![pred evaluateWithObject:_oldPasswordLabel.text]) {
        return PasswordError;
    }
    if (![pred evaluateWithObject:_presentPasswordLabel]) {
        return PresentPasswordError;
    }
    if (![pred evaluateWithObject:_confirmPasswordLabel]) {
        return ConfirmPasswordError;
    }
    if (![_presentPasswordLabel.text isEqualToString:_confirmPasswordLabel.text]) {
        return PasswordNotMatchedError;
    }
    return NoError;
}

#pragma mark - IBActiong Methods

- (IBAction)changePassword:(UIButton *)sender {
    
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
    [super touchesEnded:touches withEvent:event];
}

//- (void)tapBackground:(id)sender
//{
//    if ([_oldPasswordLabel isFirstResponder]) {
//        [_oldPasswordLabel resignFirstResponder];
//    } else if ([_presentPasswordLabel isFirstResponder]) {
//        [_presentPasswordLabel resignFirstResponder];
//    } else if ([_confirmPasswordLabel isFirstResponder]) {
//        [_confirmPasswordLabel resignFirstResponder];
//    }
//}

@end




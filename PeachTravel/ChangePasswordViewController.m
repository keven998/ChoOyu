//
//  ChangePasswordViewController.m
//  PeachTravel
//
//  Created by liangpengshuai on 14/10/14.
//  Copyright (c) 2014年 com.aizou.www. All rights reserved.
//

#import "ChangePasswordViewController.h"
#import "AccountManager.h"

@interface ChangePasswordViewController ()
@property (weak, nonatomic) IBOutlet UITextField *oldPasswordLabel;
@property (weak, nonatomic) IBOutlet UITextField *presentPasswordLabel;
@property (weak, nonatomic) IBOutlet UITextField *confirmPasswordLabel;

@end

@implementation ChangePasswordViewController

#pragma mark - LifeCycle

- (void)viewDidLoad {
    [super viewDidLoad];
    UITapGestureRecognizer *tapBackground = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapBackground:)];
    tapBackground.numberOfTapsRequired = 1;
    tapBackground.numberOfTouchesRequired = 1;
    [self.view addGestureRecognizer:tapBackground];
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

- (void)tapBackground:(id)sender
{
    if ([_oldPasswordLabel isFirstResponder]) {
        [_oldPasswordLabel resignFirstResponder];
    } else if ([_presentPasswordLabel isFirstResponder]) {
        [_presentPasswordLabel resignFirstResponder];
    } else if ([_confirmPasswordLabel isFirstResponder]) {
        [_confirmPasswordLabel resignFirstResponder];
    }
}

@end




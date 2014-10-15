//
//  LosePasswordViewController.m
//  PeachTravel
//
//  Created by liangpengshuai on 14/10/13.
//  Copyright (c) 2014年 com.aizou.www. All rights reserved.
//

#import "LosePasswordViewController.h"
#import "SMSVerifyViewController.h"

@interface LosePasswordViewController ()

@property (weak, nonatomic) IBOutlet UITextField *phoneLabel;

@end

@implementation LosePasswordViewController

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
    NSLog(@"%d", _phoneLabel.text.length);
    if (_phoneLabel.text.length != 11) {
        return PhoneNumberError;
    }
    return NoError;
}

#pragma mark - IBAction Methods

- (IBAction)receiveVerifyCode:(UIButton *)sender {
    if ([self checkInput] == PhoneNumberError) {
        NSLog(@"手机号码错误");
    } else {
        SMSVerifyViewController *smsVerifyCtl = [[SMSVerifyViewController alloc] init];
        smsVerifyCtl.phoneNumber = _phoneLabel.text;
        [self.navigationController pushViewController:smsVerifyCtl animated:YES];
    }
}

- (void)tapBackground:(id)sender
{
    if ([_phoneLabel isFirstResponder]) {
        [_phoneLabel resignFirstResponder];
    }
}


@end




//
//  BindTelephoneViewController.m
//  PeachTravel
//
//  Created by liangpengshuai on 14/10/20.
//  Copyright (c) 2014年 com.aizou.www. All rights reserved.
//

#import "BindTelephoneViewController.h"
#import "SMSVerifyViewController.h"

@interface BindTelephoneViewController ()
@property (weak, nonatomic) IBOutlet UITextField *phoneNumberLabel;

@end

@implementation BindTelephoneViewController

#pragma mark - LifeCycle

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - IBAction Methods

- (IBAction)bindTelephone:(UIButton *)sender {
    if ([self checkInput] == PhoneNumberError) {
        NSLog(@"请输入11位手机号");
    } else {
        [self getCaptcha];
    }
}

#pragma mark - Private Methods

- (UserInfoInputError)checkInput
{
    NSString * regex = @"^1\\d{10}$";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    if (![pred evaluateWithObject:_phoneNumberLabel.text]) {
        return PhoneNumberError;
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
    [params setObject:_phoneNumberLabel.text forKey:@"tel"];
    [params setObject:@"1" forKey:@"actionCode"];
    
    //获取用户信息
    [manager POST:API_GET_CAPTCHA parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSInteger code = [[responseObject objectForKey:@"code"] integerValue];
        if (code == 0) {
            SMSVerifyViewController *smsVerifyCtl = [[SMSVerifyViewController alloc] init];
            [self.navigationController pushViewController:smsVerifyCtl animated:YES];
        } else {
            
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@", error);
    }];
    
}

@end

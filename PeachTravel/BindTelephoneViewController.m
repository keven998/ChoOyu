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
    
    _phoneNumberLabel.layer.borderColor = UIColorFromRGB(0xdddddd).CGColor;
    _phoneNumberLabel.layer.borderWidth = 1.0;
    UILabel *ul = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 52.0, _phoneNumberLabel.bounds.size.height - 16.0)];
    ul.text = @" 手机:";
    ul.textColor = UIColorFromRGB(0x393939);
    ul.font = [UIFont systemFontOfSize:15.0];
    ul.textAlignment = NSTextAlignmentCenter;
    _phoneNumberLabel.leftView = ul;
    _phoneNumberLabel.leftViewMode = UITextFieldViewModeAlways;
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
            [self showHint:@"请求也是失败了"];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@", error);
        [self showHint:@"呃～好像没找到网络"];
    }];
    
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
    [super touchesEnded:touches withEvent:event];
}

@end

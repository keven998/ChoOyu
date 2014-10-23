//
//  ResetPasswordViewController.m
//  PeachTravel
//
//  Created by liangpengshuai on 14/10/23.
//  Copyright (c) 2014年 com.aizou.www. All rights reserved.
//

#import "ResetPasswordViewController.h"
#import "AccountManager.h"

@interface ResetPasswordViewController ()
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UITextField *passwordLabel;
@property (weak, nonatomic) IBOutlet UIButton *confirmBtn;

@end

@implementation ResetPasswordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

#pragma mark - IBAction Methods

- (IBAction)confirm:(UIButton *)sender {
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [manager.requestSerializer setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:_phoneNumber forKey:@"tel"];
    [params setObject:_passwordLabel.text forKey:@"pwd"];
    [params setObject:_token forKey:@"token"];
    NSString *urlStr;
    
    if (_verifyCaptchaType == UserBindTel) {
        AccountManager *accountManager = [AccountManager shareAccountManager];
        [params setObject:accountManager.account.userId forKey:@"userId"];
        urlStr = API_BINDTEL;
    } else {
        urlStr = API_RESET_PWD;
    }
    
    [SVProgressHUD show];

    //完成修改
    [manager POST:urlStr parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSInteger code = [[responseObject objectForKey:@"code"] integerValue];
        if (code == 0) {
            [SVProgressHUD dismiss];
        } else {
            [SVProgressHUD showErrorWithStatus:[[responseObject objectForKey:@"err"] objectForKey:@"message"]];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@", error);
    }];

}

@end

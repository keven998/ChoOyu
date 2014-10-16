//
//  ChangeUserInfoViewController.m
//  PeachTravel
//
//  Created by liangpengshuai on 14/10/15.
//  Copyright (c) 2014年 com.aizou.www. All rights reserved.
//

#import "ChangeUserInfoViewController.h"
#import "AccountManager.h"

@interface ChangeUserInfoViewController ()

@property (weak, nonatomic) IBOutlet UITextField *contentTextField;

@end

@implementation ChangeUserInfoViewController

#pragma mark - LifeCycle

- (void)viewDidLoad {
    [super viewDidLoad];
    if (_changeType == ChangeName) {
        self.navigationItem.title = @"昵称";
    }
    if (_changeType == ChangeSignature) {
        self.navigationItem.title = @"个性签名";
    }
    _contentTextField.text = _content;
    UIButton *registerBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 60, 30)];
    registerBtn.titleLabel.font = [UIFont systemFontOfSize:17.];
    [registerBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [registerBtn setTitle:@"保存" forState:UIControlStateNormal];
    [registerBtn addTarget:self action:@selector(saveChange:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *registerItem = [[UIBarButtonItem alloc] initWithCustomView:registerBtn];
    self.navigationItem.rightBarButtonItem = registerItem;
    
    UITapGestureRecognizer *tapBackground = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapBackground:)];
    tapBackground.numberOfTapsRequired = 1;
    tapBackground.numberOfTouchesRequired = 1;
    [self.view addGestureRecognizer:tapBackground];
}

#pragma mark - Private Methods

- (UserInfoInputError)checkInput
{
    NSString * regex = @"^[\u4E00-\u9FA5|a-zA-Z][\u4E00-\u9FA5|0-9a-zA-Z]*$";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    if (![pred evaluateWithObject:_contentTextField.text]) {
        NSLog(@"输入中含有非法字符串");
        return IllegalCharacterError;
    }
    return NoError;
}

#pragma mark - IBAction Methods

-(IBAction)saveChange:(id)sender
{
    if (!([self checkInput] == NoError)) {
        return;
    }
    
    AccountManager *accountManager = [AccountManager shareAccountManager];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [manager.requestSerializer setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    
    if (_changeType == ChangeName) {
        [params setObject:_contentTextField.text forKey:@"nickName"];
    }
    if (_changeType == ChangeSignature) {
        [params setObject:_contentTextField.text forKey:@"signature"];
    }
    
    NSString *urlStr = [NSString stringWithFormat:@"%@%@", API_USERINFO, accountManager.account.userId];
    
    //获取用户信息
    [manager POST:urlStr parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSInteger code = [[responseObject objectForKey:@"code"] integerValue];
        if (code == 0) {
            NSLog(@"%@", responseObject);
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@", error);
        
    }];

    
}

- (void)tapBackground:(id)sender
{
    if ([_contentTextField isFirstResponder]) {
        [_contentTextField resignFirstResponder];
    }
}



@end

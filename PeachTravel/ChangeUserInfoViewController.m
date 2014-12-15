//
//  ChangeUserInfoViewController.m
//  PeachTravel
//
//  Created by liangpengshuai on 14/10/15.
//  Copyright (c) 2014年 com.aizou.www. All rights reserved.
//

#import "ChangeUserInfoViewController.h"
#import "AccountManager.h"

@interface ChangeUserInfoViewController ()<UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *contentTextField;

@end

@implementation ChangeUserInfoViewController

#pragma mark - LifeCycle

- (void)viewDidLoad {
    [super viewDidLoad];
    if (_changeType == ChangeName) {
        self.navigationItem.title = @"修改昵称";
    }
    if (_changeType == ChangeSignature) {
        self.navigationItem.title = @"旅行签名";
    }
    
    _contentTextField.layer.borderColor = UIColorFromRGB(0xdcdcdc).CGColor;
    _contentTextField.layer.borderWidth = 0.5;
    _contentTextField.delegate = self;
    UIView *sv = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10.0, 20.0)];
    sv.backgroundColor = [UIColor whiteColor];
    _contentTextField.leftView = sv;
    _contentTextField.leftViewMode = UITextFieldViewModeAlways;
    [_contentTextField becomeFirstResponder];
    
    _contentTextField.text = _content;
    

    UIBarButtonItem * registerBtn = [[UIBarButtonItem alloc]initWithTitle:@"保存" style:UIBarButtonItemStyleBordered target:self action:@selector(saveChange:)];
    registerBtn.tintColor = APP_THEME_COLOR;
    self.navigationItem.rightBarButtonItem = registerBtn;
    
//    UITapGestureRecognizer *tapBackground = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapBackground:)];
//    tapBackground.numberOfTapsRequired = 1;
//    tapBackground.numberOfTouchesRequired = 1;
//    [self.view addGestureRecognizer:tapBackground];
}

#pragma mark - Private Methods

- (UserInfoInputError)checkInput
{
    if (_changeType == ChangeName) {
        NSString *regex1 = @"^[\u4E00-\u9FA5|0-9a-zA-Z|_]*$";
        NSString *regex2 = @"^[0-9]{6,}$";
        NSPredicate *pred1 = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex1];
        NSPredicate *pred2 = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex2];
        if (![pred1 evaluateWithObject:_contentTextField.text] || [pred2 evaluateWithObject:_contentTextField.text]) {
            NSLog(@"输入中含有非法字符串");
            return IllegalCharacterError;
        }
    }
    if (_changeType == ChangeSignature) {
        NSString *regex1 = @"^[\u4E00-\u9FA5|0-9a-zA-Z|_]*$";
        NSPredicate *pred1 = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex1];
        if (![pred1 evaluateWithObject:_contentTextField.text] ||  ![pred1 evaluateWithObject:_contentTextField.text]) {
            NSLog(@"输入中含有非法字符串");
            return IllegalCharacterError;
        }
    }
    return NoError;
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == _contentTextField) {
        [textField resignFirstResponder];
    }
    return YES;
}

#pragma mark - IBAction Methods

-(IBAction)saveChange:(id)sender
{
    if (_changeType == ChangeName) {
        if (!([self checkInput] == NoError)) {
            return;
        }
    }
    
    [SVProgressHUD show];
    AccountManager *accountManager = [AccountManager shareAccountManager];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [manager.requestSerializer setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"%@", accountManager.account.userId] forHTTPHeaderField:@"UserId"];
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    
    if (_changeType == ChangeName) {
        [params setObject:_contentTextField.text forKey:@"nickName"];
    }
    if (_changeType == ChangeSignature) {
        [params setObject:_contentTextField.text forKey:@"signature"];
    }
    
    NSString *urlStr = [NSString stringWithFormat:@"%@%@", API_USERINFO, accountManager.account.userId];
    
    [manager POST:urlStr parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"%@", responseObject);
        NSInteger code = [[responseObject objectForKey:@"code"] integerValue];
        if (code == 0) {
            [SVProgressHUD showSuccessWithStatus:@"修改成功"];
            [accountManager updateUserInfo:_contentTextField.text withChangeType:_changeType];
            [[NSNotificationCenter defaultCenter] postNotificationName:updateUserInfoNoti object:nil];
            if (_changeType == ChangeName) {
                [[EaseMob sharedInstance].chatManager setNickname:_contentTextField.text];
            }
            [self.navigationController popViewControllerAnimated:YES];
        } else {
            [SVProgressHUD showErrorWithStatus:@"修改失败"];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@", error);
        [SVProgressHUD showErrorWithStatus:@"修改失败"];
    }];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
    [super touchesEnded:touches withEvent:event];
}



@end

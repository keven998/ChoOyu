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
    

    UIBarButtonItem * registerBtn = [[UIBarButtonItem alloc]initWithTitle:@"保存 " style:UIBarButtonItemStyleBordered target:self action:@selector(saveChange:)];
    registerBtn.tintColor = APP_THEME_COLOR;
    self.navigationItem.rightBarButtonItem = registerBtn;
}

/**
 *  重写父类的返回方法
 */
- (void)goBack
{
    if (![_content isEqualToString:_contentTextField.text]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"不需要保存吗" delegate:self cancelButtonTitle:@"直接返回" otherButtonTitles:@"先保存", nil];
        [alert showAlertViewWithBlock:^(NSInteger buttonIndex) {
            if (buttonIndex == 0) {
                [self dismiss];
            } else {
                [self saveChange:nil];
            }
        }];
    } else {
        [self dismiss];
    }
}

- (void)dismiss
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Private Methods

- (UserInfoInputError)checkInput
{
    if (_changeType == ChangeName) {
        NSString *regex1 = @"^[\u4E00-\u9FA5|0-9a-zA-Z|_]{1,}$";
        NSString *regex2 = @"^[0-9]{6,}$";
        NSPredicate *pred1 = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex1];
        NSPredicate *pred2 = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex2];
        if (![pred1 evaluateWithObject:_contentTextField.text] || [pred2 evaluateWithObject:_contentTextField.text]) {
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
    [self.view endEditing:YES];
    if (_changeType == ChangeName) {
        if (!([self checkInput] == NoError)) {
            [SVProgressHUD showHint:@"纯数字或有特殊字符都是不行的哦"];
            return;
        }
    }
    
    if ([_content isEqualToString:_contentTextField.text]) {
        [SVProgressHUD showHint:@"修改成功"];
        [self dismiss];
        return;
    }
    
    __weak typeof(ChangeUserInfoViewController *)weakSelf = self;
    TZProgressHUD *hud = [[TZProgressHUD alloc] init];
    [hud showHUDInViewController:weakSelf];
    
    AccountManager *accountManager = [AccountManager shareAccountManager];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    AppUtils *utils = [[AppUtils alloc] init];
    [manager.requestSerializer setValue:utils.appVersion forHTTPHeaderField:@"Version"];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"iOS %@",utils.systemVersion] forHTTPHeaderField:@"Platform"];
    
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
        [hud hideTZHUD];
        NSInteger code = [[responseObject objectForKey:@"code"] integerValue];
        if (code == 0) {
            [SVProgressHUD showHint:@"修改成功"];
            [accountManager updateUserInfo:_contentTextField.text withChangeType:_changeType];
            [[NSNotificationCenter defaultCenter] postNotificationName:updateUserInfoNoti object:nil];
            if (_changeType == ChangeName) {
                [[EaseMob sharedInstance].chatManager setApnsNickname:_contentTextField.text];
            }
            [self performSelector:@selector(dismiss) withObject:nil afterDelay:0.4];
        } else {
             if (self.isShowing) {
                [SVProgressHUD showHint:@"请求也是失败了"];
             }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [hud hideTZHUD];
        if (self.isShowing) {
            [SVProgressHUD showHint:@"呃～好像没找到网络"];
        }
    }];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
    [super touchesEnded:touches withEvent:event];
}



@end

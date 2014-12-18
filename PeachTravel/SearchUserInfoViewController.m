//
//  SearchUserInfoViewController.m
//  PeachTravel
//
//  Created by liangpengshuai on 14/11/3.
//  Copyright (c) 2014年 com.aizou.www. All rights reserved.
//

#import "SearchUserInfoViewController.h"
#import "TZCMDChatHelper.h"
#import "AccountManager.h"

@interface SearchUserInfoViewController ()

@property (weak, nonatomic) IBOutlet UIView *avatarImageFrame;
@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UILabel *nickNameLabel;
@property (weak, nonatomic) IBOutlet UIButton *signatureSimLabel;


@end

@implementation SearchUserInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self showUserInfo:_userInfo];
}

- (void)showUserInfo:(NSDictionary *)userInfo
{
    _avatarImageFrame.layer.cornerRadius = 48.0;
    _avatarImageView.layer.cornerRadius = 45.0;
    _avatarImageView.clipsToBounds = YES;
    [_avatarImageView sd_setImageWithURL:[NSURL URLWithString:[userInfo objectForKey:@"avatar"]] placeholderImage:nil];
    _nickNameLabel.text = [userInfo objectForKey:@"nickName"];
    _signatureSimLabel.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    _signatureSimLabel.titleLabel.numberOfLines = 3;
    [_signatureSimLabel setTitle:[userInfo objectForKey:@"signature"] forState:UIControlStateNormal];
}

- (IBAction)addContact:(UIButton *)sender {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"打个招呼吧" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    [alert setAlertViewStyle:UIAlertViewStylePlainTextInput];
    UITextField *nameTextField = [alert textFieldAtIndex:0];
    AccountManager *accountManager = [AccountManager shareAccountManager];
    nameTextField.text = [NSString stringWithFormat:@"hello,我是%@,加个好友呗", accountManager.account.nickName];
    [alert showAlertViewWithBlock:^(NSInteger buttonIndex) {
        if (buttonIndex == 1) {
            [self requestAddContactWithHello:nameTextField.text];
        }
    }];
}

/**
 *  邀请好友
 *
 *  @param helloStr 
 */
- (void)requestAddContactWithHello:(NSString *)helloStr
{
    AccountManager *accountManager = [AccountManager shareAccountManager];

    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [manager.requestSerializer setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"%@", accountManager.account.userId] forHTTPHeaderField:@"UserId"];
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params safeSetObject:[_userInfo objectForKey:@"userId"] forKey:@"userId"];
    if ([helloStr stringByReplacingOccurrencesOfString:@" " withString:@""].length == 0) {
        helloStr = [NSString stringWithFormat:@"hello,我是%@,加个好友呗", accountManager.account.nickName];
    }
    [params safeSetObject:helloStr forKey:@"hello"];

    [SVProgressHUD show];

    [manager POST:API_REQUEST_ADD_CONTACT parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSInteger code = [[responseObject objectForKey:@"code"] integerValue];
        if (code == 0) {
            [SVProgressHUD showSuccessWithStatus:@"邀请成功"];
            [self.navigationController popViewControllerAnimated:YES];
        } else {
            [SVProgressHUD showErrorWithStatus:[[responseObject objectForKey:@"err"] objectForKey:@"message"]];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [SVProgressHUD showErrorWithStatus:@"邀请失败了"];

    }];

}

@end

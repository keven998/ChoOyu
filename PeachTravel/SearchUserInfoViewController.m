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
#import "ConvertMethods.h"

@interface SearchUserInfoViewController ()

@property (weak, nonatomic) IBOutlet UIView *avatarImageFrame;
@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UILabel *nickNameLabel;
@property (weak, nonatomic) IBOutlet UIButton *signatureSimLabel;
@property (weak, nonatomic) IBOutlet UIImageView *genderImageView;

@property (weak, nonatomic) IBOutlet UIView *cardView;
@property (weak, nonatomic) IBOutlet UIButton *addButton;

@end

@implementation SearchUserInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = [_userInfo objectForKey:@"nickName"];
    self.view.backgroundColor = APP_PAGE_COLOR;
    _cardView.layer.cornerRadius = 2.0;
    _cardView.layer.shadowColor = APP_DIVIDER_COLOR.CGColor;
    _cardView.layer.shadowOffset = CGSizeMake(0.0, 0.5);
    _cardView.layer.shadowOpacity = 1.0;
    _cardView.layer.shadowRadius = 0.5;

    _signatureSimLabel.titleLabel.numberOfLines = 2.0;
    _signatureSimLabel.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    _signatureSimLabel.contentVerticalAlignment = UIControlContentVerticalAlignmentTop;
    
    [_addButton setBackgroundImage:[ConvertMethods createImageWithColor:APP_THEME_COLOR] forState:UIControlStateNormal];
    [_addButton setBackgroundImage:[ConvertMethods createImageWithColor:APP_THEME_COLOR_HIGHLIGHT] forState:UIControlStateHighlighted];
    [_addButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_addButton setTitleColor:TEXT_COLOR_TITLE forState:UIControlStateHighlighted];
    _addButton.layer.cornerRadius = 2.0;
    
    [self showUserInfo:_userInfo];
}

- (void)showUserInfo:(NSDictionary *)userInfo
{
    _avatarImageFrame.layer.cornerRadius = 34.0;
    _avatarImageView.layer.cornerRadius = 31.0;
    _avatarImageView.clipsToBounds = YES;
    [_avatarImageView sd_setImageWithURL:[NSURL URLWithString:[userInfo objectForKey:@"avatar"]] placeholderImage:nil];
    _nickNameLabel.text = [userInfo objectForKey:@"nickName"];
    _signatureSimLabel.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    _signatureSimLabel.titleLabel.numberOfLines = 3;
    [_signatureSimLabel setTitle:[userInfo objectForKey:@"signature"] forState:UIControlStateNormal];
    if ([[userInfo objectForKey:@"gender"] isEqualToString:@"M"]) {
        self.genderImageView.image = [UIImage imageNamed:@"ic_gender_man.png"];
        
    }
    if ([[userInfo objectForKey:@"gender"] isEqualToString:@"F"]) {
        self.genderImageView.image  = [UIImage imageNamed:@"ic_gender_lady.png"];
    }
    if ([[userInfo objectForKey:@"gender"] isEqualToString:@"U"]) {
        self.genderImageView.image  = nil;
    }

}

- (IBAction)addContact:(UIButton *)sender {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"输入验证信息" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    [alert setAlertViewStyle:UIAlertViewStylePlainTextInput];
    UITextField *nameTextField = [alert textFieldAtIndex:0];
    AccountManager *accountManager = [AccountManager shareAccountManager];
    nameTextField.text = [NSString stringWithFormat:@"Hi, 我是桃友%@", accountManager.account.nickName];
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
        helloStr = [NSString stringWithFormat:@"Hi, 我是桃友%@", accountManager.account.nickName];
    }
    [params safeSetObject:helloStr forKey:@"message"];

     __weak typeof(SearchUserInfoViewController *)weakSelf = self;
    TZProgressHUD *hud = [[TZProgressHUD alloc] init];
    [hud showHUDInViewController:weakSelf];

    [manager POST:API_REQUEST_ADD_CONTACT parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [hud hideTZHUD];
        NSInteger code = [[responseObject objectForKey:@"code"] integerValue];
        if (code == 0) {
            [SVProgressHUD showHint:@"请求已发送，等待对方验证"];
            [self.navigationController popViewControllerAnimated:YES];
        } else {
            [SVProgressHUD showHint:[[responseObject objectForKey:@"err"] objectForKey:@"message"]];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [hud hideTZHUD];
        if (self.isShowing) {
            [SVProgressHUD showHint:@"呃～好像没找到网络"];
        }
    }];

}

@end

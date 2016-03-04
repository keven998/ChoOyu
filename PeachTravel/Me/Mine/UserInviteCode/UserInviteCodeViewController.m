//
//  UserInviteCodeViewController.m
//  PeachTravel
//
//  Created by liangpengshuai on 3/4/16.
//  Copyright © 2016 com.aizou.www. All rights reserved.
//

#import "UserInviteCodeViewController.h"
#import "UMSocial.h"

@interface UserInviteCodeViewController ()
@property (weak, nonatomic) IBOutlet UILabel *contentLabel;
@property (weak, nonatomic) IBOutlet UILabel *inviteCodeLabel;

@end

@implementation UserInviteCodeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"我的邀请码";
    _contentLabel.text = @"分享您的邀请码给好友\n当有好友使用你的邀请码注册后，即可获得优惠~";
    _inviteCodeLabel.textColor = COLOR_PRICE_RED;
    _inviteCodeLabel.text = [AccountManager shareAccountManager].account.inviteCode;
    
    if (![AccountManager shareAccountManager].account.inviteCode.length) {
        [[AccountManager shareAccountManager].account loadUserInfoFromServer:^(bool isSuccess) {
            _inviteCodeLabel.text = [AccountManager shareAccountManager].account.inviteCode;
        }];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)inviteFrendAction:(id)sender {
    [UMSocialData defaultData].extConfig.wechatSessionData.title = @"推荐\"旅行派\"给你。";
    
    [UMSocialData defaultData].extConfig.wechatSessionData.url = @"http://www.lvxingpai.com/app/download/";
    
    UIImage *shareImage = [UIImage imageNamed:@"share_icon.png"];
    
    [[UMSocialDataService defaultDataService]  postSNSWithTypes:@[UMShareToWechatSession] content:[NSString stringWithFormat:@"注册时填写 %@ 邀请码，咱俩都能获得支付宝红包", _inviteCodeLabel.text] image:shareImage location:nil urlResource:nil presentedController:self completion:^(UMSocialResponseEntity *response) {
    }];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

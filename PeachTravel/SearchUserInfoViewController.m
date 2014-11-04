//
//  SearchUserInfoViewController.m
//  PeachTravel
//
//  Created by liangpengshuai on 14/11/3.
//  Copyright (c) 2014年 com.aizou.www. All rights reserved.
//

#import "SearchUserInfoViewController.h"
#import "TZCMDChatHelper.h"

@interface SearchUserInfoViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UILabel *nickNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *signatureLabel;

@end

@implementation SearchUserInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self showUserInfo:_userInfo];
}

- (void)showUserInfo:(NSDictionary *)userInfo
{
    [_avatarImageView sd_setImageWithURL:[NSURL URLWithString:[userInfo objectForKey:@"avatar"]] placeholderImage:nil];
    _nickNameLabel.text = [userInfo objectForKey:@"nickName"];
    _signatureLabel.text = [userInfo objectForKey:@"signature"];
}

- (IBAction)addContact:(UIButton *)sender {
    [TZCMDChatHelper addContact:[_userInfo objectForKey:@"easemobUser"] withAttachMsg:@"我是小明,我是旅行派的小闺密"];
}

@end

//
//  ContactDetailViewController.m
//  PeachTravel
//
//  Created by liangpengshuai on 14/11/6.
//  Copyright (c) 2014年 com.aizou.www. All rights reserved.
//

#import "ContactDetailViewController.h"
#import "ANBlurredImageView.h"
#import "ChatViewController.h"

@interface ContactDetailViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *bigHeaderImageView;
@property (weak, nonatomic) IBOutlet UIImageView *smallHeaderImageView;
@property (weak, nonatomic) IBOutlet UILabel *nickNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *signatureLabel;
@property (weak, nonatomic) IBOutlet UILabel *phoneLabel;

@end

@implementation ContactDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [_bigHeaderImageView sd_setImageWithURL:[NSURL URLWithString:_contact.avatar] placeholderImage:nil];
    [_smallHeaderImageView sd_setImageWithURL:[NSURL URLWithString:_contact.avatar] placeholderImage:nil];
    _nickNameLabel.text = [NSString stringWithFormat:@"   昵称 ：%@", _contact.nickName];
    _signatureLabel.text = [NSString stringWithFormat:@"   签名 ：%@", _contact.signature];
    _phoneLabel.text = [NSString stringWithFormat:@"   番号 ：%@", _contact.userId];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


- (IBAction)chat:(UIButton *)sender {
    ChatViewController *chatCtl = [[ChatViewController alloc] initWithChatter:_contact.easemobUser isGroup:NO];
    chatCtl.title = _contact.nickName;
    NSArray *conversations = [[EaseMob sharedInstance].chatManager conversations];
    for (EMConversation *conversation in conversations) {
        if ([conversation.chatter isEqualToString:_contact.easemobUser]) {
            [conversation markMessagesAsRead:YES];
            break;
        }
    }
    [self.navigationController pushViewController:chatCtl animated:YES];
}

@end

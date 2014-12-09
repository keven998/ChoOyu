//
//  PoiDetailSuperViewController.m
//  PeachTravel
//
//  Created by liangpengshuai on 12/3/14.
//  Copyright (c) 2014 com.aizou.www. All rights reserved.
//

#import "PoiDetailSuperViewController.h"

@interface PoiDetailSuperViewController () <CreateConversationDelegate, TaoziMessageSendDelegate>


@property (nonatomic, strong) UIButton *rightItemBtn;



@end

@implementation PoiDetailSuperViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.automaticallyAdjustsScrollViewInsets = NO;
    _rightItemBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    [_rightItemBtn setTitle:@"chat" forState:UIControlStateNormal];
    [_rightItemBtn setTitleColor:UIColorFromRGB(0xee528c) forState:UIControlStateNormal];
    [_rightItemBtn addTarget:self action:@selector(chat:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:_rightItemBtn];
}

#pragma mark - IBAction Methods

- (IBAction)chat:(id)sender
{
    _chatRecordListCtl = [[ChatRecoredListTableViewController alloc] init];
    _chatRecordListCtl.delegate = self;
    UINavigationController *nCtl = [[UINavigationController alloc] initWithRootViewController:_chatRecordListCtl];
    [self presentViewController:nCtl animated:YES completion:nil];
}

#pragma mark - CreateConversationDelegate

- (void)createConversationSuccessWithChatter:(NSString *)chatter isGroup:(BOOL)isGroup chatTitle:(NSString *)chatTitle
{
    TaoziChatMessageBaseViewController *taoziMessageCtl = [[TaoziChatMessageBaseViewController alloc] init];
    [self setChatMessageModel:taoziMessageCtl];
    taoziMessageCtl.delegate = self;
    taoziMessageCtl.chatTitle = chatTitle;
    taoziMessageCtl.chatter = chatter;
    taoziMessageCtl.isGroup = isGroup;
    
    [self.chatRecordListCtl dismissViewControllerAnimated:YES completion:^{
        [self presentPopupViewController:taoziMessageCtl atHeight:170.0 animated:YES completion:^(void) {
        }];
    }];
}

#pragma mark - TaoziMessageSendDelegate

//用户确定发送景点给朋友
- (void)sendSuccess:(ChatViewController *)chatCtl
{
    [self dismissPopup];
    
    /*发送完成后不进入聊天界面
    [self.navigationController pushViewController:chatCtl animated:YES];
     */
    
    [SVProgressHUD showSuccessWithStatus:@"发送成功"];

}

- (void)sendCancel
{
    [self dismissPopup];
}

/**
 *  消除发送 poi 对话框
 *  @param sender
 */
- (void)dismissPopup
{
    if (self.popupViewController != nil) {
        [self dismissPopupViewControllerAnimated:YES completion:^{
        }];
    }
}

- (void)setChatMessageModel:(TaoziChatMessageBaseViewController *)taoziMessageCtl
{
    
}

@end

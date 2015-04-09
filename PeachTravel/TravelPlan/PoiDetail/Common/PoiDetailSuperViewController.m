//
//  PoiDetailSuperViewController.m
//  PeachTravel
//
//  Created by liangpengshuai on 12/3/14.
//  Copyright (c) 2014 com.aizou.www. All rights reserved.
//

#import "PoiDetailSuperViewController.h"
#import "AccountManager.h"
#import "LoginViewController.h"

@interface PoiDetailSuperViewController () <CreateConversationDelegate, TaoziMessageSendDelegate, UIActionSheetDelegate>

@end

@implementation PoiDetailSuperViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.automaticallyAdjustsScrollViewInsets = NO;
}

#pragma mark - IBAction Methods

- (IBAction)chat:(id)sender
{
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:nil
                                                       delegate:self
                                              cancelButtonTitle:@"取消"
                                         destructiveButtonTitle:nil
                                              otherButtonTitles:@"Talk分享", nil];
    sheet.tag = kASShare;
    [sheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (actionSheet.tag == kASShare) {
        if (buttonIndex == 0) {
            [self shareToTalk];
        }
    }
}

- (void)shareToTalk {
    if (![[AccountManager shareAccountManager] isLogin]) {
        [SVProgressHUD showHint:@"请先登录"];
        [self performSelector:@selector(login) withObject:nil afterDelay:0.3];
    } else {
        _chatRecordListCtl = [[ChatRecoredListTableViewController alloc] init];
        _chatRecordListCtl.delegate = self;
        TZNavigationViewController *nCtl = [[TZNavigationViewController alloc] initWithRootViewController:_chatRecordListCtl];
        [self presentViewController:nCtl animated:YES completion:nil];
    }
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
        [self presentPopupViewController:taoziMessageCtl atHeight:170.0 animated:YES completion:nil];
    }];
}

#pragma mark - TaoziMessageSendDelegate

//用户确定发送景点给朋友
- (void)sendSuccess:(ChatViewController *)chatCtl
{
    [self dismissPopup];
    [SVProgressHUD showSuccessWithStatus:@"已发送~"];

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
        [self dismissPopupViewControllerAnimated:YES completion:nil];
    }
}

- (void)setChatMessageModel:(TaoziChatMessageBaseViewController *)taoziMessageCtl
{
    
}

- (void)asyncFavoritePoiWithCompletion:(void (^)(BOOL))completion;
{
    AccountManager *accountManager = [AccountManager shareAccountManager];
    if (!accountManager.isLogin) {
        [self showHint:@"请先登录"];
        [self performSelector:@selector(login) withObject:nil afterDelay:0.3];
        completion(NO);
        return;
    }
    
    [_poi asyncFavoritePoiWithCompletion:^(BOOL isSuccess) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        if (isSuccess) {
            if (_poi.isMyFavorite) {
                [self showHint:@"已收藏"];
            } else {
                [self showHint:@"已取消收藏"];
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:updateFavoriteListNoti object:nil];
            completion(YES);
        } else {
            [self showHint:@"呃～好像没找到网络"];
        }
    }];
}

- (void)login
{
    LoginViewController *loginViewController = [[LoginViewController alloc] init];
    TZNavigationViewController *nctl = [[TZNavigationViewController alloc] initWithRootViewController:loginViewController];
    loginViewController.isPushed = NO;
    [self presentViewController:nctl animated:YES completion:nil];
}


@end

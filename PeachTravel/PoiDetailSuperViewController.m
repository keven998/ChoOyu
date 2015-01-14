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

@interface PoiDetailSuperViewController () <CreateConversationDelegate, TaoziMessageSendDelegate>

@end

@implementation PoiDetailSuperViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.automaticallyAdjustsScrollViewInsets = NO;
    UIButton *talkBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    [talkBtn setImage:[UIImage imageNamed:@"ic_chat.png"] forState:UIControlStateNormal];
    [talkBtn addTarget:self action:@selector(chat:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightBarItem = [[UIBarButtonItem alloc] initWithCustomView:talkBtn];
    self.navigationItem.rightBarButtonItem = rightBarItem;
}

#pragma mark - IBAction Methods

- (IBAction)chat:(id)sender
{
    if (![[AccountManager shareAccountManager] isLogin]) {
        
        [SVProgressHUD showErrorWithStatus:@"请先登录"];
        [self performSelector:@selector(login) withObject:nil afterDelay:0.3];
    } else {
        _chatRecordListCtl = [[ChatRecoredListTableViewController alloc] init];
        _chatRecordListCtl.delegate = self;
        UINavigationController *nCtl = [[UINavigationController alloc] initWithRootViewController:_chatRecordListCtl];
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
        [self dismissPopupViewControllerAnimated:YES completion:^{
        }];
    }
}

- (void)setChatMessageModel:(TaoziChatMessageBaseViewController *)taoziMessageCtl
{
    
}


- (void)asyncFavorite:(NSString *)poiId poiType:(NSString *)type isFavorite:(BOOL)isFavorite completion:(void (^)(BOOL))completion
{
    AccountManager *accountManager = [AccountManager shareAccountManager];
    if (!accountManager.isLogin) {
        [self showHint:@"请先登录"];
        [self performSelector:@selector(login) withObject:nil afterDelay:0.3];
        return;
    }
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    AppUtils *utils = [[AppUtils alloc] init];
    [manager.requestSerializer setValue:utils.appVersion forHTTPHeaderField:@"Version"];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"iOS %@",utils.systemVersion] forHTTPHeaderField:@"Platform"];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"%@", accountManager.account.userId] forHTTPHeaderField:@"UserId"];
    
    if (isFavorite) {
        [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
        [manager.requestSerializer setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
        NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
        [params setObject:poiId forKey:@"itemId"];
        [params setObject:type forKey:@"type"];
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        [manager POST:API_FAVORITE parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSLog(@"%@", responseObject);
            NSInteger code = [[responseObject objectForKey:@"code"] integerValue];
            if (code == 0) {
                [self showHint:@"已收藏"];
                [[NSNotificationCenter defaultCenter] postNotificationName:updateFavoriteListNoti object:nil];
                completion(YES);
            } else {
                completion(NO);
                if (code == 401) {
                    [self showHint:@"已收藏"];
                } else {
//                    [self showHint:@"请求也是失败了"];
                }
            }
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            completion(NO);
            [self showHint:@"呃～好像没找到网络"];
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        }];
        
    } else {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        NSString *urlStr = [NSString stringWithFormat:@"%@/%@", API_UNFAVORITE, poiId];
        [manager DELETE:urlStr parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSLog(@"%@", responseObject);
            NSInteger code = [[responseObject objectForKey:@"code"] integerValue];
            if (code == 0) {
//                [self showHint:@"收藏取消"];
                [[NSNotificationCenter defaultCenter] postNotificationName:updateFavoriteListNoti object:nil];
                completion(YES);
            } else {
                completion(NO);
//                [self showHint:@"请求也是失败了"];
            }
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            completion(NO);
            NSLog(@"%@", error);
            [self showHint:@"呃～好像没找到网络"];
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        }];
    }
}

- (void)login
{
    LoginViewController *loginViewController = [[LoginViewController alloc] init];
    UINavigationController *nctl = [[UINavigationController alloc] initWithRootViewController:loginViewController];
    loginViewController.isPushed = NO;
    [self presentViewController:nctl animated:YES completion:nil];
}


@end

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


@property (nonatomic, strong) UIButton *rightItemBtn;



@end

@implementation PoiDetailSuperViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.automaticallyAdjustsScrollViewInsets = NO;
    _rightItemBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    [_rightItemBtn setImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
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


- (void)asyncFavorite:(NSString *)poiId poiType:(NSString *)type isFavorite:(BOOL)isFavorite completion:(void (^)(BOOL))completion
{
    AccountManager *accountManager = [AccountManager shareAccountManager];
    if (!accountManager.isLogin) {
        [SVProgressHUD showErrorWithStatus:@"请登录"];
        [self performSelector:@selector(login) withObject:nil afterDelay:0.3];
        return;
    }
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [manager.requestSerializer setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"%@", accountManager.account.userId] forHTTPHeaderField:@"UserId"];

    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:poiId forKey:@"itemId"];
    
    if (isFavorite) {
        [params setObject:type forKey:@"type"];
        
        [manager PUT:API_FAVORITE parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSLog(@"%@", responseObject);
            NSInteger code = [[responseObject objectForKey:@"code"] integerValue];
            if (code == 0) {
                
                [self showHint:@"收藏成功"];
                completion(YES);
            } else {
                completion(NO);
                [self showHint:@"收藏失败"];
               
            }
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            completion(NO);
            [self showHint:@"收藏失败"];
        }];
        
    } else {
        
        [manager DELETE:API_UNFAVORITE parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSLog(@"%@", responseObject);
            NSInteger code = [[responseObject objectForKey:@"code"] integerValue];
            if (code == 0) {
                [self showHint:@"取消收藏成功"];
                completion(YES);
            } else {
                completion(NO);
               
                [self showHint:@"取消收藏失败"];
                
            }
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            completion(NO);
            [self showHint:@"取消收藏失败"];

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

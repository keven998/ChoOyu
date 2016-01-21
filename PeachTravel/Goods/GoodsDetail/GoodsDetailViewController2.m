//
//  GoodsDetailViewController.m
//  PeachTravel
//
//  Created by liangpengshuai on 10/26/15.
//  Copyright © 2015 com.aizou.www. All rights reserved.
//

#import "GoodsDetailViewController2.h"
#import "GoodsDetailViewController.h"
#import "RCTRootView.h"
#import "RCTBridge.h"
#import "RCTEventDispatcher.h"
#import "RCTBridgeModule.h"
#import "StoreDetailViewController.h"
#import "ShareActivity.h"
#import "UMSocial.h"
#import "MakeOrderViewController.h"
#import "GoodsManager.h"
#import "ChatViewController.h"
#import "PeachTravel-swift.h"
#import "ChatGroupSettingViewController.h"
#import "ChatSettingViewController.h"
#import "REFrostedViewController.h"
#import "LoginViewController.h"
#import "ChatRecoredListTableViewController.h"
#import "TaoziChatMessageBaseViewController.h"
#import "GoodsDetailSoldOutView.h"
#import "SuperWebViewController.h"

@interface GoodsDetailViewController2 ()<RCTBridgeModule, ActivityDelegate, CreateConversationDelegate, TaoziMessageSendDelegate> {
    RCTBridge *bridge;
    RCTRootView *rootView;
}

@property (nonatomic, strong) GoodsDetailModel *goodsDetail;
@property (nonatomic, strong) ChatRecoredListTableViewController *chatRecordListCtl;


@end

@implementation GoodsDetailViewController2

RCT_EXPORT_MODULE();

- (instancetype)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    if (_isSnapshot) {
        self.navigationItem.title = @"交易快照";
    } else {
        self.navigationItem.title = @"商品详情";
    }
    self.automaticallyAdjustsScrollViewInsets = NO;

    NSURL *jsCodeLocation = [[NSBundle mainBundle] URLForResource:@"main" withExtension:@"jsbundle"];
//    NSURL *jsCodeLocation = [NSURL URLWithString:@"http://192.168.1.47:8081/index.ios.bundle?platform=ios&dev=true"];

    bridge = [[RCTBridge alloc] initWithBundleURL:jsCodeLocation
                                              moduleProvider:nil
                                               launchOptions:nil];
    
    rootView = [[RCTRootView alloc] initWithBridge:bridge moduleName:@"GoodsDetailClass" initialProperties:nil];
    
    rootView.frame = CGRectMake(0, 64, kWindowWidth, kWindowHeight-64);

    if (_isSnapshot) {
        [GoodsManager asyncLoadGoodsDetailWithGoodsId:_goodsId version:_goodsVersion completionBlock:^(BOOL isSuccess, NSDictionary *goodsDetailJson, GoodsDetailModel *goodsDetail) {
            if (isSuccess) {
                _goodsDetail = goodsDetail;
                if (_goodsDetail) {
                    [self.view addSubview:rootView];
                    [bridge.eventDispatcher sendAppEventWithName:@"GoodsDetailLoadOverEvent" body:@{@"goodsDetailJson": goodsDetailJson, @"isSnapshot": [NSNumber numberWithBool:_isSnapshot]}];
                    
                } else {
                    rootView = nil;
                    GoodsDetailSoldOutView *view = [[GoodsDetailSoldOutView alloc] initWithFrame:CGRectMake(0, 100, kWindowWidth, kWindowHeight-100)];
                    [self.view addSubview:view];
                }
                
            } else {
                [SVProgressHUD showHint:HTTP_FAILED_HINT];
            }
        }];
    } else {
        [GoodsManager asyncLoadGoodsDetailWithGoodsId:_goodsId completionBlock:^(BOOL isSuccess, NSDictionary *goodsDetailJson, GoodsDetailModel *goodsDetail) {
            if (isSuccess) {
                _goodsDetail = goodsDetail;
                if (_goodsDetail) {
                    [self.view addSubview:rootView];
                    [bridge.eventDispatcher sendAppEventWithName:@"GoodsDetailLoadOverEvent" body:@{@"goodsDetailJson": goodsDetailJson, @"isSnapshot": [NSNumber numberWithBool:_isSnapshot]}];
                    if (!_isSnapshot) {
                        [self setupNaviBar];
                    }
                } else {
                    rootView = nil;
                    GoodsDetailSoldOutView *view = [[GoodsDetailSoldOutView alloc] initWithFrame:CGRectMake(0, 100, kWindowWidth, kWindowHeight-100)];
                    [self.view addSubview:view];
                }
                
            } else {
                [SVProgressHUD showHint:HTTP_FAILED_HINT];
            }
        }];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear: animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(storeDetail) name:@"RNGotoStoreDetailNoti" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(makeOrderAction) name:@"RNMakeOrderNoti" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(chatWithBusinessAction) name:@"RNChatWithBusinessNoti" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moreTrafficInfoAction:) name:@"RNMoreTrafficInfoNoti" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moreGoodsInfoAction:) name:@"RNMoreGoodsInfoNoti" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moreBuyInfoAction:) name:@"RNMoreBuyInfoNoti" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moreBookQuitInfoAction:) name:@"RNMoreBookQuitInfoNoti" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkLatestGoodsDetailAction) name:@"RNCheckLatestGoodsNoti" object:nil];


}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)dealloc
{
}

- (void)setupNaviBar
{
    UIButton *shareBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, 40)];
    [shareBtn setImage:[UIImage imageNamed:@"icon_share_white"] forState:UIControlStateNormal];
    [shareBtn addTarget:self action:@selector(share2Frend) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *favoriteBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, 40)];
    [favoriteBtn setImage:[UIImage imageNamed:@"icon_favorite_white"] forState:UIControlStateNormal];
    [favoriteBtn setImage:[UIImage imageNamed:@"icon_favorite_selected"] forState:UIControlStateSelected];
    [favoriteBtn addTarget:self action:@selector(favorite:) forControlEvents:UIControlEventTouchUpInside];
    favoriteBtn.selected = _goodsDetail.isFavorite;
    
    self.navigationItem.rightBarButtonItems = @[[[UIBarButtonItem alloc] initWithCustomView:shareBtn], [[UIBarButtonItem alloc] initWithCustomView:favoriteBtn]];
}

- (void)storeDetail
{
    dispatch_async(dispatch_get_main_queue(), ^{
        StoreDetailViewController *ctl = [[StoreDetailViewController alloc] init];
        ctl.storeId = _goodsDetail.store.storeId;
        ctl.storeName = _goodsDetail.store.storeName;
        [self.navigationController pushViewController:ctl animated:YES];
    });
}

- (void)moreTrafficInfoAction:(NSNotification *)noti
{
    dispatch_async(dispatch_get_main_queue(), ^{
        SuperWebViewController *ctl = [[SuperWebViewController alloc] init];
        ctl.urlStr = [noti.userInfo objectForKey:@"url"];
        ctl.titleStr = @"交通提示";
        [self.navigationController pushViewController:ctl animated:YES];
    });
}

- (void)moreGoodsInfoAction:(NSNotification *)noti
{
    dispatch_async(dispatch_get_main_queue(), ^{

        SuperWebViewController *ctl = [[SuperWebViewController alloc] init];
        ctl.urlStr = [noti.userInfo objectForKey:@"url"];
        ctl.titleStr = @"商品详情";
        [self.navigationController pushViewController:ctl animated:YES];
    });
}

- (void)moreBuyInfoAction:(NSNotification *)noti
{
    dispatch_async(dispatch_get_main_queue(), ^{

        SuperWebViewController *ctl = [[SuperWebViewController alloc] init];
        ctl.urlStr = [noti.userInfo objectForKey:@"url"];
        ctl.titleStr = @"购买须知";
        [self.navigationController pushViewController:ctl animated:YES];
    });
}

- (void)moreBookQuitInfoAction:(NSNotification *)noti
{
    dispatch_async(dispatch_get_main_queue(), ^{

        SuperWebViewController *ctl = [[SuperWebViewController alloc] init];
        ctl.urlStr = [noti.userInfo objectForKey:@"url"];
        ctl.titleStr = @"预订及退订";
        [self.navigationController pushViewController:ctl animated:YES];
    });
}


- (void)checkLatestGoodsDetailAction
{
    dispatch_async(dispatch_get_main_queue(), ^{
        GoodsDetailViewController *ctl = [[GoodsDetailViewController alloc] init];
        ctl.goodsId = _goodsId;
        [self.navigationController pushViewController:ctl animated:YES];
    });
}

- (void)chatWithBusinessAction
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if (![[AccountManager shareAccountManager] isLogin]) {
            [SVProgressHUD showHint:@"请先登录"];
            [self performSelector:@selector(login) withObject:nil afterDelay:0.3];
            
        } else {
            IMClientManager *clientManager = [IMClientManager shareInstance];
            ChatConversation *conversation = [clientManager.conversationManager getConversationWithChatterId:_goodsDetail.store.storeId chatType:IMChatTypeIMChatSingleType];
            ChatViewController *chatController = [[ChatViewController alloc] initWithConversation:conversation];
            if (conversation.chatterName) {
                conversation.chatterName = _goodsDetail.store.business.nickName;
            }
            GoodsLinkMessage *message = [[GoodsLinkMessage alloc] init];
            message.senderId = [AccountManager shareAccountManager].account.userId;
            message.senderName = [AccountManager shareAccountManager].account.nickName;
            message.chatterId = conversation.chatterId;
            message.chatType = conversation.chatType;
            message.goodsName = _goodsDetail.goodsName;
            message.goodsId = _goodsDetail.goodsId;
            message.price = _goodsDetail.currentPrice;
            message.imageUrl = _goodsDetail.coverImage.imageUrl;
            message.createTime = [[NSDate date] timeIntervalSince1970];
            chatController.goodsLinkMessageSnapshot = message;
            
            chatController.chatterName = conversation.chatterName;
            UIViewController *menuViewController = nil;
            if (conversation.chatType == IMChatTypeIMChatGroupType || conversation.chatType == IMChatTypeIMChatDiscussionGroupType) {
                menuViewController = [[ChatGroupSettingViewController alloc] init];
                ((ChatGroupSettingViewController *)menuViewController).groupId = conversation.chatterId;
                ((ChatGroupSettingViewController *)menuViewController).conversation = conversation;
                
            } else {
                menuViewController = [[ChatSettingViewController alloc] init];
                ((ChatSettingViewController *)menuViewController).currentConversation= conversation;
                ((ChatSettingViewController *)menuViewController).chatterId = conversation.chatterId;
            }
            
            REFrostedViewController *frostedViewController = [[REFrostedViewController alloc] initWithContentViewController:chatController menuViewController:menuViewController];
            
            if (conversation.chatType == IMChatTypeIMChatGroupType || conversation.chatType == IMChatTypeIMChatDiscussionGroupType) {
                ((ChatGroupSettingViewController *)menuViewController).containerCtl = frostedViewController;
            } else {
                ((ChatSettingViewController *)menuViewController).containerCtl = frostedViewController;
            }
            frostedViewController.hidesBottomBarWhenPushed = YES;
            frostedViewController.direction = REFrostedViewControllerDirectionRight;
            frostedViewController.liveBlurBackgroundStyle = REFrostedViewControllerLiveBackgroundStyleLight;
            frostedViewController.liveBlur = YES;
            frostedViewController.limitMenuViewSize = YES;
            chatController.backBlock = ^{
                [frostedViewController.navigationController popViewControllerAnimated:YES];
            };
            
            [self.navigationController pushViewController:frostedViewController animated:YES];
        }
    });
}


- (void)login
{
    LoginViewController *loginViewController = [[LoginViewController alloc] init];
    TZNavigationViewController *nctl = [[TZNavigationViewController alloc] initWithRootViewController:loginViewController];
    loginViewController.isPushed = NO;
    [self presentViewController:nctl animated:YES completion:nil];
}

- (void)makeOrderAction
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (![[AccountManager shareAccountManager] isLogin]) {
            [SVProgressHUD showHint:@"请先登录"];
            [self performSelector:@selector(login) withObject:nil afterDelay:0.3];
        } else {
            MakeOrderViewController *ctl = [[MakeOrderViewController alloc] init];
            ctl.goodsModel = _goodsDetail;
            [self.navigationController pushViewController:ctl animated:YES];
        }
    });
}

- (void)share2Frend
{
//    NSArray *shareButtonimageArray = @[@"ic_sns_lxp.png", @"ic_sns_pengyouquan.png",  @"ic_sns_weixin.png", @"ic_sns_qq.png", @"ic_sns_sina.png", @"ic_sns_douban.png"];
    NSArray *shareButtonimageArray = @[@"ic_sns_lxp.png", @"ic_sns_pengyouquan.png",  @"ic_sns_weixin.png", @"ic_sns_qq.png"];

    NSArray *shareButtonTitleArray = @[@"旅行派好友", @"朋友圈", @"微信朋友", @"QQ"];
    ShareActivity *shareActivity = [[ShareActivity alloc] initWithTitle:@"转发至" delegate:self cancelButtonTitle:@"取消" ShareButtonTitles:shareButtonTitleArray withShareButtonImagesName:shareButtonimageArray];
    [shareActivity showInView:self.navigationController.view];
}

- (void)favorite:(UIButton *)button
{
    if (![[AccountManager shareAccountManager] isLogin]) {
        [SVProgressHUD showHint:@"请先登录"];
        [self performSelector:@selector(login) withObject:nil afterDelay:0.3];
    } else {
        [GoodsManager asyncFavoriteGoodsWithGoodsObjectId:_goodsDetail.objectId isFavorite:!_goodsDetail.isFavorite completionBlock:^(BOOL isSuccess) {
            if (isSuccess) {
                _goodsDetail.isFavorite = !_goodsDetail.isFavorite;
                button.selected = _goodsDetail.isFavorite;
            }
        }];
    }
}

RCT_EXPORT_METHOD(makePhone:(NSString *)tel){
    NSString *number = tel;// 此处读入电话号码
    NSString *num = [[NSString alloc] initWithFormat:@"tel://%@",number];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:num]];//打电话

}

RCT_EXPORT_METHOD(gotoStoreDetail){
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"RNGotoStoreDetailNoti" object:nil];
}

RCT_EXPORT_METHOD(makeOrder){
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"RNMakeOrderNoti" object:nil];
}

RCT_EXPORT_METHOD(chatWithBusiness){
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"RNChatWithBusinessNoti" object:nil];
}

RCT_EXPORT_METHOD(moreTrafficInfo:(NSString *)webUrl){
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [dic safeSetObject:webUrl forKey:@"url"];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"RNMoreTrafficInfoNoti" object:nil userInfo:dic];
}

RCT_EXPORT_METHOD(moreGoodsInfo:(NSString *)webUrl){
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [dic safeSetObject:webUrl forKey:@"url"];

    [[NSNotificationCenter defaultCenter] postNotificationName:@"RNMoreGoodsInfoNoti" object:nil userInfo:dic];
}

RCT_EXPORT_METHOD(moreBuyInfo:(NSString *)webUrl){
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [dic safeSetObject:webUrl forKey:@"url"];

    [[NSNotificationCenter defaultCenter] postNotificationName:@"RNMoreBuyInfoNoti" object:nil userInfo:dic];
}

RCT_EXPORT_METHOD(moreBookQuitInfo:(NSString *)webUrl){
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [dic safeSetObject:webUrl forKey:@"url"];

    [[NSNotificationCenter defaultCenter] postNotificationName:@"RNMoreBookQuitInfoNoti" object:nil userInfo:dic];
}

RCT_EXPORT_METHOD(checkLatestGoodsDetail){
    [[NSNotificationCenter defaultCenter] postNotificationName:@"RNCheckLatestGoodsNoti" object:nil userInfo:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - AvtivityDelegate

- (void)didClickOnImageIndex:(NSInteger)imageIndex
{
    NSString *url = _goodsDetail.shareUrl;
    NSString *shareTitle = @"旅行派特色体验";
    NSString *shareContentWithoutUrl = [NSString stringWithFormat:@"%@元起 | %@", _goodsDetail.formatCurrentPrice, _goodsDetail.goodsName];
    NSString *shareContentWithUrl = [NSString stringWithFormat:@"%@元起 | %@ %@", _goodsDetail.formatCurrentPrice, _goodsDetail.goodsName, url];
    NSString *imageUrl = _goodsDetail.coverImage.imageUrl;
    UMSocialUrlResource *resource = [[UMSocialUrlResource alloc] initWithSnsResourceType:UMSocialUrlResourceTypeImage url:imageUrl];
    
    [UMSocialConfig setFinishToastIsHidden:NO position:UMSocialiToastPositionCenter];
    switch (imageIndex) {
            
        case 0: {
            [self shareToTalk];
            
        }
            break;
            
        case 1: {
            [UMSocialData defaultData].extConfig.wechatTimelineData.url = url;
            [UMSocialData defaultData].extConfig.wechatTimelineData.title = shareTitle;

            [[UMSocialDataService defaultDataService]  postSNSWithTypes:@[UMShareToWechatTimeline] content:shareContentWithoutUrl image:nil location:nil urlResource:resource presentedController:self completion:^(UMSocialResponseEntity *response){
                if (response.responseCode == UMSResponseCodeSuccess) {
                    NSLog(@"分享成功！");
                }
            }];
            
        }
            break;
            
        case 2: {
            [UMSocialData defaultData].extConfig.wechatSessionData.url = url;
            [UMSocialData defaultData].extConfig.wechatSessionData.title = shareTitle;
            [[UMSocialDataService defaultDataService]  postSNSWithTypes:@[UMShareToWechatSession] content:shareContentWithoutUrl image:nil location:nil urlResource:resource presentedController:nil completion:^(UMSocialResponseEntity *response){
                if (response.responseCode == UMSResponseCodeSuccess) {
                    NSLog(@"分享成功！");
                }
            }];
        }
            break;
            
        case 3: {
            [UMSocialData defaultData].extConfig.qqData.url = url;
            [UMSocialData defaultData].extConfig.qqData.title = shareTitle;

            [[UMSocialDataService defaultDataService]  postSNSWithTypes:@[UMShareToQQ] content:shareContentWithoutUrl image:nil location:nil urlResource:resource presentedController:self completion:^(UMSocialResponseEntity *response){
                if (response.responseCode == UMSResponseCodeSuccess) {
                    NSLog(@"分享成功！");
                }
            }];
        }
            break;
            
        case 4:
            [[UMSocialControllerService defaultControllerService] setShareText:shareContentWithUrl shareImage:nil socialUIDelegate:nil];
            
            [UMSocialSnsPlatformManager getSocialPlatformWithName:UMShareToSina].snsClickHandler(self,[UMSocialControllerService defaultControllerService],YES);
            
            break;
            
        case 5:
            [[UMSocialControllerService defaultControllerService] setShareText:shareContentWithUrl shareImage:nil  socialUIDelegate:nil];
            
            [UMSocialSnsPlatformManager getSocialPlatformWithName:UMShareToDouban].snsClickHandler(self,[UMSocialControllerService defaultControllerService],YES);
            
            break;
            
        default:
            break;
    }
}

- (void)shareToTalk {
    if (![[AccountManager shareAccountManager] isLogin]) {
        LoginViewController *loginViewController = [[LoginViewController alloc] initWithCompletion:^(BOOL completed) {
            _chatRecordListCtl = [[ChatRecoredListTableViewController alloc] init];
            _chatRecordListCtl.delegate = self;
            UINavigationController *nCtl = [[UINavigationController alloc] initWithRootViewController:_chatRecordListCtl];
            [self presentViewController:nCtl animated:YES completion:nil];
        }];
        UINavigationController *nctl = [[UINavigationController alloc] initWithRootViewController:loginViewController];
        loginViewController.isPushed = NO;
        [self presentViewController:nctl animated:YES completion:nil];
    } else {
        _chatRecordListCtl = [[ChatRecoredListTableViewController alloc] init];
        _chatRecordListCtl.delegate = self;
        UINavigationController *nCtl = [[UINavigationController alloc] initWithRootViewController:_chatRecordListCtl];
        [self presentViewController:nCtl animated:YES completion:nil];
    }
}

#pragma mark - CreateConversationDelegate

- (void)createConversationSuccessWithChatter:(NSInteger)chatterId chatType:(IMChatType)chatType chatTitle:(NSString *)chatTitle
{
    TaoziChatMessageBaseViewController *taoziMessageCtl = [[TaoziChatMessageBaseViewController alloc] init];
    [self setChatMessageModel:taoziMessageCtl];
    taoziMessageCtl.delegate = self;
    taoziMessageCtl.chatTitle = chatTitle;
    taoziMessageCtl.chatterId = chatterId;
    taoziMessageCtl.chatType = chatType;
    
    [self.chatRecordListCtl dismissViewControllerAnimated:YES completion:^{
        [self presentPopupViewController:taoziMessageCtl atHeight:170.0 animated:YES completion:nil];
    }];
}

- (void)setChatMessageModel:(TaoziChatMessageBaseViewController *)taoziMessageCtl
{
    taoziMessageCtl.messageId = [NSString stringWithFormat:@"%ld", self.goodsDetail.goodsId];
    taoziMessageCtl.messageImage = self.goodsDetail.coverImage.imageUrl;
    taoziMessageCtl.messageName = self.goodsDetail.goodsName;
    taoziMessageCtl.messagePrice = [NSString stringWithFormat:@"%lf", self.goodsDetail.currentPrice];
    taoziMessageCtl.messageType = IMMessageTypeGoodsMessageType;
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


@end

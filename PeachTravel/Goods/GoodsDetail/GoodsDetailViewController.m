//
//  GoodsDetailViewController.m
//  PeachTravel
//
//  Created by liangpengshuai on 10/26/15.
//  Copyright © 2015 com.aizou.www. All rights reserved.
//

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

@interface GoodsDetailViewController ()<RCTBridgeModule, ActivityDelegate, CreateConversationDelegate, TaoziMessageSendDelegate> {
    RCTBridge *bridge;
    RCTRootView *rootView;
}

@property (nonatomic, strong) GoodsDetailModel *goodsDetail;
@property (nonatomic, strong) ChatRecoredListTableViewController *chatRecordListCtl;

@end

@implementation GoodsDetailViewController

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
    self.navigationItem.title = @"商品详情";
    self.automaticallyAdjustsScrollViewInsets = NO;

    NSURL *jsCodeLocation = [[NSBundle mainBundle] URLForResource:@"main" withExtension:@"jsbundle"];
//    NSURL *jsCodeLocation = [NSURL URLWithString:@"http://192.168.1.47:8081/index.ios.bundle?platform=ios&dev=true"];
//    NSURL *jsCodeLocation = [NSURL URLWithString:@"http://localhost:8081/index.ios.bundle?platform=ios&dev=true"];

    bridge = [[RCTBridge alloc] initWithBundleURL:jsCodeLocation
                                              moduleProvider:nil
                                               launchOptions:nil];
    
    rootView = [[RCTRootView alloc] initWithBridge:bridge moduleName:@"GoodsDetailClass" initialProperties:nil];
    
    rootView.frame = CGRectMake(0, 64, kWindowWidth, kWindowHeight-64);

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(storeDetail) name:@"gotoStoreDetailNoti" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(makeOrderAction) name:@"makeOrderNoti" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(chatWithBusinessAction) name:@"chatWithBusinessNoti" object:nil];


    UIButton *shareBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, 40)];
    [shareBtn setImage:[UIImage imageNamed:@"icon_share_white"] forState:UIControlStateNormal];
    [shareBtn addTarget:self action:@selector(share2Frend) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *favoriteBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, 40)];
    [favoriteBtn setImage:[UIImage imageNamed:@"icon_favorite_white"] forState:UIControlStateNormal];
    [favoriteBtn addTarget:self action:@selector(favorite) forControlEvents:UIControlEventTouchUpInside];

    self.navigationItem.rightBarButtonItems = @[[[UIBarButtonItem alloc] initWithCustomView:favoriteBtn], [[UIBarButtonItem alloc] initWithCustomView:shareBtn]];

    [GoodsManager asyncLoadGoodsDetailWithGoodsId:_goodsId completionBlock:^(BOOL isSuccess, NSDictionary *goodsDetailJson, GoodsDetailModel *goodsDetail) {
        if (isSuccess) {
            _goodsDetail = goodsDetail;
            [self.view addSubview:rootView];
            [bridge.eventDispatcher sendAppEventWithName:@"GoodsDetailLoadOverEvent" body:@{@"goodsDetailJson": goodsDetailJson}];
        } else {
            [SVProgressHUD showHint:HTTP_FAILED_HINT];
        }
    }];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear: animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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

- (void)chatWithBusinessAction
{
    dispatch_async(dispatch_get_main_queue(), ^{
        IMClientManager *clientManager = [IMClientManager shareInstance];
        ChatConversation *conversation = [clientManager.conversationManager getExistConversationInConversationList:_goodsDetail.store.storeId];
        ChatViewController *chatController = [[ChatViewController alloc] initWithConversation:conversation];
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
    NSArray *shareButtonimageArray = @[@"ic_sns_qzone.png", @"ic_sns_pengyouquan.png",  @"ic_sns_weixin.png", @"ic_sns_qq.png", @"ic_sns_sina.png", @"ic_sns_douban.png"];
    NSArray *shareButtonTitleArray = @[@"旺旺", @"朋友圈", @"微信朋友", @"QQ", @"新浪微博", @"豆瓣"];
    ShareActivity *shareActivity = [[ShareActivity alloc] initWithTitle:@"转发至" delegate:self cancelButtonTitle:@"取消" ShareButtonTitles:shareButtonTitleArray withShareButtonImagesName:shareButtonimageArray];
    [shareActivity showInView:self.navigationController.view];
}

- (void)favorite
{
    
}

RCT_EXPORT_METHOD(makePhone:(NSString *)tel){
    NSString *number = tel;// 此处读入电话号码
    NSString *num = [[NSString alloc] initWithFormat:@"tel://%@",number];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:num]];//打电话

}

RCT_EXPORT_METHOD(gotoStoreDetail){
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"gotoStoreDetailNoti" object:nil];
}

RCT_EXPORT_METHOD(makeOrder){
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"makeOrderNoti" object:nil];
}

RCT_EXPORT_METHOD(chatWithBusiness){
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"chatWithBusinessNoti" object:nil];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - AvtivityDelegate

- (void)didClickOnImageIndex:(NSInteger)imageIndex
{
    NSString *url = @"http://7af4ik.com1.z0.glb.clouddn.com/react/index.html";
    NSString *shareContentWithoutUrl = [NSString stringWithFormat:@"这个商品来自旅行派～"];
    NSString *shareContentWithUrl = [NSString stringWithFormat:@"这个商品来自旅行派 %@", url];
    NSString *imageUrl = @"http://images.taozilvxing.com/28c2d1ef35c12100e99fecddb63c436a?imageView2/2/w/300";
    UMSocialUrlResource *resource = [[UMSocialUrlResource alloc] initWithSnsResourceType:UMSocialUrlResourceTypeImage url:imageUrl];
    
    [UMSocialConfig setFinishToastIsHidden:NO position:UMSocialiToastPositionCenter];
    switch (imageIndex) {
            
        case 0: {
            [self shareToTalk];
            
        }
            break;
            
        case 1: {
            [UMSocialData defaultData].extConfig.wechatTimelineData.url = url;
            [[UMSocialDataService defaultDataService]  postSNSWithTypes:@[UMShareToWechatTimeline] content:shareContentWithoutUrl image:nil location:nil urlResource:resource presentedController:self completion:^(UMSocialResponseEntity *response){
                if (response.responseCode == UMSResponseCodeSuccess) {
                    NSLog(@"分享成功！");
                }
            }];
            
        }
            break;
            
        case 2: {
            [UMSocialData defaultData].extConfig.wechatSessionData.url = url;
            [[UMSocialDataService defaultDataService]  postSNSWithTypes:@[UMShareToWechatSession] content:shareContentWithoutUrl image:nil location:nil urlResource:resource presentedController:nil completion:^(UMSocialResponseEntity *response){
                if (response.responseCode == UMSResponseCodeSuccess) {
                    NSLog(@"分享成功！");
                }
            }];
        }
            break;
            
        case 3: {
            [UMSocialData defaultData].extConfig.qqData.url = url;
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

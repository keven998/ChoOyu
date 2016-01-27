//
//  GoodsDetailViewController.m
//  PeachTravel
//
//  Created by liangpengshuai on 1/20/16.
//  Copyright © 2016 com.aizou.www. All rights reserved.
//

#import "GoodsDetailViewController.h"
#import "GoodsDetailHeaderView.h"
#import "GoodsManager.h"
#import "GoodsDetailSoldOutView.h"
#import "GoodsDetailSellerQualificationsTableViewCell.h"
#import "GoodsDetailDescTableViewCell.h"
#import "GoodsDetailCommonSectionHeaderView.h"
#import "GoodsDetailCommonSectionFooterView.h"
#import "GoodsDetailBookTipsTableViewCell.h"
#import "GoodsDetailBookQuitTableViewCell.h"
#import "GoodsDetailTrafficTableViewCell.h"
#import "GoodsDetailStoreInfoTableViewCell.h"
#import "GoodsDetailSnapshotTableViewCell.h"
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

@interface GoodsDetailViewController () <UITableViewDataSource, UITableViewDelegate, ActivityDelegate, CreateConversationDelegate, TaoziMessageSendDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) GoodsDetailModel *goodsDetail;
@property (nonatomic, strong) ChatRecoredListTableViewController *chatRecordListCtl;

@end

@implementation GoodsDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    if (_isSnapshot) {
        self.navigationItem.title = @"交易快照";
    } else {
        self.navigationItem.title = @"商品详情";
    }
    self.automaticallyAdjustsScrollViewInsets = NO;
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.separatorStyle = UITableViewCellSelectionStyleNone;
    [_tableView registerNib:[UINib nibWithNibName:@"GoodsDetailSellerQualificationsTableViewCell" bundle:nil] forCellReuseIdentifier:@"goodsDetailSellerQualificationsTableViewCell"];
    [_tableView registerNib:[UINib nibWithNibName:@"GoodsDetailDescTableViewCell" bundle:nil] forCellReuseIdentifier:@"goodsDetailDescTableViewCell"];
    [_tableView registerNib:[UINib nibWithNibName:@"GoodsDetailBookTipsTableViewCell" bundle:nil] forCellReuseIdentifier:@"goodsDetailBookTipsTableViewCell"];
    [_tableView registerNib:[UINib nibWithNibName:@"GoodsDetailBookQuitTableViewCell" bundle:nil] forCellReuseIdentifier:@"goodsDetailBookQuitTableViewCell"];
    [_tableView registerNib:[UINib nibWithNibName:@"GoodsDetailTrafficTableViewCell" bundle:nil] forCellReuseIdentifier:@"goodsDetailTrafficTableViewCell"];
    [_tableView registerNib:[UINib nibWithNibName:@"GoodsDetailStoreInfoTableViewCell" bundle:nil] forCellReuseIdentifier:@"goodsDetailStoreInfoTableViewCell"];
    [_tableView registerNib:[UINib nibWithNibName:@"GoodsDetailSnapshotTableViewCell" bundle:nil] forCellReuseIdentifier:@"goodsDetailSnapshotTableViewCell"];

    _tableView.backgroundColor = APP_PAGE_COLOR;
    if (_isSnapshot) {
        [GoodsManager asyncLoadGoodsDetailWithGoodsId:_goodsId version:_goodsVersion completionBlock:^(BOOL isSuccess, NSDictionary *goodsDetailJson, GoodsDetailModel *goodsDetail) {
            if (isSuccess) {
                _goodsDetail = goodsDetail;
                if (_goodsDetail) {
                    [self renderTableView];
                } else {
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
                    [self renderTableView];
                    [self setupNaviBar];

                } else {
                    GoodsDetailSoldOutView *view = [[GoodsDetailSoldOutView alloc] initWithFrame:CGRectMake(0, 100, kWindowWidth, kWindowHeight-100)];
                    [self.view addSubview:view];
                }
                
            } else {
                [SVProgressHUD showHint:HTTP_FAILED_HINT];
            }
        }];
    }
    _tableView.hidden = YES;
}

- (void)renderTableView
{
    _tableView.hidden = NO;
    [_tableView reloadData];
    GoodsDetailHeaderView *headerView = [[GoodsDetailHeaderView alloc] initWithFrame:CGRectMake(0, 64, kWindowWidth, [GoodsDetailHeaderView heightWithGoodsmodel:_goodsDetail])];
    headerView.goodsDetail = _goodsDetail;
    UIView *tempView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kWindowWidth, [GoodsDetailHeaderView heightWithGoodsmodel:_goodsDetail]+64)];
    [tempView addSubview:headerView];
    self.tableView.tableHeaderView = tempView;
    [self setupToolbar];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _tableView.bounds.size.width, 60)];
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

- (void)setupToolbar
{
    UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0, kWindowHeight-60, kWindowWidth, 60)];
    bgView.backgroundColor = [UIColor whiteColor];
    CGFloat width = bgView.bounds.size.width;
    
    UIButton *chatWithBusinessBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, width/3, 60)];
    [chatWithBusinessBtn addTarget:self action:@selector(chatWithBusinessAction) forControlEvents:UIControlEventTouchUpInside];
    [chatWithBusinessBtn setTitle:@"联系商家" forState:UIControlStateNormal];
    [chatWithBusinessBtn setTitleColor:COLOR_TEXT_I forState:UIControlStateNormal];
    [chatWithBusinessBtn setImage:[UIImage imageNamed:@"icon_goodsDetail_toolbar_chat"] forState:UIControlStateNormal];
    chatWithBusinessBtn.titleLabel.font = [UIFont systemFontOfSize:16.0];
    chatWithBusinessBtn.titleEdgeInsets = UIEdgeInsetsMake(0, 5, 0, 0);
    chatWithBusinessBtn.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 5);
    [bgView addSubview:chatWithBusinessBtn];
    
    UIView *spaceView = [[UIView alloc] initWithFrame:CGRectMake(width/3-0.5, 11, 0.5, 38)];
    spaceView.backgroundColor = COLOR_LINE;
    [bgView addSubview:spaceView];
    
    UIButton *gotoStoreBtn = [[UIButton alloc] initWithFrame:CGRectMake(width/3, 0, width/3, 60)];
    [gotoStoreBtn addTarget:self action:@selector(storeDetailAction) forControlEvents:UIControlEventTouchUpInside];
    [gotoStoreBtn setTitle:@"进入店铺" forState:UIControlStateNormal];
    [gotoStoreBtn setTitleColor:COLOR_TEXT_I forState:UIControlStateNormal];
    [gotoStoreBtn setImage:[UIImage imageNamed:@"icon_goodsDetail_toolbar_store"] forState:UIControlStateNormal];
    gotoStoreBtn.titleLabel.font = [UIFont systemFontOfSize:16.0];
    gotoStoreBtn.titleEdgeInsets = UIEdgeInsetsMake(0, 5, 0, 0);
    gotoStoreBtn.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 5);
    [bgView addSubview:gotoStoreBtn];

    UIButton *bookBtn = [[UIButton alloc] initWithFrame:CGRectMake(width/3*2, 0, width/3, 60)];
    [bookBtn addTarget:self action:@selector(makeOrderAction) forControlEvents:UIControlEventTouchUpInside];
    [bookBtn setTitle:@"立即预订" forState:UIControlStateNormal];
    [bookBtn setBackgroundImage:[ConvertMethods createImageWithColor:UIColorFromRGB(0xFB4F28)] forState:UIControlStateNormal];
    [bookBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    bookBtn.titleLabel.font = [UIFont systemFontOfSize:18.0];
    [bgView addSubview:bookBtn];

    [self.view addSubview:bgView];
    
    UIView *topSpaceView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, 0.5)];
    topSpaceView.backgroundColor = COLOR_LINE;
    [bgView addSubview:topSpaceView];
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

- (void)checkLatestGoodsDetailAction
{
    GoodsDetailViewController *ctl = [[GoodsDetailViewController alloc] init];
    ctl.goodsId = _goodsId;
    [self.navigationController pushViewController:ctl animated:YES];
}


- (void)chatWithBusinessAction
{
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
}

- (void)storeDetailAction
{
    StoreDetailViewController *ctl = [[StoreDetailViewController alloc] init];
    ctl.storeId = _goodsDetail.store.storeId;
    ctl.storeName = _goodsDetail.store.storeName;
    [self.navigationController pushViewController:ctl animated:YES];
}

- (void)makeOrderAction
{
    if (![[AccountManager shareAccountManager] isLogin]) {
        [SVProgressHUD showHint:@"请先登录"];
        [self performSelector:@selector(login) withObject:nil afterDelay:0.3];
    } else {
        MakeOrderViewController *ctl = [[MakeOrderViewController alloc] init];
        ctl.goodsModel = _goodsDetail;
        [self.navigationController pushViewController:ctl animated:YES];
    }
}

- (void)login
{
    LoginViewController *loginViewController = [[LoginViewController alloc] init];
    TZNavigationViewController *nctl = [[TZNavigationViewController alloc] initWithRootViewController:loginViewController];
    loginViewController.isPushed = NO;
    [self presentViewController:nctl animated:YES completion:nil];
}

- (void)showMoreContrent:(UIButton *)sender
{
    SuperWebViewController *ctl = [[SuperWebViewController alloc] init];
    if (sender.tag == 2) {
        ctl.urlStr = _goodsDetail.allDescUrl;
        ctl.titleStr = @"商品介绍";
        
    } else if (sender.tag == 3) {
        ctl.urlStr = _goodsDetail.allBookTipsUrl;
        ctl.titleStr = @"购买须知";
        
    } else if (sender.tag == 4) {
        ctl.urlStr = _goodsDetail.allBookQuitUrl;
        ctl.titleStr = @"预订及退订";
        
    } else if (sender.tag == 5) {
        ctl.urlStr = _goodsDetail.allTrafficUrl;
        ctl.titleStr = @"交通提示";
    }

    [self.navigationController pushViewController:ctl animated:YES];
}

#pragma mark - UITableViewDatasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 7;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        if (_goodsDetail.store.qualifications.count) {
            return 55;
        } else {
            return 10;
        }
    } else if (indexPath.section == 1) {
        if (_isSnapshot) {
            return 45;
        } else {
            return 0;
        }
        
    } else if (indexPath.section == 2) {
        return [GoodsDetailDescTableViewCell heightWithGoodsDetail:_goodsDetail];
        
    } else if (indexPath.section == 3) {
        return [GoodsDetailBookTipsTableViewCell heightWithGoodsDetail:_goodsDetail];
        
    } else if (indexPath.section == 4) {
        return [GoodsDetailBookQuitTableViewCell heightWithGoodsDetail:_goodsDetail];
        
    } else if (indexPath.section == 5) {
        return [GoodsDetailTrafficTableViewCell heightWithGoodsDetail:_goodsDetail];
        
    } else if (indexPath.section == 6) {
        return [GoodsDetailStoreInfoTableViewCell storeHeaderHeightWithStoreDetail:_goodsDetail.store];
    }
    
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0 || section == 1 || section == 6) {
        return 0;
    } else {
        return 40;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if (section == 0 || section == 1 || section == 6) {
        return 0;
    } else {
        return 60;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section == 2) {
        GoodsDetailCommonSectionHeaderView *view = [[GoodsDetailCommonSectionHeaderView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.bounds.size.width, 40)];
        view.headerImageView.image = [UIImage imageNamed:@"icon_goodsDetail_desc.png"];
        view.titleLabel.text = @"商品介绍";
        return view;
        
    } else if (section == 3) {
        GoodsDetailCommonSectionHeaderView *view = [[GoodsDetailCommonSectionHeaderView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.bounds.size.width, 40)];
        view.headerImageView.image = [UIImage imageNamed:@"icon_goodsDetail_prebook.png"];
        view.titleLabel.text = @"购买须知";
        return view;
        
    } else if (section == 4) {
        GoodsDetailCommonSectionHeaderView *view = [[GoodsDetailCommonSectionHeaderView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.bounds.size.width, 40)];
        view.headerImageView.image = [UIImage imageNamed:@"icon_goodsDetail_bookquit.png"];
        view.titleLabel.text = @"预订及退订";
        return view;
        
    } else if (section == 5) {
        GoodsDetailCommonSectionHeaderView *view = [[GoodsDetailCommonSectionHeaderView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.bounds.size.width, 40)];
        view.headerImageView.image = [UIImage imageNamed:@"icon_goodsDetail_traffic.png"];
        view.titleLabel.text = @"交通提示";
        return view;
    } 
    return nil;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    if (section == 0 || section == 1 || section == 6) {
        return nil;
    } else {
        GoodsDetailCommonSectionFooterView *view = [[GoodsDetailCommonSectionFooterView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.bounds.size.width, 60)];
        [view.showAllButton addTarget:self action:@selector(showMoreContrent:) forControlEvents:UIControlEventTouchUpInside];
        view.showAllButton.tag = section;
        return view;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        GoodsDetailSellerQualificationsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"goodsDetailSellerQualificationsTableViewCell" forIndexPath:indexPath];
        cell.qualifications = _goodsDetail.store.qualifications;
        return cell;
        
    } else if (indexPath.section == 1) {
        GoodsDetailSnapshotTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"goodsDetailSnapshotTableViewCell" forIndexPath:indexPath];
        [cell.showLatestGoodsInfoBtn addTarget:self action:@selector(checkLatestGoodsDetailAction) forControlEvents:UIControlEventTouchUpInside];
        return cell;
        
    } else if (indexPath.section == 2) {
        GoodsDetailDescTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"goodsDetailDescTableViewCell" forIndexPath:indexPath];
        cell.goodsDetail = _goodsDetail;
        return cell;
        
    } else if (indexPath.section == 3) {
        GoodsDetailBookTipsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"goodsDetailBookTipsTableViewCell" forIndexPath:indexPath];
        cell.goodsDetail = _goodsDetail;
        return cell;

    } else if (indexPath.section == 4) {
        GoodsDetailBookQuitTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"goodsDetailBookQuitTableViewCell" forIndexPath:indexPath];
        cell.goodsDetail = _goodsDetail;
        return cell;
        
    } else if (indexPath.section == 5) {
        GoodsDetailTrafficTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"goodsDetailTrafficTableViewCell" forIndexPath:indexPath];
        cell.goodsDetail = _goodsDetail;
        return cell;
        
    } else if (indexPath.section == 6) {
        GoodsDetailStoreInfoTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"goodsDetailStoreInfoTableViewCell" forIndexPath:indexPath];
        cell.storeDetail = _goodsDetail.store;
        return cell;
    }
    
    return nil;
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

//用户确定发送商品给朋友
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
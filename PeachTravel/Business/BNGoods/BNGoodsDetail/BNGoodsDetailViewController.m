//
//  BNGoodsDetailViewController.m
//  PeachTravel
//
//  Created by liangpengshuai on 1/20/16.
//  Copyright © 2016 com.aizou.www. All rights reserved.
//

#import "BNGoodsDetailViewController.h"
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
#import "StoreDetailViewController.h"
#import "ShareActivity.h"
#import "UMSocial.h"
#import "MakeOrderViewController.h"
#import "GoodsManager+BNGoodsManager.h"
#import "PeachTravel-swift.h"
#import "ChatGroupSettingViewController.h"
#import "ChatSettingViewController.h"
#import "REFrostedViewController.h"
#import "LoginViewController.h"
#import "ChatRecoredListTableViewController.h"
#import "TaoziChatMessageBaseViewController.h"
#import "GoodsDetailSoldOutView.h"
#import "GoodsDetailWebViewController.h"
#import "GoodsCommentsListViewController.h"
#import "GoodsCommentTableViewCell.h"
#import "BNGoodsDetailPackageTableViewCell.h"

@interface BNGoodsDetailViewController () <UITableViewDataSource, UITableViewDelegate, ActivityDelegate, CreateConversationDelegate, TaoziMessageSendDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) UIView *toolBar;

@property (nonatomic, strong) BNGoodsDetailModel *goodsDetail;
@property (nonatomic, strong) ChatRecoredListTableViewController *chatRecordListCtl;

@end

@implementation BNGoodsDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"商品详情";

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
    [_tableView registerNib:[UINib nibWithNibName:@"BNGoodsDetailPackageTableViewCell" bundle:nil] forCellReuseIdentifier:@"BNGoodsDetailPackageTableViewCell"];
    [_tableView registerNib:[UINib nibWithNibName:@"GoodsCommentTableViewCell" bundle:nil] forCellReuseIdentifier:@"goodsCommentTableViewCell"];
    
    _tableView.backgroundColor = APP_PAGE_COLOR;
    [GoodsManager asyncLoadBNGoodsDetailWithGoodsId:_goodsId completionBlock:^(BOOL isSuccess, NSDictionary *goodsDic, BNGoodsDetailModel *goodsDetail) {
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
    
    self.navigationItem.rightBarButtonItems = @[[[UIBarButtonItem alloc] initWithCustomView:shareBtn]];
}

- (void)setupToolbar
{
    if (_toolBar.superview) {
        [_toolBar removeFromSuperview];
    }

    _toolBar = [[UIView alloc] initWithFrame:CGRectMake(0, kWindowHeight-60, kWindowWidth, 60)];
    _toolBar.backgroundColor = [UIColor whiteColor];
    CGFloat width = _toolBar.bounds.size.width;
    
    UILabel *goodsStatusLabel = [[UILabel alloc] initWithFrame:CGRectMake(12, 0, 100, 60)];
    goodsStatusLabel.textColor = COLOR_PRICE_RED;
    goodsStatusLabel.font = [UIFont systemFontOfSize:17.0];
    goodsStatusLabel.text = _goodsDetail.goodsStatusDesc;
    [_toolBar addSubview:goodsStatusLabel];
    
    if (_goodsDetail.goodsStatus != kReviewing) {
        UIButton *actionButton = [[UIButton alloc] initWithFrame:CGRectMake(kWindowWidth-80, 15, 70, 30)];
        [actionButton setTitleColor:APP_THEME_COLOR forState:UIControlStateNormal];
        actionButton.layer.borderColor = APP_THEME_COLOR.CGColor;
        actionButton.layer.borderWidth = 0.5;
        actionButton.layer.cornerRadius = 4.0;
        if (_goodsDetail.goodsStatus == kOnSale) {
            [actionButton setTitle:@"下架" forState:UIControlStateNormal];
            [actionButton addTarget:self action:@selector(disableGoodsAction:) forControlEvents:UIControlEventTouchUpInside];
            
        } else if (_goodsDetail.goodsStatus == kOffSale) {
            [actionButton setTitle:@"上架" forState:UIControlStateNormal];
            [actionButton addTarget:self action:@selector(disableGoodsAction:) forControlEvents:UIControlEventTouchUpInside];
        } else {
            actionButton.hidden = YES;
        }
        [_toolBar addSubview:actionButton];
    }
    
    UIView *topSpaceView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, 0.5)];
    topSpaceView.backgroundColor = COLOR_LINE;
    [_toolBar addSubview:topSpaceView];
    
    [self.view addSubview:_toolBar];
}

//商品下架
- (void)disableGoodsAction:(UIButton *)sender
{
    [GoodsManager asyncDisableGoods:_goodsId completionBlock:^(BOOL isSuccess, NSString *errDesc) {
        if (isSuccess) {
            [SVProgressHUD showHint:@"商品下架成功"];
            _goodsDetail.goodsStatus = kOffSale;
            [self setupToolbar];

        } else {
            [SVProgressHUD showHint:@"商品下架失败"];
        }
    }];
}

//商品上架
- (void)onSaleGoodsAction:(UIButton *)sender
{
    [GoodsManager asyncOnsaleGoods:_goodsId completionBlock:^(BOOL isSuccess, NSString *errDesc) {
        if (isSuccess) {
            [SVProgressHUD showHint:@"商品上架成功"];
            _goodsDetail.goodsStatus = kOnSale;
            [self setupToolbar];

        } else {
            [SVProgressHUD showHint:@"商品上架失败"];
        }
    }];
}

- (void)share2Frend
{
    NSArray *shareButtonimageArray = @[@"ic_sns_lxp.png", @"ic_sns_pengyouquan.png",  @"ic_sns_weixin.png", @"ic_sns_qq.png", @"ic_sns_sina.png", @"ic_sns_douban.png"];
    //    NSArray *shareButtonimageArray = @[@"ic_sns_lxp.png", @"ic_sns_pengyouquan.png",  @"ic_sns_weixin.png", @"ic_sns_qq.png"];
    
    NSArray *shareButtonTitleArray = @[@"旅行派好友", @"朋友圈", @"微信朋友", @"QQ", @"新浪微博", @"豆瓣"];
    ShareActivity *shareActivity = [[ShareActivity alloc] initWithTitle:@"转发至" delegate:self cancelButtonTitle:@"取消" ShareButtonTitles:shareButtonTitleArray withShareButtonImagesName:shareButtonimageArray];
    [shareActivity showInView:self.navigationController.view];
}

- (void)showMoreContrent:(UIButton *)sender
{
    if (sender.tag == 6) {
        [self showMoreCommentAction];
        return;
    }
    GoodsDetailWebViewController *ctl = [[GoodsDetailWebViewController alloc] init];
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
    [self presentViewController:[[UINavigationController alloc] initWithRootViewController:ctl] animated:YES completion:^{
        
    }];
}

- (void)showMoreCommentAction
{
    GoodsCommentsListViewController *ctl = [[GoodsCommentsListViewController alloc] init];
    ctl.goodsId = _goodsId;
    [self.navigationController pushViewController:ctl animated:YES];
}

#pragma mark - UITableViewDatasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 8;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 6 && !_goodsDetail.commentList.count) {
        return 0;
    }
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
        return [BNGoodsDetailPackageTableViewCell heightWithGoodsDetail:_goodsDetail];
        
    } else if (indexPath.section == 2) {
        return [GoodsDetailDescTableViewCell heightWithGoodsDetail:_goodsDetail];
        
    } else if (indexPath.section == 3) {
        return [GoodsDetailBookTipsTableViewCell heightWithGoodsDetail:_goodsDetail];
        
    } else if (indexPath.section == 4) {
        return [GoodsDetailBookQuitTableViewCell heightWithGoodsDetail:_goodsDetail];
        
    } else if (indexPath.section == 5) {
        return [GoodsDetailTrafficTableViewCell heightWithGoodsDetail:_goodsDetail];
        
    } else if (indexPath.section == 6) {
        return [GoodsCommentTableViewCell heightWithCommentDetail:[_goodsDetail.commentList firstObject]];
        
    } else if (indexPath.section == 7) {
        return [GoodsDetailStoreInfoTableViewCell storeHeaderHeightWithStoreDetail:_goodsDetail.store];
    }
    
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0 || section == 7) {
        return 0;
    } else {
        return 40;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if (section == 0 || section == 7) {
        return 0;
    } else if (section == 1) {
        return 10;
    } else {
        return 60;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section == 1) {
        GoodsDetailCommonSectionHeaderView *view = [[GoodsDetailCommonSectionHeaderView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.bounds.size.width, 40)];
        view.headerImageView.image = [UIImage imageNamed:@"icon_goodsDetail_desc.png"];
        view.titleLabel.text = @"商品套餐";
        return view;
        
    } else if (section == 2) {
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
        
    } else if (section == 6) {
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.bounds.size.width, 40)];
        view.backgroundColor = [UIColor whiteColor];
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(12, 0, kWindowWidth-24, 40)];
        titleLabel.textColor = COLOR_TEXT_I;
        titleLabel.font = [UIFont systemFontOfSize:15.0];
        if (_goodsDetail.commentList.count) {
            titleLabel.text = [NSString stringWithFormat:@"用户评价 (%ld人, %.1f分)", _goodsDetail.commentCnt, _goodsDetail.rating*5];
        } else {
            titleLabel.text = @"用户评价";
        }
        [view addSubview:titleLabel];
        
        UIView *spaceView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kWindowWidth, 0.5)];
        spaceView.backgroundColor = COLOR_LINE;
        [view addSubview:spaceView];
        
        return view;
    }
    return nil;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    if (section == 0 || section == 1 || section == 7) {
        return nil;
        
    } else {
        if (section == 6 && !_goodsDetail.commentList.count) {
            UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kWindowWidth, 60)];
            footerView.backgroundColor = APP_PAGE_COLOR;
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, footerView.bounds.size.width, 50)];
            label.backgroundColor = [UIColor whiteColor];
            label.text = @"   暂无评论";
            label.textColor = COLOR_TEXT_II;
            label.font = [UIFont systemFontOfSize:14.0];
            [footerView addSubview:label];
            
            UIView *spaceView = [[UIView alloc] initWithFrame:CGRectMake(0, 49.5, kWindowWidth, 0.5)];
            spaceView.backgroundColor = COLOR_LINE;
            [footerView addSubview:spaceView];
            return footerView;
        }
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
        BNGoodsDetailPackageTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BNGoodsDetailPackageTableViewCell" forIndexPath:indexPath];
        cell.goodsDetail = _goodsDetail;
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
        GoodsCommentTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"goodsCommentTableViewCell" forIndexPath:indexPath];
        cell.goodsComment = [_goodsDetail.commentList firstObject];
        return cell;
        
    } else if (indexPath.section == 7) {
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
            
            [UMSocialData defaultData].extConfig.sinaData.urlResource = resource;
            
            [[UMSocialDataService defaultDataService]  postSNSWithTypes:@[UMShareToSina] content:shareContentWithUrl image:nil location:nil urlResource:resource presentedController:self completion:^(UMSocialResponseEntity *response){
                if (response.responseCode == UMSResponseCodeSuccess) {
                    NSLog(@"分享成功！");
                }
            }];
            
            break;
            
        case 5:
            [[UMSocialControllerService defaultControllerService] setShareText:shareContentWithUrl shareImage:nil  socialUIDelegate:nil];
            
            [UMSocialSnsPlatformManager getSocialPlatformWithName:UMShareToDouban].snsClickHandler(self,[UMSocialControllerService defaultControllerService],YES);
            
            break;
            
        default:
            break;
    }
}

- (void)shareToTalk
{
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

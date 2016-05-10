//
//  StoreDetailViewController.m
//  PeachTravel
//
//  Created by liangpengshuai on 10/29/15.
//  Copyright © 2015 com.aizou.www. All rights reserved.
//

#import "StoreDetailViewController.h"
#import "UMSocial.h"
#import "StoreDetailModel.h"
#import "StoreManager.h"
#import "StoreDetailHeaderView.h"
#import "GoodsManager.h"
#import "StoreDetailCollectionViewCell.h"
#import "ChatGroupSettingViewController.h"
#import "ChatSettingViewController.h"
#import "REFrostedViewController.h"
#import "ChatViewController.h"
#import "LoginViewController.h"
#import "GoodsDetailViewController.h"
#import "StoreDetailCollectionReusableView.h"

@interface StoreDetailViewController () <UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIView *storeInfoView;

@property (nonatomic, strong) StoreDetailModel *storeDetail;
@property (nonatomic, strong) StoreDetailHeaderView *storeHeaderView;
@property (nonatomic, strong) NSArray *dataSource;
@property (nonatomic, strong) UIButton *switchGoodsButton;
@property (nonatomic, strong) UIButton *switchPlanButton;
@property (nonatomic, strong) UIButton *switchStoreInfo;
@property (nonatomic) NSInteger currentSelectedIndex;

@end

@implementation StoreDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = _storeName;
//    self.automaticallyAdjustsScrollViewInsets = NO;
    self.view.backgroundColor = APP_PAGE_COLOR;
    _scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    _scrollView.backgroundColor = APP_PAGE_COLOR;
    [self.view addSubview:_scrollView];
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.itemSize = CGSizeMake(kWindowWidth/2, kWindowWidth/2);
    layout.minimumInteritemSpacing = 0;
    layout.minimumLineSpacing = 0;
    
    _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 145, kWindowWidth, 0) collectionViewLayout:layout];
    _collectionView.scrollEnabled = NO;
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    _collectionView.backgroundColor = APP_PAGE_COLOR;
    [_collectionView registerNib:[UINib nibWithNibName:@"StoreDetailCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"storeDetailCollectionViewCell"];
 
    [_collectionView registerNib:[UINib nibWithNibName:@"StoreDetailCollectionReusableView" bundle:nil] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"storeDetailCollectionReusableView"];

    [_scrollView addSubview:_collectionView];
    
    UIButton *chatBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, kWindowHeight-49, kWindowWidth, 49)];
    chatBtn.backgroundColor = [UIColor whiteColor];
    chatBtn.layer.borderWidth = 0.5;
    chatBtn.layer.borderColor = COLOR_LINE.CGColor;
    chatBtn.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 10);
    chatBtn.titleEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 0);
    [chatBtn setTitle:@"联系卖家" forState:UIControlStateNormal];
    [chatBtn setTitleColor:COLOR_TEXT_I forState:UIControlStateNormal];
    [chatBtn setImage:[UIImage imageNamed:@"icon_store_chat"] forState:UIControlStateNormal];
    [chatBtn addTarget:self action:@selector(chatWithBusiness) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:chatBtn];
    
    [StoreManager asyncLoadStoreInfoWithStoreId:_storeId completionBlock:^(BOOL isSuccess, StoreDetailModel *storeDetail) {
        self.storeDetail = storeDetail;
        [GoodsManager asyncLoadGoodsOfStore:_storeId startIndex:-1 count:-1 completionBlock:^(BOOL isSuccess, NSArray *goodsList) {
            self.dataSource = goodsList;
        }];
    }];
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 145, kWindowWidth, 0) style:UITableViewStyleGrouped];
    [_tableView registerNib:[UINib nibWithNibName:@"StorePlanTableViewCell" bundle:nil] forCellReuseIdentifier:@"cell"];
    _tableView.hidden = YES;
    [self.scrollView addSubview:_tableView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)setDataSource:(NSArray *)dataSource
{
    _dataSource = dataSource;
    CGFloat height = ((int)(_dataSource.count/2) + _dataSource.count%2) * kWindowWidth/2 + 40;
    CGRect frame = self.collectionView.frame;
    frame.size.height = height;
    self.collectionView.frame = frame;
    self.scrollView.contentSize = CGSizeMake(0, frame.size.height + frame.origin.y + 50);
    [self.collectionView reloadData];
}

- (void)setStoreDetail:(StoreDetailModel *)storeDetail
{
    _storeDetail = storeDetail;
    _storeName = _storeDetail.storeName;
    self.navigationItem.title = _storeName;
    [self setupHeaderView];
    _storeHeaderView.storeDetail = _storeDetail;
}

- (void)setupHeaderView
{
    CGFloat height = [StoreDetailHeaderView storeHeaderHeightWithStoreDetail:_storeDetail];
    _storeHeaderView = [[StoreDetailHeaderView alloc] initWithFrame:CGRectMake(0, 0, kWindowWidth, height)];
    
    UIButton *storeIntroduceButton = [[UIButton alloc] initWithFrame:CGRectMake(0, height+10, kWindowWidth, 40)];
    [storeIntroduceButton setBackgroundColor:[UIColor whiteColor]];
    [storeIntroduceButton setTitleColor:COLOR_TEXT_II forState:UIControlStateNormal];
    [storeIntroduceButton setTitle:@"店主介绍" forState:UIControlStateNormal];
    storeIntroduceButton.titleLabel.font = [UIFont systemFontOfSize:16.0];
    [storeIntroduceButton setContentEdgeInsets:UIEdgeInsetsMake(0, 20, 0, 0)];
    [storeIntroduceButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    [self.scrollView addSubview:storeIntroduceButton];
    
    height += 60;
    
    CGFloat buttonWidth = kWindowWidth/3;
    _switchGoodsButton = [[UIButton alloc] initWithFrame:CGRectMake(0, height, buttonWidth, 49)];
    [_switchGoodsButton setTitle:@"在售商品" forState:UIControlStateNormal];
    [_switchGoodsButton setTitleColor:COLOR_TEXT_I forState:UIControlStateNormal];
    [_switchGoodsButton setTitleColor:APP_THEME_COLOR forState:UIControlStateSelected];
    _switchGoodsButton.titleLabel.font = [UIFont systemFontOfSize:15.0];
    _switchGoodsButton.tag = 0;
    _switchGoodsButton.selected = YES;
    [_switchGoodsButton setBackgroundColor:[UIColor whiteColor]];
    [_switchGoodsButton addTarget:self action:@selector(swithchStoreInfo:) forControlEvents:UIControlEventTouchUpInside];
    [self.scrollView addSubview:_switchGoodsButton];
    
    _switchPlanButton = [[UIButton alloc] initWithFrame:CGRectMake(buttonWidth, height, buttonWidth, 49)];
    [_switchPlanButton setTitle:@"行程方案" forState:UIControlStateNormal];
    [_switchPlanButton setTitleColor:COLOR_TEXT_I forState:UIControlStateNormal];
    [_switchPlanButton setTitleColor:APP_THEME_COLOR forState:UIControlStateSelected];
    _switchPlanButton.titleLabel.font = [UIFont systemFontOfSize:15.0];
    _switchPlanButton.tag = 1;
    [_switchPlanButton setBackgroundColor:[UIColor whiteColor]];
    [_switchPlanButton addTarget:self action:@selector(swithchStoreInfo:) forControlEvents:UIControlEventTouchUpInside];
    [self.scrollView addSubview:_switchPlanButton];
    
    _switchStoreInfo = [[UIButton alloc] initWithFrame:CGRectMake(buttonWidth *2, height, buttonWidth, 49)];
    [_switchStoreInfo setTitle:@"店铺详情" forState:UIControlStateNormal];
    [_switchStoreInfo setTitleColor:COLOR_TEXT_I forState:UIControlStateNormal];
    [_switchStoreInfo setTitleColor:APP_THEME_COLOR forState:UIControlStateSelected];
    _switchStoreInfo.titleLabel.font = [UIFont systemFontOfSize:15.0];
    _switchStoreInfo.tag = 1;
    [_switchStoreInfo setBackgroundColor:[UIColor whiteColor]];
    [_switchStoreInfo addTarget:self action:@selector(swithchStoreInfo:) forControlEvents:UIControlEventTouchUpInside];
    [self.scrollView addSubview:_switchStoreInfo];
    
    [self.scrollView addSubview:_storeHeaderView];
    
    CGRect frame = self.collectionView.frame;
    frame.origin.y = height + 49;
    self.collectionView.frame = frame;

}

- (void)swithchStoreInfo:(UIButton *)sender
{
    if (sender.tag == _currentSelectedIndex) {
        return;
    }
    _currentSelectedIndex = sender.selected;
    _collectionView.hidden = _currentSelectedIndex != 0;
    _tableView.hidden = _currentSelectedIndex != 1;
    _storeInfoView.hidden = _currentSelectedIndex != 2;
}

- (void)chatWithBusiness
{
    if (![[AccountManager shareAccountManager] isLogin]) {
        [SVProgressHUD showHint:@"请先登录"];
        [self performSelector:@selector(login) withObject:nil afterDelay:0.3];
        return;
    }
    IMClientManager *clientManager = [IMClientManager shareInstance];
    ChatConversation *conversation = [clientManager.conversationManager getConversationWithChatterId:_storeId chatType:IMChatTypeIMChatSingleType];
    ChatViewController *chatController = [[ChatViewController alloc] initWithConversation:conversation];
    if (conversation.chatterName && conversation.chatterName.length) {
        chatController.chatterName = conversation.chatterName;
    } else {
//        chatController.chatterName = _storeDetail.business.nickName;
    }
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

- (void)login
{
    LoginViewController *loginViewController = [[LoginViewController alloc] init];
    TZNavigationViewController *nctl = [[TZNavigationViewController alloc] initWithRootViewController:loginViewController];
    loginViewController.isPushed = NO;
    [self presentViewController:nctl animated:YES completion:nil];
}

#pragma mark - UICollectionViewDataSource

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section;
{
    return CGSizeMake(collectionView.frame.size.width, 40);
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return _dataSource.count;
}

- (NSInteger)numberOfItemsInSection:(NSInteger)section
{
    return 1;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        StoreDetailCollectionReusableView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"storeDetailCollectionReusableView" forIndexPath:indexPath];
        headerView.headerView.image = [UIImage imageNamed:@"icon_store_cagtegory"];
        headerView.titleLabel.text = @"在售商品";
        return headerView;
    }
    return nil;
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    StoreDetailCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"storeDetailCollectionViewCell" forIndexPath:indexPath];
    cell.goodsDetail = _dataSource[indexPath.row];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    GoodsDetailModel *goodsDetail = _dataSource[indexPath.row];
    GoodsDetailViewController *ctl = [[GoodsDetailViewController alloc] init];
    ctl.goodsId = goodsDetail.goodsId;
    [self.navigationController pushViewController:ctl animated:YES];
}

@end

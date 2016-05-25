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

@interface StoreDetailViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIView *storeInfoView;

@property (nonatomic, strong) StoreDetailModel *storeDetail;
@property (nonatomic, strong) StoreDetailHeaderView *storeHeaderView;
@property (nonatomic, strong) NSArray *dataSource;
@property (nonatomic, strong) NSArray *planDataSource;

@property (nonatomic, strong) UIButton *switchGoodsButton;
@property (nonatomic, strong) UIButton *switchPlanButton;
@property (nonatomic, strong) UIButton *switchStoreInfo;
@property (nonatomic, strong) UIButton *currentSelectedButton;

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
        [self updateStoreInfoView];
        [GoodsManager asyncLoadGoodsOfStore:_storeId startIndex:-1 count:-1 completionBlock:^(BOOL isSuccess, NSArray *goodsList) {
            self.dataSource = goodsList;
            self.planDataSource = goodsList;
        }];
    }];
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 145, kWindowWidth, 0) style:UITableViewStyleGrouped];
    _tableView.hidden = YES;
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.scrollEnabled = NO;
    _tableView.separatorColor = COLOR_LINE;
    [self.scrollView addSubview:_tableView];
    
    _storeInfoView = [[UIView alloc] init];
    _storeInfoView.backgroundColor = [UIColor whiteColor];
    [self.scrollView addSubview:_storeInfoView];
    _storeInfoView.hidden = YES;
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

- (void)setPlanDataSource:(NSArray *)planDataSource
{
    _planDataSource = planDataSource;
    CGRect frame = self.tableView.frame;
    _tableView.frame = CGRectMake(frame.origin.x, CGRectGetMaxY(_switchPlanButton.frame), frame.size.width, 50*_planDataSource.count);
    [self.tableView reloadData];
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
    [self.scrollView addSubview:_storeHeaderView];

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
    _currentSelectedButton = _switchGoodsButton;
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
    _switchStoreInfo.tag = 2;
    [_switchStoreInfo setBackgroundColor:[UIColor whiteColor]];
    [_switchStoreInfo addTarget:self action:@selector(swithchStoreInfo:) forControlEvents:UIControlEventTouchUpInside];
    [self.scrollView addSubview:_switchStoreInfo];
    
    UIView *spaceView1 = [[UIView alloc] initWithFrame:CGRectMake(0, height+49, kWindowWidth, 0.5)];
    spaceView1.backgroundColor = COLOR_LINE;
    [self.scrollView addSubview:spaceView1];

    
    CGRect frame = self.collectionView.frame;
    frame.origin.y = height + 49;
    self.collectionView.frame = frame;
}

- (void)updateStoreInfoView
{
    CGFloat height = _switchStoreInfo.frame.origin.y + 49;
    CGFloat offsetY = 10;
    UILabel *titleLabel1 = [[UILabel alloc] initWithFrame:CGRectMake(12, offsetY, kWindowWidth-24, 25)];
    titleLabel1.text = @"卖家诚信度";
    titleLabel1.textColor = COLOR_TEXT_I;
    titleLabel1.font = [UIFont systemFontOfSize:15.0];
    [_storeInfoView addSubview:titleLabel1];
    offsetY += 30;
    
    UILabel *monthLable1 = [[UILabel alloc] initWithFrame:CGRectMake(kWindowWidth-140, offsetY, 60, 20)];
    monthLable1.text = @"本月";
    monthLable1.textColor = COLOR_TEXT_II;
    monthLable1.textAlignment = NSTextAlignmentCenter;
    monthLable1.font = [UIFont systemFontOfSize:15.0];
    [_storeInfoView addSubview:monthLable1];
    
    UILabel *monthLable2 = [[UILabel alloc] initWithFrame:CGRectMake(kWindowWidth-80, offsetY, 60, 20)];
    monthLable2.text = @"上月";
    monthLable2.textAlignment = NSTextAlignmentCenter;
    monthLable2.textColor = COLOR_TEXT_II;
    monthLable2.font = [UIFont systemFontOfSize:15.0];
    [_storeInfoView addSubview:monthLable2];
    
    offsetY += 25;
    
    UILabel *itemLabel1 = [[UILabel alloc] initWithFrame:CGRectMake(12, offsetY, 60, 20)];
    itemLabel1.text = @"退款数";
    itemLabel1.textColor = COLOR_TEXT_II;
    itemLabel1.font = [UIFont systemFontOfSize:15.0];
    [_storeInfoView addSubview:itemLabel1];
    
    UILabel *valueLabel1 = [[UILabel alloc] initWithFrame:CGRectMake(kWindowWidth-140, offsetY, 60, 20)];
    valueLabel1.text = @"0";
    valueLabel1.textColor = COLOR_TEXT_II;
    valueLabel1.font = [UIFont systemFontOfSize:15.0];
    valueLabel1.textAlignment = NSTextAlignmentCenter;

    [_storeInfoView addSubview:valueLabel1];
    
    UILabel *valueLabel2 = [[UILabel alloc] initWithFrame:CGRectMake(kWindowWidth-80, offsetY, 60, 20)];
    valueLabel2.text = @"0";
    valueLabel2.textColor = COLOR_TEXT_II;
    valueLabel2.font = [UIFont systemFontOfSize:14.0];
    valueLabel2.textAlignment = NSTextAlignmentCenter;

    [_storeInfoView addSubview:valueLabel2];
    offsetY += 25;
    
    UILabel *itemLabel2 = [[UILabel alloc] initWithFrame:CGRectMake(12, offsetY, 60, 20)];
    itemLabel2.text = @"纠纷数";
    itemLabel2.textColor = COLOR_TEXT_II;
    itemLabel2.font = [UIFont systemFontOfSize:15.0];
    [_storeInfoView addSubview:itemLabel2];
    
    UILabel *valueLabel3 = [[UILabel alloc] initWithFrame:CGRectMake(kWindowWidth-140, offsetY, 60, 20)];
    valueLabel3.text = @"0";
    valueLabel3.textColor = COLOR_TEXT_II;
    valueLabel3.font = [UIFont systemFontOfSize:15.0];
    valueLabel3.textAlignment = NSTextAlignmentCenter;

    [_storeInfoView addSubview:valueLabel3];
    
    UILabel *valueLabel4 = [[UILabel alloc] initWithFrame:CGRectMake(kWindowWidth-80, offsetY, 60, 20)];
    valueLabel4.text = @"0";
    valueLabel4.textColor = COLOR_TEXT_II;
    valueLabel4.font = [UIFont systemFontOfSize:14.0];
    valueLabel4.textAlignment = NSTextAlignmentCenter;

    [_storeInfoView addSubview:valueLabel4];
    
    offsetY += 25;
    
    UILabel *itemLabel4 = [[UILabel alloc] initWithFrame:CGRectMake(12, offsetY, 60, 20)];
    itemLabel4.text = @"处罚数";
    itemLabel4.textColor = COLOR_TEXT_II;
    itemLabel4.font = [UIFont systemFontOfSize:15.0];
    [_storeInfoView addSubview:itemLabel4];
    
    UILabel *valueLabel5 = [[UILabel alloc] initWithFrame:CGRectMake(kWindowWidth-140, offsetY, 60, 20)];
    valueLabel5.text = @"0";
    valueLabel5.textColor = COLOR_TEXT_II;
    valueLabel5.font = [UIFont systemFontOfSize:15.0];
    valueLabel5.textAlignment = NSTextAlignmentCenter;

    [_storeInfoView addSubview:valueLabel5];
    
    UILabel *valueLabel6 = [[UILabel alloc] initWithFrame:CGRectMake(kWindowWidth-80, offsetY, 60, 20)];
    valueLabel6.text = @"0";
    valueLabel6.textColor = COLOR_TEXT_II;
    valueLabel6.font = [UIFont systemFontOfSize:14.0];
    valueLabel6.textAlignment = NSTextAlignmentCenter;

    [_storeInfoView addSubview:valueLabel6];
    
    offsetY += 30;
    
    UIView *spaceView1 = [[UIView alloc] initWithFrame:CGRectMake(0, offsetY, kWindowWidth, 10)];
    spaceView1.backgroundColor = APP_PAGE_COLOR;
    [_storeInfoView addSubview:spaceView1];
    
    offsetY += 20;
    
    _storeDetail.storeInfo = @"我是一个店铺简介水电费几克里斯多夫上岛咖啡结舌杜口林凤娇顺利的看风景少的可怜费劲儿索科洛夫威锋网范文芳问问范文芳";
    
    if (_storeDetail.storeInfo.length > 0) {
        UILabel *titleLabel2 = [[UILabel alloc] initWithFrame:CGRectMake(12, offsetY, kWindowWidth-24, 25)];
        titleLabel2.text = @"店铺简介";
        titleLabel2.textColor = COLOR_TEXT_I;
        titleLabel2.font = [UIFont systemFontOfSize:15.0];
        [_storeInfoView addSubview:titleLabel2];
        
        offsetY += 30;
        
        NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] initWithString:_storeDetail.storeInfo];
        [attr addAttributes:@{NSFontAttributeName: [UIFont systemFontOfSize:14.0]} range:NSMakeRange(0, _storeDetail.storeInfo.length)];
        CGRect rect = [attr boundingRectWithSize:(CGSize){kWindowWidth-24, CGFLOAT_MAX} options:NSStringDrawingUsesLineFragmentOrigin context:nil];
        
        UILabel *infoLabel = [[UILabel alloc] initWithFrame:CGRectMake(12, offsetY, kWindowWidth-24, rect.size.height+20)];
        infoLabel.attributedText = attr;
        infoLabel.textColor = COLOR_TEXT_II;
        infoLabel.numberOfLines = 0;
        infoLabel.font = [UIFont systemFontOfSize:14.0];
        [_storeInfoView addSubview:infoLabel];
        
        offsetY += infoLabel.frame.size.height+10;
        
        UIView *spaceView1 = [[UIView alloc] initWithFrame:CGRectMake(0, offsetY, kWindowWidth, 10)];
        spaceView1.backgroundColor = APP_PAGE_COLOR;
        [_storeInfoView addSubview:spaceView1];
        
        offsetY += 20;
    }
    
    UILabel *titleLabel3 = [[UILabel alloc] initWithFrame:CGRectMake(12, offsetY, kWindowWidth-24, 25)];
    titleLabel3.text = @"服务领域";
    titleLabel3.textColor = COLOR_TEXT_I;
    titleLabel3.font = [UIFont systemFontOfSize:15.0];
    [_storeInfoView addSubview:titleLabel3];
    
    offsetY += 30;
    
    UILabel *serviceLabel = [[UILabel alloc] initWithFrame:CGRectMake(12, offsetY, kWindowWidth-24, 30)];
    serviceLabel.text = @"机票酒店  美食门票  导游接机  行程设计  全套服务";
    serviceLabel.textColor = COLOR_TEXT_II;
    serviceLabel.adjustsFontSizeToFitWidth = YES;
    serviceLabel.font = [UIFont systemFontOfSize:14.0];
    [_storeInfoView addSubview:serviceLabel];
    
    offsetY += 40;
    
    UIView *spaceView2 = [[UIView alloc] initWithFrame:CGRectMake(0, offsetY, kWindowWidth, 10)];
    spaceView2.backgroundColor = APP_PAGE_COLOR;
    [_storeInfoView addSubview:spaceView2];
    
    offsetY += 20;
   
    UILabel *titleLabel4 = [[UILabel alloc] initWithFrame:CGRectMake(12, offsetY, kWindowWidth-24, 25)];
    titleLabel4.text = @"定制服务城市";
    titleLabel4.textColor = COLOR_TEXT_I;
    titleLabel4.font = [UIFont systemFontOfSize:15.0];
    [_storeInfoView addSubview:titleLabel4];
    
    offsetY += 30;
    
    NSMutableString *cityName = [[NSMutableString alloc] init];
    for (CityDestinationPoi *city in _storeDetail.planServiceCities) {
        [cityName appendFormat:@"%@  ", city.zhName];
    }
    
    NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] initWithString:cityName];
    [attr addAttributes:@{NSFontAttributeName: [UIFont systemFontOfSize:14.0]} range:NSMakeRange(0, cityName.length)];
    CGRect rect = [attr boundingRectWithSize:(CGSize){kWindowWidth-24, CGFLOAT_MAX} options:NSStringDrawingUsesLineFragmentOrigin context:nil];
    
    UILabel *infoLabel = [[UILabel alloc] initWithFrame:CGRectMake(12, offsetY, kWindowWidth-24, rect.size.height+20)];
    infoLabel.attributedText = attr;
    infoLabel.textColor = COLOR_TEXT_II;
    infoLabel.numberOfLines = 0;
    infoLabel.font = [UIFont systemFontOfSize:14.0];
    [_storeInfoView addSubview:infoLabel];
    
    offsetY += infoLabel.frame.size.height;
    
    _storeInfoView.frame = CGRectMake(0, height, kWindowWidth,offsetY+10);

}

- (void)swithchStoreInfo:(UIButton *)sender
{
    if (sender.tag == _currentSelectedButton.tag) {
        return;
    }
    _currentSelectedButton.selected = !_currentSelectedButton.selected;

    sender.selected = !sender.selected;
    _currentSelectedButton = sender;
    _collectionView.hidden = _currentSelectedButton.tag != 0;
    _tableView.hidden = _currentSelectedButton.tag != 1;
    _storeInfoView.hidden = _currentSelectedButton.tag != 2;
    if (_currentSelectedButton.tag == 0) {
        self.scrollView.contentSize = CGSizeMake(0, self.collectionView.frame.size.height + self.collectionView.frame.origin.y + 50);
    } else if (_currentSelectedButton.tag == 1) {
        self.scrollView.contentSize = CGSizeMake(0, self.tableView.frame.size.height + self.tableView.frame.origin.y + 50);

    } else {
        self.scrollView.contentSize = CGSizeMake(0, self.storeInfoView.frame.size.height + self.storeInfoView.frame.origin.y + 50);

    }
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

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return _dataSource.count;
}

- (NSInteger)numberOfItemsInSection:(NSInteger)section
{
    return 1;
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

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _planDataSource.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0.01;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.01;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    GoodsDetailModel *goodsDetail = _dataSource[indexPath.row];

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    cell.backgroundColor = [UIColor whiteColor];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
        
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(12, 0, kWindowWidth-70, 50)];

        titleLabel.textColor = COLOR_TEXT_I;
        titleLabel.font = [UIFont systemFontOfSize:14.0];
        titleLabel.tag = 1000;
        [cell addSubview:titleLabel];
        
        UILabel *priceLabel = [[UILabel alloc] initWithFrame:CGRectMake(kWindowWidth-60, 0, 50, 50)];
        priceLabel.textAlignment = NSTextAlignmentRight;
        priceLabel.tag = 1001;
        priceLabel.font = [UIFont systemFontOfSize:13.0];
        priceLabel.textColor = COLOR_PRICE_RED;
        [cell addSubview:priceLabel];
    }
    for (UIView *view in cell.subviews) {
        if (view.tag == 1001) {
            UILabel *priceLabel = (UILabel  *)view;
            priceLabel.text = [NSString stringWithFormat:@"%@元", goodsDetail.formatCurrentPrice];
            break;
        }
    }
    for (UIView *view in cell.subviews) {
        if (view.tag == 1000) {
            UILabel *titleLabel = (UILabel  *)view;
            titleLabel.text = goodsDetail.goodsName;
            break;
        }
    }

    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}
@end

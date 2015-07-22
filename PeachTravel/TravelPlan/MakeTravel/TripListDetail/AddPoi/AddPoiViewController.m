//
//  AddPoiViewController.m
//  PeachTravel
//
//  Created by liangpengshuai on 11/26/14.
//  Copyright (c) 2014 com.aizou.www. All rights reserved.
//

#import "AddPoiViewController.h"
#import "CityDestinationPoi.h"
#import "TripDetail.h"
#import "SpotDetailViewController.h"
#import "CommonPoiDetailViewController.h"
#import "CommonPoiListTableViewCell.h"
#import "PoiDetailViewControllerFactory.h"
#import "SelectionTableViewController.h"
#import "FilterViewController.h"
#import "PoisOfCityViewController.h"
#import "PoisSearchViewController.h"
#import "TripPoiListTableViewCell.h"
#import "HWDropdownMenu.h"
#import "DropDownViewController.h"
enum {
    FILTER_TYPE_CITY = 1,
    FILTER_TYPE_CATE
};

@interface AddPoiViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate, UISearchDisplayDelegate, UIActionSheetDelegate, SelectDelegate,updateSelectedPlanDelegate,dropDownMenuProtocol,HWDropdownMenuDelegate>

@property (nonatomic) NSUInteger currentListTypeIndex;
@property (nonatomic) NSUInteger currentCityIndex;
@property (nonatomic, strong) NSArray *urlArray;
@property (nonatomic, strong) NSMutableArray *dataSource;

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) UIActivityIndicatorView *indicatroView;
@property (nonatomic, strong) UIView *footerView;

@property (nonatomic, copy) NSString *requestUrl;

@property (nonatomic, strong) UICollectionView *selectPanel;

//管理普通 tableview 的加载状态
@property (nonatomic) NSUInteger currentPageNormal;
@property (nonatomic, assign) BOOL isLoadingMoreNormal;
@property (nonatomic, assign) BOOL didEndScrollNormal;
@property (nonatomic, assign) BOOL enableLoadMoreNormal;

@property (nonatomic, strong)HWDropdownMenu * dropDownMenu;

@property (nonatomic, copy) NSString *currentCategory;

//类型筛选: 1是城市、2是分类
@property (nonatomic, assign) NSInteger filterType;

/**
 *   两个分类Button
 */
@property (nonatomic, weak)UIButton * cityButton;
@property (nonatomic, weak)UIButton * categoryButton;

@end

@implementation AddPoiViewController

static NSString *addPoiCellIndentifier = @"tripPoiListCell";

- (id)init {
    if (self = [super init]) {
        _currentPageNormal = 0;
        _isLoadingMoreNormal = YES;
        _didEndScrollNormal = YES;
        _enableLoadMoreNormal = NO;
        _currentCategory = @"景点";
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height-49) style:UITableViewStyleGrouped];
    _tableView.delegate  = self;
    _tableView.dataSource = self;
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    [self.view addSubview:_tableView];
    
    if (_tripDetail) {
        UIBarButtonItem *finishBtn = [[UIBarButtonItem alloc]initWithTitle:@"完成" style:UIBarButtonItemStylePlain target:self action:@selector(addFinish:)];
        self.navigationItem.leftBarButtonItem = finishBtn;
        
        UIBarButtonItem *sbtn = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"search.png"] style:UIBarButtonItemStylePlain target:self action:@selector(beginSearch)];
        self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:sbtn, nil];
        
        CityDestinationPoi *firstDestination = [_tripDetail.destinations firstObject];
        _cityName = firstDestination.zhName;
        _cityId = firstDestination.cityId;
        
        self.navigationItem.title = @"添加行程";
        [self setupSelectPanel];
    } else {
        UIBarButtonItem *sbtn = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"search.png"] style:UIBarButtonItemStylePlain target:self action:@selector(beginSearch)];
        self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:sbtn, nil];
        self.navigationItem.title = [NSString stringWithFormat:@"%@景点", _cityName];
    }
    
    _urlArray = @[API_GET_SPOTLIST_CITY, API_GET_RESTAURANTSLIST_CITY, API_GET_SHOPPINGLIST_CITY, API_GET_HOTELLIST_CITY];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"TripPoiListTableViewCell" bundle:nil] forCellReuseIdentifier:addPoiCellIndentifier];
    
    self.tableView.separatorColor = COLOR_LINE;
    self.tableView.backgroundColor = APP_PAGE_COLOR;
    _requestUrl =  API_GET_SPOTLIST_CITY;
    _requestUrl = API_GET_SPOTLIST_CITY;
    
    [_tableView setContentOffset:CGPointMake(0, 45)];
    _tableView.contentInset = UIEdgeInsetsMake(0, 0, 20, 0);
    
    [self loadDataWithPageNo:_currentPageNormal];
}

- (void) setupSelectPanel {
    CGRect collectionViewFrame = CGRectMake(0, CGRectGetHeight(self.view.bounds) - 49 - 64, CGRectGetWidth(self.view.bounds), 49);
    UICollectionViewFlowLayout *aFlowLayout = [[UICollectionViewFlowLayout alloc] init];
    [aFlowLayout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    self.selectPanel = [[UICollectionView alloc] initWithFrame:collectionViewFrame collectionViewLayout:aFlowLayout];
    self.selectPanel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.selectPanel.showsHorizontalScrollIndicator = NO;
    self.selectPanel.showsVerticalScrollIndicator = NO;
    self.selectPanel.delegate = self;
    self.selectPanel.dataSource = self;
    self.selectPanel.contentInset = UIEdgeInsetsMake(0, 10, 0, 10);
    [self.selectPanel registerClass:[SelectDestCell class] forCellWithReuseIdentifier:@"sdest_cell"];
    self.selectPanel.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:_selectPanel];
    
    UIView *spaceView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.view.bounds) - 49 - 64, self.selectPanel.frame.size.width, 1)];
    spaceView.backgroundColor = COLOR_LINE;
    [self.view addSubview:spaceView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (_shouldEdit) {
        [MobClick beginLogPageView:@"page_add_agenda"];
    } else {
        [MobClick beginLogPageView:@"page_spot_lists"];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if (_shouldEdit) {
        [MobClick endLogPageView:@"page_add_agenda"];
    } else {
        [MobClick endLogPageView:@"page_spot_lists"];
    }
}

- (void)setTripDetail:(TripDetail *)tripDetail
{
    _tripDetail = tripDetail;
    CityDestinationPoi *firstDestination = [_tripDetail.destinations firstObject];
    _cityId = firstDestination.cityId;
}

- (NSMutableArray *)dataSource
{
    if (!_dataSource) {
        _dataSource = [[NSMutableArray alloc] init];
    }
    return _dataSource;
}

- (UIView *)footerView {
    if (!_footerView) {
        _footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.tableView.bounds), 44.0)];
        _footerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _footerView.backgroundColor = APP_PAGE_COLOR;
        _indicatroView = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 32.0, 32.0)];
        [_indicatroView setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
        [_footerView addSubview:_indicatroView];
        [_indicatroView setCenter:CGPointMake(CGRectGetWidth(self.tableView.bounds)/2.0, 44.0/2.0)];
    }
    return _footerView;
}

#pragma mark - private methods

/**
 *  非搜索状态下上拉加载更多
 */
- (void) beginLoadingMoreNormal
{
    if (self.tableView.tableFooterView == nil) {
        self.tableView.tableFooterView = self.footerView;
    }
    _isLoadingMoreNormal = YES;
    [_indicatroView startAnimating];
    [self loadDataWithPageNo:(_currentPageNormal + 1)];
    
    
}

/**
 *  非搜索状态下加载完成
 */
- (void) loadMoreCompletedNormal
{
    if (!_isLoadingMoreNormal) return;
    [_indicatroView stopAnimating];
    _isLoadingMoreNormal = NO;
    _didEndScrollNormal = YES;
}

#pragma mark - IBAction Methods

- (void)beginSearch {
    PoisSearchViewController *searchCtl = [[PoisSearchViewController alloc] init];
    [searchCtl setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];
    searchCtl.currentDayIndex = _currentDayIndex;
    searchCtl.cityId = _cityId;
    searchCtl.tripDetail = _tripDetail;
    searchCtl.poiType = kSpotPoi;
    searchCtl.delegate = self;
    searchCtl.shouldEdit = _shouldEdit;
    TZNavigationViewController *tznavc = [[TZNavigationViewController alloc] initWithRootViewController:searchCtl];
    
    [self presentViewController:tznavc animated:YES completion:^{
        
    }];
    
}

- (IBAction)addFinish:(id)sender
{
    [_delegate finishEdit];
    if (self.navigationController.viewControllers.count > 1) {
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

/**
 *  跳转到导航
 *
 *  @param sender
 */
- (IBAction)jumpToMapView:(UIButton *)sender
{
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"其他软件导航"
                                                       delegate:self
                                              cancelButtonTitle:nil
                                         destructiveButtonTitle:nil
                                              otherButtonTitles:nil];
    NSArray *platformArray = [ConvertMethods mapPlatformInPhone];
    for (NSDictionary *dic in platformArray) {
        [sheet addButtonWithTitle:[dic objectForKey:@"platform"]];
    }
    [sheet addButtonWithTitle:@"取消"];
    sheet.cancelButtonIndex = sheet.numberOfButtons-1;
    [sheet showInView:self.view];
    sheet.tag = sender.tag;
    
}

/**
 *  添加或者删除景点
 *
 *  @param sender
 */
- (IBAction)addPoi:(UIButton *)sender
{
    [MobClick event:@"event_add_desination_as_schedule"];
    
    CGPoint point;
    NSIndexPath *indexPath;
    TripPoiListTableViewCell *cell;
    point = [sender convertPoint:CGPointZero toView:_tableView];
    indexPath = [_tableView indexPathForRowAtPoint:point];
    cell = (TripPoiListTableViewCell *)[_tableView cellForRowAtIndexPath:indexPath];
    
    NSMutableArray *oneDayArray = [self.tripDetail.itineraryList objectAtIndex:_currentDayIndex];
    SuperPoi *poi;
    if (!cell.actionBtn.selected) {
        poi = [self.dataSource objectAtIndex:indexPath.row];
        [oneDayArray addObject:poi];
        
        NSIndexPath *lnp = [NSIndexPath indexPathForItem:oneDayArray.count - 1 inSection:0];
        [self.selectPanel performBatchUpdates:^{
            [self.selectPanel insertItemsAtIndexPaths:[NSArray arrayWithObject:lnp]];
        } completion:^(BOOL finished) {
            [self.selectPanel scrollToItemAtIndexPath:lnp
                                     atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
        }];
    } else {
        SuperPoi *poi;
        poi = [self.dataSource objectAtIndex:indexPath.row];
        NSMutableArray *oneDayArray = [self.tripDetail.itineraryList objectAtIndex:_currentDayIndex];
        int index = -1;
        NSInteger count = oneDayArray.count;
        for (int i = 0; i < count; ++i) {
            SuperPoi *tripPoi = [oneDayArray objectAtIndex:i];
            if ([tripPoi.poiId isEqualToString:poi.poiId]) {
                [oneDayArray removeObjectAtIndex:i];
                index = i;
                break;
            }
        }
        if (index != -1) {
            NSIndexPath *lnp = [NSIndexPath indexPathForItem:index inSection:0];
            [self.selectPanel performBatchUpdates:^{
                [self.selectPanel deleteItemsAtIndexPaths:[NSArray arrayWithObject:lnp]];
            } completion:^(BOOL finished) {
                [self.selectPanel reloadData];
            }];
        }
        
    }
    cell.actionBtn.selected = !cell.actionBtn.selected;
}

- (void)deletePoi:(UIButton *)sender
{
    NSMutableArray *oneDayArray = [self.tripDetail.itineraryList objectAtIndex:_currentDayIndex];
    SuperPoi *poi = [oneDayArray objectAtIndex:sender.tag];
    int index = -1;
    NSInteger count = oneDayArray.count;
    for (int i = 0; i < count; ++i) {
        SuperPoi *tripPoi = [oneDayArray objectAtIndex:i];
        if ([tripPoi.poiId isEqualToString:poi.poiId]) {
            [oneDayArray removeObjectAtIndex:i];
            index = i;
            break;
        }
    }
    
    if (index != -1) {
        NSIndexPath *lnp = [NSIndexPath indexPathForItem:index inSection:0];
        [self.selectPanel performBatchUpdates:^{
            [self.selectPanel deleteItemsAtIndexPaths:[NSArray arrayWithObject:lnp]];
        } completion:^(BOOL finished) {
            [self.selectPanel reloadData];
        }];
        [self.tableView reloadData];
    }
}

- (void) changeCity {
    NSMutableArray *array = [[NSMutableArray alloc] init];
    for (CityDestinationPoi *poi in _tripDetail.destinations) {
        [array addObject:poi.zhName];
    }
    SelectionTableViewController *ctl = [[SelectionTableViewController alloc] init];
    ctl.contentItems = [NSArray arrayWithArray:array];
    ctl.titleTxt = @"切换城市";
    ctl.delegate = self;
    UIButton *tbtn = (UIButton *)self.navigationItem.titleView;
    NSString *title = [tbtn attributedTitleForState:UIControlStateNormal].string;
    ctl.selectItem = [title substringToIndex:title.length - 4];
    TZNavigationViewController *nav = [[TZNavigationViewController alloc] initWithRootViewController:ctl];
    [self presentViewController:nav animated:YES completion:^{
        _filterType = FILTER_TYPE_CITY;
    }];
}

#pragma mark - Private Methods

- (void)loadDataWithPageNo:(NSUInteger)pageNo
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    AppUtils *utils = [[AppUtils alloc] init];
    [manager.requestSerializer setValue:utils.appVersion forHTTPHeaderField:@"Version"];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"iOS %@",utils.systemVersion] forHTTPHeaderField:@"Platform"];
    
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [manager.requestSerializer setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    NSNumber *imageWidth = [NSNumber numberWithInt:300];
    [params setObject:imageWidth forKey:@"imgWidth"];
    [params setObject:[NSNumber numberWithInteger:pageNo] forKey:@"page"];
    [params setObject:[NSNumber numberWithInt:15] forKey:@"pageSize"];
    [params setObject:_cityId forKey:@"locality"];
    
    NSString *backUrlForCheck = _requestUrl;
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    TZProgressHUD *hud;
    if (pageNo == 0) {
        hud = [[TZProgressHUD alloc] init];
        __weak typeof(self)weakSelf = self;
        [hud showHUDInViewController:weakSelf content:64];
    }
    //获取列表信息
    [manager GET:_requestUrl parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"%@", responseObject);
        if (hud) {
            [hud hideTZHUD];
        }
        NSInteger code = [[responseObject objectForKey:@"code"] integerValue];
        if (code == 0) {
            if ([backUrlForCheck isEqualToString:_requestUrl]) {
                NSArray *jsonDic = [responseObject objectForKey:@"result"];
                if (jsonDic.count == 15) {
                    _enableLoadMoreNormal = YES;
                }
                for (id poiDic in [responseObject objectForKey:@"result"]) {
                    [self.dataSource addObject:[PoiFactory poiWithJson:poiDic]];
                }
                [self.tableView reloadData];
                _currentPageNormal = pageNo;
            } else {
                NSLog(@"用户切换页面了，我不应该加载数据");
            }
        } else {
            if (self.isShowing) {
                [SVProgressHUD showHint:[NSString stringWithFormat:@"%@",[[responseObject objectForKey:@"err"] objectForKey:@"message"]]];
            }
        }
        [self loadMoreCompletedNormal];
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@", error);
        if (hud) {
            [hud hideTZHUD];
        }
        [self loadMoreCompletedNormal];
        
        if (self.isShowing) {
            [SVProgressHUD showHint:HTTP_FAILED_HINT];
        }
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    }];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 70;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)sectio
{
//    return 50;
    return self.tripDetail ? 50 : 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.5;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}

/**
 *  设置cell的头部
 *
 *  @param tableView 视图tableView
 *  @param section   标识哪一组
 *
 *  @return headerView
 */
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    // 1.创建头部视图
    UIView * header = [[UIView alloc] init];
    header.frame = CGRectMake(0, 0, SCREEN_WIDTH, 50);
    header.backgroundColor = [UIColor whiteColor];
    
    // 2.创建头部视图列表
    NSMutableArray * siteArray = [NSMutableArray array];
    NSLog(@"%@",self.tripDetail);
    for (CityDestinationPoi * poi in self.tripDetail.destinations){
        NSString * zhName = poi.zhName;
        [siteArray addObject:zhName];
    }
    // 设置城市Button的一些基本属性
    UIButton * scene = [UIButton buttonWithType:UIButtonTypeCustom];
    self.cityButton = scene;
    scene.selected = NO;
    [scene setTitle:siteArray[_currentCityIndex] forState:UIControlStateNormal];
    scene.titleLabel.font = [UIFont boldSystemFontOfSize:17.0];
    [scene setTitleColor:COLOR_TEXT_I forState:UIControlStateNormal];
    [scene addTarget:self action:@selector(sceneClick:) forControlEvents:UIControlEventTouchDown];
    scene.frame = CGRectMake(0, 0, SCREEN_WIDTH * 0.5, 50);
    [scene setImage:[UIImage imageNamed:@"ArtboardBottom@3x"] forState:UIControlStateNormal];
    [scene setImage:[UIImage imageNamed:@"ArtboardTop@3x"] forState:UIControlStateSelected];
    scene.imageEdgeInsets = UIEdgeInsetsMake(0, 80, 0, 0);
    scene.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 40);
    [header addSubview:scene];
    
    // 设置分类界面的一些基本属性
    NSArray * typeArray = @[@"景点",@"美食",@"购物"];
    UIButton * type = [UIButton buttonWithType:UIButtonTypeCustom];
    type.titleLabel.font = [UIFont boldSystemFontOfSize:17.0];
    self.categoryButton = type;
    type.selected = NO;
    [type setTitle:typeArray[_currentListTypeIndex] forState:UIControlStateNormal];
    [type setTitleColor:COLOR_TEXT_I forState:UIControlStateNormal];
    [type addTarget:self action:@selector(typeClick:) forControlEvents:UIControlEventTouchDown];
    [type setImage:[UIImage imageNamed:@"ArtboardBottom@3x"] forState:UIControlStateNormal];
    [type setImage:[UIImage imageNamed:@"ArtboardTop@3x"] forState:UIControlStateSelected];
    type.imageEdgeInsets = UIEdgeInsetsMake(0, 80, 0, 0);
    type.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 40);
    type.frame = CGRectMake(SCREEN_WIDTH * 0.5, 0, SCREEN_WIDTH * 0.5, 50);
    [header addSubview:type];

    // 3.添加中间的分割线
    UIView * line = [[UIView alloc] init];
    line.frame = CGRectMake(SCREEN_WIDTH * 0.5, 10, 1, 30);
    line.backgroundColor = COLOR_LINE;
    [header addSubview:line];
    
    return header;
}

/**
 *  添加监听弹出下拉菜单的事件
 */
- (void)sceneClick:(UIButton *)scene
{
    NSLog(@"%s",__func__);
    
    scene.selected = !scene.selected;
    
    // 1.创建下拉菜单
    HWDropdownMenu *menu = [HWDropdownMenu menu];
    menu.delegate = self;
    self.dropDownMenu = menu;
    // 2.设置传入数组
    NSMutableArray * siteArray = [NSMutableArray array];
    NSLog(@"%@",self.tripDetail);
    for (CityDestinationPoi * poi in self.tripDetail.destinations){
        NSString * zhName = poi.zhName;
        [siteArray addObject:zhName];
    }
    
    // 3.设置内容
    DropDownViewController *vc = [[DropDownViewController alloc] init];
    vc.delegateDrop = self;
    vc.siteArray = siteArray;
    vc.showAccessory = _currentCityIndex;
    vc.tag = 1;
    vc.view.height = siteArray.count * 44;
    vc.view.width = SCREEN_WIDTH / 3;
    menu.contentController = vc;
    
    // 4.显示
    [menu showFrom:scene];
}

- (void)typeClick:(UIButton *)type
{
    NSLog(@"%s",__func__);
    
    type.selected = !type.selected;
    
    // 1.创建下拉菜单
    HWDropdownMenu *menu = [HWDropdownMenu menu];
    menu.delegate = self;
    self.dropDownMenu = menu;
    
    // 2.设置传入数组
    NSArray * siteArray = @[@"景点",@"美食",@"购物"];
    
    // 3.设置内容
    DropDownViewController *vc = [[DropDownViewController alloc] init];
    vc.delegateDrop = self;
    vc.siteArray = siteArray;
    vc.showAccessory = _currentListTypeIndex;
    vc.tag = 2;
    vc.view.height = siteArray.count * 44;
    vc.view.width = SCREEN_WIDTH / 3;
    menu.contentController = vc;
    
    // 4.显示
    [menu showFrom:type];
}

#pragma mark - HWDropdownMenuDelegate
/**
 *  下拉菜单被销毁了
 */
- (void)dropdownMenuDidDismiss:(HWDropdownMenu *)menu
{
    self.cityButton.selected = NO;
    self.categoryButton.selected = NO;
    // 让箭头向下
    //    [titleButton setImage:[UIImage imageNamed:@"navigationbar_arrow_down"] forState:UIControlStateNormal];
}

/**
 *  下拉菜单显示了
 */
- (void)dropdownMenuDidShow:(HWDropdownMenu *)menu
{
    
    self.categoryButton.selected = YES;
    // 让箭头向上
    //    [titleButton setImage:[UIImage imageNamed:@"navigationbar_arrow_up"] forState:UIControlStateNormal];
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SuperPoi *poi = [self.dataSource objectAtIndex:indexPath.row];
    
    NSLog(@"%@",self.tripDetail);

    BOOL isAdded = NO;
    NSMutableArray *oneDayArray = [self.tripDetail.itineraryList objectAtIndex:_currentDayIndex];
    for (SuperPoi *tripPoi in oneDayArray) {
        if ([tripPoi.poiId isEqualToString:poi.poiId]) {
            isAdded = YES;
        }
    }
    
    TripPoiListTableViewCell *poiCell = [tableView dequeueReusableCellWithIdentifier:addPoiCellIndentifier forIndexPath:indexPath];
    poiCell.tripPoi = poi;
    
    if (_shouldEdit) {
        poiCell.actionBtn.hidden = NO;
        poiCell.actionBtn.tag = indexPath.row;
        poiCell.actionBtn.selected = isAdded;
        [poiCell.actionBtn removeTarget:self action:@selector(addPoi:) forControlEvents:UIControlEventTouchUpInside];
        [poiCell.actionBtn addTarget:self action:@selector(addPoi:) forControlEvents:UIControlEventTouchUpInside];
    }
    return poiCell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    SuperPoi *tripPoi = [self.dataSource objectAtIndex:indexPath.row];
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    switch (tripPoi.poiType) {
        case kSpotPoi: {
            SpotDetailViewController *spotDetailCtl = [[SpotDetailViewController alloc] init];
            spotDetailCtl.spotId = tripPoi.poiId;
            
            [self.navigationController pushViewController:spotDetailCtl animated:YES];
            
        }
            break;
        default: {
            CommonPoiDetailViewController *ctl = [PoiDetailViewControllerFactory poiDetailViewControllerWithPoiType:tripPoi.poiType];
            ctl.poiId = tripPoi.poiId;
            [self.navigationController pushViewController:ctl animated:YES];
            
        }
            break;
    }
}

#pragma mark - UIScrollViewDelegate

- (void) scrollViewDidScroll:(UIScrollView *)scrollView
{
    if ([scrollView isEqual:self.tableView]) {
        if (!_isLoadingMoreNormal && _didEndScrollNormal && _enableLoadMoreNormal) {
            CGFloat scrollPosition = scrollView.contentSize.height - scrollView.frame.size.height - scrollView.contentOffset.y;
            if (scrollPosition < 44.0) {
                _didEndScrollNormal = NO;
                [self beginLoadingMoreNormal];
            }
        }
    }
    
}

- (void) scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if ([scrollView isEqual:self.tableView]) {
        _didEndScrollNormal = YES;
    }
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == actionSheet.cancelButtonIndex) {
        return;
    }
    SuperPoi *poi;
    poi = [_dataSource objectAtIndex:actionSheet.tag];
    NSArray *platformArray = [ConvertMethods mapPlatformInPhone];
    switch (buttonIndex) {
        case 0:
            switch ([[[platformArray objectAtIndex:0] objectForKey:@"type"] intValue]) {
                case kAMap:
                    [ConvertMethods jumpGaodeMapAppWithPoiName:poi.zhName lat:poi.lat lng:poi.lng];
                    break;
                    
                case kBaiduMap: {
                    [ConvertMethods jumpBaiduMapAppWithPoiName:poi.zhName lat:poi.lat lng:poi.lng];
                }
                    break;
                    
                case kAppleMap: {
                    [ConvertMethods jumpAppleMapAppWithPoiName:poi.zhName lat:poi.lat lng:poi.lng];
                }
                    
                default:
                    break;
            }
            break;
            
        case 1:
            switch ([[[platformArray objectAtIndex:1] objectForKey:@"type"] intValue]) {
                case kAMap:
                    [ConvertMethods jumpGaodeMapAppWithPoiName:poi.zhName lat:poi.lat lng:poi.lng];
                    break;
                    
                case kBaiduMap: {
                    [ConvertMethods jumpBaiduMapAppWithPoiName:poi.zhName lat:poi.lat lng:poi.lng];
                }
                    break;
                    
                case kAppleMap: {
                    [ConvertMethods jumpAppleMapAppWithPoiName:poi.zhName lat:poi.lat lng:poi.lng];
                }
                    break;
                    
                default:
                    break;
            }
            break;
            
        case 2:
            switch ([[[platformArray objectAtIndex:2] objectForKey:@"type"] intValue]) {
                case kAMap:
                    [ConvertMethods jumpGaodeMapAppWithPoiName:poi.zhName lat:poi.lat lng:poi.lng];
                    break;
                    
                case kBaiduMap: {
                    [ConvertMethods jumpBaiduMapAppWithPoiName:poi.zhName lat:poi.lat lng:poi.lng];
                }
                    break;
                    
                case kAppleMap: {
                    [ConvertMethods jumpAppleMapAppWithPoiName:poi.zhName lat:poi.lat lng:poi.lng];
                }                    break;
                    
                default:
                    break;
            }
            break;
            
        default:
            break;
    }
}

#pragma mark - Collection view

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    NSArray *oneDayArray = [self.tripDetail.itineraryList objectAtIndex:_currentDayIndex];
    return oneDayArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    SelectDestCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"sdest_cell" forIndexPath:indexPath];
    NSArray *oneDayArray = [self.tripDetail.itineraryList objectAtIndex:_currentDayIndex];
    SuperPoi *tripPoi = [oneDayArray objectAtIndex:indexPath.row];
    
    NSString *txt = [NSString stringWithFormat:@" %ld %@ ", (indexPath.row + 1), tripPoi.zhName];
    cell.textLabel.text = txt;
    CGSize size = [txt sizeWithAttributes:@{NSFontAttributeName : cell.textLabel.font}];
    cell.textLabel.frame = CGRectMake(0, 15, size.width, 25);
    cell.deleteBtn.frame = CGRectMake(size.width-13, 5, 20, 20);
    cell.deleteBtn.tag = indexPath.row;
    [cell.deleteBtn removeTarget:self action:@selector(deletePoi:) forControlEvents:UIControlEventTouchUpInside];
    [cell.deleteBtn addTarget:self action:@selector(deletePoi:) forControlEvents:UIControlEventTouchUpInside];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    NSArray *oneDayArray = [self.tripDetail.itineraryList objectAtIndex:_currentDayIndex];
    SuperPoi *tripPoi = [oneDayArray objectAtIndex:indexPath.row];
    SpotDetailViewController *spotDetailCtl = [[SpotDetailViewController alloc] init];
    spotDetailCtl.spotId = tripPoi.poiId;
    
    [self.navigationController pushViewController:spotDetailCtl animated:YES];
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSArray *oneDayArray = [self.tripDetail.itineraryList objectAtIndex:_currentDayIndex];
    SuperPoi *tripPoi = [oneDayArray objectAtIndex:indexPath.row];
    NSString *txt = [NSString stringWithFormat:@"%ld %@", (indexPath.row + 1), tripPoi.zhName];
    CGSize size = [txt sizeWithAttributes:@{NSFontAttributeName : [UIFont systemFontOfSize:17]}];
    return CGSizeMake(size.width, 49);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 15.0;
}

// 实现代理方法
- (void)didSelectedcityIndex:(NSInteger)cityindex categaryIndex:(NSInteger)categaryIndex andTag:(int)tag
{
    [self.dropDownMenu dismiss];
    if (tag == 1) {
        _currentCityIndex = cityindex;
    }else{
        _currentListTypeIndex = categaryIndex;
        if (_currentListTypeIndex == 0){
            _currentCategory= @"景点";
        }else if (_currentListTypeIndex == 1) {
            _currentCategory = @"美食";
        }else if (_currentListTypeIndex== 2) {
            _currentCategory = @"购物";
        }else if (_currentListTypeIndex == 3) {
            _currentCategory = @"酒店";
        }

    }
    // 刷新整个表格数据
    [self resetContents];
}


#pragma mark - SelectDelegate
- (void) selectItem:(NSString *)str atIndex:(NSIndexPath *)indexPath {

    [self resetContents];
}

#pragma mark - updateSelectedPlanDelegate
- (void) updateSelectedPlan
{
    [self.tableView reloadData];
    [self.selectPanel reloadData];
}

- (void) resetContents {
    _isLoadingMoreNormal = YES;
    _didEndScrollNormal = YES;
    _enableLoadMoreNormal = NO;
    CityDestinationPoi *poi = [self.tripDetail.destinations objectAtIndex:_currentCityIndex];
    _cityId = poi.cityId;
    _cityName = poi.zhName;
    _requestUrl = _urlArray[_currentListTypeIndex];
    [self.dataSource removeAllObjects];
    [self.tableView reloadData];
    _currentPageNormal = 0;
    [self loadDataWithPageNo:_currentPageNormal];
}

@end
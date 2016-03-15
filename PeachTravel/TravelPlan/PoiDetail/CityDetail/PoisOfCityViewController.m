//
//  PoisOfCityViewController.m
//  PeachTravel
//
//  Created by liangpengshuai on 11/25/14.
//  Copyright (c) 2014 com.aizou.www. All rights reserved.
//

#import "PoisOfCityViewController.h"
#import "TripPoiListTableViewCell.h"
#import "TZFilterViewController.h"
#import "CityDestinationPoi.h"
#import "RecommendsOfCity.h"
#import "CommonPoiDetailViewController.h"
#import "RestaurantDetailViewController.h"
#import "ShoppingDetailViewController.h"
#import "SuperWebViewController.h"
#import "PoisSearchViewController.h"
#import "SelectionTableViewController.h"

@interface PoisOfCityViewController () <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, TZFilterViewDelegate, UIGestureRecognizerDelegate, UIActionSheetDelegate, UISearchDisplayDelegate, UICollectionViewDataSource, UICollectionViewDelegate,updateSelectedPlanDelegate,SelectDelegate>

@property (nonatomic, strong) UIButton *rightItemBtn;
@property (nonatomic, strong) RecommendsOfCity *dataSource;
@property (nonatomic, strong) UIActivityIndicatorView *indicatroView;
@property (nonatomic, strong) UIView *footerView;

@property (nonatomic, strong) TripDetail *backTripDetail;
//如果从攻略编辑界面进来，则代表的是美食列表/购物列表
@property (nonatomic, strong) NSMutableArray *tripPoiList;

//管理普通 tableview 的加载状态
@property (nonatomic) NSUInteger currentPageNormal;
@property (nonatomic, assign) BOOL isLoadingMoreNormal;
@property (nonatomic, assign) BOOL didEndScrollNormal;
@property (nonatomic, assign) BOOL enableLoadMoreNormal;

@property (nonatomic, copy) NSString *searchText;
@property (nonatomic, strong) TZProgressHUD *hud;
@property (nonatomic, strong) UIButton *filterBtn;
@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) UICollectionView *selectPanel;


@property (nonatomic) NSInteger currentCityIndex;
@end

@implementation PoisOfCityViewController

static NSString *poisOfCityCellIdentifier = @"tripPoiListCell";

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setAutomaticallyAdjustsScrollViewInsets:YES];
    [self setExtendedLayoutIncludesOpaqueBars:YES];
    _currentCityIndex = 0;
    if (self.shouldEdit) {
        UIBarButtonItem *lbtn = [[UIBarButtonItem alloc] initWithTitle:@"完成" style:UIBarButtonItemStylePlain target:self action:@selector(finishAdd:)];
        self.navigationItem.leftBarButtonItem = lbtn;
    } else {
        UIButton *button =  [UIButton buttonWithType:UIButtonTypeCustom];
        [button setImage:[UIImage imageNamed:@"common_icon_navigation_back_normal"] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(goBack)forControlEvents:UIControlEventTouchUpInside];
        [button setFrame:CGRectMake(0, 0, 48, 30)];
        button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithCustomView:button];
        self.navigationItem.leftBarButtonItem = barButton;
    }
    
    NSMutableArray *rbItems = [[NSMutableArray alloc] init];
    
    if (self.tripDetail) {
        _backTripDetail = [self.tripDetail backUpTrip];
        CityDestinationPoi * destination = self.backTripDetail.destinations[self.page];
        _zhName = destination.zhName;
        _cityId = destination.cityId;
        if (self.backTripDetail.destinations.count > 1) {
            TZButton *btn = [TZButton buttonWithType:UIButtonTypeCustom];
            btn.frame = CGRectMake(0, 0, 44, 44);
            [btn setTitle:@"城市" forState:UIControlStateNormal];
            [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [btn setImage:[UIImage imageNamed:@"ic_shaixuan_.png"] forState:UIControlStateNormal];
            btn.titleLabel.font = [UIFont boldSystemFontOfSize:16];
            [btn addTarget:self action:@selector(filter:) forControlEvents:UIControlEventTouchUpInside];
            btn.imagePosition = IMAGE_AT_RIGHT;
            UIBarButtonItem *cbtn = [[UIBarButtonItem alloc] initWithCustomView:btn];
            [rbItems addObject:cbtn];
        }
    }
    
    UIBarButtonItem *lbtn = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ic_common_search.png"] style:UIBarButtonItemStylePlain target:self action:@selector(beginSearch:)];
    [rbItems addObject:lbtn];
    self.navigationItem.rightBarButtonItem = lbtn;
    
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.backgroundColor = APP_PAGE_COLOR;
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.tableView.separatorColor = COLOR_LINE;
    [self.tableView registerNib:[UINib nibWithNibName:@"TripPoiListTableViewCell" bundle:nil] forCellReuseIdentifier:poisOfCityCellIdentifier];
    [self.view addSubview:self.tableView];
    
    for (CityDestinationPoi *poi in _tripDetail.destinations) {
        if ([poi.cityId isEqualToString:_cityId]) {
            _zhName = poi.zhName;
            break;
        }
    }
    
    if (_poiType == kRestaurantPoi) {
        self.navigationItem.title = [NSString stringWithFormat:@"%@美食", _zhName];
    } else if (_poiType == kShoppingPoi) {
        self.navigationItem.title = [NSString stringWithFormat:@"%@购物", _zhName];
    }
    
    _currentPageNormal = 0;
    
    _hud = [[TZProgressHUD alloc] init];
    __weak typeof(PoisOfCityViewController *)weakSelf = self;
    [_hud showHUDInViewController:weakSelf];
    
    if (_poiType == kRestaurantPoi) {
        _tripPoiList = self.backTripDetail.restaurantsList;
    } else if (_poiType == kShoppingPoi) {
        _tripPoiList = self.backTripDetail.shoppingList;
    }
    
    if (!_shouldEdit) {
        [self loadIntroductionOfCity];
    } else {
        [self loadDataPoisOfCity:_currentPageNormal];
        [self setupSelectPanel];
        _tableView.contentInset = UIEdgeInsetsMake(0, 0, 50, 0);
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)goBack
{
    if (self.navigationController.viewControllers.count == 1) {
        [self dismissViewControllerAnimated:YES completion:nil];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark - private method

- (void) setupSelectPanel {
    CGRect collectionViewFrame = CGRectMake(0, CGRectGetHeight(self.view.bounds) - 49, CGRectGetWidth(self.view.bounds), 49);
    UICollectionViewFlowLayout *aFlowLayout = [[UICollectionViewFlowLayout alloc] init];
    [aFlowLayout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    self.selectPanel = [[UICollectionView alloc] initWithFrame:collectionViewFrame collectionViewLayout:aFlowLayout];
    self.selectPanel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    self.selectPanel.showsHorizontalScrollIndicator = NO;
    self.selectPanel.showsVerticalScrollIndicator = NO;
    self.selectPanel.delegate = self;
    self.selectPanel.dataSource = self;
    self.selectPanel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    self.selectPanel.contentInset = UIEdgeInsetsMake(0, 15, 0, 15);
    [self.selectPanel registerClass:[SelectDestCell class] forCellWithReuseIdentifier:@"sdest_cell"];
    self.selectPanel.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:_selectPanel];
    
    UIView *spaceView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.view.bounds) - 49, self.selectPanel.frame.size.width, 0.6)];
    spaceView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    spaceView.backgroundColor = COLOR_LINE;
    spaceView.layer.shadowColor = COLOR_LINE.CGColor;
    spaceView.layer.shadowOffset = CGSizeMake(0, -1.0);
    spaceView.layer.shadowOpacity = 0.33;
    spaceView.layer.shadowRadius = 1.0;
    [self.view addSubview:spaceView];
    
}

#pragma mark - setter & getter

- (RecommendsOfCity *)dataSource
{
    if (!_dataSource) {
        _dataSource = [[RecommendsOfCity alloc] init];
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

- (void)setTripDetail:(TripDetail *)tripDetail
{
    _tripDetail = tripDetail;
}

#pragma mark - Private Methods

- (void)loadIntroductionOfCity
{
    NSString *requsetUrl;
    
    if (_poiType == kRestaurantPoi) {
        requsetUrl = [NSString stringWithFormat:@"%@%@/restaurant", API_GET_GUIDE_CITY,_cityId];
    }
    if (_poiType == kShoppingPoi) {
        requsetUrl = [NSString stringWithFormat:@"%@%@/shopping", API_GET_GUIDE_CITY,_cityId];
        
        
    }
    //获取城市的美食列表信息
    [LXPNetworking GET:requsetUrl parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"%@", responseObject);
        NSInteger code = [[responseObject objectForKey:@"code"] integerValue];
        if (code == 0) {
            self.dataSource = [[RecommendsOfCity alloc] initWithJson:[responseObject objectForKey:@"result"]];
            [self loadDataPoisOfCity:_currentPageNormal];
        } else {
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self showHint:HTTP_FAILED_HINT];
    }];
}
/**
 *  加载城市的poi列表
 *
 *  @param pageNO
 */
- (void)loadDataPoisOfCity:(NSUInteger)pageNO
{
    NSString *requsetUrl;
    if (_poiType == kRestaurantPoi) {
        requsetUrl = API_GET_RESTAURANTSLIST_CITY;
        
    } else if (_poiType == kShoppingPoi) {
        requsetUrl = API_GET_SHOPPINGLIST_CITY;
    }
    
    //加载之前备份一个城市的 id 与从网上取完数据后的 id 对比，如果不一致说明用户切换了城市
    NSString *backUpCityId = _cityId;
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    NSNumber *imageWidth = [NSNumber numberWithInt:300];
    [params setObject:imageWidth forKey:@"imgWidth"];
    [params setObject:[NSNumber numberWithInt:15] forKey:@"pageSize"];
    [params setObject:[NSNumber numberWithInteger:pageNO] forKey:@"page"];
    [params setObject:_cityId forKey:@"locality"];
    
    //获取城市的美食.购物列表信息
    [LXPNetworking GET:requsetUrl parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"%@",responseObject);
        if (_hud) {
            [_hud hideTZHUD];
            _hud = nil;
        }
        [self loadMoreCompletedNormal];
        if ([backUpCityId isEqualToString:_cityId]) {
            NSInteger code = [[responseObject objectForKey:@"code"] integerValue];
            if (code == 0) {
                NSArray *jsonDic = [responseObject objectForKey:@"result"];
                if (jsonDic.count == 15) {
                    _enableLoadMoreNormal = YES;
                } else if (jsonDic.count == 0) {
                    [self showHint:@"没有了~"];
                }
                [self.dataSource addRecommendList:jsonDic];
                [self updateView];
                _currentPageNormal = pageNO;
            }
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [SVProgressHUD dismiss];
        if (_hud) {
            [_hud hideTZHUD];
            _hud = nil;
        }
        NSLog(@"%@", error);
        [self loadMoreCompletedNormal];
        [self showHint:HTTP_FAILED_HINT];
    }];
}

/**
 *  切换城市的poi列表
 *
 *  @param pageNO
 */
- (void)loadDataPoisOfCity:(NSUInteger)pageNO
                   withUrl:(NSString *)url
{
    //加载之前备份一个城市的 id 与从网上取完数据后的 id 对比，如果不一致说明用户切换了城市
    NSString *backUpCityId = _cityId;
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    NSNumber *imageWidth = [NSNumber numberWithInt:300];
    [params setObject:imageWidth forKey:@"imgWidth"];
    [params setObject:[NSNumber numberWithInt:15] forKey:@"pageSize"];
    [params setObject:[NSNumber numberWithInteger:pageNO] forKey:@"page"];
    
    //获取城市的美食.购物列表信息
    [LXPNetworking GET:url parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (_hud) {
            [_hud hideTZHUD];
            _hud = nil;
        }
        [self loadMoreCompletedNormal];
        if ([backUpCityId isEqualToString:_cityId]) {
            NSInteger code = [[responseObject objectForKey:@"code"] integerValue];
            if (code == 0) {
                NSArray *jsonDic = [responseObject objectForKey:@"result"];
                if (jsonDic.count == 15) {
                    _enableLoadMoreNormal = YES;
                } else if (jsonDic.count == 0) {
                    [self showHint:@"没有了~"];
                }
                [self.dataSource addRecommendList:jsonDic];
                [self updateView];
                _currentPageNormal = pageNO;
                [_tableView reloadData];
                
            }
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [SVProgressHUD dismiss];
        if (_hud) {
            [_hud hideTZHUD];
            _hud = nil;
        }
        NSLog(@"%@", error);
        [self loadMoreCompletedNormal];
        [self showHint:HTTP_FAILED_HINT];
    }];
}

- (void)updateView
{
    [self.tableView reloadData];
}

- (void)filter:(id)sender
{
    NSMutableArray *array = [[NSMutableArray alloc] init];
    SelectionTableViewController *selectCtl = [[SelectionTableViewController alloc]init];
    for (CityDestinationPoi *poi in _backTripDetail.destinations) {
        [array addObject:poi.zhName];
    }
    selectCtl.contentItems = [NSArray arrayWithArray:array];
    selectCtl.titleTxt = @"筛选";
    selectCtl.delegate = self;
    selectCtl.selectItem = array[_currentCityIndex];
    TZNavigationViewController *nav = [[TZNavigationViewController alloc] initWithRootViewController:selectCtl];
    [self presentViewController:nav animated:YES completion:nil];
}


#pragma mark - IBAction Methods

/**
 *  添加一个 poi
 *
 *  @param sender
 */
- (IBAction)addPoi:(UIButton *)sender
{
    sender.userInteractionEnabled = NO;
    CGPoint point;
    NSIndexPath *indexPath;
    TripPoiListTableViewCell *cell;
    point = [sender convertPoint:CGPointZero toView:_tableView];
    indexPath = [_tableView indexPathForRowAtPoint:point];
    cell = (TripPoiListTableViewCell *)[_tableView cellForRowAtIndexPath:indexPath];
    
    
    SuperPoi *poi = [_dataSource.recommendList objectAtIndex:sender.tag];
    
    if (!cell.actionBtn.isSelected) {
        [_selectedArray addObject:poi];
        [_tripPoiList addObject:poi];
        
        NSIndexPath *lnp = [NSIndexPath indexPathForItem:_selectedArray.count - 1 inSection:0];
        [self.selectPanel performBatchUpdates:^{
            [self.selectPanel insertItemsAtIndexPaths:[NSArray arrayWithObject:lnp]];
        } completion:^(BOOL finished) {
            [self.selectPanel scrollToItemAtIndexPath:lnp
                                     atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
            sender.userInteractionEnabled = YES;
        }];
        
    } else {
        int index = -1;
        NSInteger count = _selectedArray.count;
        for (int i = 0; i < count; ++i) {
            SuperPoi *tripPoi = [_selectedArray objectAtIndex:i];
            if ([tripPoi.poiId isEqualToString:poi.poiId]) {
                [_selectedArray removeObjectAtIndex:i];
                [_tripPoiList removeObjectAtIndex:i];
                index = i;
                break;
            }
        }
        
        if (index != -1) {
            NSIndexPath *lnp = [NSIndexPath indexPathForItem:index inSection:0];
            [self.selectPanel performBatchUpdates:^{
                [self.selectPanel deleteItemsAtIndexPaths:[NSArray arrayWithObject:lnp]];
            } completion:^(BOOL finished) {
                sender.userInteractionEnabled = YES;
                [self.selectPanel reloadData];
            }];
        }
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.15 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        cell.actionBtn.selected = !cell.actionBtn.selected;
    });
}

- (void)deletePoi:(UIButton *)sender
{
    SuperPoi *poi = [_selectedArray objectAtIndex:sender.tag];
    int index = -1;
    NSInteger count = _selectedArray.count;
    for (int i = 0; i < count; ++i) {
        SuperPoi *tripPoi = [_selectedArray objectAtIndex:i];
        if ([tripPoi.poiId isEqualToString:poi.poiId]) {
            [_selectedArray removeObjectAtIndex:i];
            index = i;
            break;
        }
    }
    
    for (SuperPoi *oldPoi in _tripPoiList) {
        if ([poi.poiId isEqualToString:oldPoi.poiId]) {
            [_tripPoiList removeObject:oldPoi];

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

- (IBAction)finishAdd:(id)sender
{
    [_backTripDetail saveTrip:^(BOOL isSuccesss) {
        NSLog(@"%d",isSuccesss);
        if (isSuccesss) {
            if (_poiType == kRestaurantPoi) {
                _tripDetail.restaurantsList = _backTripDetail.restaurantsList;
            } else if (_poiType == kShoppingPoi) {
                _tripDetail.shoppingList = _backTripDetail.shoppingList;
            }
            NSLog(@"%@",_tripDetail.restaurantsList);
            _tripDetail.backUpJson = _backTripDetail.backUpJson;
            [_delegate finishEdit];
            [self dismissViewControllerAnimated:YES completion:nil];
        } else {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"保存失败，请检查你的网络设置" delegate:self cancelButtonTitle:@"直接返回" otherButtonTitles:@"确定", nil];
            [alertView dismissWithClickedButtonIndex:1 animated:YES];
            [alertView showAlertViewWithBlock:^(NSInteger buttonIndex) {
                if (buttonIndex == 0) {
                    [self dismissViewControllerAnimated:YES completion:nil];
                }
            }];
        }
    }];
}

/**
 *  点击搜索按钮开始搜索
 *
 *  @param sender
 */
- (IBAction)beginSearch:(id)sender
{
    PoisSearchViewController *poiSearchCtl = [[PoisSearchViewController alloc]init];
    poiSearchCtl.poiType = _poiType;
    poiSearchCtl.tripDetail = _backTripDetail;
    poiSearchCtl.cityId = _cityId;
    poiSearchCtl.zhName = _zhName;
    poiSearchCtl.delegate = self;
    poiSearchCtl.shouldEdit = _shouldEdit;
    [poiSearchCtl setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];
    TZNavigationViewController *tznavc = [[TZNavigationViewController alloc] initWithRootViewController:poiSearchCtl];
    
    [self presentViewController:tznavc animated:YES completion:nil];
}

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

- (void)showIntruductionOfCity
{
    SuperWebViewController *webCtl = [[SuperWebViewController alloc] init];
    if (_poiType == kRestaurantPoi) {
        webCtl.titleStr = @"美食攻略";
        
    } else if (_poiType == kShoppingPoi) {
        webCtl.titleStr = @"购物攻略";
        
    }
    webCtl.urlStr = _dataSource.detailUrl;
    [self.navigationController pushViewController:webCtl animated:YES];
}

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
    [self loadDataPoisOfCity:(_currentPageNormal + 1)];
    
    NSLog(@"我要加载到第%lu",(long)_currentPageNormal+1);
    
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

#pragma mark - TZFilterViewDelegate

-(void)didSelectedItems:(NSArray *)itemIndexPath
{
    CityDestinationPoi *destination = [self.backTripDetail.destinations objectAtIndex:[[itemIndexPath firstObject] integerValue]];
    _cityId = destination.cityId;
    _zhName = destination.zhName;
    
    if (_poiType == kRestaurantPoi) {
        self.navigationItem.title = [NSString stringWithFormat:@"吃在%@", _zhName];
    } else if (_poiType == kShoppingPoi) {
        self.navigationItem.title = [NSString stringWithFormat:@"%@购物", _zhName];
    }
    
    [_dataSource.recommendList removeAllObjects];
    _currentPageNormal = 0;
    [self.tableView reloadData];
    [self loadDataPoisOfCity:_currentPageNormal];
}


#pragma mark - UITableViewDataSource & delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (![_dataSource.desc isBlankString] && _dataSource.desc != nil) {
        if (section == 0) {
            return 0;
        } else {
            return _dataSource.recommendList.count;
        }
    }
    return _dataSource.recommendList.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 90;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (![tableView isEqual:self.tableView]) {
        return 1;
    }
    if (!_dataSource) {
        return 0;
    }
    if (![_dataSource.desc isBlankString] && _dataSource.desc != nil) {
        return 2;
    }
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (![_dataSource.desc isBlankString] && _dataSource.desc != nil) {
        if (section == 0) {
            return 100;
        }
        return CGFLOAT_MIN;
    }
    return CGFLOAT_MIN;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return CGFLOAT_MIN;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (_dataSource.desc != nil && ![_dataSource.desc isBlankString]) {
        if (section == 0) {
            UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, self.tableView.bounds.size.width, 100)];
            btn.titleLabel.font = [UIFont systemFontOfSize:13.0];
            btn.titleEdgeInsets = UIEdgeInsetsMake(0, 24, 0, 24);
            NSUInteger len = [_dataSource.desc length];
            
            NSMutableAttributedString *desc = [[NSMutableAttributedString alloc] initWithString:_dataSource.desc];
            [desc addAttribute:NSForegroundColorAttributeName value:COLOR_TEXT_II range:NSMakeRange(0, len)];
            NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
            style.lineBreakMode = NSLineBreakByTruncatingTail;
            style.lineSpacing = 5;
            [desc addAttribute:NSParagraphStyleAttributeName value:style range:NSMakeRange(0, len)];
            [btn setAttributedTitle:desc forState:UIControlStateNormal];
            
            desc = [[NSMutableAttributedString alloc] initWithAttributedString:desc];
            [desc addAttribute:NSForegroundColorAttributeName value:COLOR_DISABLE range:NSMakeRange(0, len)];
            [btn setAttributedTitle:desc forState:UIControlStateHighlighted];
            [btn addTarget:self action:@selector(showIntruductionOfCity) forControlEvents:UIControlEventTouchUpInside];
            btn.titleLabel.numberOfLines = 2;
            
            UILabel *moreLabel = [[UILabel alloc] initWithFrame:CGRectMake(btn.bounds.size.width-49, btn.bounds.size.height-31, 30, 20)];
            moreLabel.textColor = APP_THEME_COLOR;
            moreLabel.font = [UIFont systemFontOfSize:13.0];
            moreLabel.text = @"全文";
            [btn addSubview:moreLabel];
            
            return btn;
        }
        return nil;
    }
    return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SuperPoi *poi = [_dataSource.recommendList objectAtIndex:indexPath.row];
    NSLog(@"%@",poi);
    TripPoiListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:poisOfCityCellIdentifier forIndexPath:indexPath];
    cell.tripPoi = poi;
    [cell.actionBtn setTitle:@"收集" forState:UIControlStateNormal];
    [cell.actionBtn setTitle:@"已添加" forState:UIControlStateSelected];
    //    如果从攻略列表进来想要添加美食或酒店
    if (_shouldEdit) {
        cell.actionBtn.tag = indexPath.row;
        cell.actionBtn.hidden = NO;
        BOOL isAdded = NO;
        for (SuperPoi *tripPoi in _selectedArray) {
            if ([tripPoi.poiId isEqualToString:poi.poiId]) {
                isAdded = YES;
                break;
            }
        }
        
        cell.actionBtn.selected = isAdded;
        
        [cell.actionBtn removeTarget:self action:@selector(addPoi:) forControlEvents:UIControlEventTouchUpInside];
        [cell.actionBtn addTarget:self action:@selector(addPoi:) forControlEvents:UIControlEventTouchUpInside];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    SuperPoi *poi = [_dataSource.recommendList objectAtIndex:indexPath.row];
    
    if (_poiType == kRestaurantPoi) {
        CommonPoiDetailViewController *restaurantDetailCtl = [[RestaurantDetailViewController alloc] init];
        restaurantDetailCtl.poiId = poi.poiId;
        [self.navigationController pushViewController:restaurantDetailCtl animated:YES];
        NSLog(@"%@", self.navigationController);
    }
    if (_poiType == kShoppingPoi) {
        CommonPoiDetailViewController *shoppingDetailCtl = [[ShoppingDetailViewController alloc] init];
        shoppingDetailCtl.poiId = poi.poiId;
        [self.navigationController pushViewController:shoppingDetailCtl animated:YES];
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
    SuperPoi *poi = [_dataSource.recommendList objectAtIndex:actionSheet.tag];
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
                }
                    break;
                    
                default:
                    break;
            }
            break;
            
        default:
            break;
    }
}

#pragma mark - Collection view

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return _selectedArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    SelectDestCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"sdest_cell" forIndexPath:indexPath];
    SuperPoi *tripPoi = [_selectedArray objectAtIndex:indexPath.row];
    
    NSString *txt = [NSString stringWithFormat:@" %ld.%@      ", (indexPath.row + 1), tripPoi.zhName];
    cell.textLabel.text = txt;
    CGSize size = [txt sizeWithAttributes:@{NSFontAttributeName : cell.textLabel.font}];
    cell.textLabel.frame = CGRectMake(0, 12, size.width, 26);
    cell.deleteBtn.frame = CGRectMake(size.width-11, 5, 20, 20);
    cell.deleteBtn.tag = indexPath.row;
    [cell.deleteBtn removeTarget:self action:@selector(deletePoi:) forControlEvents:UIControlEventTouchUpInside];
    [cell.deleteBtn addTarget:self action:@selector(deletePoi:) forControlEvents:UIControlEventTouchUpInside];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    SuperPoi *tripPoi = [_selectedArray objectAtIndex:indexPath.row];
    
    if (_poiType == kRestaurantPoi) {
        CommonPoiDetailViewController *restaurantDetailCtl = [[RestaurantDetailViewController alloc] init];
        restaurantDetailCtl.poiId = tripPoi.poiId;
        [self.navigationController pushViewController:restaurantDetailCtl animated:YES];
        NSLog(@"%@", self.navigationController);
    }
    if (_poiType == kShoppingPoi) {
        CommonPoiDetailViewController *shoppingDetailCtl = [[ShoppingDetailViewController alloc] init];
        shoppingDetailCtl.poiId = tripPoi.poiId;
        [self.navigationController pushViewController:shoppingDetailCtl animated:YES];
    }
    
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    SuperPoi *tripPoi = [_selectedArray objectAtIndex:indexPath.row];
    NSString *txt = [NSString stringWithFormat:@" %ld.%@      ", (long)(indexPath.row + 1), tripPoi.zhName];
    CGSize size = [txt sizeWithAttributes:@{NSFontAttributeName : [UIFont systemFontOfSize:13]}];
    return CGSizeMake(size.width+5, 49);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 14.0;
}

#pragma mark - updateSelectedPlanDelegate
-(void)updateSelectedPlan
{
    [self.tableView reloadData];
    [self.selectPanel reloadData];
    
}

#pragma mark - SelectDelegate

- (void) selectItem:(NSString *)str atIndex:(NSIndexPath *)indexPath {
    _currentCityIndex = indexPath.row;
    [self resetContents:indexPath.row];
}

- (void) resetContents:(NSInteger ) cityindex {
    _isLoadingMoreNormal = YES;
    _didEndScrollNormal = YES;
    _enableLoadMoreNormal = NO;
    CityDestinationPoi *poi = [self.backTripDetail.destinations objectAtIndex:cityindex];
    NSString *requsetUrl = [[NSString alloc]init];
    if (_poiType == kRestaurantPoi) {
        requsetUrl = API_GET_RESTAURANTSLIST_CITY;
        self.navigationItem.title = [NSString stringWithFormat:@"吃在%@",poi.zhName];
    } else if (_poiType == kShoppingPoi) {
        requsetUrl = API_GET_SHOPPINGLIST_CITY;
        self.navigationItem.title = [NSString stringWithFormat:@"%@购物",poi.zhName];
    }
    
    [self.dataSource.recommendList removeAllObjects];
    [self.tableView reloadData];
    _currentPageNormal = 0;
    [self loadDataPoisOfCity:_currentPageNormal withUrl:requsetUrl];
}

@end

@implementation SelectDestCell

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        _textLabel = [[UILabel alloc] init];
        _textLabel.font = [UIFont systemFontOfSize:13];
        _textLabel.textColor = COLOR_TEXT_III;
        _textLabel.textAlignment = NSTextAlignmentCenter;
        _textLabel.numberOfLines = 1;
        _textLabel.layer.borderColor = COLOR_LINE.CGColor;
        _textLabel.layer.borderWidth = 1.0;
        _textLabel.layer.cornerRadius = 2.0;
        _textLabel.clipsToBounds = YES;
        [self.contentView addSubview:_textLabel];
        _deleteBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
        [_deleteBtn setImage:[UIImage imageNamed:@"delete_album.png"] forState:UIControlStateNormal];
        [self.contentView addSubview:_deleteBtn];
    }
    return self;
}

@end

//
//  FavoriteViewController.m
//  PeachTravel
//
//  Created by Luo Yong on 14/12/2.
//  Copyright (c) 2014年 com.aizou.www. All rights reserved.
//

#import "FavoriteViewController.h"
#import "FavoriteTableViewCell.h"
#import "AccountManager.h"
#import "Favorite.h"
#import "SpotDetailViewController.h"
#import "CommonPoiDetailViewController.h"
#import "CityDetailViewController.h"
#import "TMCache.h"
#import "TravelNoteDetailViewController.h"
#import "PoiDetailViewControllerFactory.h"
#import "SelectionTableViewController.h"

#define PAGE_COUNT 15

@interface FavoriteViewController () <TaoziMessageSendDelegate, SelectDelegate, UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) UIRefreshControl *refreshControl;
@property (nonatomic) BOOL isEditing;

@property (nonatomic, assign) NSInteger selectedIndex;
@property (nonatomic, strong) FavoriteTableViewCell *prototypeCell;

@property (nonatomic, strong) NSMutableArray *dataSource;
@property (nonatomic) NSUInteger currentPage;

@property (nonatomic, strong) UIActivityIndicatorView *indicatroView;
@property (nonatomic, strong) UIView *footerView;
@property (nonatomic, assign) BOOL isLoadingMore;
@property (nonatomic, assign) BOOL didEndScroll;
@property (nonatomic, assign) BOOL enableLoadMore;

@property (nonatomic, strong) NSArray *urlArray;
@property (nonatomic, strong) NSArray *urlTitleArray;

@property (nonatomic, copy) NSString *selectText;

/**
 *  当前显示的收藏类型
 */
@property (nonatomic, copy) NSString *currentFavoriteType;

/**
 *  当前页面是否可见，如果可见显示提示，如果不可见不显示提示
 */
@property (nonatomic) BOOL isVisible;

@end

@implementation FavoriteViewController

#pragma mark - lifeCycle

- (id)init
{
    if (self = [super init]) {
        _urlArray = @[@"all", @"locality", @"vs", @"restaurant", @"shopping", @"hotel", @"travelNote"];
        _urlTitleArray = @[@"全部分类", @"城市", @"景点", @"美食", @"购物", @"酒店", @"游记"];
        _currentFavoriteType = [_urlArray objectAtIndex:0];
        _selectedIndex = -1;
        _currentPage = 0;
        _isLoadingMore = YES;
        _didEndScroll = YES;
        _enableLoadMore = NO;
        _isVisible = YES;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.navigationItem.title = @"收藏夹";
    TZButton *btn = [TZButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(0, 0, 44, 44);
    [btn setTitle:@"筛选" forState:UIControlStateNormal];
    [btn setTitleColor:APP_THEME_COLOR forState:UIControlStateNormal];
    [btn setImage:[UIImage imageNamed:@"ic_shaixuan_.png"] forState:UIControlStateNormal];
    btn.titleLabel.font = [UIFont boldSystemFontOfSize:16];
    [btn addTarget:self action:@selector(switchCate) forControlEvents:UIControlEventTouchUpInside];
    btn.imagePosition = IMAGE_AT_RIGHT;
    UIBarButtonItem *cbtn = [[UIBarButtonItem alloc] initWithCustomView:btn];
    self.navigationItem.rightBarButtonItem = cbtn;
    _selectText = @"全部分类";
    
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.tableView.backgroundColor = APP_PAGE_COLOR;
    [self.view addSubview:self.tableView];
    
    if (_selectToSend) {
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(goBack)];
    } else {
        UIButton *button =  [UIButton buttonWithType:UIButtonTypeCustom];
        [button setImage:[UIImage imageNamed:@"common_icon_navigation_back_normal"] forState:UIControlStateNormal];
        [button setImage:[UIImage imageNamed:@"common_icon_navigation_back_highlight"] forState:UIControlStateHighlighted];
        [button addTarget:self action:@selector(goBack)forControlEvents:UIControlEventTouchUpInside];
        [button setFrame:CGRectMake(0, 0, 48, 30)];
        button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithCustomView:button];
        self.navigationItem.leftBarButtonItem = barButton;
    }
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.view.backgroundColor = APP_PAGE_COLOR;
    [self.tableView registerNib:[UINib nibWithNibName:@"FavoriteTableViewCell" bundle:nil] forCellReuseIdentifier:@"favorite_cell"];
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl.tintColor = APP_THEME_COLOR;
    [self.refreshControl addTarget:self action:@selector(pullToRefreash:) forControlEvents:UIControlEventValueChanged];
    
    [self.tableView addSubview:self.refreshControl];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pullToRefreash:) name:updateFavoriteListNoti object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userDidLogout) name:userDidLogoutNoti object:nil];
    
//    [self initDataFromCache];
//    [self loadDataWithPageIndex:0 andFavoriteType:_currentFavoriteType];
//    [self refreshLoadData];
    [self performSelector:@selector(refreshLoadData) withObject:nil afterDelay:0.25];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    _isVisible = YES;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    _isVisible = NO;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [self.refreshControl endRefreshing];
    self.refreshControl = nil;
    self.tableView.delegate = nil;
}

- (void)initDataFromCache
{
    AccountManager *accountManager = [AccountManager shareAccountManager];
    [[TMCache sharedCache] objectForKey:[NSString stringWithFormat:@"%ld_favorites", (long)accountManager.account.userId] block:^(TMCache *cache, NSString *key, id object)  {
        if (object != nil) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.dataSource addObjectsFromArray:object];
                [self.tableView reloadData];
                if (_dataSource.count >= PAGE_COUNT) {
                    _enableLoadMore = YES;
                }
            });
            [self loadDataWithPageIndex:0 andFavoriteType:_currentFavoriteType];
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.refreshControl beginRefreshing];
                [self.refreshControl sendActionsForControlEvents:UIControlEventValueChanged];
            });
        }
    }];
}

#pragma mark - setter or getter

- (UIView *)footerView
{
    if (!_footerView) {
        _footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.tableView.bounds), 44.0)];
        _footerView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        _footerView.backgroundColor = APP_PAGE_COLOR;
        
        _indicatroView = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 32.0, 32.0)];
        [_indicatroView setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
        [_footerView addSubview:_indicatroView];
        [_indicatroView setCenter:CGPointMake(CGRectGetWidth(self.tableView.bounds)/2.0, 44.0/2.0)];
    }
    return _footerView;
}


#pragma mark - private Methods

- (void)switchCate
{
    SelectionTableViewController *ctl = [[SelectionTableViewController alloc] init];
    ctl.contentItems = _urlTitleArray;
    ctl.delegate = self;
    ctl.titleTxt = @"筛选";
    ctl.selectItem = _selectText;
    TZNavigationViewController *nav = [[TZNavigationViewController alloc] initWithRootViewController:ctl];
    [self presentViewController:nav animated:YES completion:nil];
}

- (void)pullToRefreash:(id)sender
{
    [self loadDataWithPageIndex:0 andFavoriteType:_currentFavoriteType];
}

#pragma mark - ActionEvent

- (void)userDidLogout
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)goBack
{
    if (self == [self.navigationController.viewControllers objectAtIndex:0]) {
        [self dismissViewControllerAnimated:YES completion:nil];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (NSMutableArray *)dataSource
{
    if (!_dataSource) {
        _dataSource = [[NSMutableArray alloc] init];
    }
    return _dataSource;
}

/**
 *  获取我的收藏列表
 */

- (void)loadDataWithPageIndex:(NSInteger)pageIndex andFavoriteType:(NSString *)faType
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    AppUtils *utils = [[AppUtils alloc] init];
    [manager.requestSerializer setValue:utils.appVersion forHTTPHeaderField:@"Version"];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"iOS %@",utils.systemVersion] forHTTPHeaderField:@"Platform"];
    
    [manager.requestSerializer setValue:@"application/vnd.lvxingpai.v1+json" forHTTPHeaderField:@"Accept"];
    [manager.requestSerializer setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    AccountManager *accountManager = [AccountManager shareAccountManager];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"%ld", (long)accountManager.account.userId] forHTTPHeaderField:@"UserId"];
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    NSNumber *imageWidth = [NSNumber numberWithInt:300];
    [params setObject:imageWidth forKey:@"imgWidth"];
    [params safeSetObject:[NSNumber numberWithInt:PAGE_COUNT] forKey:@"pageSize"];
    [params safeSetObject:[NSNumber numberWithInteger:pageIndex] forKey:@"page"];
    [params safeSetObject:faType forKey:@"faType"];
    
    //加载前备份一些，如果加载后用户已经切换界面了，那么就不加载了
    NSString *backupTypeForCheck = faType;
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    // 获得用户的接口ID改变
    NSString * urlStr = [NSString stringWithFormat:@"%@%ld/favorites",API_USERS,accountManager.account.userId];
    [manager GET:urlStr parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"%@", operation);
        
        if ([_currentFavoriteType isEqualToString:backupTypeForCheck]) {
            NSInteger code = [[responseObject objectForKey:@"code"] integerValue];
            if (code == 0) {
                if (pageIndex == 0) {
                    [self.dataSource removeAllObjects];
                    [self.tableView reloadData];
                }
                _currentPage = pageIndex;
                [self bindDataToView:responseObject];
//                if ((pageIndex == 0 || self.dataSource.count < 2*PAGE_COUNT) && [_urlArray[0] isEqual:faType]) {
//                    dispatch_async(dispatch_get_global_queue(0, 0), ^{
//                        [self cacheFirstPage];
//                    });
//                }
            } else {
                [self showHint:@"请求失败"];
            }
        }
        [self loadMoreCompleted];
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        [self.refreshControl endRefreshing];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        [self loadMoreCompleted];
        [self showHint:HTTP_FAILED_HINT];
        [self.refreshControl endRefreshing];
    }];
}

/**
 *  删除我的攻略
 *
 *  @param guideSummary
 */
- (void)deleteUserFavorite:(Favorite *)favorite atIndexPath:(NSIndexPath *)indexpath
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    AppUtils *utils = [[AppUtils alloc] init];
    [manager.requestSerializer setValue:utils.appVersion forHTTPHeaderField:@"Version"];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"iOS %@",utils.systemVersion] forHTTPHeaderField:@"Platform"];
    
    AccountManager *accountManager = [AccountManager shareAccountManager];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"%ld", (long)accountManager.account.userId] forHTTPHeaderField:@"UserId"];
    
    NSString *urlStr = [NSString stringWithFormat:@"%@/%@", API_UNFAVORITE, favorite.itemId];
    
    __weak typeof(FavoriteViewController *)weakSelf = self;
    TZProgressHUD *hud = [[TZProgressHUD alloc] init];
    [hud showHUDInViewController:weakSelf];
    
    [manager DELETE:urlStr parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [hud hideTZHUD];
        NSLog(@"%@", responseObject);
        NSInteger code = [[responseObject objectForKey:@"code"] integerValue];
        if (code == 0) {
            [_dataSource removeObjectAtIndex:indexpath.section];
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex: indexpath.section] withRowAnimation:UITableViewRowAnimationAutomatic];
            if (_dataSource.count == 0) {
                [self.refreshControl beginRefreshing];
                [self.refreshControl sendActionsForControlEvents:UIControlEventValueChanged];
            }
//            else if (indexpath.section < PAGE_COUNT) {
//                dispatch_async(dispatch_get_global_queue(0, 0), ^{
//                    [self cacheFirstPage];
//                });
//            }
        } else {
            [hud hideTZHUD];
            if (self.isVisible) {
                [SVProgressHUD showHint:@"请求也是失败了"];
            }
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@", error);
        if (self.isVisible) {
            [SVProgressHUD showHint:HTTP_FAILED_HINT];
        }
    }];
    
}

- (void)cacheFirstPage
{
    AccountManager *accountManager = [AccountManager shareAccountManager];
    NSInteger count = _dataSource.count;
    if (count > 0) {
        NSArray *cd = [_dataSource subarrayWithRange:NSMakeRange(0, count > PAGE_COUNT ? PAGE_COUNT : count)];
        [[TMCache sharedCache] setObject:cd forKey:[NSString stringWithFormat:@"%ld_favorites", (long)accountManager.account.userId]];
    } else {
        [[TMCache sharedCache] removeObjectForKey:[NSString stringWithFormat:@"%ld_favorites", (long)accountManager.account.userId]];
    }
}

- (void) bindDataToView:(id)responseObject
{
    NSArray *datas = [responseObject objectForKey:@"result"];
    if (datas.count == 0) {
        if (_currentPage == 0) {
//            if (_isVisible) {
//                [self showHint:@"No收藏"];
//            }
            [self.tableView reloadData];
        } else {
//            [self showHint:@"已加载全部"];
        }
        return;
    }
   
    for (NSDictionary *favoriteDic in datas) {
        Favorite *favorite = [[Favorite alloc] initWithJson:favoriteDic];
        [self.dataSource addObject:favorite];
    }
    
    [self.tableView reloadData];
    
    if (_dataSource.count >= 15) {
        _enableLoadMore = YES;
    }
}

- (IBAction)sendPoi:(id)sender
{
    CGPoint point = [sender convertPoint:CGPointZero toView:_tableView];
    NSIndexPath *indexPath = [_tableView indexPathForRowAtPoint:point];
    Favorite *item = [_dataSource objectAtIndex:indexPath.section];
    TaoziChatMessageBaseViewController *taoziMessageCtl = [[TaoziChatMessageBaseViewController alloc] init];
    taoziMessageCtl.delegate = self;
    taoziMessageCtl.messageId = item.itemId;
    taoziMessageCtl.messageImage = ((TaoziImage *)[item.images firstObject]).imageUrl;
    taoziMessageCtl.messageDesc = item.desc;
    taoziMessageCtl.messageName = item.zhName;
    taoziMessageCtl.chatterId = self.chatterId;
    taoziMessageCtl.chatType = self.chatType;
    //        taoziMessageCtl.messageTimeCost = item.timeCostStr;
    taoziMessageCtl.descLabel.text = item.desc;
    if (item.type == kSpotPoi) {
        taoziMessageCtl.messageType = IMMessageTypeSpotMessageType;
        taoziMessageCtl.messageTimeCost = item.timeCostDesc;
    } else if (item.type == kHotelPoi) {
        taoziMessageCtl.messageType = IMMessageTypeHotelMessageType;
        taoziMessageCtl.messageRating = item.rating;
        taoziMessageCtl.messagePrice = item.priceDesc;
    } else if (item.type == kRestaurantPoi) {
        taoziMessageCtl.messageType = IMMessageTypeRestaurantMessageType;
        taoziMessageCtl.messageRating = item.rating;
        taoziMessageCtl.messagePrice = item.priceDesc;
    } else if (item.type == kShoppingPoi) {
        taoziMessageCtl.messageType = IMMessageTypeShoppingMessageType;
        taoziMessageCtl.messageRating = item.rating;
    } else if (item.type == kTravelNotePoi) {
        taoziMessageCtl.messageType = IMMessageTypeTravelNoteMessageType;
        taoziMessageCtl.messageDetailUrl = item.detailUrl;
    } else {
        taoziMessageCtl.messageType = IMMessageTypeCityPoiMessageType;
        taoziMessageCtl.messageTimeCost = item.timeCostDesc;
    }
    
    [self presentPopupViewController:taoziMessageCtl atHeight:170.0 animated:YES completion:nil];
}

#pragma mark - SelectDelegate
- (void) selectItem:(NSString *)str atIndex:(NSIndexPath *)indexPath
{
    _currentFavoriteType = [_urlArray objectAtIndex:indexPath.row];
    _selectText = str;
    _enableLoadMore = NO;
    [_dataSource removeAllObjects];
    [_tableView reloadData];
    [self performSelector:@selector(refreshLoadData) withObject:nil afterDelay:0.25];
}

- (void) refreshLoadData
{
    [self.tableView setContentOffset:CGPointMake(0, -self.refreshControl.frame.size.height) animated:YES];
    [self.refreshControl beginRefreshing];
    [self.refreshControl sendActionsForControlEvents:UIControlEventValueChanged];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return _dataSource.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 10)];
    view.backgroundColor = [UIColor clearColor];
    return view;
}

- (UITableViewCell *)tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    FavoriteTableViewCell *cell = [tv dequeueReusableCellWithIdentifier:@"favorite_cell" forIndexPath:indexPath];
    Favorite *item = [_dataSource objectAtIndex:indexPath.section];
    
    if (item.images != nil && item.images.count > 0) {
        [cell.standardImageView sd_setImageWithURL:[NSURL URLWithString:((TaoziImage *)[item.images objectAtIndex:0]).imageUrl]];
    } else {
        cell.standardImageView.image = nil;
    }
    cell.contentType.text = [item typeDescByType];
    cell.contentTitle.text = item.zhName;
    cell.contentLocation.text = item.locality.zhName;
    
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:item.createTime/1000];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    [cell.timeBtn setTitle:[dateFormatter stringFromDate:date] forState:UIControlStateNormal];
    
    
    NSMutableAttributedString *desc = [[NSMutableAttributedString alloc] initWithString:item.desc];
    [desc addAttribute:NSForegroundColorAttributeName value:TEXT_COLOR_TITLE_SUBTITLE  range:NSMakeRange(0, [desc length])];
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.lineSpacing = 2.0;
    [style setLineBreakMode:NSLineBreakByTruncatingTail];
    [desc addAttribute:NSParagraphStyleAttributeName value:style range:NSMakeRange(0, desc.length)];
    cell.contentDescLabel.attributedText = desc;
    cell.isCanSend = _selectToSend;
    [cell.sendBtn addTarget:self action:@selector(sendPoi:) forControlEvents:UIControlEventTouchUpInside];
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 10;
}

- (CGFloat)tableView:(UITableView *)tv heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    return 135.0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    Favorite *item = [_dataSource objectAtIndex:indexPath.section];
    if (item.type == kSpotPoi) {
        SpotDetailViewController *ctl = [[SpotDetailViewController alloc] init];
        ctl.spotId = item.itemId;
//        [self addChildViewController:ctl];
//        [self.view addSubview:ctl.view];
        [self.navigationController pushViewController:ctl animated:YES];
    } else if (item.type == kHotelPoi || item.type == kRestaurantPoi || item.type == kShoppingPoi) {
        CommonPoiDetailViewController *ctl = [PoiDetailViewControllerFactory poiDetailViewControllerWithPoiType:item.type];
        ctl.poiId = item.itemId;
//        [self addChildViewController:ctl];
//        [self.view addSubview:ctl.view];
        [self.navigationController pushViewController:ctl animated:YES];
    } else if (item.type == kTravelNotePoi) {
        TravelNoteDetailViewController *ctl = [[TravelNoteDetailViewController alloc] init];
        TravelNote *travelNote = [[TravelNote alloc] init];
        travelNote.travelNoteId = item.itemId;
    
        travelNote.title = item.zhName;
        travelNote.images = item.images;
        travelNote.detailUrl = item.detailUrl;
        travelNote.summary = item.desc;
        [self.navigationController pushViewController:ctl animated:YES];
        
    } else  if (item.type == kCityPoi){
        CityDetailViewController *ctl = [[CityDetailViewController alloc] init];
        ctl.cityId = item.itemId;
        [self.navigationController pushViewController:ctl animated:YES];
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void) tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"确定从收藏夹中删除" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        [alertView showAlertViewWithBlock:^(NSInteger buttonIndex) {
            if (buttonIndex == 1) {
                if (buttonIndex == 1) {
                    Favorite *favorite = [self.dataSource objectAtIndex:indexPath.section];
                    [self deleteUserFavorite:favorite atIndexPath:indexPath];
                }
            }
        }];
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return @"删除";
}

- (void) beginLoadingMore
{
    if (self.tableView.tableFooterView == nil) {
        self.tableView.tableFooterView = self.footerView;
    }
    _isLoadingMore = YES;
    [_indicatroView startAnimating];
    [self loadDataWithPageIndex:(_currentPage + 1) andFavoriteType:_currentFavoriteType];
}

- (void) loadMoreCompleted
{
    [_indicatroView stopAnimating];
    _isLoadingMore = NO;
    _didEndScroll = YES;
}

#pragma mark - TaoziMessageSendDelegate

//用户确定发送poi给朋友
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
        [self dismissPopupViewControllerAnimated:YES completion:nil];
    }
}

#pragma mark - UIScrollViewDelegate

- (void) scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (!_isLoadingMore && _didEndScroll && _enableLoadMore) {
        CGFloat scrollPosition = scrollView.contentSize.height - scrollView.frame.size.height - scrollView.contentOffset.y;
        if (scrollPosition < 44.0) {
            _didEndScroll = NO;
            [self beginLoadingMore];
        }
    }
}

- (void) scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    _didEndScroll = YES;
}


@end

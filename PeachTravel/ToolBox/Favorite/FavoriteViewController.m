//
//  FavoriteViewController.m
//  PeachTravel
//
//  Created by Luo Yong on 14/12/2.
//  Copyright (c) 2014年 com.aizou.www. All rights reserved.
//

#import "FavoriteViewController.h"
#import "FavoriteTableViewCell.h"
#import "DKCircleButton.h"
#import "AccountManager.h"
#import "Favorite.h"
#import "SpotDetailViewController.h"
#import "RestaurantDetailViewController.h"
#import "ShoppingDetailViewController.h"
#import "HotelDetailViewController.h"
#import "CityDetailTableViewController.h"
#import "SRRefreshView.h"
#import "TMCache.h"
#import "TravelNoteDetailViewController.h"
#import "TZFilterViewController.h"

#define PAGE_COUNT 15

@interface FavoriteViewController () <SRRefreshDelegate, UITableViewDelegate, UITableViewDataSource, TaoziMessageSendDelegate, TZFilterViewDelegate>

@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) DKCircleButton *editBtn;
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

@property (strong, nonatomic) SRRefreshView *slimeView;

@property (nonatomic, strong) TZFilterViewController *filterCtl;

@property (nonatomic, strong) NSArray *urlArray;
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

- (id)init {
    if (self = [super init]) {
        _urlArray = @[@"all", @"locality", @"vs", @"restaurant", @"shopping", @"hotel", @"travelNote"];
        _currentFavoriteType = [_urlArray objectAtIndex:0];
        _isEditing = NO;
        _selectedIndex = -1;
        _currentPage = 0;
        _isLoadingMore = YES;
        _didEndScroll = YES;
        _enableLoadMore = NO;
        _isVisible = YES;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = APP_PAGE_COLOR;
    self.navigationController.navigationBar.translucent = YES;
    self.automaticallyAdjustsScrollViewInsets = NO;
    if (_selectToSend) {
        self.navigationItem.title = @"发送收藏";
    } else {
        self.navigationItem.title = @"收藏夹";
    }
    
    UIButton *button =  [UIButton buttonWithType:UIButtonTypeCustom];
    [button setImage:[UIImage imageNamed:@"ic_navigation_back.png"] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(goBack)forControlEvents:UIControlEventTouchUpInside];
    [button setFrame:CGRectMake(0, 0, 48, 30)];
    //[button setTitle:@"返回" forState:UIControlStateNormal];
    [button setTitleColor:TEXT_COLOR_TITLE_SUBTITLE forState:UIControlStateNormal];
    [button setTitleColor:TEXT_COLOR_TITLE forState:UIControlStateHighlighted];
    button.titleLabel.font = [UIFont systemFontOfSize:17.0];
    button.titleEdgeInsets = UIEdgeInsetsMake(2, 1, 0, 0);
    button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithCustomView:button];
    self.navigationItem.leftBarButtonItem = barButton;
    
    
    UIBarButtonItem * filterBtn = [[UIBarButtonItem alloc]initWithTitle:nil style:UIBarButtonItemStyleBordered target:self action:@selector(filter:)];
    self.navigationItem.rightBarButtonItem = filterBtn;
    [filterBtn setImage:[UIImage imageNamed:@"ic_nav_filter_normal.png"]];
    
    
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.delegate = nil;
    }
    
    [self.view addSubview:self.tableView];
    [self.tableView addSubview:self.slimeView];
    [self.view addSubview:self.editBtn];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pullToRefreash:) name:updateFavoriteListNoti object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pullToRefreash:) name:updateFavoriteListNoti object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userDidLogout) name:userDidLogoutNoti object:nil];
    
    [self initDataFromCache];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    _isVisible = YES;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    _isVisible = NO;
}

- (void) initDataFromCache {
    AccountManager *accountManager = [AccountManager shareAccountManager];
    [[TMCache sharedCache] objectForKey:[NSString stringWithFormat:@"%@_favorites", accountManager.account.userId] block:^(TMCache *cache, NSString *key, id object)  {
//        if (object != nil) {
        if (false) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.dataSource addObjectsFromArray:object];
                [self.tableView reloadData];
                if (_dataSource.count >= PAGE_COUNT) {
                    _enableLoadMore = YES;
                }
            });
            [self loadDataWithPageIndex:0 andFavoriteType:_currentFavoriteType];
        } else {
            self.slimeView.loading = YES;
            [self pullToRefreash:nil];
        }
    }];
}

- (UITableView *)tableView
{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 64, self.view.bounds.size.width, self.view.bounds.size.height-64)];
        _tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        _tableView.tableFooterView = [[UIView alloc] init];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.backgroundColor = APP_PAGE_COLOR;
        [_tableView registerNib:[UINib nibWithNibName:@"FavoriteTableViewCell" bundle:nil] forCellReuseIdentifier:@"favorite_cell"];
    }
    return _tableView;
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

- (TZFilterViewController *)filterCtl
{
    if (!_filterCtl) {
        _filterCtl = [[TZFilterViewController alloc] init];
        _filterCtl.filterItemsArray = @[@[@"All", @"城市", @"景点", @"美食", @"购物", @"酒店", @"游记"]];
        _filterCtl.filterTitles = @[@"类型"];
        _filterCtl.lineCountPerFilterType = @[@2];
        _filterCtl.selectedItmesIndex = @[@0];
        _filterCtl.delegate = self;

    }
    return _filterCtl;
}

- (SRRefreshView *)slimeView
{
    if (_slimeView == nil) {
        _slimeView = [[SRRefreshView alloc] init];
        _slimeView.delegate = self;
        _slimeView.upInset = 0;
        _slimeView.slimeMissWhenGoingBack = YES;
        _slimeView.slime.bodyColor = APP_THEME_COLOR;
        _slimeView.slime.skinColor = [UIColor clearColor];
        _slimeView.slime.lineWith = 0.7;
        _slimeView.slime.shadowBlur = 0;
        _slimeView.slime.shadowColor = [UIColor clearColor];
    }
    
    return _slimeView;
}

/**
 *  点击筛选按钮
 *
 *  @param sender
 */
- (void)filter:(id)sender
{
    if (!self.filterCtl.filterViewIsShowing) {
        typeof(FavoriteViewController *)weakSelf = self;
        [self.filterCtl showFilterViewInViewController:weakSelf.navigationController];
    } else {
        [self.filterCtl hideFilterView];
    }
}

- (void)pullToRefreash:(id)sender {
    
    [self loadDataWithPageIndex:0 andFavoriteType:_currentFavoriteType];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    _tableView.delegate = nil;
    _tableView.dataSource = nil;
    _tableView = nil;
    _slimeView.delegate = nil;
    _slimeView = nil;
}

- (void)userDidLogout
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)goBack
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (NSMutableArray *)dataSource
{
    if (!_dataSource) {
        _dataSource = [[NSMutableArray alloc] init];
    }
    return _dataSource;
}

- (DKCircleButton *)editBtn
{
    if (!_editBtn) {
        _editBtn = [[DKCircleButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width-60, self.view.frame.size.height-70.0, 50, 50)];
        [_editBtn setImage:[UIImage imageNamed:@"ic_layer_edit.png"] forState:UIControlStateNormal];
        [_editBtn setImage:[UIImage imageNamed:@"ic_layer_edit_done.png"] forState:UIControlStateSelected];
        [_editBtn addTarget:self action:@selector(editMyFavorite:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _editBtn;
}

/**
 *  点击编辑按钮
 *
 *  @param sender
 */
- (IBAction)editMyFavorite:(id)sender
{
    UIButton *btn = sender;
    BOOL isEditing = btn.isSelected;
    _isEditing = !isEditing;
    btn.selected = !isEditing;
    [self.tableView reloadData];
}

/**
 *  点击删除攻略按钮
 *
 *  @param sender
 */
- (IBAction)deleteFavorite:(UIButton *)sender
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"确定移除收藏" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    [alertView showAlertViewWithBlock:^(NSInteger buttonIndex) {
        if (buttonIndex == 1) {
            if (buttonIndex == 1) {
                CGPoint viewPos = [sender convertPoint:CGPointZero toView:self.tableView];
                NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:viewPos];
                NSInteger index = indexPath.row;
                Favorite *favorite = [self.dataSource objectAtIndex:index];
                [self deleteUserFavorite:favorite];
            }
        }
    }];
}


/**
 *  获取我的收藏列表
 */

- (void)loadDataWithPageIndex:(NSInteger)pageIndex andFavoriteType:(NSString *)faType
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    AppUtils *utils = [[AppUtils alloc] init];
    [manager.requestSerializer setValue:utils.appVersion forHTTPHeaderField:@"Version"];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"iOS %@",utils.systemVersion] forHTTPHeaderField:@"Platform"];
    
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [manager.requestSerializer setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    AccountManager *accountManager = [AccountManager shareAccountManager];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"%@", accountManager.account.userId] forHTTPHeaderField:@"UserId"];
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    NSNumber *imageWidth = [NSNumber numberWithInt:(kWindowWidth-22)*2];
    [params setObject:imageWidth forKey:@"imgWidth"];
    [params safeSetObject:[NSNumber numberWithInt:PAGE_COUNT] forKey:@"pageSize"];
    [params safeSetObject:[NSNumber numberWithInteger:pageIndex] forKey:@"page"];
    [params safeSetObject:faType forKey:@"faType"];
    
    //加载前备份一些，如果加载后用户已经切换界面了，那么就不加载了
    NSString *backupTypeForCheck = faType;
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    [manager GET:API_GET_FAVORITES parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if ([_currentFavoriteType isEqualToString:backupTypeForCheck]) {
            NSInteger code = [[responseObject objectForKey:@"code"] integerValue];
            if (code == 0) {
                if (pageIndex == 0) {
                    [self.dataSource removeAllObjects];
                }
                _currentPage = pageIndex;
                [self bindDataToView:responseObject];
                if ((pageIndex == 0 || self.dataSource.count < 2*PAGE_COUNT) && [_urlArray[0] isEqual:faType]) {
                    dispatch_async(dispatch_get_global_queue(0, 0), ^{
                        [self cacheFirstPage];
                    });
                }
            } else {
                
            }
        } else {
            NSLog(@"用户切换界面了，我不需要加载了");
        }
        if (self.slimeView.loading) {
            [self hideSlimeView];
        }
        [self loadMoreCompleted];
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        [self loadMoreCompleted];
        if (self.slimeView.loading) {
            [self hideSlimeView];
        }
        [self showHint:@"呃～好像没找到网络"];
    }];
}

/**
 *  删除我的攻略
 *
 *  @param guideSummary
 */
- (void)deleteUserFavorite:(Favorite *)favorite
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    AppUtils *utils = [[AppUtils alloc] init];
    [manager.requestSerializer setValue:utils.appVersion forHTTPHeaderField:@"Version"];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"iOS %@",utils.systemVersion] forHTTPHeaderField:@"Platform"];
    
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    AccountManager *accountManager = [AccountManager shareAccountManager];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"%@", accountManager.account.userId] forHTTPHeaderField:@"UserId"];
    
    NSString *urlStr = [NSString stringWithFormat:@"%@/%@", API_UNFAVORITE, favorite.itemId];
    
    __weak typeof(FavoriteViewController *)weakSelf = self;
    TZProgressHUD *hud = [[TZProgressHUD alloc] init];
    [hud showHUDInViewController:weakSelf];
    
    [manager DELETE:urlStr parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [hud hideTZHUD];
        NSLog(@"%@", responseObject);
        NSInteger code = [[responseObject objectForKey:@"code"] integerValue];
        if (code == 0) {
//            [SVProgressHUD showHint:@"OK!成功删除"];
            NSInteger index = [self.dataSource indexOfObject:favorite];
            [self.dataSource removeObject:favorite];
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
            [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            if (_dataSource.count == 0) {
                self.slimeView.loading = YES;
                [self pullToRefreash:nil];
            } else if (index < PAGE_COUNT) {
                dispatch_async(dispatch_get_global_queue(0, 0), ^{
                    [self cacheFirstPage];
                });
            }
        } else {
            [hud hideTZHUD];
            if (self.isVisible) {
                [SVProgressHUD showHint:@"请求也是失败了"];
            }
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@", error);
        if (self.isVisible) {
            [SVProgressHUD showHint:@"呃～好像没找到网络"];
        }
    }];
    
}

- (void)cacheFirstPage
{
    AccountManager *accountManager = [AccountManager shareAccountManager];
    NSInteger count = _dataSource.count;
    if (count > 0) {
        NSArray *cd = [_dataSource subarrayWithRange:NSMakeRange(0, count > PAGE_COUNT ? PAGE_COUNT : count)];
        [[TMCache sharedCache] setObject:cd forKey:[NSString stringWithFormat:@"%@_favorites", accountManager.account.userId]];
    } else {
        [[TMCache sharedCache] removeObjectForKey:[NSString stringWithFormat:@"%@_favorites", accountManager.account.userId]];
    }
}

- (void) bindDataToView:(id)responseObject {
    NSArray *datas = [responseObject objectForKey:@"result"];
    if (datas.count == 0) {
        if (_currentPage == 0) {
            if (_isVisible) {
                [self showHint:@"No收藏"];
            }
            [self.tableView reloadData];
        } else {
            [self showHint:@"已取完所有内容啦"];
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

- (void)hideSlimeView
{
    [self.slimeView endRefresh];
}

#pragma makr - TZFilterViewDelegate
-(void)didSelectedItems:(NSArray *)itemIndexPath
{
    _currentFavoriteType = [_urlArray objectAtIndex:[[itemIndexPath firstObject] integerValue]];
    [self pullToRefreash:nil];
}

#pragma mark - SINavigationMenuDelegate

- (void)didSelectItemAtIndex:(NSUInteger)index withSender:(id)sender
{
    _currentFavoriteType = [_urlArray objectAtIndex:index];
    [self pullToRefreash:nil];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    FavoriteTableViewCell *cell = [tv dequeueReusableCellWithIdentifier:@"favorite_cell" forIndexPath:indexPath];
    cell.isEditing = _isEditing;
    [cell.deleteBtn addTarget:self action:@selector(deleteFavorite:) forControlEvents:UIControlEventTouchUpInside];
    Favorite *item = [_dataSource objectAtIndex:indexPath.row];
    
    if (item.images != nil && item.images.count > 0) {
        [cell.standardImageView sd_setImageWithURL:[NSURL URLWithString:((TaoziImage *)[item.images objectAtIndex:0]).imageUrl]];
    } else {
        cell.standardImageView.image = [UIImage imageNamed:@"country.jpg"];
    }
    cell.contentType.text = [item typeDescByType];
    cell.contentTitle.text = item.zhName;
    cell.contentLocation.text = item.locality.zhName;
    cell.contentTypeFlag.image = [UIImage imageNamed:[item typeFlagName]];
    
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:item.createTime/1000];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    cell.timeLabel.text = [dateFormatter stringFromDate:date];
    
    
    NSMutableAttributedString *desc = [[NSMutableAttributedString alloc] initWithString:item.desc];
    [desc addAttribute:NSForegroundColorAttributeName value:TEXT_COLOR_TITLE_SUBTITLE  range:NSMakeRange(0, [desc length])];
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.lineSpacing = 4.0;
    [desc addAttribute:NSParagraphStyleAttributeName value:style range:NSMakeRange(0, desc.length)];
    [cell.contentDescExpandView setAttributedTitle:desc forState:UIControlStateNormal];
//    if (indexPath.row != _selectedIndex) {
//        cell.contentDescExpandView.selected = NO;
//    } 
    
    [cell.contentDescExpandView addTarget:self action:@selector(expandDesc:) forControlEvents:UIControlEventTouchUpInside];
    
    return cell;
}

- (IBAction)expandDesc:(id)sender {
    UIButton *btn = sender;
    CGPoint viewPos = [btn convertPoint:CGPointZero toView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:viewPos];
    
//    if (!btn.isSelected) {
//        _selectedIndex = indexPath.row;
//        btn.selected = YES;
//    } else {
//        _selectedIndex = -1;
//        btn.selected = NO;
//    }
    
    if (_selectedIndex != indexPath.row) {
        _selectedIndex = indexPath.row;
    } else {
        _selectedIndex = -1;
    }
    
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tv heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == _selectedIndex) {
        NSString *text = ((Favorite *)[_dataSource objectAtIndex:indexPath.row]).desc;
        NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
        style.lineSpacing = 4.0;
        NSDictionary *attributes = @{NSFontAttributeName: [UIFont systemFontOfSize:13.0],
                                     NSParagraphStyleAttributeName : style};
        CGRect rect = [text boundingRectWithSize:CGSizeMake(self.tableView.bounds.size.width - 44.0, MAXFLOAT)
                                              options:NSStringDrawingUsesLineFragmentOrigin
                                           attributes:attributes
                                              context:nil];
        if (rect.size.height <= 24) {
            return 216.0;
        }
        
        NSLog(@"高度为:%f",(210+rect.size.height-24.0));

        return 210 + rect.size.height - 24.0;
    }
    return 216;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    Favorite *item = [_dataSource objectAtIndex:indexPath.row];
    if (!_selectToSend) {
        if (item.type == kSpotPoi) {
            SpotDetailViewController *ctl = [[SpotDetailViewController alloc] init];
            ctl.spotId = item.itemId;
            [self.navigationController pushViewController:ctl animated:YES];
            
        } else if (item.type == kHotelPoi) {
            HotelDetailViewController *ctl = [[HotelDetailViewController alloc] init];
            ctl.hotelId = item.itemId;
            [self.navigationController pushViewController:ctl animated:YES];
            
        } else if (item.type == kRestaurantPoi) {
            RestaurantDetailViewController *ctl = [[RestaurantDetailViewController alloc] init];
            ctl.restaurantId = item.itemId;
            [self.navigationController pushViewController:ctl animated:YES];
            
        } else if (item.type == kShoppingPoi) {
            ShoppingDetailViewController *ctl = [[ShoppingDetailViewController alloc] init];
            ctl.shoppingId = item.itemId;
            [self.navigationController pushViewController:ctl animated:YES];
            
        } else if (item.type == kTravelNotePoi) {
            TravelNoteDetailViewController *ctl = [[TravelNoteDetailViewController alloc] init];
            ctl.travelNoteId = item.itemId;
            ctl.travelNoteTitle = item.zhName;
            ctl.travelNoteCover = item.desc;
            [self.navigationController pushViewController:ctl animated:YES];
            
        } else {
            CityDetailTableViewController *ctl = [[CityDetailTableViewController alloc] init];
            ctl.cityId = item.itemId;
            [self.navigationController pushViewController:ctl animated:YES];
        }
    } else {
        
//TODO:点击发送
        TaoziChatMessageBaseViewController *taoziMessageCtl = [[TaoziChatMessageBaseViewController alloc] init];
        taoziMessageCtl.delegate = self;
        taoziMessageCtl.messageId = item.itemId;
        taoziMessageCtl.messageImage = ((TaoziImage *)[item.images firstObject]).imageUrl;
        taoziMessageCtl.messageDesc = item.desc;
        taoziMessageCtl.messageName = item.zhName;
        taoziMessageCtl.chatter = self.chatter;
        taoziMessageCtl.isGroup = self.isChatGroup;
//        taoziMessageCtl.messageTimeCost = item.timeCostStr;
        taoziMessageCtl.descLabel.text = item.desc;
        if (item.type == kSpotPoi) {
            taoziMessageCtl.chatType = TZChatTypeSpot;
            taoziMessageCtl.messageTimeCost = item.timeCostDesc;
        } else if (item.type == kHotelPoi) {
            taoziMessageCtl.chatType = TZChatTypeHotel;
            taoziMessageCtl.messageRating = item.rating;
            taoziMessageCtl.messagePrice = item.priceDesc;
        } else if (item.type == kRestaurantPoi) {
            taoziMessageCtl.chatType = TZChatTypeFood;
            taoziMessageCtl.messageRating = item.rating;
            taoziMessageCtl.messagePrice = item.priceDesc;
        } else if (item.type == kShoppingPoi) {
            taoziMessageCtl.chatType = TZChatTypeShopping;
            taoziMessageCtl.messageRating = item.rating;
        } else if (item.type == kTravelNotePoi) {
            taoziMessageCtl.chatType = TZChatTypeTravelNote;
        } else {
            taoziMessageCtl.chatType = TZChatTypeCity;
            taoziMessageCtl.messageTimeCost = item.timeCostDesc;
        }

        [self presentPopupViewController:taoziMessageCtl atHeight:170.0 animated:YES completion:^(void) {
            
        }];

    }
}

- (void) beginLoadingMore {
    if (self.tableView.tableFooterView == nil) {
        self.tableView.tableFooterView = self.footerView;
    }
    _isLoadingMore = YES;
    [_indicatroView startAnimating];
    [self loadDataWithPageIndex:(_currentPage + 1) andFavoriteType:_currentFavoriteType];
}

- (void) loadMoreCompleted {
    [_indicatroView stopAnimating];
    _isLoadingMore = NO;
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
        [self dismissPopupViewControllerAnimated:YES completion:^{
            
        }];
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
    if (_slimeView) {
        [_slimeView scrollViewDidScroll];
    }
}

- (void) scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    _didEndScroll = YES;
    if (_slimeView) {
        [_slimeView scrollViewDidEndDraging];
    }
}

#pragma mark - slimeRefresh delegate
//加载更多
- (void)slimeRefreshStartRefresh:(SRRefreshView *)refreshView
{
    [self pullToRefreash:nil];
}


@end

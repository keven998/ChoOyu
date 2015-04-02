//
//  MyGuideListTableViewController.m
//  PeachTravel
//
//  Created by liangpengshuai on 11/28/14.
//  Copyright (c) 2014 com.aizou.www. All rights reserved.
//

#import "MyGuideListTableViewController.h"
#import "MyGuidesTableViewCell.h"
#import "DKCircleButton.h"
#import "AccountManager.h"
#import "MyGuideSummary.h"
#import "TripDetailRootViewController.h"
#import "ConfirmRouteViewController.h"
#import "TaoziChatMessageBaseViewController.h"
#import "Destinations.h"
#import "DomesticViewController.h"
#import "ForeignViewController.h"

#define PAGE_COUNT 10

@interface MyGuideListTableViewController () <UIGestureRecognizerDelegate, TaoziMessageSendDelegate, TripUpdateDelegate, SWTableViewCellDelegate, UITableViewDataSource, UITableViewDelegate>

@property (nonatomic) NSUInteger currentPage;
@property (nonatomic, strong) NSMutableArray *dataSource;
@property (nonatomic, strong) ConfirmRouteViewController *confirmRouteViewController;
@property (nonatomic, strong) UITapGestureRecognizer *tapRecognizer;
@property (nonatomic, strong) UIView *emptyView;

@property (nonatomic, strong) UIActivityIndicatorView *indicatroView;
@property (nonatomic, strong) UIView *footerView;
@property (nonatomic, assign) BOOL isLoadingMore;
@property (nonatomic, assign) BOOL didEndScroll;
@property (nonatomic, assign) BOOL enableLoadMore;

@property (nonatomic, strong) UIButton *addBtn;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIRefreshControl *refreshControl;

@property (nonatomic) BOOL isShowing;

@end

@implementation MyGuideListTableViewController

static NSString *reusableCell = @"myGuidesCell";

- (id)init {
    if (self = [super init]) {
        _currentPage = 0;
        _isLoadingMore = YES;
        _didEndScroll = YES;
        _enableLoadMore = NO;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"我的旅程";
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view addSubview:self.tableView];
    self.tableView.backgroundColor = APP_PAGE_COLOR;
    
    UIButton *button =  [UIButton buttonWithType:UIButtonTypeCustom];
    [button setImage:[UIImage imageNamed:@"ic_navigation_back.png"] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(goBack)forControlEvents:UIControlEventTouchUpInside];
    [button setFrame:CGRectMake(0, 0, 48, 30)];
    button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithCustomView:button];
    self.navigationItem.leftBarButtonItem = barButton;
    
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.delegate = nil;
    }
    
    _tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissPopup:)];
    _tapRecognizer.numberOfTapsRequired = 1;
    _tapRecognizer.delegate = self;
    
    if (!_selectToSend) {
        UIButton *editBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 64, 64)];
        [editBtn setBackgroundImage:[UIImage imageNamed:@"btn_new_plan.png"] forState:UIControlStateNormal];
        [editBtn addTarget:self action:@selector(makePlan) forControlEvents:UIControlEventTouchUpInside];
        editBtn.center = CGPointMake(CGRectGetWidth(self.view.bounds)/2, CGRectGetHeight(self.view.bounds) - 120);
        _addBtn = editBtn;
    }
    
    if (!_selectToSend) {
        [self.view addSubview:_addBtn];
    }
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView registerNib:[UINib nibWithNibName:@"MyGuidesTableViewCell" bundle:nil] forCellReuseIdentifier:reusableCell];
    self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 100, 0);
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl.tintColor = APP_THEME_COLOR;
    [self.refreshControl addTarget:self action:@selector(pullToRefreash:) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:self.refreshControl];

    [self initDataFromCache];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userDidLogout) name:userDidLogoutNoti object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pullToRefreash:) name:updateGuideListNoti object:nil];

}

- (void)goBack
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void) initDataFromCache {
    AccountManager *accountManager = [AccountManager shareAccountManager];
    [[TMCache sharedCache] objectForKey:[NSString stringWithFormat:@"%@_plans", accountManager.account.userId] block:^(TMCache *cache, NSString *key, id object)  {
        if (object != nil) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.dataSource addObjectsFromArray:object];
                [self.tableView reloadData];
                if (_dataSource.count >= PAGE_COUNT) {
                    _enableLoadMore = YES;
                }
            });
            [self loadDataWithPageIndex:0];
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.refreshControl beginRefreshing];
                [self.refreshControl sendActionsForControlEvents:UIControlEventValueChanged];
            });
        }
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [MobClick beginLogPageView:@"page_my_trip_plans"];
    _isShowing = YES;
    self.navigationController.navigationBar.translucent = NO;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:@"page_my_trip_plans"];
    _isShowing = NO;
    self.navigationController.navigationBar.translucent = YES;
}

- (void)dealloc
{
    [self.navigationController.view removeGestureRecognizer:_tapRecognizer];

    [self.refreshControl endRefreshing];
    self.refreshControl = nil;
    _tapRecognizer = nil;
}

#pragma mark - navigation action

- (void)userDidLogout
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)makePlan {
    [MobClick event:@"event_create_new_trip_plan_mine"];
    
    Destinations *destinations = [[Destinations alloc] init];
    MakePlanViewController *makePlanCtl = [[MakePlanViewController alloc] init];
    ForeignViewController *foreignCtl = [[ForeignViewController alloc] init];
    DomesticViewController *domestic = [[DomesticViewController alloc] init];
    domestic.destinations = destinations;
    foreignCtl.destinations = destinations;
    makePlanCtl.destinations = destinations;
    makePlanCtl.viewControllers = @[domestic, foreignCtl];
    domestic.makePlanCtl = makePlanCtl;
    foreignCtl.makePlanCtl = makePlanCtl;
    makePlanCtl.animationOptions = UIViewAnimationOptionTransitionNone;
    makePlanCtl.duration = 0;
    makePlanCtl.segmentedTitles = @[@"国内", @"国外"];
    makePlanCtl.selectedColor = APP_THEME_COLOR;
    makePlanCtl.segmentedTitleFont = [UIFont systemFontOfSize:18.0];
    makePlanCtl.normalColor= [UIColor grayColor];
    
    [self.navigationController pushViewController:makePlanCtl animated:YES];}

#pragma mark - setter & getter

- (NSMutableArray *)dataSource
{
    if (!_dataSource) {
        _dataSource = [[NSMutableArray alloc] init];
    }
    return _dataSource;
}

#pragma mark - IBAction Methods
/**
 *  下拉刷新
 *
 *  @param sender
 */
- (void)pullToRefreash:(id)sender {
    [self loadDataWithPageIndex:0];
}

/**
 *  点击删除攻略按钮
 *
 *  @param sender
 */
- (void)deleteGuide:(NSIndexPath *)indexPath
{
    [MobClick event:@"event_delete_trip_plan"];
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"删除确认" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确认", nil];
    [alertView showAlertViewWithBlock:^(NSInteger buttonIndex) {
        if (buttonIndex == 1) {
            NSInteger index = indexPath.section;
            MyGuideSummary *guideSummary = [self.dataSource objectAtIndex:index];
            [self deleteUserGuide:guideSummary];
        }
    }];
}

/**
 *  点击路线列表里的编辑标题按钮
 *
 *  @param sender
 */
- (void)edit:(NSIndexPath *)index
{
    [MobClick event:@"event_edit_trip_title"];
    _confirmRouteViewController = [[ConfirmRouteViewController alloc] init];
    MyGuideSummary *guideSummary = [self.dataSource objectAtIndex:index.section];
    [self.navigationController.view addGestureRecognizer:_tapRecognizer];
    
    CGFloat y = kWindowHeight-260-176;
    if (y>100) {
        y = 100;
    }
    [self.navigationController presentPopupViewController:_confirmRouteViewController atHeight:y animated:YES completion:nil];
    _confirmRouteViewController.routeTitle.text = guideSummary.title;
    _confirmRouteViewController.confirmRouteTitle.tag = index.section;
    [_confirmRouteViewController.confirmRouteTitle addTarget:self action:@selector(willConfirmRouteTitle:) forControlEvents:UIControlEventTouchUpInside];
}

/**
 *  点击修改标题的弹出框的确定按钮
 *
 *  @param sender
 */
- (IBAction)willConfirmRouteTitle:(UIButton *)sender
{
    MyGuideSummary *guideSummary = [self.dataSource objectAtIndex:sender.tag];
    if ([guideSummary.title isEqualToString:_confirmRouteViewController.routeTitle.text]) {
        [SVProgressHUD showHint:@"修改成功"];
        [self dismissPopup:nil];
        return;
    }
    [self editGuideTitle:guideSummary andTitle:_confirmRouteViewController.routeTitle.text atIndex:sender.tag];
}

/**
 *  弹出修改标题后点击背景，消除修改标题弹出框
 *
 *  @param sender
 */
- (IBAction)dismissPopup:(id)sender
{
    if (self.navigationController.popupViewController != nil) {
        if ([_confirmRouteViewController.routeTitle isFirstResponder]) {
            [_confirmRouteViewController.routeTitle resignFirstResponder];
        }
        [self.navigationController dismissPopupViewControllerAnimated:YES completion:^{
            [self.navigationController.view removeGestureRecognizer:_tapRecognizer];
        }];
    }
}

#pragma mark - Private Methods

/**
 *  删除我的攻略
 *
 *  @param guideSummary
 */
- (void)deleteUserGuide:(MyGuideSummary *)guideSummary
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    AppUtils *utils = [[AppUtils alloc] init];
    [manager.requestSerializer setValue:utils.appVersion forHTTPHeaderField:@"Version"];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"iOS %@",utils.systemVersion] forHTTPHeaderField:@"Platform"];
    
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    AccountManager *accountManager = [AccountManager shareAccountManager];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"%@", accountManager.account.userId] forHTTPHeaderField:@"UserId"];

    NSString *urlStr = [NSString stringWithFormat:@"%@%@", API_DELETE_GUIDE, guideSummary.guideId];
    
    __weak typeof(MyGuideListTableViewController *)weakSelf = self;
    TZProgressHUD *hud = [[TZProgressHUD alloc] init];
    [hud showHUDInViewController:weakSelf];
    
    [manager DELETE:urlStr parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"%@", responseObject);
        [hud hideTZHUD];
        NSInteger code = [[responseObject objectForKey:@"code"] integerValue];
        if (code == 0) {
            NSInteger index = [self.dataSource indexOfObject:guideSummary];
            [self.dataSource removeObject:guideSummary];
            NSIndexSet *set = [NSIndexSet indexSetWithIndex:index];
            [self.tableView deleteSections:set withRowAnimation:UITableViewRowAnimationAutomatic];
            
            if (self.dataSource.count == 0) {
                [self.refreshControl beginRefreshing];
                [self.refreshControl sendActionsForControlEvents:UIControlEventValueChanged];
            } else if (index < PAGE_COUNT) {
                dispatch_async(dispatch_get_global_queue(0, 0), ^{
                    [self cacheFirstPage:responseObject];
                });
            }
        } else {
             if (self.isShowing) {
                [SVProgressHUD showHint:@"请求也是失败了"];
            }
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@", error);
        [hud hideTZHUD];
        if (self.isShowing) {
            [SVProgressHUD showHint:@"呃～好像没找到网络"];
        }
    }];
}

/**
 *  修改攻略名称
 *
 *  @param guideSummary 被修改的攻略
 *  @param title        新的标题
 */
- (void)editGuideTitle:(MyGuideSummary *)guideSummary andTitle:(NSString *)title atIndex:(NSInteger)index
{
    AccountManager *accountManager = [AccountManager shareAccountManager];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    AppUtils *utils = [[AppUtils alloc] init];
    [manager.requestSerializer setValue:utils.appVersion forHTTPHeaderField:@"Version"];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"iOS %@",utils.systemVersion] forHTTPHeaderField:@"Platform"];
     __weak typeof(MyGuideListTableViewController *)weakSelf = self;
    TZProgressHUD *hud = [[TZProgressHUD alloc] init];
    [hud showHUDInViewController:weakSelf];

    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [manager.requestSerializer setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"%@", accountManager.account.userId] forHTTPHeaderField:@"UserId"];
    
    NSString *requestUrl = [NSString stringWithFormat:@"%@%@",API_SAVE_TRIPINFO, guideSummary.guideId];
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:title forKey:@"title"];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    [manager PUT:requestUrl parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"%@", responseObject);
        [hud hideTZHUD];
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        NSInteger code = [[responseObject objectForKey:@"code"] integerValue];
        if (code == 0) {
//            [self showHint:@"OK~修改成功"];
            [self performSelector:@selector(dismissPopup:) withObject:nil afterDelay:0.3];

            guideSummary.title = title;
            NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:index];
            [self.tableView reloadSections:indexSet withRowAnimation:UITableViewRowAnimationAutomatic];
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                [self cacheFirstPage:responseObject];
            });
        } else {
            [self showHint:@"请求也是失败了"];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [hud hideTZHUD];
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        [self showHint:@"呃～好像没找到网络"];
    }];
}

/**
 *  获取我的攻略列表
 */
- (void)loadDataWithPageIndex:(NSInteger)pageIndex
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
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    //获取我的攻略列表
    [manager GET:API_GET_GUIDELIST parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSInteger code = [[responseObject objectForKey:@"code"] integerValue];
        if (code == 0) {
            if (pageIndex == 0) {
                [self.dataSource removeAllObjects];
            }
            _currentPage = pageIndex;
            [self bindDataToView:responseObject];
            if (pageIndex == 0 || self.dataSource.count < 2*PAGE_COUNT) {
                dispatch_async(dispatch_get_global_queue(0, 0), ^{
                    [self cacheFirstPage:responseObject];
                });
            }
        } else {
            [self showHint:[NSString stringWithFormat:@"%@",[[responseObject objectForKey:@"err"] objectForKey:@"message"]]];
        }
        [self loadMoreCompleted];
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        [self.refreshControl endRefreshing];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@", error);
        [self loadMoreCompleted];
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        [self.refreshControl endRefreshing];
        [self showHint:@"呃～好像没找到网络"];
    }];
}

- (void) cacheFirstPage:(id)responseObject {
    AccountManager *accountManager = [AccountManager shareAccountManager];
    NSInteger count = _dataSource.count;
    if (count > 0) {
        NSArray *cd = [_dataSource subarrayWithRange:NSMakeRange(0, count > PAGE_COUNT ? PAGE_COUNT : count)];
        [[TMCache sharedCache] setObject:cd forKey:[NSString stringWithFormat:@"%@_plans", accountManager.account.userId]];
    } else {
        [[TMCache sharedCache] removeObjectForKey:[NSString stringWithFormat:@"%@_plans", accountManager.account.userId]];
    }
}

- (void) bindDataToView:(id)responseObject
{
    NSArray *datas = [responseObject objectForKey:@"result"];
    if (datas.count == 0) {
        if (_currentPage == 0) {
            [self performSelector:@selector(setupEmptyView) withObject:nil afterDelay:0.8];
        } else {
            _enableLoadMore = NO;
            [self showHint:@"已取完所有内容啦"];
        }
        [self.tableView reloadData];
        return;
    } else {
        [self removeEmptyView];
    }
    
    for (NSDictionary *guideSummaryDic in [responseObject objectForKey:@"result"]) {
        MyGuideSummary *guideSummary = [[MyGuideSummary alloc] initWithJson:guideSummaryDic];
        [self.dataSource addObject:guideSummary];
    }
    
    [self.tableView reloadData];
    
    if (_dataSource.count >= 10) {
        _enableLoadMore = YES;
    }
}

- (void)setupEmptyView {
    if (self.emptyView != nil) {
        return;
    }
    
    CGFloat width = self.view.bounds.size.width;
    
    self.emptyView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height-200)];
    [self.view addSubview:self.emptyView];
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 72, 72)];
//    imageView.contentMode = UIViewContentModeCenter;
    imageView.image = [UIImage imageNamed:@"ic_guide_earth.png"];
    imageView.center = CGPointMake(width/2.0, 144);
    [self.emptyView addSubview:imageView];
    
    UILabel *desc = [[UILabel alloc] initWithFrame:CGRectMake(0, 144+imageView.frame.size.height/2.0, width, 64.0)];
//    desc.textColor = TEXT_COLOR_TITLE_SUBTITLE;
    desc.font = [UIFont systemFontOfSize:14.0];
    desc.numberOfLines = 2;
//    desc.textAlignment = NSTextAlignmentCenter;
    NSString *text = @"你还没有任何旅程计划~";
    NSMutableAttributedString *attrDesc = [[NSMutableAttributedString alloc] initWithString:text];
    [attrDesc addAttribute:NSForegroundColorAttributeName value:TEXT_COLOR_TITLE_SUBTITLE  range:NSMakeRange(0, [text length])];
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.lineSpacing = 4.0;
    [style setAlignment:NSTextAlignmentCenter];
    [attrDesc addAttribute:NSParagraphStyleAttributeName value:style range:NSMakeRange(0, text.length)];
    [desc setAttributedText:attrDesc];
    
    [self.emptyView addSubview:desc];
}

- (void) removeEmptyView {
    if (self.emptyView != nil) {
        [self.emptyView removeFromSuperview];
        self.emptyView = nil;
    }
}

- (IBAction)sendPoi:(UIButton *)sender
{
    CGPoint point = [sender convertPoint:CGPointZero toView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:point];
    MyGuideSummary *guideSummary = [self.dataSource objectAtIndex:indexPath.section];

    TaoziChatMessageBaseViewController *taoziMessageCtl = [[TaoziChatMessageBaseViewController alloc] init];
    taoziMessageCtl.delegate = self;
    taoziMessageCtl.chatType = TZChatTypeStrategy;
    taoziMessageCtl.chatter = _chatter;
    taoziMessageCtl.chatTitle = @"计划";
    taoziMessageCtl.messageId = guideSummary.guideId;
    taoziMessageCtl.messageDesc = guideSummary.summary;
    taoziMessageCtl.messageName = guideSummary.title;
    taoziMessageCtl.isGroup = _isChatGroup;
    TaoziImage *image = [guideSummary.images firstObject];
    taoziMessageCtl.messageImage = image.imageUrl;
    taoziMessageCtl.messageTimeCost = [NSString stringWithFormat:@"%ld天", (long)guideSummary.dayCount];
    
    [self.navigationController presentPopupViewController:taoziMessageCtl atHeight:170.0 animated:YES completion:nil];
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
    if (self.navigationController.popupViewController != nil) {
        [self.navigationController dismissPopupViewControllerAnimated:YES completion:^{
            
        }];
    }
}


#pragma mark - Table view data source

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 12;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.dataSource.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 92;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 10)];
    view.backgroundColor = APP_PAGE_COLOR;
    return view;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MyGuidesTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reusableCell forIndexPath:indexPath];
    [cell setRightUtilityButtons:[self rightButtons] WithButtonWidth:60];
    cell.guideSummary = [self.dataSource objectAtIndex:indexPath.section];
    cell.delegate = self;
    cell.isCanSend = _selectToSend;
    [cell.sendBtn addTarget:self action:@selector(sendPoi:) forControlEvents:UIControlEventTouchUpInside];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    MyGuideSummary *guideSummary = [self.dataSource objectAtIndex:indexPath.section];
    TripDetailRootViewController *tripDetailRootCtl = [[TripDetailRootViewController alloc] init];
    tripDetailRootCtl.isMakeNewTrip = NO;
    tripDetailRootCtl.tripId = guideSummary.guideId;
    tripDetailRootCtl.canEdit = YES;
    tripDetailRootCtl.contentMgrDelegate = self;
    [self.navigationController pushViewController:tripDetailRootCtl animated:YES];
}

- (NSArray *)rightButtons
{
    NSMutableArray *rightUtilityButtons = [NSMutableArray new];
    [rightUtilityButtons sw_addUtilityButtonWithColor:[UIColor lightGrayColor] icon:[UIImage imageNamed:@"ic_guide_edit.png"]];
    [rightUtilityButtons sw_addUtilityButtonWithColor:[UIColor redColor] icon:[UIImage imageNamed:@"ic_guide_archieve.png"]];
    
    return rightUtilityButtons;
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

- (void) beginLoadingMore {
    if (self.tableView.tableFooterView == nil) {
        self.tableView.tableFooterView = self.footerView;
    }
    _isLoadingMore = YES;
    [_indicatroView startAnimating];
    [self loadDataWithPageIndex:(_currentPage + 1)];
    
    NSLog(@"我要加载到第%lu",(long)_currentPage+1);
}

- (void) loadMoreCompleted {
    if (!_isLoadingMore) return;
    [_indicatroView stopAnimating];
    _isLoadingMore = NO;
}

#pragma mark - SWTableViewCellDelegate
- (void)swipeableTableViewCell:(SWTableViewCell *)cell didTriggerRightUtilityButtonWithIndex:(NSInteger)index
{
    switch (index) {
        case 0:
        {
            NSIndexPath *cellIndexPath = [self.tableView indexPathForCell:cell];
            [self edit:cellIndexPath];
            break;
        }
        case 1:
        {
            NSIndexPath *cellIndexPath = [self.tableView indexPathForCell:cell];
            [self deleteGuide:cellIndexPath];
            break;
        }
        default:
            break;
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

- (void) scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    _didEndScroll = YES;
}

- (void) tripUpdate:(id)jsonString {
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [[TMCache sharedCache] setObject:jsonString forKey:@"last_tripdetail"];
    });
}

@end

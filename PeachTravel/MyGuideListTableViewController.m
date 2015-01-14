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
#import "SRRefreshView.h"

#define PAGE_COUNT 10

@interface MyGuideListTableViewController () <UIGestureRecognizerDelegate, TaoziMessageSendDelegate, SRRefreshDelegate, UITableViewDataSource, UITableViewDelegate, TripUpdateDelegate>

@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) DKCircleButton *editBtn;
@property (nonatomic) BOOL isEditing;
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

@property (strong, nonatomic) SRRefreshView *slimeView;


@end

@implementation MyGuideListTableViewController

static NSString *reusableCell = @"myGuidesCell";

- (id)init {
    if (self = [super init]) {
        _isEditing = NO;
        _currentPage = 0;
        _isLoadingMore = YES;
        _didEndScroll = YES;
        _enableLoadMore = NO;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    if (_selectToSend) {
        self.navigationItem.title = @"发送计划";
    } else {
        self.navigationItem.title = @"旅行计划";
        UIBarButtonItem * mp = [[UIBarButtonItem alloc]initWithTitle:@"新计划" style:UIBarButtonItemStyleBordered target:self action:@selector(makePlan)];
        mp.tintColor = APP_THEME_COLOR;
        self.navigationItem.rightBarButtonItem = mp;
    }
    
    self.view.backgroundColor = APP_PAGE_COLOR;
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    [self.view addSubview:self.tableView];
    [self.tableView addSubview:self.slimeView];
    
    _tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissPopup:)];
    _tapRecognizer.numberOfTapsRequired = 1;
    _tapRecognizer.delegate = self;
    [self.view addSubview:self.editBtn];

    [self initDataFromCache];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userDidLogout) name:userDidLogoutNoti object:nil];
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
            self.slimeView.loading = YES;
            [self pullToRefreash:nil];
        }
    }];
}


- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)dealloc
{
    _tableView.delegate = nil;
    _tableView.dataSource = nil;
    _tableView = nil;
    _slimeView.delegate = nil;
    _slimeView = nil;
    _tapRecognizer = nil;
}

#pragma mark - navigation action

- (void)userDidLogout
{
    [self.navigationController popToRootViewControllerAnimated:YES];
    
}

- (void)goBack
{
    [self.navigationController popViewControllerAnimated:YES];
   
}

- (void)makePlan {
    Destinations *destinations = [[Destinations alloc] init];
    MakePlanViewController *makePlanCtl = [[MakePlanViewController alloc] init];
    ForeignViewController *foreignCtl = [[ForeignViewController alloc] init];
    DomesticViewController *domestic = [[DomesticViewController alloc] init];
    domestic.destinations = destinations;
    foreignCtl.destinations = destinations;
    makePlanCtl.destinations = destinations;
    foreignCtl.title = @"国外";
    domestic.title = @"国内";
    makePlanCtl.viewControllers = @[domestic, foreignCtl];
    domestic.makePlanCtl = makePlanCtl;
    foreignCtl.makePlanCtl = makePlanCtl;
    domestic.notify = NO;
    foreignCtl.notify = NO;
    [self.navigationController pushViewController:makePlanCtl animated:YES];
}

#pragma mark - setter & getter

- (NSMutableArray *)dataSource
{
    if (!_dataSource) {
        _dataSource = [[NSMutableArray alloc] init];
    }
    return _dataSource;
}

- (UITableView *)tableView
{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 64, self.view.bounds.size.width, self.view.bounds.size.height-64)];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.backgroundColor = APP_PAGE_COLOR;
        [_tableView registerNib:[UINib nibWithNibName:@"MyGuidesTableViewCell" bundle:nil] forCellReuseIdentifier:reusableCell];
    }
    return _tableView;
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

- (DKCircleButton *)editBtn
{
    if (!_editBtn) {
        _editBtn = [[DKCircleButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width-60, self.view.frame.size.height-70.0, 50, 50)];
        [_editBtn setImage:[UIImage imageNamed:@"ic_layer_edit.png"] forState:UIControlStateNormal];
        [_editBtn setImage:[UIImage imageNamed:@"ic_layer_edit_done.png"] forState:UIControlStateSelected];
        [_editBtn addTarget:self action:@selector(editMyGuides:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _editBtn;
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
 *  点击编辑按钮
 *
 *  @param sender
 */
- (IBAction)editMyGuides:(id)sender
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
- (IBAction)deleteGuide:(UIButton *)sender
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"确定删除" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    [alertView showAlertViewWithBlock:^(NSInteger buttonIndex) {
        if (buttonIndex == 1) {
            CGPoint viewPos = [sender convertPoint:CGPointZero toView:self.tableView];
            NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:viewPos];
            NSInteger index = indexPath.row;
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
- (IBAction)edit:(UIButton *)sender
{
    _confirmRouteViewController = [[ConfirmRouteViewController alloc] init];
    MyGuideSummary *guideSummary = [self.dataSource objectAtIndex:sender.tag];
    [self.navigationController.view addGestureRecognizer:_tapRecognizer];
    
    CGFloat y = kWindowHeight-260-176;
    if (y>100) {
        y = 100;
    }
    [self.navigationController presentPopupViewController:_confirmRouteViewController atHeight:y animated:YES completion:nil];
    _confirmRouteViewController.routeTitle.text = guideSummary.title;
    _confirmRouteViewController.confirmRouteTitle.tag = sender.tag;
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
//            [SVProgressHUD showHint:@"OK~成功删除"];
            NSInteger index = [self.dataSource indexOfObject:guideSummary];
            [self.dataSource removeObject:guideSummary];
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
            [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            
            if (self.dataSource.count == 0) {
                self.slimeView.loading = YES;
                [self pullToRefreash:nil];
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
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
            [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
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
    NSNumber *imageWidth = [NSNumber numberWithFloat:(kWindowWidth-22)*2];
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
        if (self.slimeView.loading) {
            [self hideSlimeView];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@", error);
        [self loadMoreCompleted];
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        if (self.slimeView.loading) {
            [self hideSlimeView];
        }
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

- (void)hideSlimeView
{
    [self.slimeView endRefresh];
}

- (void)setupEmptyView {
    if (self.emptyView != nil) {
        return;
    }
    
    CGFloat width = self.view.bounds.size.width;
    
    self.emptyView = [[UIView alloc] initWithFrame:self.view.bounds];
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
    NSString *text = @"为旅行准备memo\n让你的旅行更精彩～";
    NSMutableAttributedString *attrDesc = [[NSMutableAttributedString alloc] initWithString:text];
    [attrDesc addAttribute:NSForegroundColorAttributeName value:TEXT_COLOR_TITLE_SUBTITLE  range:NSMakeRange(0, [text length])];
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.lineSpacing = 4.0;
    [style setAlignment:NSTextAlignmentCenter];
    [attrDesc addAttribute:NSParagraphStyleAttributeName value:style range:NSMakeRange(0, text.length)];
    [desc setAttributedText:attrDesc];
    
    [self.emptyView addSubview:desc];
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(0.0, 0.0, 90.0, 34.0);
//    btn.backgroundColor = APP_THEME_COLOR;
    [btn setBackgroundImage:[ConvertMethods createImageWithColor:APP_THEME_COLOR] forState:UIControlStateNormal];
    btn.clipsToBounds = YES;
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btn setTitle:@"新计划" forState:UIControlStateNormal];
    btn.titleLabel.font = [UIFont systemFontOfSize:14.0];
    btn.center = CGPointMake(width/2.0, desc.frame.origin.y + 64.0 + 40.0);
    btn.layer.cornerRadius = 2.0;
    [btn addTarget:self action:@selector(makePlan) forControlEvents:UIControlEventTouchUpInside];
    [self.emptyView addSubview:btn];
}

- (void) removeEmptyView {
    if (self.emptyView != nil) {
        [self.emptyView removeFromSuperview];
        self.emptyView = nil;
    }
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


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return self.dataSource.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 216;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MyGuidesTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reusableCell forIndexPath:indexPath];
    [cell.deleteBtn addTarget:self action:@selector(deleteGuide:) forControlEvents:UIControlEventTouchUpInside];

    cell.isEditing = _isEditing;
    if (_isEditing) {
        cell.titleBtn.userInteractionEnabled = YES;
        cell.titleBtn.tag = indexPath.row;
        [cell.titleBtn addTarget:self action:@selector(edit:) forControlEvents:UIControlEventTouchUpInside];
    } else {
        cell.titleBtn.userInteractionEnabled = NO;
    }
    cell.guideSummary = [self.dataSource objectAtIndex:indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    MyGuideSummary *guideSummary = [self.dataSource objectAtIndex:indexPath.row];
    //进入攻略详情
    if (!_selectToSend) {
        TripDetailRootViewController *tripDetailRootCtl = [[TripDetailRootViewController alloc] init];
        tripDetailRootCtl.isMakeNewTrip = NO;
        tripDetailRootCtl.tripId = guideSummary.guideId;
        tripDetailRootCtl.canEdit = YES;
        tripDetailRootCtl.contentMgrDelegate = self;
        [self.navigationController pushViewController:tripDetailRootCtl animated:YES];
        //弹出发送菜单
    } else {
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

        [self presentPopupViewController:taoziMessageCtl atHeight:170.0 animated:YES completion:^(void) {
            
        }];
    }
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

- (void) tripUpdate:(id)jsonString {
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [[TMCache sharedCache] setObject:jsonString forKey:@"last_tripdetail"];
    });
}

@end

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

@interface MyGuideListTableViewController () <UIGestureRecognizerDelegate, TaoziMessageSendDelegate>

@property (strong, nonatomic) DKCircleButton *editBtn;
@property (nonatomic) BOOL isEditing;
@property (nonatomic) NSUInteger currentPage;
@property (nonatomic, strong) NSMutableArray *dataSource;
@property (nonatomic, strong) ConfirmRouteViewController *confirmRouteViewController;
@property (nonatomic, strong) UITapGestureRecognizer *tapRecognizer;
@property (nonatomic, strong) UIView *emptyView;

@end

@implementation MyGuideListTableViewController

static NSString *reusableCell = @"myGuidesCell";

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"我的攻略";
    
    self.navigationController.navigationBar.translucent = YES;
    UIBarButtonItem * backBtn = [[UIBarButtonItem alloc]initWithTitle:nil style:UIBarButtonItemStyleBordered target:self action:@selector(goBackToAllPets)];
    [backBtn setImage:[UIImage imageNamed:@"ic_navigation_back.png"]];
    self.navigationItem.leftBarButtonItem = backBtn;
    
    UIButton *mp = [UIButton buttonWithType:UIButtonTypeCustom];
    mp.frame = CGRectMake(0.0, 0.0, 40.0, 32.0);
    [mp setTitle:@"新建" forState:UIControlStateNormal];
    mp.titleLabel.font = [UIFont systemFontOfSize:17.0];
    [mp setTitleColor:APP_THEME_COLOR forState:UIControlStateNormal];
    [mp setTitleColor:APP_THEME_COLOR_HIGHLIGHT forState:UIControlStateHighlighted];
    [mp addTarget:self action:@selector(makePlan) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightBtn = [[UIBarButtonItem alloc] initWithCustomView:mp];
    self.navigationItem.rightBarButtonItem = rightBtn;
    
    self.tableView.contentInset = UIEdgeInsetsMake(5.0, 0.0, 5.0, 0.0);
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.backgroundColor = APP_PAGE_COLOR;
    [self.tableView registerNib:[UINib nibWithNibName:@"MyGuidesTableViewCell" bundle:nil] forCellReuseIdentifier:reusableCell];
    
    _tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissPopup:)];
    _tapRecognizer.numberOfTapsRequired = 1;
    _tapRecognizer.delegate = self;
    
    _isEditing = NO;
    _currentPage = 0;
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(pullToRefreash:) forControlEvents:UIControlEventValueChanged];
    [self.refreshControl beginRefreshing];
    [self.refreshControl sendActionsForControlEvents:UIControlEventValueChanged];
    
//    [self loadDataWithPageIndex:_currentPage];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController.view addSubview:self.editBtn];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.editBtn removeFromSuperview];
}

#pragma mark - navigation action

- (void)goBackToAllPets
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
    makePlanCtl.hidesBottomBarWhenPushed = YES;
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

- (DKCircleButton *)editBtn
{
    if (!_editBtn) {
        _editBtn = [[DKCircleButton alloc] initWithFrame:CGRectMake(self.tableView.bounds.size.width-60, self.tableView.bounds.size.height-70.0, 50, 50)];
//        _editBtn.backgroundColor = APP_THEME_COLOR;
//        _editBtn.titleLabel.font = [UIFont systemFontOfSize:13.0];
//        [_editBtn setTitle:@"编辑" forState:UIControlStateNormal];
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
    //    UIRefreshControl *refreshControl = (UIRefreshControl *)sender;
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
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"确定删除吗?" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    [alertView showAlertViewWithBlock:^(NSInteger buttonIndex) {
        if (buttonIndex == 1) {
            CGPoint viewPos = [sender convertPoint:CGPointZero toView:self.tableView];
            NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:viewPos];
            int index = indexPath.row;
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
    [self.view addGestureRecognizer:_tapRecognizer];
    [_confirmRouteViewController.confirmRouteTitle addTarget:self action:@selector(willConfirmRouteTitle:) forControlEvents:UIControlEventTouchUpInside];
    [self presentPopupViewController:_confirmRouteViewController atHeight:70.0 animated:YES completion:^(void) {
    }];
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
        [SVProgressHUD showSuccessWithStatus:@"修改成功"];
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
    if (self.popupViewController != nil) {
        if ([_confirmRouteViewController.routeTitle isFirstResponder]) {
            [_confirmRouteViewController.routeTitle resignFirstResponder];
        }
        [self dismissPopupViewControllerAnimated:YES completion:^{
            [self.view removeGestureRecognizer:_tapRecognizer];
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
    
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
//    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
//    [manager.requestSerializer setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    AccountManager *accountManager = [AccountManager shareAccountManager];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"%@", accountManager.account.userId] forHTTPHeaderField:@"UserId"];

    
    NSString *urlStr = [NSString stringWithFormat:@"%@%@", API_DELETE_GUIDE, guideSummary.guideId];
    
    [SVProgressHUD show];
    
    [manager DELETE:urlStr parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"%@", responseObject);
        NSInteger code = [[responseObject objectForKey:@"code"] integerValue];
        if (code == 0) {
            [SVProgressHUD showSuccessWithStatus:@"删除成功"];
            NSInteger index = [self.dataSource indexOfObject:guideSummary];
            [self.dataSource removeObject:guideSummary];
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
            [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            if (_dataSource.count == 0) {
                [self setupEmptyView];
            }
        } else {
            [SVProgressHUD showErrorWithStatus:@"删除失败"];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@", error);
        [SVProgressHUD showErrorWithStatus:@"删除失败"];
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
    [SVProgressHUD show];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [manager.requestSerializer setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"%@", accountManager.account.userId] forHTTPHeaderField:@"UserId"];
    
    NSString *requestUrl = [NSString stringWithFormat:@"%@%@",API_SAVE_TRIPINFO, guideSummary.guideId];
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:title forKey:@"title"];

    [manager POST:requestUrl parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"%@", responseObject);
        NSInteger code = [[responseObject objectForKey:@"code"] integerValue];
        if (code == 0) {
            [SVProgressHUD showSuccessWithStatus:@"修改成功"];
            guideSummary.title = title;
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
            [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];

        } else {
            
            [SVProgressHUD showErrorWithStatus:@"修改失败"];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [SVProgressHUD showErrorWithStatus:@"修改失败"];
    }];

}

/**
 *  获取我的攻略列表
 */

- (void)loadDataWithPageIndex:(NSInteger)pageIndex
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [manager.requestSerializer setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    AccountManager *accountManager = [AccountManager shareAccountManager];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"%@", accountManager.account.userId] forHTTPHeaderField:@"UserId"];
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params safeSetObject:[NSNumber numberWithInt:10] forKey:@"pageSize"];
    [params safeSetObject:[NSNumber numberWithInt:pageIndex] forKey:@"page"];
    
    if (!self.refreshControl.isRefreshing) {
        [SVProgressHUD show];
    }
    
    //获取我的攻略列表
    [manager GET:API_GET_GUIDELIST parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"%@", responseObject);
        NSInteger code = [[responseObject objectForKey:@"code"] integerValue];
        if (code == 0) {
            [self bindDataToView:responseObject];
            _currentPage = pageIndex;
        } else {
            [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"%@",[[responseObject objectForKey:@"err"] objectForKey:@"message"]]];
        }
        [SVProgressHUD dismiss];
        [self.refreshControl endRefreshing];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@", error);
        [SVProgressHUD dismiss];
        [self.refreshControl endRefreshing];
    }];
    
}

- (void) bindDataToView:(id) responseObject {
    NSArray *datas = [responseObject objectForKey:@"result"];
    if (datas.count == 0) {
        if (_dataSource.count == 0) {
            [self setupEmptyView];
        } else {
            [self showHint:@"已取完所有内容啦"];
        }
        return;
    } else {
        [self removeEmptyView];
    }
    if (self.refreshControl.isRefreshing) {
        [_dataSource removeAllObjects];
    }
    for (NSDictionary *guideSummaryDic in [responseObject objectForKey:@"result"]) {
        MyGuideSummary *guideSummary = [[MyGuideSummary alloc] initWithJson:guideSummaryDic];
        [self.dataSource addObject:guideSummary];
    }
    [self.tableView reloadData];
}

- (void) setupEmptyView {
    if (self.emptyView != nil) {
        return;
    }
    
    CGFloat width = self.view.bounds.size.width;
    
    self.emptyView = [[UIView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:self.emptyView];
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"first_selected.png"]];
    imageView.contentMode = UIViewContentModeScaleToFill;
    imageView.center = CGPointMake(width/2.0, 100.0);
    [self.emptyView addSubview:imageView];
    
    UILabel *desc = [[UILabel alloc] initWithFrame:CGRectMake(0, 100.0+imageView.frame.size.height/2.0, width, 64.0)];
    desc.textColor = UIColorFromRGB(0x797979);
    desc.font = [UIFont systemFontOfSize:15.0];
    desc.numberOfLines = 2;
    desc.textAlignment = NSTextAlignmentCenter;
    desc.text = @"木有任何旅行攻略\n这么好的旅行助手不用可惜了";
    [self.emptyView addSubview:desc];
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(0.0, 0.0, 90.0, 34.0);
    btn.backgroundColor = APP_THEME_COLOR;
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btn setTitle:@"新建" forState:UIControlStateNormal];
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
    
    [SVProgressHUD showSuccessWithStatus:@"发送成功"];
    
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
//    cell.editTitleBtn.tag = indexPath.row;
    [cell.deleteBtn addTarget:self action:@selector(deleteGuide:) forControlEvents:UIControlEventTouchUpInside];
//    [cell.editTitleBtn addTarget:self action:@selector(edit:) forControlEvents:UIControlEventTouchUpInside];

    cell.isEditing = self.isEditing;
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
        [self.navigationController pushViewController:tripDetailRootCtl animated:YES];
        
        //弹出发送菜单
    } else {
        TaoziChatMessageBaseViewController *taoziMessageCtl = [[TaoziChatMessageBaseViewController alloc] init];
        taoziMessageCtl.delegate = self;
        taoziMessageCtl.chatType = TZChatTypeStrategy;
        taoziMessageCtl.chatCtl = _chatCtl;
        taoziMessageCtl.chatTitle = @"攻略";
        taoziMessageCtl.messageId = guideSummary.guideId;
        taoziMessageCtl.messageDesc = guideSummary.summary;
        taoziMessageCtl.messageName = guideSummary.title;
        TaoziImage *image = [guideSummary.images firstObject];
        taoziMessageCtl.messageImage = image.imageUrl;
        taoziMessageCtl.messageTimeCost = [NSString stringWithFormat:@"%d天", guideSummary.dayCount];

        [self presentPopupViewController:taoziMessageCtl atHeight:170.0 animated:YES completion:^(void) {
            
        }];
    }

}

@end

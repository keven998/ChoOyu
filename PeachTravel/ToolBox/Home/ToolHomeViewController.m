//
//  ToolHomeViewController.m
//  PeachTravel
//
//  Created by Luo Yong on 15/4/8.
//  Copyright (c) 2015年 com.aizou.www. All rights reserved.
//

#import "ToolHomeViewController.h"
#import "HotDestinationCollectionViewController.h"
#import "MyGuideListTableViewController.h"
#import "LocalViewController.h"
#import "LoginViewController.h"
#import "TravelersTableViewController.h"
#import "SearchDestinationViewController.h"
#import "AutoSlideScrollView.h"
#import "NSTimer+Addition.h"
#import "OperationData.h"
#import "SuperWebViewController.h"

@interface ToolHomeViewController ()<UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) UISearchBar *searchBar;
@property (nonatomic, strong) AutoSlideScrollView *ascrollView;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *operationDataArray;
@property (nonatomic, strong) NSMutableArray *operationImageViews;

@end

@implementation ToolHomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.title = @"旅行";
    
    _ascrollView = [[AutoSlideScrollView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), 128.0) animationDuration:8];
    _ascrollView.backgroundColor = [UIColor grayColor];
    _ascrollView.scrollView.showsHorizontalScrollIndicator = NO;
    _ascrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:_ascrollView];
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 128.0, CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds) - 128) style:UITableViewStyleGrouped];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.tableView.backgroundColor = APP_PAGE_COLOR;
    self.tableView.separatorColor = APP_BORDER_COLOR;
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"tool_cell"];
    [self.view addSubview:_tableView];
    
    _searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, self.tableView.bounds.size.width, 45)];
    _searchBar.delegate = self;
    [_searchBar setBackgroundImage:[UIImage imageNamed:@"app_background.png"]];
    _searchBar.placeholder = @"城市、景点、酒店、美食、游记";
    self.tableView.tableHeaderView = _searchBar;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (_operationDataArray == nil || _operationDataArray.count == 0) {
        [self loadOperationData];
    } else {
        [_ascrollView.animationTimer resumeTimerAfterTimeInterval:8];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [_ascrollView.animationTimer pauseTimer];
}

- (void) dealloc {
    [_ascrollView.animationTimer pauseTimer];
    _ascrollView = nil;
    [_operationImageViews removeAllObjects];
    _operationImageViews = nil;
}

- (IBAction)hideKeyboard:(id)sender
{
    [self.view endEditing:YES];
}

#pragma mark - ScrollViewDelegate

- (void) scrollViewDidScroll:(UIScrollView *)scrollView {
    [self.view endEditing:YES];
}

#pragma mark - UISearchBarDelegate
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    
}

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {
    SearchDestinationViewController *searchCtl = [[SearchDestinationViewController alloc] init];
    searchCtl.hidesBottomBarWhenPushed = YES;
//    searchCtl.titleStr = @"旅行搜搜";
//    [self.navigationController pushViewController:searchCtl animated:YES];
    [searchCtl setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];
    TZNavigationViewController *tznavc = [[TZNavigationViewController alloc] initWithRootViewController:searchCtl];
    [self presentViewController:tznavc animated:YES completion:nil];
    return NO;
}

#pragma mark - UITableViewDataSource & UITableViewDelegate

//- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
//    UIView *view = [[UIView alloc] init];
//    view.backgroundColor = APP_PAGE_COLOR;
//    return view;
//}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return CGFLOAT_MIN;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44.0f;
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 1;
    } else if (section == 1) {
        return 2;
    } else {
        return 1;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"tool_cell" forIndexPath:indexPath];
    cell.textLabel.font = [UIFont systemFontOfSize:15.0];
    cell.textLabel.textColor = TEXT_COLOR_TITLE;
    if (indexPath.section == 0) {
        cell.textLabel.text = @"达人指路";
        cell.imageView.image = [UIImage imageNamed:@"ic_gender_man.png"];
    } else if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            cell.textLabel.text = @"旅途计划";
            cell.imageView.image = [UIImage imageNamed:@"ic_gender_man.png"];
        } else {
            cell.textLabel.text = @"身边哪好玩";
            cell.imageView.image = [UIImage imageNamed:@"ic_gender_man.png"];
        }
    } else {
        cell.textLabel.text = @"目的地推荐";
        cell.imageView.image = [UIImage imageNamed:@"ic_gender_man.png"];
    }
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        TravelersTableViewController *ttvc = [[TravelersTableViewController alloc] init];
        ttvc.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:ttvc animated:YES];
    } else if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            [self myTravelPlans];
        } else {
            [MobClick event:@"event_locality"];
            LocalViewController *lvc = [[LocalViewController alloc] init];
            lvc.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:lvc animated:YES];
        }
    } else {
        HotDestinationCollectionViewController *hcvc = [[HotDestinationCollectionViewController alloc] init];
        hcvc.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:hcvc animated:YES];
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

/**
 *  我的攻略列表
 *
 *  @param sender
 */
- (IBAction)myTravelPlans {
    [MobClick event:@"event_my_trip_plans"];
    
    AccountManager *accountManager = [AccountManager shareAccountManager];
    if (!accountManager.isLogin) {
        [self performSelector:@selector(goLogin) withObject:nil afterDelay:0.3];
        [SVProgressHUD showErrorWithStatus:@"请先登录"];
    } else {
        MyGuideListTableViewController *myGuidesCtl = [[MyGuideListTableViewController alloc] init];
        myGuidesCtl.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:myGuidesCtl animated:YES];
    }
}

/**
 *  登录
 *
 *  @param sender
 */
- (IBAction)goLogin
{
    LoginViewController *loginCtl = [[LoginViewController alloc] init];
    TZNavigationViewController *nctl = [[TZNavigationViewController alloc] initWithRootViewController:loginCtl];
    loginCtl.isPushed = NO;
    [self.navigationController presentViewController:nctl animated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - HTTP METHOD
- (void)loadOperationData
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    AppUtils *utils = [[AppUtils alloc] init];
    [manager.requestSerializer setValue:utils.appVersion forHTTPHeaderField:@"Version"];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"iOS %@",utils.systemVersion] forHTTPHeaderField:@"Platform"];
    
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [manager.requestSerializer setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    NSNumber *imageWidth = [NSNumber numberWithInt:(kWindowWidth-22)*2];
    [params setObject:imageWidth forKey:@"imgWidth"];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    //获取首页数据
    [manager GET:API_GET_COLUMNS parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSInteger code = [[responseObject objectForKey:@"code"] integerValue];
        if (code == 0) {
            if (!_operationDataArray) {
                _operationDataArray = [[NSMutableArray alloc] init];
            } else {
                [_operationDataArray removeAllObjects];
            }
            for (id operationDic in [responseObject objectForKey:@"result"]) {
                OperationData *operation = [[OperationData alloc] initWithJson:operationDic];
                [_operationDataArray addObject:operation];
            }
            
            [self setupOptionContents];
        } else {
            
        }
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    }];
    
}

- (void) setupOptionContents
{
    NSInteger count = [_operationDataArray count];
    NSMutableArray *imageviews = [[NSMutableArray alloc] initWithCapacity:count];
    for (NSUInteger i = 0; i < count; i++)
    {
        [imageviews addObject:[NSNull null]];
    }
    _operationImageViews = imageviews;
    
    __weak typeof(ToolHomeViewController *)weakSelf = self;
    
    _ascrollView.fetchContentViewAtIndex = ^UIView *(NSInteger pageIndex){
        return [weakSelf loadScrollViewWithPage:pageIndex];
    };
    
    _ascrollView.totalPagesCount = ^NSInteger(void) {
        return count;
    };
    
    
    _ascrollView.TapActionBlock = ^(NSInteger pageIndex){
        OperationData *data = [weakSelf.operationDataArray objectAtIndex:pageIndex];
        SuperWebViewController *webCtl = [[SuperWebViewController alloc] init];
        webCtl.titleStr = data.title;
        webCtl.urlStr = data.linkUrl;
        webCtl.hidesBottomBarWhenPushed = YES;
        [weakSelf.navigationController pushViewController:webCtl animated:YES];
    };
}

- (UIImageView *)loadScrollViewWithPage:(NSUInteger)page {
    if (page >= _operationDataArray.count ) {
        return nil;
    }
    
    UIImageView *img = [_operationImageViews objectAtIndex:page];
    if ((NSNull *)img == [NSNull null]) {
        img = [[UIImageView alloc] initWithFrame:_ascrollView.frame];
        img.contentMode = UIViewContentModeScaleAspectFill;
        img.clipsToBounds = YES;
        [_operationImageViews replaceObjectAtIndex:page withObject:img];
        NSString *imageStr = ((OperationData *)[_operationDataArray objectAtIndex:page]).imageUrl;
        [img sd_setImageWithURL:[NSURL URLWithString:imageStr] placeholderImage:[UIImage imageNamed:@"spot_detail_default.png"]];
    }
    return img;
}

@end

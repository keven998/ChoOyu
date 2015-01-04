//
//  CityDetailTableViewController.m
//  PeachTravel
//
//  Created by liangpengshuai on 11/14/14.
//  Copyright (c) 2014 com.aizou.www. All rights reserved.
//

#import "CityDetailTableViewController.h"
#import "CityHeaderView.h"
#import "TravelNoteTableViewCell.h"
#import "CityPoi.h"
#import "TravelNote.h"
#import "PoisOfCityTableViewController.h"
#import "AccountManager.h"
#import "SuperWebViewController.h"
#import "TravelNoteListViewController.h"
#import "TravelNoteDetailViewController.h"

@interface CityDetailTableViewController () <UITableViewDataSource, UITableViewDelegate, CityHeaderViewDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) CityPoi *cityPoi;
@property (nonatomic, strong) CityHeaderView *cityHeaderView;

@end

@implementation CityDetailTableViewController

static NSString * const reuseIdentifier = @"travelNoteCell";


- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = APP_PAGE_COLOR;
    [self.tableView registerNib:[UINib nibWithNibName:@"TravelNoteTableViewCell" bundle:nil] forCellReuseIdentifier:reuseIdentifier];
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self.view addSubview:self.tableView];
    [self loadCityData];
}

- (void)updateView
{
    self.navigationItem.title = _cityPoi.zhName;
    _cityHeaderView = [[CityHeaderView alloc] init];
    _cityHeaderView.delegate = self;
    _cityHeaderView.backgroundColor = APP_PAGE_COLOR;
    [_cityHeaderView setFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 0)];
    _cityHeaderView.cityPoi = _cityPoi;
    UIView *tableHeaderView = [[UIView alloc] initWithFrame:_cityHeaderView.frame];
    self.tableView.tableHeaderView = tableHeaderView;
    [self.tableView addSubview:_cityHeaderView];
    [_cityHeaderView.favoriteBtn addTarget:self action:@selector(favorite:) forControlEvents:UIControlEventTouchUpInside];
    [_cityHeaderView.showSpotsBtn addTarget:self action:@selector(viewSpots:) forControlEvents:UIControlEventTouchUpInside];
    [_cityHeaderView.showRestaurantsBtn addTarget:self action:@selector(viewRestaurants:) forControlEvents:UIControlEventTouchUpInside];
    [_cityHeaderView.showShoppingBtn addTarget:self action:@selector(viewShopping:) forControlEvents:UIControlEventTouchUpInside];

    [self.tableView reloadData];
}

- (UITableView *)tableView
{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(11, 64, self.view.frame.size.width-22, self.view.frame.size.height-64) style:UITableViewStyleGrouped];
        _tableView.backgroundColor = APP_PAGE_COLOR;
        [_tableView setContentInset:UIEdgeInsetsMake(10, 0, 0, 0)];
        
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.showsVerticalScrollIndicator = NO;
    }
    return _tableView;
}

- (void)loadCityData
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [manager.requestSerializer setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    
    AccountManager *accountManager = [AccountManager shareAccountManager];
    if (accountManager.isLogin) {
        [manager.requestSerializer setValue:[NSString stringWithFormat:@"%@", accountManager.account.userId] forHTTPHeaderField:@"UserId"];
    }
    
    NSString *requsetUrl = [NSString stringWithFormat:@"%@%@", API_GET_CITYDETAIL, _cityId];
    
    [SVProgressHUD show];
    
    //获取城市信息
    [manager GET:requsetUrl parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"%@", responseObject);
        NSInteger code = [[responseObject objectForKey:@"code"] integerValue];
        if (code == 0) {
            [SVProgressHUD dismiss];
            _cityPoi = [[CityPoi alloc] initWithJson:[responseObject objectForKey:@"result"]];
            [self updateView];
            [self loadTravelNoteOfCityData];
        } else {
            [SVProgressHUD showHint:[NSString stringWithFormat:@"%@",[[responseObject objectForKey:@"err"] objectForKey:@"message"]]];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@", error);
        [SVProgressHUD showHint:@"呃～好像没找到网络"];
    }];
}

/**
 *  当加载完城市详情后开始加载城市的攻略内容
 */
- (void)loadTravelNoteOfCityData
{

    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [manager.requestSerializer setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:[NSNumber numberWithInt:3] forKey:@"pageSize"];
    [params setObject:_cityPoi.cityId forKey:@"locId"];
    [params setObject:[NSNumber numberWithInt:0] forKey:@"page"];
    
    [manager GET:API_SEARCH_TRAVELNOTE parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"%@", responseObject);
        NSInteger code = [[responseObject objectForKey:@"code"] integerValue];
        if (code == 0) {
            id travelNotes = [responseObject objectForKey:@"result"];
            if ([travelNotes isKindOfClass:[NSArray class]]) {
                _cityPoi.travelNotes = travelNotes;
            }
            [self.tableView reloadData];
        } else {
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@", error);
//        [SVProgressHUD showErrorWithStatus:@"加载失败"];
//        [self showHint:@"呃～好像没找到网络"];
    }];

}

/** 
 *  实现父类的发送 poi 到桃talk 的值传递
 *
 *  @param taoziMessageCtl
 */
- (void)setChatMessageModel:(TaoziChatMessageBaseViewController *)taoziMessageCtl
{
    taoziMessageCtl.messageId = _cityPoi.cityId;
    taoziMessageCtl.messageImage = ((TaoziImage *)[_cityPoi.images firstObject]).imageUrl;
    taoziMessageCtl.messageDesc = _cityPoi.desc;
    taoziMessageCtl.messageName = _cityPoi.zhName;
    taoziMessageCtl.messageTimeCost = _cityPoi.timeCostDesc;
    taoziMessageCtl.descLabel.text = _cityPoi.desc;
    taoziMessageCtl.chatType = TZChatTypeCity;
}

#pragma mark - IBAction Methods

- (IBAction)favorite:(id)sender
{
    //先将收藏的状态改变
    _cityHeaderView.favoriteBtn.selected = !_cityPoi.isMyFavorite;
    _cityHeaderView.favoriteBtn.userInteractionEnabled = NO;
    [super asyncFavorite:_cityPoi.cityId poiType:@"locality" isFavorite:!_cityPoi.isMyFavorite completion:^(BOOL isSuccess) {
        _cityHeaderView.favoriteBtn.userInteractionEnabled = YES;
        if (isSuccess) {
            _cityPoi.isMyFavorite = !_cityPoi.isMyFavorite;
        } else {      //如果失败了，再把状态改回来
            _cityHeaderView.favoriteBtn.selected = !_cityPoi.isMyFavorite;
        }
    }];
}

- (IBAction)viewSpots:(id)sender
{
    SuperWebViewController *funOfCityWebCtl = [[SuperWebViewController alloc] init];
    funOfCityWebCtl.urlStr = [NSString stringWithFormat:@"%@%@", FUN_CITY_HTML, _cityPoi.cityId];
    funOfCityWebCtl.titleStr = _cityPoi.zhName;
    [self.navigationController pushViewController:funOfCityWebCtl animated:YES];
}

- (IBAction)viewRestaurants:(id)sender
{
    NSLog(@"应该进入城市的美食信息");

    PoisOfCityTableViewController *restaurantOfCityCtl = [[PoisOfCityTableViewController alloc] init];
    restaurantOfCityCtl.shouldEdit = NO;
    restaurantOfCityCtl.cityId = _cityPoi.cityId;
    restaurantOfCityCtl.zhName = _cityPoi.zhName;
    restaurantOfCityCtl.poiType = kRestaurantPoi;
    
    [self.navigationController pushViewController:restaurantOfCityCtl animated:YES];
}

- (IBAction)viewShopping:(id)sender
{
    NSLog(@"应该进入城市的购物信息");

    PoisOfCityTableViewController *shoppingOfCityCtl = [[PoisOfCityTableViewController alloc] init];
    shoppingOfCityCtl.shouldEdit = NO;
    shoppingOfCityCtl.cityId = _cityPoi.cityId;
    shoppingOfCityCtl.zhName = _cityPoi.zhName;
    shoppingOfCityCtl.poiType = kShoppingPoi;
    
    [self.navigationController pushViewController:shoppingOfCityCtl animated:YES];
}

- (IBAction)showMoreTravelNote:(id)sender
{
    TravelNoteListViewController *travelListCtl = [[TravelNoteListViewController alloc] init];
    travelListCtl.isSearch = NO;
    travelListCtl.cityId = self.cityPoi.cityId;
    [self.navigationController pushViewController:travelListCtl animated:YES];
}

#pragma mark - CityHeaderViewDelegate

- (void)updateCityHeaderView
{
    UIView *tableHeaderView = [[UIView alloc] initWithFrame:_cityHeaderView.frame];
    tableHeaderView.backgroundColor = APP_PAGE_COLOR;
    [self.tableView beginUpdates];
    [self.tableView setTableHeaderView:tableHeaderView];
    [self.tableView endUpdates];
    [self.tableView bringSubviewToFront:_cityHeaderView];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (self.cityPoi.travelNotes.count >= 1) {
        return 1;
    } else {
        return 0;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 149.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return 30.0;
    }
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.cityPoi.travelNotes.count;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 30)];
    [btn setImage:[UIImage imageNamed:@"ic_standard_travelnote.png"] forState:UIControlStateNormal];
    [btn setImage:[UIImage imageNamed:@"ic_standard_travelnote.png"] forState:UIControlStateHighlighted];
    
    btn.layer.cornerRadius = 2.0;

    [btn setTitle:@"精选游记" forState:UIControlStateNormal];
    [btn setTitleColor:TEXT_COLOR_TITLE forState:UIControlStateNormal];
    [btn setTitleColor:TEXT_COLOR_TITLE forState:UIControlStateHighlighted];

    btn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [btn setContentEdgeInsets:UIEdgeInsetsMake(0, 8, 0, 0)];
    [btn setTitleEdgeInsets:UIEdgeInsetsMake(0, 8, 0, 0)];
    btn.titleLabel.font = [UIFont systemFontOfSize:12.0];
    btn.backgroundColor = [UIColor whiteColor];
    
    UIButton *moreTravelNoteBtn = [[UIButton alloc] initWithFrame:CGRectMake(btn.frame.size.width-75, 0, 80, 30)];
//    [moreTravelNoteBtn setTitle:@"更多游记" forState:UIControlStateNormal];
//    [moreTravelNoteBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    moreTravelNoteBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    moreTravelNoteBtn.titleLabel.font = [UIFont systemFontOfSize:12.0];
    moreTravelNoteBtn.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 12.0);
    [moreTravelNoteBtn addTarget:self action:@selector(showMoreTravelNote:) forControlEvents:UIControlEventTouchUpInside];
    
    NSMutableAttributedString *desc = [[NSMutableAttributedString alloc] initWithString:@"更多游记"];
    [desc addAttribute:NSForegroundColorAttributeName value:[[UIColor blueColor] colorWithAlphaComponent:0.8]  range:NSMakeRange(0, 4)];
//    [desc addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInt:1] range:NSMakeRange(0, 4)];
//    [desc addAttribute:NSUnderlineColorAttributeName value:[[UIColor blueColor] colorWithAlphaComponent:0.8] range:NSMakeRange(0, 4)];
    [moreTravelNoteBtn setAttributedTitle:desc forState:UIControlStateNormal];
    desc = [[NSMutableAttributedString alloc] initWithString:@"更多游记"];
//    [desc addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInt:1] range:NSMakeRange(0, 4)];
    [desc addAttribute:NSForegroundColorAttributeName value:[[UIColor blueColor] colorWithAlphaComponent:0.5]  range:NSMakeRange(0, 4)];
//    [desc addAttribute:NSUnderlineColorAttributeName value:[[UIColor blueColor] colorWithAlphaComponent:0.5] range:NSMakeRange(0, 4)];
    [moreTravelNoteBtn setAttributedTitle:desc forState:UIControlStateHighlighted];
    
    [btn addSubview:moreTravelNoteBtn];
    
    UIView *spaceView = [[UIView alloc] initWithFrame:CGRectMake(0, 29, btn.frame.size.width, 0.5)];
    spaceView.backgroundColor = APP_PAGE_COLOR;
    [btn addSubview:spaceView];
    btn.layer.cornerRadius = 2.0;

    return btn;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TravelNoteTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier forIndexPath:indexPath];
    TravelNote *travelNote = [self.cityPoi.travelNotes objectAtIndex:indexPath.row];
    cell.travelNoteImage = travelNote.cover;
    cell.title = travelNote.title;
    cell.desc = travelNote.summary;
    cell.authorName = travelNote.authorName;
    cell.authorAvatar = travelNote.authorAvatar;
    cell.resource = travelNote.source;
    cell.time = travelNote.publishDateStr;
    cell.canSelect = NO;
    return cell;
}

#pragma mark - TableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    TravelNote *travelNote = [self.cityPoi.travelNotes objectAtIndex:indexPath.row];
    TravelNoteDetailViewController *travelNoteCtl = [[TravelNoteDetailViewController alloc] init];
    travelNoteCtl.title = travelNote.title;
    
    travelNoteCtl.travelNoteTitle = travelNote.title;
    travelNoteCtl.desc = travelNote.summary;
    travelNoteCtl.travelNoteCover = travelNote.cover;
    travelNoteCtl.travelNoteId = travelNote.travelNoteId;
    [self.navigationController pushViewController:travelNoteCtl animated:YES];
    
}



@end







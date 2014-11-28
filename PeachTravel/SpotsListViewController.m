//
//  SpotsListViewController.m
//  PeachTravel
//
//  Created by liangpengshuai on 11/24/14.
//  Copyright (c) 2014 com.aizou.www. All rights reserved.
//

#import "SpotsListViewController.h"
#import "SpotsListTableViewCell.h"
#import "DKCircleButton.h"
#import "RNGridMenu.h"
#import "DestinationsView.h"
#import "AddPoiTableViewController.h"
#import "CityDestinationPoi.h"
#import "DestinationUnit.h"
#import "CityDetailTableViewController.h"
#import "RecommendDataSource.h"
#import "SpotDetailViewController.h"
#import "RestaurantDetailViewController.h"
#import "ShoppingDetailViewController.h"

@interface SpotsListViewController () <UITableViewDataSource, UITableViewDelegate, RNGridMenuDelegate, addPoiDelegate>

@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) DKCircleButton *editBtn;
@property (strong, nonatomic) UIView *tableViewFooterView;
@property (strong, nonatomic) DestinationsView *destinationsHeaderView;


@end

@implementation SpotsListViewController

static NSString *spotsListReusableIdentifier = @"spotsListCell";

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.view.backgroundColor = APP_PAGE_COLOR;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView registerNib:[UINib nibWithNibName:@"SpotsListTableViewCell" bundle:nil] forCellReuseIdentifier:spotsListReusableIdentifier];
    [self.view addSubview:self.tableView];
    
    _editBtn = [[DKCircleButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width-60, self.view.frame.size.height-100, 40, 40)];
    _editBtn.backgroundColor = APP_THEME_COLOR;
    _editBtn.titleLabel.font = [UIFont systemFontOfSize:13.0];
    [_editBtn setTitle:@"编辑" forState:UIControlStateNormal];
    [_editBtn addTarget:self action:@selector(editTrip:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_editBtn];

}

#pragma mark - setter & getter

- (void)setTripDetail:(TripDetail *)tripDetail
{
    _tripDetail = tripDetail;
    [_tableView reloadData];
    [self updateDestinationsHeaderView];
}

- (UITableView *)tableView
{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(8, 64+8, self.view.frame.size.width-16, self.view.frame.size.height-64-48)];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.backgroundColor = APP_PAGE_COLOR;
        _tableView.tableHeaderView = self.destinationsHeaderView;
        _tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 80)];
        [_tableView setContentOffset:CGPointMake(0, 60)];
    }
    return _tableView;
}

- (UIView *)tableViewFooterView
{
    if (!_tableViewFooterView) {
        _tableViewFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 80)];
        UIButton *addOneDayBtn = [[UIButton alloc] initWithFrame:CGRectMake(20, 5, 80, 30)];
        [addOneDayBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [addOneDayBtn setTitle:@"添加一天" forState:UIControlStateNormal];
        addOneDayBtn.backgroundColor = APP_THEME_COLOR;
        [addOneDayBtn addTarget:self action:@selector(addOneDay:) forControlEvents:UIControlEventTouchUpInside];
        addOneDayBtn.layer.cornerRadius = 2.0;
        addOneDayBtn.titleLabel.font = [UIFont boldSystemFontOfSize:14.0];
        [_tableViewFooterView addSubview:addOneDayBtn];
        if (!self.tableView.isEditing) {
            UIView *nodeView = [[UIView alloc] initWithFrame:CGRectMake(1, 16, 8, 8)];
            nodeView.backgroundColor = APP_THEME_COLOR;
            nodeView.layer.cornerRadius = 4.0;
            [_tableViewFooterView addSubview:nodeView];
            
            
            UIView *verticalSpaceViewUp = [[UIView alloc] initWithFrame:CGRectMake(5, 0, 1, 16)];
            verticalSpaceViewUp.backgroundColor = [UIColor lightGrayColor];
            [_tableViewFooterView addSubview:verticalSpaceViewUp];
       
        }
    }
    return _tableViewFooterView;
}

- (DestinationsView *)destinationsHeaderView
{
    if (!_destinationsHeaderView) {
        _destinationsHeaderView = [[DestinationsView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 60) andContentOffsetX:20];
        [self updateDestinationsHeaderView];
    }
    return _destinationsHeaderView;
}

#pragma mark Private Methods

- (void)updateDestinationsHeaderView
{
    NSMutableArray *destinationsArray = [[NSMutableArray alloc] init];
    for (CityDestinationPoi *poi in _tripDetail.destinations) {
        if (poi.zhName) {
            [destinationsArray addObject:poi.zhName];
        }
    }
    _destinationsHeaderView.destinations = destinationsArray;
    for (DestinationUnit *unit in _destinationsHeaderView.destinationItmes) {
        [unit addTarget:self action:@selector(viewCityDetail:) forControlEvents:UIControlEventTouchUpInside];
    }
}

#pragma makr - IBAction Methods

- (IBAction)addOneDay:(id)sender
{
    [_tripDetail.itineraryList addObject:[[NSMutableArray alloc] init]];
    NSIndexSet *indexSet = [[NSIndexSet alloc] initWithIndex:_tripDetail.itineraryList.count-1];
    [self.tableView insertSections:indexSet withRowAnimation:UITableViewRowAnimationAutomatic];
    _tripDetail.dayCount++;
}

- (IBAction)showMore:(UIButton *)sender
{
    NSInteger numberOfOptions = 2;
    RNGridMenuItem *addItem = [[RNGridMenuItem alloc] initWithImage:[UIImage imageNamed:@"ic_menu_circle_chat.png"] title:@"添加目的地"];
    RNGridMenuItem *deleteItem = [[RNGridMenuItem alloc] initWithImage:[UIImage imageNamed:@"ic_menu_add_friend.png"] title:@"删除"]
    ;
    
    NSArray *items = @[
                       addItem,
                       deleteItem
                       ];
    
    RNGridMenu *av = [[RNGridMenu alloc] initWithItems:[items subarrayWithRange:NSMakeRange(0, numberOfOptions)]];
    av.backgroundColor = [UIColor clearColor];
    av.delegate = self;
    av.menuView.tag = sender.tag;
    [av showInViewController:self center:CGPointMake(self.view.bounds.size.width/2.f, self.view.bounds.size.height/2.f)];
}

- (IBAction)mapView:(id)sender
{
    //TODO:进入地图导航
}

- (void)updateTableView
{
    [self.tableView reloadData];
    if (self.tableView.isEditing) {
        self.tableView.tableFooterView = self.tableViewFooterView;
    } else {
        self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 80)];
    }
}

- (IBAction)editTrip:(id)sender
{
    [self.tableView setEditing:!self.tableView.isEditing animated:YES];
    [self performSelector:@selector(updateTableView) withObject:nil afterDelay:0.2];
    if (self.tableView.isEditing) {
        [_editBtn setTitle:@"完成" forState:UIControlStateNormal];
    } else {
        [_editBtn setTitle:@"编辑" forState:UIControlStateNormal];
        [self.tripDetail saveTrip:^(BOOL isSuccesss) {
            
        }];
    }
}

/**
 *  点击我的目的地进入城市详情
 *
 *  @param sender
 */
- (IBAction)viewCityDetail:(UIButton *)sender
{
    CityDestinationPoi *poi = [_tripDetail.destinations objectAtIndex:sender.tag];
    CityDetailTableViewController *cityDetailCtl = [[CityDetailTableViewController alloc] init];
    cityDetailCtl.cityId = poi.cityId;
    [self.rootViewController.navigationController pushViewController:cityDetailCtl animated:YES];
}

#pragma mark - RNGridMenuDelegate
- (void)gridMenu:(RNGridMenu *)gridMenu willDismissWithSelectedItem:(RNGridMenuItem *)item atIndex:(NSInteger)itemIndex {
    //进入添加目的地界面
    if (itemIndex == 0) {
        AddPoiTableViewController *addPoiCtl = [[AddPoiTableViewController alloc] init];
        addPoiCtl.tripDetail = self.tripDetail;
        addPoiCtl.delegate = self;
        addPoiCtl.currentDayIndex = gridMenu.menuView.tag;
        UINavigationController *nctl = [[UINavigationController alloc] initWithRootViewController:addPoiCtl];
        [self presentViewController:nctl animated:YES completion:^{
            [addPoiCtl loadData];
        }];
    }
    //删除一天
    if (itemIndex == 1) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"确定删除？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        [alertView showAlertViewWithBlock:^(NSInteger buttonIndex) {
            if (buttonIndex == 1) {
                [_tripDetail.itineraryList removeObjectAtIndex:gridMenu.menuView.tag];
                _tripDetail.dayCount--;
                [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:gridMenu.menuView.tag] withRowAnimation:UITableViewRowAnimationAutomatic];
            }
        }];
    }
}

#pragma mark - AddPoiDelegate

- (void)finishEdit
{
    [self.tableView reloadData];
}

#pragma mark - UITableViewDataSource & Delegate

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 30;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 20;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return _tripDetail.itineraryList.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[_tripDetail.itineraryList objectAtIndex:section] count];
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 20)];
    UIView *spaceView = [[UIView alloc] initWithFrame:CGRectMake(5, 0, 1, 20)];
    view.backgroundColor = APP_PAGE_COLOR;
    if (!self.tableView.isEditing) {
        spaceView.backgroundColor = [UIColor lightGrayColor];
        [view addSubview:spaceView];
    }
    return view;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 30)];
    UILabel *headerTitle;
    if (self.tableView.isEditing) {
        headerTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, headerView.frame.size.width-60, 30)];
    } else {
        headerTitle = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, headerView.frame.size.width-80, 30)];
    }
    NSMutableString *headerTitleStr = [NSMutableString stringWithFormat:@"  D%d  ", section+1];
    NSMutableOrderedSet *set = [[NSMutableOrderedSet alloc] init];
    for (TripPoi *tripPoi in [_tripDetail.itineraryList objectAtIndex:section]) {
        CityDestinationPoi *poi = [tripPoi.locList lastObject];
        if (poi.zhName) {
            [set addObject:poi.zhName];
        }
    }

    for (int i=0; i<set.count; i++) {
        NSString *str;
        if (i == set.count-1) {
            str = [set objectAtIndex:i];
        } else {
            str = [NSString stringWithFormat:@"%@--", [set objectAtIndex:i]];
        }
        [headerTitleStr appendString:str];

    }
    headerTitle.text = headerTitleStr;
    headerTitle.font = [UIFont boldSystemFontOfSize:17.0];
    headerTitle.backgroundColor = [UIColor whiteColor];
    [headerView addSubview:headerTitle];
    
    if (self.tableView.isEditing) {
        UIButton *moreBtn = [[UIButton alloc] initWithFrame:CGRectMake(headerView.frame.size.width-80, 0, 80, 30)];
        [moreBtn setBackgroundColor:[UIColor whiteColor]];
        [moreBtn setTitle:@"更多" forState:UIControlStateNormal];
        [moreBtn setTitleColor:APP_THEME_COLOR forState:UIControlStateNormal];
        moreBtn.tag = section;
        [moreBtn addTarget:self action:@selector(showMore:) forControlEvents:UIControlEventTouchUpInside];
        [headerView addSubview:moreBtn];
    } else {
        UIButton *mapBtn = [[UIButton alloc] initWithFrame:CGRectMake(headerView.frame.size.width-80, 0, 80, 30)];
        [mapBtn setBackgroundColor:[UIColor whiteColor]];
        [mapBtn setTitle:@"地图" forState:UIControlStateNormal];
        [mapBtn setTitleColor:APP_THEME_COLOR forState:UIControlStateNormal];
        mapBtn.tag = section;
        [mapBtn addTarget:self action:@selector(mapView:) forControlEvents:UIControlEventTouchUpInside];
        [headerView addSubview:mapBtn];

    }
    
    UIView *horizontalSpaceView = [[UIView alloc] initWithFrame:CGRectMake(0, headerView.frame.size.height-1, headerView.frame.size.width, 1)];
    horizontalSpaceView.backgroundColor = APP_PAGE_COLOR;
    [headerView addSubview:horizontalSpaceView];
    if (!tableView.isEditing) {
        UIView *nodeView = [[UIView alloc] initWithFrame:CGRectMake(1, 11, 8, 8)];
        nodeView.backgroundColor = APP_THEME_COLOR;
        nodeView.layer.cornerRadius = 4.0;
        [headerView addSubview:nodeView];
        
        UIView *verticalSpaceView = [[UIView alloc] initWithFrame:CGRectMake(5, 19, 1, 11)];
        verticalSpaceView.backgroundColor = [UIColor lightGrayColor];
        [headerView addSubview:verticalSpaceView];
        
        if (section != 0) {
            UIView *verticalSpaceViewUp = [[UIView alloc] initWithFrame:CGRectMake(5, 0, 1, 11)];
            verticalSpaceViewUp.backgroundColor = [UIColor lightGrayColor];
            [headerView addSubview:verticalSpaceViewUp];
        }
    }
    
    return headerView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SpotsListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:spotsListReusableIdentifier forIndexPath:indexPath];
    cell.isEditing = self.tableView.isEditing;
    cell.tripPoi = _tripDetail.itineraryList[indexPath.section][indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    TripPoi *tripPoi = _tripDetail.itineraryList[indexPath.section][indexPath.row];
    switch (tripPoi.poiType) {
        case TripSpotPoi: {
            SpotDetailViewController *spotDetailCtl = [[SpotDetailViewController alloc] init];
            spotDetailCtl.spotId = tripPoi.poiId;
            [self.rootViewController.navigationController pushViewController:spotDetailCtl animated:YES];
        }
            break;
        case TripRestaurantPoi: {
            RestaurantDetailViewController *restaurantDetailCtl = [[RestaurantDetailViewController alloc] init];
            restaurantDetailCtl.restaurantId = tripPoi.poiId;
            [self.rootViewController.navigationController pushViewController:restaurantDetailCtl animated:YES];
        }
            
            break;
        case TripShoppingPoi: {
            ShoppingDetailViewController *shoppingDetailCtl = [[ShoppingDetailViewController alloc] init];
            shoppingDetailCtl.shoppingId = tripPoi.poiId;
            [self.rootViewController.navigationController pushViewController:shoppingDetailCtl animated:YES];
        }
            
            break;
        case TripHotelPoi:
            
            break;
            
        default:
            break;
    }
    
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (NSIndexPath *)tableView:(UITableView *)tableView targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)sourceIndexPath toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath {
    return proposedDestinationIndexPath;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSMutableArray *tempArray = [_tripDetail.itineraryList objectAtIndex:indexPath.section];
        [tempArray removeObjectAtIndex:indexPath.row];
        NSArray *indexPaths = [NSArray arrayWithObject:indexPath];
        [tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationLeft];
    }
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
    NSMutableArray *fromArray = _tripDetail.itineraryList[sourceIndexPath.section];
    NSMutableArray *toArray = _tripDetail.itineraryList[destinationIndexPath.section];

    TripPoi *poi = [fromArray objectAtIndex:sourceIndexPath.row];
    [fromArray removeObjectAtIndex:sourceIndexPath.row];
    [toArray insertObject:poi atIndex:destinationIndexPath.row];
    
}

- (UITableViewCellEditingStyle) tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleDelete;
}


#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    CGPoint currentOffset = scrollView.contentOffset;
    NSLog(@"%@",NSStringFromCGPoint(currentOffset));
    
    if ([scrollView isEqual:self.tableView]) {
        if (currentOffset.y < 20) {
            [self.tableView setContentOffset:CGPointZero animated:YES];
        } else if ((currentOffset.y > 20) && (currentOffset.y < 60)) {
            [self.tableView setContentOffset:CGPointMake(0, 60) animated:YES];
        }
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    CGPoint currentOffset = scrollView.contentOffset;
    NSLog(@"***%@",NSStringFromCGPoint(currentOffset));

    if ([scrollView isEqual:self.tableView]) {
        if (currentOffset.y < 20) {
            [self.tableView setContentOffset:CGPointZero animated:YES];
        } else if ((currentOffset.y > 20) && (currentOffset.y < 60)) {
            [self.tableView setContentOffset:CGPointMake(0, 60) animated:YES];
        }
    }
}


@end

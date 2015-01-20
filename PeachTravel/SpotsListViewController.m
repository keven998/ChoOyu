//
//  SpotsListViewController.m
//  PeachTravel
//
//  Created by liangpengshuai on 11/24/14.
//  Copyright (c) 2014 com.aizou.www. All rights reserved.
//

#import "SpotsListViewController.h"
#import "TripPoiListTableViewCell.h"
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
#import "CommonPoiListTableViewCell.h"
#import "HotelDetailViewController.h"
#import "MyTripSpotsMapViewController.h"
#import "PositionBean.h"

@interface SpotsListViewController () <UITableViewDataSource, UITableViewDelegate, RNGridMenuDelegate, addPoiDelegate, DestinationsViewDelegate>

@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) UIView *tableViewFooterView;

@end

@implementation SpotsListViewController

static NSString *tripPoiListReusableIdentifier = @"tripPoiListCell";
static NSString *commonPoiListReusableIdentifier = @"commonPoiListCell";


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.view.backgroundColor = APP_PAGE_COLOR;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView registerNib:[UINib nibWithNibName:@"TripPoiListTableViewCell" bundle:nil] forCellReuseIdentifier:tripPoiListReusableIdentifier];
    [self.tableView registerNib:[UINib nibWithNibName:@"CommonPoiListTableViewCell" bundle:nil] forCellReuseIdentifier:commonPoiListReusableIdentifier];
    
    [self.view addSubview:self.tableView];
    
    NSLog(@"spots didload");
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    NSLog(@"spots viewDisAppear");
}

#pragma mark - setter & getter

- (void)setTripDetail:(TripDetail *)tripDetail
{
    _tripDetail = tripDetail;
    [_tableView reloadData];
}

- (UITableView *)tableView
{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(11, -35, self.view.bounds.size.width-22, self.view.bounds.size.height-62) style:UITableViewStyleGrouped];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.showsVerticalScrollIndicator = NO;
        _tableView.showsHorizontalScrollIndicator = NO;
        _tableView.backgroundColor = APP_PAGE_COLOR;
        _tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 135)];
        _tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 45)];
    }
    return _tableView;
}

- (UIView *)tableViewFooterView
{
    if (!_tableViewFooterView) {
        _tableViewFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 135)];
        UIButton *addOneDayBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 5, 108.0, 34)];
        [addOneDayBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [addOneDayBtn setTitle:@"增加一天" forState:UIControlStateNormal];
        addOneDayBtn.clipsToBounds = YES;
        [addOneDayBtn setBackgroundImage:[ConvertMethods createImageWithColor:APP_THEME_COLOR] forState:UIControlStateNormal];
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

#pragma makr - IBAction Methods

- (IBAction)addOneDay:(id)sender
{
    [_tripDetail.itineraryList addObject:[[NSMutableArray alloc] init]];
    NSIndexSet *indexSet = [[NSIndexSet alloc] initWithIndex:_tripDetail.itineraryList.count-1];
    [self.tableView insertSections:indexSet withRowAnimation:UITableViewRowAnimationAutomatic];
    _tripDetail.dayCount++;
}

- (IBAction)addPoi:(UIButton *)sender
{
    AddPoiTableViewController *addPoiCtl = [[AddPoiTableViewController alloc] init];
    addPoiCtl.tripDetail = self.tripDetail;
    addPoiCtl.delegate = self;
    addPoiCtl.currentDayIndex = sender.tag;
    UINavigationController *nctl = [[UINavigationController alloc] initWithRootViewController:addPoiCtl];
    [self presentViewController:nctl animated:YES completion:^{
    }];
}

- (IBAction)deleteOneDay:(UIButton *)sender
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"确定删除这一天吗？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    [alertView showAlertViewWithBlock:^(NSInteger buttonIndex) {
        if (buttonIndex == 1) {
            [_tripDetail.itineraryList removeObjectAtIndex:sender.tag];
            _tripDetail.dayCount--;
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sender.tag] withRowAnimation:UITableViewRowAnimationAutomatic];
            [self.tableView reloadData];
        }
    }];
}

- (IBAction)mapView:(UIButton *)sender
{
    MyTripSpotsMapViewController *ctl = [[MyTripSpotsMapViewController alloc] init];

    NSMutableArray *allPositions = [[NSMutableArray alloc] init];
    for (TripPoi *poi in _tripDetail.itineraryList[sender.tag]) {
        PositionBean *position = [[PositionBean alloc] init];
        position.latitude = poi.lat;
        position.longitude = poi.lng;
        position.poiName = poi.zhName;
        position.poiId = poi.poiId;
        [allPositions addObject:position];
    }
    ctl.pois = allPositions;
    UINavigationController *nCtl = [[UINavigationController alloc] initWithRootViewController:ctl];
    [self presentViewController:nCtl animated:YES completion:^{
        
    }];
}

- (void)updateTableView
{
    [self.tableView reloadData];
    if (self.tableView.isEditing) {
        self.tableView.tableFooterView = self.tableViewFooterView;
    } else {
        self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 80)];
    }
    
    [self.tableView reloadData];
    
}

- (void)setShouldEdit:(BOOL)shouldEdit
{
    _shouldEdit = shouldEdit;
    [self editTrip:nil];
}

- (IBAction)editTrip:(id)sender
{
    if (!self.tableView.isEditing) {
        [self.tableView setEditing:YES animated:YES];
        [self performSelector:@selector(updateTableView) withObject:nil afterDelay:0.2];
        
    } else {
         __weak typeof(SpotsListViewController *)weakSelf = self;
        
        if (!self.tripDetail.tripIsChange) {
            [self.tableView setEditing:NO animated:YES];
            [self performSelector:@selector(updateTableView) withObject:nil afterDelay:0.2];
            return;
        }
        TZProgressHUD *hud = [[TZProgressHUD alloc] init];
        [hud showHUDInViewController:weakSelf.navigationController];

        [self.tripDetail saveTrip:^(BOOL isSuccesss) {
            [hud hideTZHUD];
            if (isSuccesss) {
                [self.tableView setEditing:NO animated:YES];
                [self performSelector:@selector(updateTableView) withObject:nil afterDelay:0.2];
            } else {
                [SVProgressHUD showErrorWithStatus:@"保存失败"];
            }
        }];
    }
}

#pragma mark - AddPoiDelegate

- (void)finishEdit
{
    [self.tableView reloadData];
}

#pragma mark - DestinationsViewDelegate

//TODO:进入城市详情
- (void)distinationDidSelect:(UIButton *)button
{
    
}

#pragma mark - UITableViewDataSource & Delegate

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if ([[_tripDetail.itineraryList objectAtIndex:section] count]) {
        return 60;
    } else {
        return 30;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 18;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
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
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 18)];
    view.backgroundColor = APP_PAGE_COLOR;
    return view;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 60)];
    headerView.layer.cornerRadius = 2.0;
    headerView.backgroundColor = UIColorFromRGB(0xeaeaea);
    headerView.clipsToBounds = YES;
    UILabel *headerTitle;
    if (self.tableView.isEditing) {
        headerTitle = [[UILabel alloc] initWithFrame:CGRectMake(40, 0, headerView.frame.size.width-103, 30)];
    } else {
        headerTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, headerView.frame.size.width-80, 30)];
    }
    NSMutableString *headerTitleStr = [NSMutableString stringWithFormat:@"   第%ld天  ",(long)section+1];
    NSMutableOrderedSet *set = [[NSMutableOrderedSet alloc] init];
    for (TripPoi *tripPoi in [_tripDetail.itineraryList objectAtIndex:section]) {
        if (tripPoi.locality.zhName) {
            [set addObject:tripPoi.locality.zhName];
        }
    }
    
    if (set.count) {
        DestinationsView *destinationView = [[DestinationsView alloc] initWithFrame:CGRectMake(0, 30, tableView.bounds.size.width, 30)];
        destinationView.backgroundColor = [UIColor whiteColor];
        [headerView addSubview:destinationView];
        NSMutableArray *distinationArray = [[NSMutableArray alloc] init];
        for (NSString *s in set) {
            [distinationArray addObject:s];
        }
        destinationView.destinations = distinationArray;
        destinationView.tag = section;
        destinationView.delegate = self;
    }
    
    headerTitle.text = headerTitleStr;
    headerTitle.font = [UIFont boldSystemFontOfSize:13.0];
    [headerView addSubview:headerTitle];
    
    if (self.tableView.isEditing) {
        UIButton *addbtn = [[UIButton alloc] initWithFrame:CGRectMake(headerView.frame.size.width-72, 0, 72, 30)];
        addbtn.tag = section;
        [addbtn addTarget:self action:@selector(addPoi:) forControlEvents:UIControlEventTouchUpInside];
        
        UIButton *addSpotBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 6, 60, 18)];
        [addSpotBtn setTitle:@"添加安排" forState:UIControlStateNormal];
        [addSpotBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [addSpotBtn setBackgroundImage:[ConvertMethods createImageWithColor:APP_THEME_COLOR] forState:UIControlStateNormal];
        addSpotBtn.clipsToBounds = YES;
        addSpotBtn.titleLabel.font = [UIFont systemFontOfSize:12.0];
        addSpotBtn.layer.cornerRadius = 9;
        addSpotBtn.userInteractionEnabled = NO;
        [addbtn addSubview:addSpotBtn];
        [headerView addSubview:addbtn];
        
        UIButton *deleteBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 50, headerView.frame.size.height)];
        deleteBtn.tag = section;
        [deleteBtn addTarget:self action:@selector(deleteOneDay:) forControlEvents:UIControlEventTouchUpInside];
        
        UIButton *deleteSpotBtn = [[UIButton alloc] initWithFrame:CGRectMake(10, 7, 36, 21)];
        [deleteSpotBtn setTitle:@"删除" forState:UIControlStateNormal];
        [deleteSpotBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//        deleteSpotBtn.backgroundColor = APP_THEME_COLOR;
        [deleteSpotBtn setBackgroundImage:[ConvertMethods createImageWithColor:APP_THEME_COLOR] forState:UIControlStateNormal];
        deleteSpotBtn.clipsToBounds = YES;
        deleteSpotBtn.titleLabel.font = [UIFont systemFontOfSize:12.0];
        deleteSpotBtn.layer.cornerRadius = 10.5;
        deleteSpotBtn.userInteractionEnabled = NO;
        [deleteBtn addSubview:deleteSpotBtn];
        [headerView addSubview:deleteBtn];
        
    } else {
        UIButton *mapBtn = [[UIButton alloc] initWithFrame:CGRectMake(headerView.frame.size.width-60, 0, 60, 35)];
        [mapBtn setImage:[UIImage imageNamed:@"ic_map.png"] forState:UIControlStateNormal];
        [mapBtn setImageEdgeInsets:UIEdgeInsetsMake(0, 20, 0, 0)];
        mapBtn.tag = section;
        mapBtn.titleLabel.font = [UIFont systemFontOfSize:12.0];
        [mapBtn addTarget:self action:@selector(mapView:) forControlEvents:UIControlEventTouchUpInside];
        [headerView addSubview:mapBtn];
    }
    
    
    return headerView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TripPoi *tripPoi = _tripDetail.itineraryList[indexPath.section][indexPath.row];
    TripPoiListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:tripPoiListReusableIdentifier forIndexPath:indexPath];
    cell.isShouldEditing = self.tableView.isEditing;
    cell.tripPoi = tripPoi;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    TripPoi *tripPoi = _tripDetail.itineraryList[indexPath.section][indexPath.row];
    switch (tripPoi.poiType) {
        case kSpotPoi: {
            SpotDetailViewController *spotDetailCtl = [[SpotDetailViewController alloc] init];
            spotDetailCtl.spotId = tripPoi.poiId;
            [self.rootViewController.navigationController pushViewController:spotDetailCtl animated:YES];
        }
            break;
        case kRestaurantPoi: {
            RestaurantDetailViewController *restaurantDetailCtl = [[RestaurantDetailViewController alloc] init];
            restaurantDetailCtl.restaurantId = tripPoi.poiId;
            [self.rootViewController.navigationController pushViewController:restaurantDetailCtl animated:YES];
        }
            
            break;
        case kShoppingPoi: {
            ShoppingDetailViewController *shoppingDetailCtl = [[ShoppingDetailViewController alloc] init];
            shoppingDetailCtl.shoppingId = tripPoi.poiId;
            [self.rootViewController.navigationController pushViewController:shoppingDetailCtl animated:YES];
        }
            
            break;
        case kHotelPoi: {
            HotelDetailViewController *hotelDetailCtl = [[HotelDetailViewController alloc] init];
            hotelDetailCtl.hotelId = tripPoi.poiId;
            [self.rootViewController.navigationController pushViewController:hotelDetailCtl animated:YES];
        }
            
            break;
            
        default:
            break;
    }
    
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.tableView.isEditing) {
        return YES;
    }
    return NO;
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

- (void)dealloc {
    _tableView.delegate = nil;
    _tableView.dataSource = nil;
    _tableView = nil;
    _rootViewController = nil;
    
}




@end

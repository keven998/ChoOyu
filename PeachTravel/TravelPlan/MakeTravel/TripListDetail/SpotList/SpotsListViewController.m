//
//  SpotsListViewController.m
//  PeachTravel
//
//  Created by liangpengshuai on 11/24/14.
//  Copyright (c) 2014 com.aizou.www. All rights reserved.
//

#import "SpotsListViewController.h"
#import "TripPoiListTableViewCell.h"
#import "DestinationsView.h"
#import "AddPoiViewController.h"
#import "CityDestinationPoi.h"
#import "DestinationUnit.h"
#import "CityDetailTableViewController.h"
#import "RecommendDataSource.h"
#import "SpotDetailViewController.h"
#import "CommonPoiDetailViewController.h"
#import "CommonPoiDetailViewController.h"
#import "CommonPoiListTableViewCell.h"
#import "CommonPoiDetailViewController.h"
#import "MyTripSpotsMapViewController.h"
#import "PositionBean.h"
#import "PoiDetailViewControllerFactory.h"

@interface SpotsListViewController () <UITableViewDataSource, UITableViewDelegate, addPoiDelegate>

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
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

#pragma mark - setter & getter

- (void)setTripDetail:(TripDetail *)tripDetail
{
    _tripDetail = tripDetail;
    if (_canEdit && _tripDetail) {
        _tableView.tableFooterView = self.tableViewFooterView;
    } else {
        _tableView.tableFooterView = nil;
    }
    [_tableView reloadData];
}

- (UITableView *)tableView
{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(11, 0, self.view.bounds.size.width-22, self.view.bounds.size.height-62) style:UITableViewStyleGrouped];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.showsVerticalScrollIndicator = NO;
        _tableView.showsHorizontalScrollIndicator = NO;
        _tableView.contentInset = UIEdgeInsetsMake(8, 0, 60, 0);
        _tableView.backgroundColor = APP_PAGE_COLOR;
        
        if (_canEdit && _tripDetail) {
            _tableView.tableFooterView = self.tableViewFooterView;
        }
        //        _tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 20)];
    }
    return _tableView;
}

- (UIView *)tableViewFooterView
{
    if (!_tableViewFooterView) {
        _tableViewFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 85)];
        UIButton *addOneDayBtn = [[UIButton alloc] initWithFrame:CGRectMake((_tableViewFooterView.bounds.size.width-185)/2, 5, 185.0, 33)];
        [addOneDayBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [addOneDayBtn setTitle:@"增加一天" forState:UIControlStateNormal];
        addOneDayBtn.clipsToBounds = YES;
        [addOneDayBtn setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 60)];
        [addOneDayBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, 10, 0, 0)];
        [addOneDayBtn setImage:[UIImage imageNamed:@"add_to_list.png"] forState:UIControlStateNormal];
        [addOneDayBtn setBackgroundImage:[ConvertMethods createImageWithColor:APP_SUB_THEME_COLOR] forState:UIControlStateNormal];
        [addOneDayBtn addTarget:self action:@selector(addOneDay:) forControlEvents:UIControlEventTouchUpInside];
        addOneDayBtn.layer.cornerRadius = 16.5;
        addOneDayBtn.titleLabel.font = [UIFont boldSystemFontOfSize:16.0];
        [_tableViewFooterView addSubview:addOneDayBtn];
    }
    return _tableViewFooterView;
}

- (void)setCanEdit:(BOOL)canEdit
{
    _canEdit = canEdit;
    if (_canEdit && _tripDetail) {
        _tableView.tableFooterView = self.tableViewFooterView;
    } else {
        _tableView.tableFooterView = nil;
    }
}

#pragma makr - IBAction Methods

- (IBAction)addOneDay:(id)sender
{
    [MobClick event:@"event_add_day"];
    if (!_shouldEdit) {
        [_rootViewController.editBtn sendActionsForControlEvents:UIControlEventTouchUpInside];
    }
    [_tripDetail.itineraryList addObject:[[NSMutableArray alloc] init]];
    NSIndexSet *indexSet = [[NSIndexSet alloc] initWithIndex:_tripDetail.itineraryList.count-1];
    [self.tableView insertSections:indexSet withRowAnimation:UITableViewRowAnimationAutomatic];
    _tripDetail.dayCount++;
}

- (IBAction)addPoi:(UIButton *)sender
{
    [MobClick event:@"event_add_plan_in_agenda"];
    AddPoiViewController *addPoiCtl = [[AddPoiViewController alloc] init];
    addPoiCtl.tripDetail = self.tripDetail;
    addPoiCtl.delegate = self;
    addPoiCtl.shouldEdit = YES;
    addPoiCtl.currentDayIndex = sender.tag;
    UINavigationController *nctl = [[UINavigationController alloc] initWithRootViewController:addPoiCtl];
    [self presentViewController:nctl animated:YES completion:nil];
}

- (IBAction)deleteOneDay:(UIButton *)sender
{
    [MobClick event:@"event_delete_day_agenda"];
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"将会删除一整天" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
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
    [MobClick event:@"event_day_map_view"];
    MyTripSpotsMapViewController *ctl = [[MyTripSpotsMapViewController alloc] init];
    
//    NSMutableArray *allPositions = [[NSMutableArray alloc] init];
//    for (SuperPoi *poi in _tripDetail.itineraryList[sender.tag]) {
//        PositionBean *position = [[PositionBean alloc] init];
//        position.latitude = poi.lat;
//        position.longitude = poi.lng;
//        position.poiName = poi.zhName;
//        position.poiId = poi.poiId;
//        [allPositions addObject:position];
//    }
    ctl.pois = _tripDetail.itineraryList;
    ctl.currentDay = sender.tag;
    UINavigationController *nCtl = [[UINavigationController alloc] initWithRootViewController:ctl];
    [self presentViewController:nCtl animated:YES completion:nil];
}

- (void)updateTableView
{
    [self.tableView reloadData];
}

- (void)setShouldEdit:(BOOL)shouldEdit
{
    _shouldEdit = shouldEdit;
    [self editTrip:nil];
}

- (IBAction)editTrip:(id)sender
{
    if (_shouldEdit) {
        [self.tableView setEditing:YES animated:YES];
        [self performSelector:@selector(updateTableView) withObject:nil afterDelay:0.2];
        
    } else {
        [self.tableView setEditing:NO animated:YES];
        [self performSelector:@selector(updateTableView) withObject:nil afterDelay:0.2];
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
    return 65;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 30;
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
    CGFloat width = tableView.frame.size.width;
    
    UIView *retView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, 30)];
    retView.backgroundColor = APP_PAGE_COLOR;
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, 20)];
    view.layer.cornerRadius = 3.0;
    view.backgroundColor = [UIColor whiteColor];
    UIView *spaceView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, 3)];
    spaceView.backgroundColor = [UIColor whiteColor];
    [view addSubview:spaceView];
    [retView addSubview:view];
    return retView;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    CGFloat width = tableView.frame.size.width;
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, 65)];
    headerView.layer.cornerRadius = 2.0;
    headerView.backgroundColor = [UIColor whiteColor];
    
    UIView *retView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, 10)];
    retView.backgroundColor = APP_PAGE_COLOR;
    [headerView addSubview:retView];
    
    UILabel *headerTitle = [[UILabel alloc] initWithFrame:CGRectMake(15, 20, width-80, 30)];
    NSMutableString *headerTitleStr = [NSMutableString stringWithFormat:@"第%ld天  ",(long)section+1];
    NSMutableOrderedSet *set = [[NSMutableOrderedSet alloc] init];
    for (SuperPoi *tripPoi in [_tripDetail.itineraryList objectAtIndex:section]) {
        if (tripPoi.locality.zhName) {
            [set addObject:tripPoi.locality.zhName];
        }
    }
    
    DestinationsView *destinationView = [[DestinationsView alloc] initWithFrame:CGRectMake(60, 23, width-150, 20)];
    destinationView.backgroundColor = [UIColor whiteColor];
    [headerView addSubview:destinationView];
    
    if (set.count) {
        NSMutableArray *distinationArray = [[NSMutableArray alloc] init];
        for (NSString *s in set) {
            [distinationArray addObject:s];
        }
        destinationView.titleColor = TEXT_COLOR_TITLE_HINT;
        destinationView.destinations = distinationArray;
        //        destinationView.tag = section;
        //        destinationView.delegate = self;
    }
    if ([[_tripDetail.itineraryList objectAtIndex:section] count] <= 0) {
        NSMutableArray *distinationArray = [[NSMutableArray alloc] initWithObjects:@"没有安排", nil];
        destinationView.titleColor = APP_SUB_THEME_COLOR;
        destinationView.destinations = distinationArray;
    }
    
    headerTitle.text = headerTitleStr;
    headerTitle.textColor = TEXT_COLOR_TITLE_HINT;
    headerTitle.font = [UIFont systemFontOfSize:15.0];
    [headerView addSubview:headerTitle];
    
    if (self.tableView.isEditing) {
        UIButton *addbtn = [[UIButton alloc] initWithFrame:CGRectMake(width-72, 0, 72, 65)];
        addbtn.tag = section;
        [addbtn addTarget:self action:@selector(addPoi:) forControlEvents:UIControlEventTouchUpInside];
        
        UIButton *addSpotBtn = [[UIButton alloc] initWithFrame:CGRectMake(2, 25, 60, 22)];
        [addSpotBtn setTitle:@"添加安排" forState:UIControlStateNormal];
        [addSpotBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [addSpotBtn setBackgroundImage:[ConvertMethods createImageWithColor:APP_SUB_THEME_COLOR] forState:UIControlStateNormal];
        addSpotBtn.clipsToBounds = YES;
        addSpotBtn.titleEdgeInsets = UIEdgeInsetsMake(3, 0, 0, 0);
        addSpotBtn.titleLabel.font = [UIFont systemFontOfSize:13.0];
        addSpotBtn.layer.cornerRadius = 4;
        addSpotBtn.tag = section;
        [addSpotBtn addTarget:self action:@selector(addPoi:) forControlEvents:UIControlEventTouchUpInside];
        [addbtn addSubview:addSpotBtn];
        [headerView addSubview:addbtn];
        
        //        UIButton *deleteBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 64, headerView.frame.size.height)];
        //        deleteBtn.tag = section;
        //        [deleteBtn addTarget:self action:@selector(deleteOneDay:) forControlEvents:UIControlEventTouchUpInside];
        //        UIButton *deleteSpotBtn = [[UIButton alloc] initWithFrame:CGRectMake(-8, 2, 36, 21)];
        //        [deleteSpotBtn setImage:[UIImage imageNamed:@"ic_delete.png"] forState:UIControlStateNormal];
        //        deleteSpotBtn.clipsToBounds = YES;
        //        deleteSpotBtn.userInteractionEnabled = NO;
        //        [deleteBtn addSubview:deleteSpotBtn];
        //        [headerView addSubview:deleteBtn];
    } else {
        UIButton *mapBtn = [[UIButton alloc] initWithFrame:CGRectMake(width-64, 0, 64, 65)];
        [mapBtn setImage:[UIImage imageNamed:@"ic_map.png"] forState:UIControlStateNormal];
        [mapBtn setImageEdgeInsets:UIEdgeInsetsMake(5, 15, 0, 0)];
        mapBtn.tag = section;
        [mapBtn addTarget:self action:@selector(mapView:) forControlEvents:UIControlEventTouchUpInside];
        [headerView addSubview:mapBtn];
    }
    
    
    return headerView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SuperPoi *tripPoi = _tripDetail.itineraryList[indexPath.section][indexPath.row];
    TripPoiListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:tripPoiListReusableIdentifier forIndexPath:indexPath];
    cell.tripPoi = tripPoi;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    SuperPoi *tripPoi = _tripDetail.itineraryList[indexPath.section][indexPath.row];
    switch (tripPoi.poiType) {
        case kSpotPoi: {
            SpotDetailViewController *spotDetailCtl = [[SpotDetailViewController alloc] init];
            spotDetailCtl.spotId = tripPoi.poiId;
            [self.rootViewController addChildViewController:spotDetailCtl];
            [self.rootViewController.view addSubview:spotDetailCtl.view];
            
        }
            break;
            
        case kRestaurantPoi: case kShoppingPoi: case kHotelPoi:{
            CommonPoiDetailViewController *ctl = [PoiDetailViewControllerFactory poiDetailViewControllerWithPoiType:tripPoi.poiType];
            ctl.poiId = tripPoi.poiId;
            [self.rootViewController addChildViewController:ctl];
            [self.rootViewController.view addSubview:ctl.view];
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
        [MobClick event:@"event_delete_select_item"];
        NSMutableArray *tempArray = [_tripDetail.itineraryList objectAtIndex:indexPath.section];
        [tempArray removeObjectAtIndex:indexPath.row];
        NSArray *indexPaths = [NSArray arrayWithObject:indexPath];
        [tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationLeft];
    }
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
    [MobClick event:@"event_reorder_items"];
    NSMutableArray *fromArray = _tripDetail.itineraryList[sourceIndexPath.section];
    NSMutableArray *toArray = _tripDetail.itineraryList[destinationIndexPath.section];
    
    SuperPoi *poi = [fromArray objectAtIndex:sourceIndexPath.row];
    [fromArray removeObjectAtIndex:sourceIndexPath.row];
    [toArray insertObject:poi atIndex:destinationIndexPath.row];
    
}

- (UITableViewCellEditingStyle) tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleDelete;
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    return @"删除";
}

- (void)dealloc {
    _tableView.delegate = nil;
    _tableView.dataSource = nil;
    _tableView = nil;
    _rootViewController = nil;
    
}




@end

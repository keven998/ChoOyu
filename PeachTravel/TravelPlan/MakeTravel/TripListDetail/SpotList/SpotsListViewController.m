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
#import "MyTripSpotsMapViewController.h"
#import "PositionBean.h"
#import "PoiDetailViewControllerFactory.h"
#import "PXAlertView+Customization.h"
#import "REFrostedViewController.h"

@interface SpotsListViewController () <UITableViewDataSource, UITableViewDelegate, addPoiDelegate>

@property (strong, nonatomic) UITableView *tableView;

@end

@implementation SpotsListViewController

static NSString *tripPoiListReusableIdentifier = @"tripPoiListCell";


- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView registerNib:[UINib nibWithNibName:@"TripPoiListTableViewCell" bundle:nil] forCellReuseIdentifier:tripPoiListReusableIdentifier];
    
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
    [_tableView reloadData];
}

- (UITableView *)tableView
{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:self.view.bounds];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.showsHorizontalScrollIndicator = NO;
        _tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _tableView.contentInset = UIEdgeInsetsMake(-26, 0, 50, 0); // 20 + 26
        _tableView.backgroundColor = APP_PAGE_COLOR;
    }
    return _tableView;
}

- (void)setCanEdit:(BOOL)canEdit
{
    _canEdit = canEdit;
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

- (void)addPoiToDay:(NSInteger)day
{
    [MobClick event:@"event_add_plan_in_agenda"];
    AddPoiViewController *addPoiCtl = [[AddPoiViewController alloc] init];
    addPoiCtl.tripDetail = self.tripDetail;
    addPoiCtl.delegate = self;
    addPoiCtl.shouldEdit = YES;
    addPoiCtl.currentDayIndex = day;
    UINavigationController *nctl = [[UINavigationController alloc] initWithRootViewController:addPoiCtl];
    [self presentViewController:nctl animated:YES completion:nil];
}

- (void)deleteOneDay:(NSInteger)day
{
    [MobClick event:@"event_delete_day_agenda"];
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:[NSString stringWithFormat:@"确定要删除第%ld天", (long)(day + 1)] delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    [alertView showAlertViewWithBlock:^(NSInteger buttonIndex) {
        if (buttonIndex == 1) {
            [_tripDetail.itineraryList removeObjectAtIndex:day];
            _tripDetail.dayCount--;
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:day] withRowAnimation:UITableViewRowAnimationAutomatic];
            if (_tripDetail.dayCount == 0) {
                [self insertDay:YES currentDay:0];
            } else {
                [self performSelector:@selector(updateRoute) withObject:nil afterDelay:0.3];
            }
        }
    }];
}

- (void)insertDay:(BOOL)before currentDay:(NSInteger)currentDay {
    NSMutableArray *newDay = [[NSMutableArray alloc] init];
    NSInteger insertIndex;
    if (before) {
        insertIndex = currentDay;
    } else {
        insertIndex = currentDay + 1;
    }
    [_tripDetail.itineraryList insertObject:newDay atIndex:insertIndex];
    
    NSIndexSet *indexSet = [[NSIndexSet alloc] initWithIndex:insertIndex];
    [self.tableView insertSections:indexSet withRowAnimation:UITableViewRowAnimationAutomatic];
    _tripDetail.dayCount++;
    [self performSelector:@selector(updateRoute) withObject:nil afterDelay:0.3];
}

- (void) updateRoute {
    [self.tableView reloadData];
}

- (void)mapView
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
    ctl.currentDay = 0;
    [ctl setModalTransitionStyle:UIModalTransitionStyleFlipHorizontal];
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
    } else {
        [self.tableView setEditing:NO animated:YES];
    }
}

- (IBAction)editDay:(id)sender {
    UIButton *btn = sender;
    NSInteger dayIndex = btn.tag;
    PXAlertView *alertView = [PXAlertView showAlertWithTitle:[NSString stringWithFormat:@"第%ld天", dayIndex + 1]
                                                     message:@"请选择你要进行的操作"
                                                 cancelTitle:@"删除这一天"
                                                 otherTitles:@[ @"添加行程", @"加一天在前面", @"加一天在后面"]
                                                  completion:^(BOOL cancelled, NSInteger buttonIndex) {
                                                      if (buttonIndex == 1) {
                                                          [self addPoiToDay:dayIndex];
                                                      } else if (buttonIndex == 2) {
                                                          [self insertDay:YES currentDay:dayIndex];
                                                      } else if (buttonIndex == 3) {
                                                          [self insertDay:NO currentDay:dayIndex];
                                                      } else if (buttonIndex == 0) {
                                                          [self deleteOneDay:dayIndex];
                                                      }
                                                  }];
    [alertView useDefaultIOS7Style];
    [alertView setMessageColor:TEXT_COLOR_TITLE_HINT];
    [alertView setTitleFont:[UIFont systemFontOfSize:16]];
    [alertView setCancelButtonTextColor:[UIColor redColor]];
}

#pragma mark - AddPoiDelegate

- (void)finishEdit
{
    [self.tableView reloadData];
}

#pragma mark - UITableViewDataSource & Delegate

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 50;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 90;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return _tripDetail.itineraryList.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[_tripDetail.itineraryList objectAtIndex:section] count];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    CGFloat width = tableView.frame.size.width;
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, 50)];
    headerView.backgroundColor = [UIColor whiteColor];
    
    UIView *spaceView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, 6)];
    spaceView.backgroundColor = APP_PAGE_COLOR;
    [headerView addSubview:spaceView];
    
    UIView *dividerView = [[UIView alloc] initWithFrame:CGRectMake(36, 50, width - 46, 1)];
    dividerView.backgroundColor = APP_PAGE_COLOR;
    dividerView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [headerView addSubview:dividerView];
    
    UILabel *headerTitle = [[UILabel alloc] initWithFrame:CGRectMake(37, 6, width-80, 44)];
    headerTitle.textColor = TEXT_COLOR_TITLE;
    headerTitle.font = [UIFont systemFontOfSize:15.0];
    headerTitle.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    headerTitle.lineBreakMode = NSLineBreakByTruncatingTail;
    NSString *titleStr = [NSString stringWithFormat:@"第%ld天 ",(long)section+1];
    NSMutableOrderedSet *set = [[NSMutableOrderedSet alloc] init];
    for (SuperPoi *tripPoi in [_tripDetail.itineraryList objectAtIndex:section]) {
        if (tripPoi.locality.zhName) {
            [set addObject:tripPoi.locality.zhName];
        }
    }
    
    NSMutableString *dest = [[NSMutableString alloc] init];
    if (set.count) {
        for (NSString *s in set) {
            if (dest.length > 0) {
                [dest appendFormat:@"-%@", s];
            } else {
                [dest appendString:s];
            }
        }
    } else {
        [dest appendString:@"没有安排"];
    }
    
    NSMutableAttributedString *attributeString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@%@", titleStr, dest]];
    [attributeString addAttributes:@{NSForegroundColorAttributeName:TEXT_COLOR_TITLE_SUBTITLE} range:NSMakeRange(titleStr.length, dest.length)];
    [attributeString addAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:11]} range:NSMakeRange(titleStr.length, dest.length)];
    headerTitle.attributedText = attributeString;
    [headerView addSubview:headerTitle];
    
    UIButton *mapBtn = [[UIButton alloc] initWithFrame:CGRectMake(width-64, 6, 64, 44)];
    [mapBtn setImage:[UIImage imageNamed:@"ic_more.png"] forState:UIControlStateNormal];
//    [mapBtn setImageEdgeInsets:UIEdgeInsetsMake(5, 15, 0, 0)];
    mapBtn.tag = section;
    [mapBtn addTarget:self action:@selector(editDay:) forControlEvents:UIControlEventTouchUpInside];
    [headerView addSubview:mapBtn];
    
    CGFloat tloffsety = 0;
    if (section == 0) {
        tloffsety = 25;
    }
    UIView *timelineView = [[UIView alloc] initWithFrame:CGRectMake(20, tloffsety, 7, 50 - tloffsety)];
    timelineView.backgroundColor = APP_DIVIDER_COLOR;
    [headerView addSubview:timelineView];
    
    UIImageView *tv = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"route_timeline_pot.png"]];
    tv.center = CGPointMake(23.5, 28); // 20+7/2, 44/2+6
    [headerView addSubview:tv];
    
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
//    if (self.tableView.isEditing) {
//        return YES;
//    }
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

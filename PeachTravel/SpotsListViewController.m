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

@interface SpotsListViewController () <UITableViewDataSource, UITableViewDelegate, RNGridMenuDelegate, addPoiDelegate>

@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) UIView *tableViewFooterView;
@property (strong, nonatomic) DKCircleButton *editBtn;

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
    
    _editBtn = [[DKCircleButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width-60, self.view.frame.size.height-110-62, 40, 40)];
    _editBtn.backgroundColor = TEXT_COLOR_TITLE_SUBTITLE;
    [_editBtn setImage:[UIImage imageNamed:@"ic_layer_edit"] animated:YES];
    [_editBtn addTarget:self action:@selector(editTrip:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_editBtn];
    if (!_tripDetail || !_canEdit) {
        _editBtn.hidden = YES;
    }
    
    NSLog(@"spots didload");
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    NSLog(@"spots willAppear");
    for (UIView *subview in self.view.subviews) {
        if ([subview isEqual:_destinationsHeaderView]) {
            return;
        }
    }
    [self.view addSubview:_destinationsHeaderView];
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
    if (!_tripDetail || !_canEdit) {
        _editBtn.hidden = YES;
    } else {
        _editBtn.hidden = NO;
        NSInteger count = _tripDetail.itineraryList.count;
        if (!tripDetail || count == 0) {
            if (!_tableView.isEditing) {
                [_editBtn sendActionsForControlEvents:UIControlEventTouchUpInside];
            }
        } else {
            BOOL ed = true;
            for (int i = 0; i < count; ++i) {
                if ([[_tripDetail.itineraryList objectAtIndex:i] count] > 0) {
                    ed = false;
                    break;
                }
            }
            if (ed) {
                if (!_tableView.isEditing) {
                    [_editBtn sendActionsForControlEvents:UIControlEventTouchUpInside];
                }
            }
        }
    }
    for (UIView *subview in self.view.subviews) {
        if ([subview isEqual:_destinationsHeaderView]) {
            return;
        }
    }
    [self.view addSubview:_destinationsHeaderView];
}

- (UITableView *)tableView
{
    NSLog(@"%@", NSStringFromCGRect(self.view.frame));

    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(11, 0, self.view.bounds.size.width-22, self.view.bounds.size.height-62-44)];
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

- (void)setCanEdit:(BOOL)canEdit
{
    _canEdit = canEdit;
    if (!_canEdit) {
        _editBtn.hidden = YES;
    } else {
        _editBtn.hidden = NO;
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
        }
    }];
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
    if (!self.tableView.isEditing) {
        [self.tableView setEditing:YES animated:YES];
        _editBtn.backgroundColor = APP_THEME_COLOR;
        [_editBtn setImage:[UIImage imageNamed:@"ic_layer_edit_done"] animated:YES];
        [self performSelector:@selector(updateTableView) withObject:nil afterDelay:0.2];
        
    } else {
         __weak typeof(SpotsListViewController *)weakSelf = self;
        TZProgressHUD *hud = [[TZProgressHUD alloc] init];
        [hud showHUDInViewController:weakSelf.navigationController];

        [self.tripDetail saveTrip:^(BOOL isSuccesss) {
            [hud hideTZHUD];
            if (isSuccesss) {
                _editBtn.backgroundColor = UIColorFromRGB(0x797979);
                [_editBtn setImage:[UIImage imageNamed:@"ic_layer_edit"] animated:YES];
                [self.tableView setEditing:NO animated:YES];
                [self performSelector:@selector(updateTableView) withObject:nil afterDelay:0.2];
//                [SVProgressHUD showSuccessWithStatus:@"已保存"];
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

#pragma mark - UITableViewDataSource & Delegate

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 35;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if ([[_tripDetail.itineraryList objectAtIndex:section] count] || tableView.isEditing) {
        return 20;
    } else {
        return 100;
    }
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
    if ([[_tripDetail.itineraryList objectAtIndex:section] count] || tableView.isEditing) {
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 20)];
        UIView *spaceView = [[UIView alloc] initWithFrame:CGRectMake(5, 0, 1, 20)];
        view.backgroundColor = APP_PAGE_COLOR;
        if (!self.tableView.isEditing) {
            spaceView.backgroundColor = APP_THEME_COLOR;
            [view addSubview:spaceView];
        }
        return view;
    } else {
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self
                                                                .tableView.frame.size.width, 100)];
        UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(20, 0, self.tableView.frame.size.width-20, 80)];
        btn.backgroundColor = [UIColor whiteColor];
        [btn setImage:[UIImage imageNamed:nil] forState:UIControlStateNormal];
        [btn setTitle:@"还木有任何安排\n 快来添加安排把~" forState:UIControlStateNormal];
        [btn setTitleColor:TEXT_COLOR_TITLE_SUBTITLE forState:UIControlStateNormal];
        btn.titleLabel.font = [UIFont systemFontOfSize:12.0];
        btn.titleLabel.numberOfLines = 2;
        [btn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentCenter];
        [btn setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
        btn.layer.cornerRadius = 2.0;
        [view addSubview:btn];
        
        UIView *spaceView = [[UIView alloc] initWithFrame:CGRectMake(5, 0, 1, 100)];
        spaceView.backgroundColor = APP_THEME_COLOR;
        [view addSubview:spaceView];
        
        return view;
    }
    
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 35)];
    headerView.layer.cornerRadius = 2.0;
    headerView.backgroundColor = APP_PAGE_COLOR;
    headerView.clipsToBounds = YES;
    UILabel *headerTitle;
    if (self.tableView.isEditing) {
        headerTitle = [[UILabel alloc] initWithFrame:CGRectMake(43, 0, headerView.frame.size.width-103, 35)];
    } else {
        headerTitle = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, headerView.frame.size.width-80, 35)];
    }
    NSMutableString *headerTitleStr = [NSMutableString stringWithFormat:@"   第%ld天  ",(long)section+1];
    NSMutableOrderedSet *set = [[NSMutableOrderedSet alloc] init];
    for (TripPoi *tripPoi in [_tripDetail.itineraryList objectAtIndex:section]) {
        if (tripPoi.locality.zhName) {
            [set addObject:tripPoi.locality.zhName];
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
    headerTitle.font = [UIFont boldSystemFontOfSize:15.0];
    headerTitle.backgroundColor = [UIColor whiteColor];
    [headerView addSubview:headerTitle];
    
    if (self.tableView.isEditing) {
        UIButton *addbtn = [[UIButton alloc] initWithFrame:CGRectMake(headerView.frame.size.width-62, 0, 62, headerView.frame.size.height)];
        addbtn.backgroundColor = [UIColor whiteColor];
        addbtn.tag = section;
        [addbtn addTarget:self action:@selector(addPoi:) forControlEvents:UIControlEventTouchUpInside];
        
        UIButton *addSpotBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 8, 60, 21)];
        [addSpotBtn setBackgroundColor:[UIColor whiteColor]];
        [addSpotBtn setTitle:@"添加安排" forState:UIControlStateNormal];
        [addSpotBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [addSpotBtn setBackgroundImage:[ConvertMethods createImageWithColor:APP_THEME_COLOR] forState:UIControlStateNormal];
        addSpotBtn.clipsToBounds = YES;
        addSpotBtn.titleLabel.font = [UIFont systemFontOfSize:12.0];
        addSpotBtn.layer.cornerRadius = 10.5;
        [addSpotBtn addTarget:self action:@selector(addPoi:) forControlEvents:UIControlEventTouchUpInside];
        [addbtn addSubview:addSpotBtn];
        [headerView addSubview:addbtn];
        
        UIButton *deleteBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 50, headerView.frame.size.height)];
        deleteBtn.backgroundColor = [UIColor whiteColor];
        deleteBtn.tag = section;
        [deleteBtn addTarget:self action:@selector(deleteOneDay:) forControlEvents:UIControlEventTouchUpInside];
        
        UIButton *deleteSpotBtn = [[UIButton alloc] initWithFrame:CGRectMake(10, 7, 36, 21)];
        [deleteSpotBtn setBackgroundColor:[UIColor whiteColor]];
        [deleteSpotBtn setTitle:@"删除" forState:UIControlStateNormal];
        [deleteSpotBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//        deleteSpotBtn.backgroundColor = APP_THEME_COLOR;
        [deleteSpotBtn setBackgroundImage:[ConvertMethods createImageWithColor:APP_THEME_COLOR] forState:UIControlStateNormal];
        deleteSpotBtn.clipsToBounds = YES;
        deleteSpotBtn.titleLabel.font = [UIFont systemFontOfSize:12.0];
        deleteSpotBtn.layer.cornerRadius = 10.5;
        [deleteSpotBtn addTarget:self action:@selector(deleteOneDay:) forControlEvents:UIControlEventTouchUpInside];
        [deleteBtn addSubview:deleteSpotBtn];
        [headerView addSubview:deleteBtn];
        
    } else {
        UIButton *mapBtn = [[UIButton alloc] initWithFrame:CGRectMake(headerView.frame.size.width-60, 0, 60, 35)];
        [mapBtn setBackgroundColor:[UIColor whiteColor]];
        [mapBtn setTitle:@"地图" forState:UIControlStateNormal];
        [mapBtn setTitleColor:APP_THEME_COLOR forState:UIControlStateNormal];
        mapBtn.tag = section;
        mapBtn.titleLabel.font = [UIFont systemFontOfSize:12.0];
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
        
        UIView *verticalSpaceView = [[UIView alloc] initWithFrame:CGRectMake(5, 19, 1, 16)];
        verticalSpaceView.backgroundColor = APP_THEME_COLOR;
        [headerView addSubview:verticalSpaceView];
        
        if (section != 0) {
            UIView *verticalSpaceViewUp = [[UIView alloc] initWithFrame:CGRectMake(5, 0, 1, 11)];
            verticalSpaceViewUp.backgroundColor = APP_THEME_COLOR;
            [headerView addSubview:verticalSpaceViewUp];
        }
    }
    
    return headerView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TripPoi *tripPoi = _tripDetail.itineraryList[indexPath.section][indexPath.row];
    TripPoiListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:tripPoiListReusableIdentifier forIndexPath:indexPath];
    cell.isEditing = self.tableView.isEditing;
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
        case kHotelPoi:
            
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

- (void)dealloc {
    _tableView.delegate = nil;
    _tableView.dataSource = nil;
    _tableView = nil;
    _rootViewController = nil;
    
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView.contentOffset.y > 20.0) {
        [_rootViewController showDHView:NO];
    } else {
        [_rootViewController showDHView:YES];
    }
}



@end

//
//  ShoppingListViewController.m
//  PeachTravel
//
//  Created by liangpengshuai on 11/24/14.
//  Copyright (c) 2014 com.aizou.www. All rights reserved.
//

#import "ShoppingListViewController.h"
#import "DKCircleButton.h"
#import "CommonPoiListTableViewCell.h"
#import "DestinationsView.h"
#import "CityDestinationPoi.h"
#import "DestinationUnit.h"
#import "CityDetailTableViewController.h"
#import "CommonPoiDetailViewController.h"
#import "PoisOfCityViewController.h"

@interface ShoppingListViewController () <UITableViewDataSource, UITableViewDelegate, PoisOfCityDelegate, UIActionSheetDelegate>

@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) UIView *tableViewFooterView;

@end

@implementation ShoppingListViewController

static NSString *shoppingListReusableIdentifier = @"commonPoiListCell";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.view.backgroundColor = APP_PAGE_COLOR;
    [self.view addSubview:self.tableView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    NSLog(@"Rest willdisappear");
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
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(11, 0, self.view.bounds.size.width-22, self.view.bounds.size.height-54)];
        _tableView.showsVerticalScrollIndicator = NO;
        _tableView.showsHorizontalScrollIndicator = NO;
        [_tableView registerNib:[UINib nibWithNibName:@"CommonPoiListTableViewCell" bundle:nil] forCellReuseIdentifier:shoppingListReusableIdentifier];
        _tableView.backgroundColor = APP_PAGE_COLOR;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.delegate = self;
        _tableView.dataSource = self;
        if (_canEdit) {
            _tableView.tableFooterView = self.tableViewFooterView;
        }
        _tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 10)];
        
    }
    return _tableView;
}

- (UIView *)tableViewFooterView
{
    _tableViewFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 100)];
    UIButton *addWantToBtn = [[UIButton alloc] initWithFrame:CGRectMake((_tableViewFooterView.bounds.size.width-185)/2, 5, 185.0, 33)];
    
    [addWantToBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [addWantToBtn setTitle:@"购物收集" forState:UIControlStateNormal];
    [addWantToBtn setImage:[UIImage imageNamed:@"add_to_list.png"] forState:UIControlStateNormal];
    [addWantToBtn setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 60)];
    [addWantToBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, 10, 0, 0)];
    
    addWantToBtn.clipsToBounds = YES;
    [addWantToBtn setBackgroundImage:[ConvertMethods createImageWithColor:APP_SUB_THEME_COLOR] forState:UIControlStateNormal];
    [addWantToBtn addTarget:self action:@selector(addWantTo:) forControlEvents:UIControlEventTouchUpInside];
    addWantToBtn.layer.cornerRadius = 16.5;
    addWantToBtn.titleLabel.font = [UIFont boldSystemFontOfSize:15.0];
    [_tableViewFooterView addSubview:addWantToBtn];
    
    return _tableViewFooterView;
}

- (void)setShouldEdit:(BOOL)shouldEdit
{
    _shouldEdit = shouldEdit;
    [self editTrip:nil];
}

- (void)setCanEdit:(BOOL)canEdit
{
    _canEdit = canEdit;
    if (_canEdit) {
        _tableView.tableFooterView = self.tableViewFooterView;
    } else {
        _tableView.tableFooterView = nil;
    }
}


#pragma makr - IBAction Methods

- (IBAction)addWantTo:(id)sender
{
    PoisOfCityViewController *shoppingOfCityCtl = [[PoisOfCityViewController alloc] init];
    shoppingOfCityCtl.tripDetail = _tripDetail;
    shoppingOfCityCtl.delegate = self;
    shoppingOfCityCtl.poiType = kShoppingPoi;
    
    shoppingOfCityCtl.shouldEdit = YES;
    UINavigationController *nctl = [[UINavigationController alloc] initWithRootViewController:shoppingOfCityCtl];
    [self presentViewController:nctl animated:YES completion:^{
    }];
}

- (void)updateTableView
{
    [self.tableView reloadData];
}

- (IBAction)editTrip:(id)sender
{
    if (_shouldEdit) {
        [self.tableView setEditing:YES animated:YES];
        [self performSelector:@selector(updateTableView) withObject:nil afterDelay:0.2];
        
    } else {
        if (!self.tripDetail.tripIsChange) {
            [self.tableView setEditing:NO animated:YES];
            [self performSelector:@selector(updateTableView) withObject:nil afterDelay:0.2];
            
            return;
        }
        TZProgressHUD *hud = [[TZProgressHUD alloc] init];
        [hud showHUD];
        
        [self.tripDetail saveTrip:^(BOOL isSuccesss) {
            [hud hideTZHUD];
            if (isSuccesss) {
                [self.tableView setEditing:NO animated:YES];
                [self performSelector:@selector(updateTableView) withObject:nil afterDelay:0.2];
            } else {
                [SVProgressHUD showSuccessWithStatus:@"保存失败"];
            }
        }];
    }
}

- (void)jumpMapView:(UIButton *)sender
{
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"其他软件导航"
                                                       delegate:self
                                              cancelButtonTitle:nil
                                         destructiveButtonTitle:nil
                                              otherButtonTitles:nil];
    NSArray *platformArray = [ConvertMethods mapPlatformInPhone];
    for (NSDictionary *dic in platformArray) {
        [sheet addButtonWithTitle:[dic objectForKey:@"platform"]];
    }
    [sheet addButtonWithTitle:@"取消"];
    sheet.tag = sender.tag;
    sheet.cancelButtonIndex = sheet.numberOfButtons-1;
    [sheet showInView:self.view];
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

- (IBAction)deletePoi:(UIButton *)sender
{
    CGPoint point = [sender convertPoint:CGPointMake(20, 20) toView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:point];
    [_tripDetail.shoppingList removeObjectAtIndex:indexPath.section];
    NSIndexSet *set = [NSIndexSet indexSetWithIndex:indexPath.section];
    [self.tableView deleteSections:set withRowAnimation:UITableViewRowAnimationAutomatic];
}

#pragma mark - ShoppingOfCityDelegate

- (void)finishEdit
{
    if (!_shouldEdit) {
        [_rootViewController.editBtn sendActionsForControlEvents:UIControlEventTouchUpInside];
    }
    [self.tableView reloadData];
}

#pragma mark - UITableViewDataSource & Delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.tripDetail.shoppingList.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 135.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 10;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 10)];
    return footerView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CommonPoiListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:shoppingListReusableIdentifier forIndexPath:indexPath];
    cell.mapBtn.tag = indexPath.section;
    [cell.mapBtn removeTarget:self action:@selector(jumpMapView:) forControlEvents:UIControlEventTouchUpInside];
    [cell.mapBtn addTarget:self action:@selector(jumpMapView:) forControlEvents:UIControlEventTouchUpInside];
    [cell.deleteBtn addTarget:self action:@selector(deletePoi:) forControlEvents:UIControlEventTouchUpInside];
    cell.tripPoi = [_tripDetail.shoppingList objectAtIndex:indexPath.section];
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (UITableViewCellEditingStyle) tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleNone;
}
- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
    NSLog(@"from:%@ to:%@",sourceIndexPath, destinationIndexPath);
    PoiSummary *poi = [_tripDetail.shoppingList objectAtIndex:sourceIndexPath.section];
    [_tripDetail.shoppingList removeObjectAtIndex:sourceIndexPath.section];
    
    [_tripDetail.shoppingList insertObject:poi atIndex:destinationIndexPath.section];
    [self.tableView reloadData];
}

//此举是为了在移动的时候保证顺序。过程有点复杂，慢慢看
- (NSIndexPath *)tableView:(UITableView *)tableView targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)sourceIndexPath toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath
{
    if (proposedDestinationIndexPath.row > 0 && sourceIndexPath.section > proposedDestinationIndexPath.section) {
        NSIndexPath *path = [NSIndexPath indexPathForItem:0 inSection:proposedDestinationIndexPath.section+1];
        return path;
    }
    
    if (sourceIndexPath.section < proposedDestinationIndexPath.section && proposedDestinationIndexPath.row == 0) {
        NSIndexPath *path;
        
        if (proposedDestinationIndexPath.section == sourceIndexPath.section+1) {
            path = [NSIndexPath indexPathForItem:0 inSection:proposedDestinationIndexPath.section-1];
            
        } else {
            path = [NSIndexPath indexPathForItem:1 inSection:proposedDestinationIndexPath.section-1];
            
        }
        return path;
    }
    return proposedDestinationIndexPath;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [_tripDetail.shoppingList removeObjectAtIndex:indexPath.section];
        [tableView deleteSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    PoiSummary *tripPoi = [_tripDetail.shoppingList objectAtIndex:indexPath.section];
    CommonPoiDetailViewController *shoppingDetailCtl = [[CommonPoiDetailViewController alloc] init];
    shoppingDetailCtl.poiId = tripPoi.poiId;
    shoppingDetailCtl.poiType = kShoppingPoi;
    [self.rootViewController addChildViewController:shoppingDetailCtl];
    [self.rootViewController.view addSubview:shoppingDetailCtl.view];
}

- (void)dealloc {
    _tableView.delegate = nil;
    _tableView.dataSource = nil;
    _tableView = nil;
    _rootViewController = nil;
    
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == actionSheet.cancelButtonIndex) {
        return;
    }
    PoiSummary *poi = [_tripDetail.shoppingList objectAtIndex:actionSheet.tag];
    NSArray *platformArray = [ConvertMethods mapPlatformInPhone];
    switch (buttonIndex) {
        case 0:
            switch ([[[platformArray objectAtIndex:0] objectForKey:@"type"] intValue]) {
                case kAMap:
                    [ConvertMethods jumpGaodeMapAppWithPoiName:poi.zhName lat:poi.lat lng:poi.lng];
                    break;
                    
                case kBaiduMap: {
                    [ConvertMethods jumpBaiduMapAppWithPoiName:poi.zhName lat:poi.lat lng:poi.lng];
                }
                    break;
                    
                case kAppleMap: {
                    [ConvertMethods jumpAppleMapAppWithPoiName:poi.zhName lat:poi.lat lng:poi.lng];
                }
                    
                default:
                    break;
            }
            break;
            
        case 1:
            switch ([[[platformArray objectAtIndex:1] objectForKey:@"type"] intValue]) {
                case kAMap:
                    [ConvertMethods jumpGaodeMapAppWithPoiName:poi.zhName lat:poi.lat lng:poi.lng];
                    break;
                    
                case kBaiduMap: {
                    [ConvertMethods jumpBaiduMapAppWithPoiName:poi.zhName lat:poi.lat lng:poi.lng];
                }
                    break;
                    
                case kAppleMap: {
                    [ConvertMethods jumpAppleMapAppWithPoiName:poi.zhName lat:poi.lat lng:poi.lng];
                }
                    break;
                    
                default:
                    break;
            }
            break;
            
        case 2:
            switch ([[[platformArray objectAtIndex:2] objectForKey:@"type"] intValue]) {
                case kAMap:
                    [ConvertMethods jumpGaodeMapAppWithPoiName:poi.zhName lat:poi.lat lng:poi.lng];
                    break;
                    
                case kBaiduMap: {
                    [ConvertMethods jumpBaiduMapAppWithPoiName:poi.zhName lat:poi.lat lng:poi.lng];
                }
                    break;
                    
                case kAppleMap: {
                    [ConvertMethods jumpAppleMapAppWithPoiName:poi.zhName lat:poi.lat lng:poi.lng];
                }                    break;
                    
                default:
                    break;
            }
            break;
            
        default:
            break;
    }
}


@end




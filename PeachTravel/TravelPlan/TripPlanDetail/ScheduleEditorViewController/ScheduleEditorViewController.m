//
//  ScheduleEditorViewController.m
//  PeachTravel
//
//  Created by Luo Yong on 15/6/13.
//  Copyright (c) 2015年 com.aizou.www. All rights reserved.
//

#import "ScheduleEditorViewController.h"
#import "PoiOnEditorTableViewCell.h"
#import "ScheduleDayEditViewController.h"
#import "DayAgendaViewController.h"
#import "AddPoiViewController.h"

@interface ScheduleEditorViewController ()<UITableViewDataSource, UITableViewDelegate, REFrostedViewControllerDelegate, addPoiDelegate> {
    NSMutableArray *_cityArray;
}

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) TripDetail *backupTrip;
@end

@implementation ScheduleEditorViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"调整";
    
    UIBarButtonItem *finishBtn = [[UIBarButtonItem alloc]initWithTitle:@"保存" style:UIBarButtonItemStylePlain target:self action:@selector(saveTripChange:)];
    UIBarButtonItem *cancelBtn = [[UIBarButtonItem alloc]initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(cancel:)];
    self.navigationItem.rightBarButtonItem = finishBtn;
    self.navigationItem.leftBarButtonItem = cancelBtn;
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.frostedViewController.delegate = self;
    
    _cityArray = [NSMutableArray array];
    
    _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    _tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _tableView.backgroundColor = APP_PAGE_COLOR;
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.separatorColor = COLOR_LINE;
    [_tableView registerNib:[UINib nibWithNibName:@"PoiOnEditorTableViewCell" bundle:nil] forCellReuseIdentifier:@"poi_cell_of_edit"];
    _tableView.editing = YES;
    _tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _tableView.bounds.size.width, 50)];
    [self.view addSubview:_tableView];
    
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.view.bounds) - 49 - 44, CGRectGetWidth(self.view.bounds), 49)];
    btn.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
    [btn setBackgroundImage:[ConvertMethods createImageWithColor:APP_THEME_COLOR] forState:UIControlStateNormal];
    [btn setBackgroundImage:[ConvertMethods createImageWithColor:APP_THEME_COLOR_HIGHLIGHT] forState:UIControlStateHighlighted];
    [btn setTitle:@"增加一天" forState:UIControlStateNormal];
    btn.titleLabel.font = [UIFont systemFontOfSize:16.0];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.view addSubview:btn];
    
    UIButton *editBtn = [[UIButton alloc] initWithFrame:CGRectMake(-4, self.view.bounds.size.height-300, 25, 70)];
    editBtn.backgroundColor = APP_THEME_COLOR;
    editBtn.titleLabel.numberOfLines = 0;
    editBtn.titleLabel.font = [UIFont systemFontOfSize:12.0];
    [editBtn setTitle:@"按\n天\n调\n整" forState:UIControlStateNormal];
    [editBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    editBtn.layer.cornerRadius = 5.0;
    [editBtn addTarget:self action:@selector(editDay:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:editBtn];
}

- (void)setTripDetail:(TripDetail *)tripDetail
{
    _tripDetail = tripDetail;
    _backupTrip = [_tripDetail backUpTrip];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)editDay:(id)sender
{
    ((ScheduleDayEditViewController *)self.frostedViewController.menuViewController).tripDetail = _backupTrip;
    [self.frostedViewController presentMenuViewController];
}

- (void)addPoi:(UIButton *)sender
{
    AddPoiViewController *ctl = [[AddPoiViewController alloc] init];
    ctl.currentDayIndex = sender.tag;
    ctl.tripDetail = _backupTrip;
    ctl.shouldEdit = YES;
    ctl.delegate = self;
    [self.navigationController pushViewController:ctl animated:YES];
}

#pragma mark - addPoiDelegate

- (void)finishEdit
{
    [_tableView reloadData];
}

#pragma mark - UITableViewDataSource & Delegate

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 64*CGRectGetHeight(self.view.frame)/768;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 64*CGRectGetHeight(self.view.frame)/768;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return _backupTrip.itineraryList.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger numberOfRows = [[_backupTrip.itineraryList objectAtIndex:section] count];
    return numberOfRows;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    CGFloat width = tableView.frame.size.width;
    CGFloat height = 60*CGRectGetHeight(self.view.frame)/768;
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, height)];
    
    UILabel *dayLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, (height - 40)/2 + 1, 40, 40)];
    dayLabel.font = [UIFont systemFontOfSize:14.0];
    dayLabel.textAlignment = NSTextAlignmentCenter;
    dayLabel.textColor = [UIColor whiteColor];
    dayLabel.numberOfLines = 2.0;
    dayLabel.layer.cornerRadius = 3.0;
    dayLabel.clipsToBounds = YES;
    dayLabel.backgroundColor = APP_THEME_COLOR;
    dayLabel.layer.cornerRadius = 4.0;
    
    NSString *dayIndex;
    if (section < 9) {
        dayIndex = [NSString stringWithFormat:@"0%ld.", section+1];
    } else {
        dayIndex = [NSString stringWithFormat:@"%ld.", section+1];
    }
    
    NSAttributedString *unitAStr = [[NSAttributedString alloc] initWithString:@"\nDay" attributes:@{
                                                                                                    NSFontAttributeName : [UIFont systemFontOfSize:10.0],
                                                                                                    }];
    NSMutableAttributedString *attrstr = [[NSMutableAttributedString alloc] initWithString:dayIndex attributes:nil];
    [attrstr appendAttributedString:unitAStr];
    dayLabel.attributedText = attrstr;
    [headerView addSubview:dayLabel];
    
    UILabel *headerTitle = [[UILabel alloc] initWithFrame:CGRectMake(64, 1, width-140, height-1)];
    headerTitle.textColor = COLOR_TEXT_II;
    headerTitle.userInteractionEnabled = NO;
    headerTitle.font = [UIFont systemFontOfSize:14.0];
    headerTitle.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    headerTitle.lineBreakMode = NSLineBreakByTruncatingTail;
    
    NSMutableOrderedSet *set = [[NSMutableOrderedSet alloc] init];
    for (SuperPoi *tripPoi in [_backupTrip.itineraryList objectAtIndex:section]) {
        if (tripPoi.locality.zhName) {
            [set addObject:tripPoi.locality.zhName];
            [_cityArray addObject:tripPoi.locality.cityId];
        }
    }
    
    NSMutableString *dest = [[NSMutableString alloc] init];
    if (set.count) {
        for (NSString *s in set) {
            if (dest.length > 0) {
                [dest appendFormat:@" > %@", s];
            } else {
                [dest appendString:s];
            }
        }
    }
    else
    {
        [dest appendString:@""];
    }
   
    headerTitle.text = dest;
    [headerView addSubview:headerTitle];
    
    UIButton *addPoiBtn = [[UIButton alloc] initWithFrame:CGRectMake(width-70, 1, 66, height-1)];
    [addPoiBtn setImage:[UIImage imageNamed:@"add_poi.png"] forState:UIControlStateNormal];
    [addPoiBtn addTarget:self action:@selector(addPoi:) forControlEvents:UIControlEventTouchUpInside];
    addPoiBtn.tag = section;
    
    [headerView addSubview:addPoiBtn];
    
    return headerView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PoiOnEditorTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"poi_cell_of_edit" forIndexPath:indexPath];
    
    if (_backupTrip.itineraryList[indexPath.section][indexPath.row] != [NSNull null]) {
        SuperPoi *tripPoi = _backupTrip.itineraryList[indexPath.section][indexPath.row];
        cell.poiNameLabel.text = tripPoi.zhName;
        cell.shouldIndentWhileEditing = NO;
        cell.showsReorderControl = NO;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (UITableViewCellEditingStyle) tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleDelete;
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    return @"删除";
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
    SuperPoi *poi = [[_tripDetail.itineraryList objectAtIndex:sourceIndexPath.section] objectAtIndex:sourceIndexPath.row];
    [[_tripDetail.itineraryList objectAtIndex:sourceIndexPath.section] removeObjectAtIndex:sourceIndexPath.section];
    
    [[_tripDetail.itineraryList objectAtIndex:destinationIndexPath.section] insertObject:poi atIndex:destinationIndexPath.row];
    [self.tableView reloadData];
}

- (NSIndexPath *)tableView:(UITableView *)tableView targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)sourceIndexPath toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath {
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

#pragma mark - IBAction

- (IBAction)saveTripChange:(id)sender
{
    NSMutableArray *backItineraryList = _tripDetail.itineraryList;
    _tripDetail.itineraryList = _backupTrip.itineraryList;
    [_tripDetail saveTrip:^(BOOL isSuccesss) {
        if (isSuccesss) {
            _backupTrip = [_tripDetail backUpTrip];
            [SVProgressHUD showHint:@"保存成功"];
            if ([self.rootCtl isKindOfClass:[DayAgendaViewController class]]) {
                [self dismissViewControllerAnimated:YES completion:nil];
                [self.rootCtl.navigationController popViewControllerAnimated:YES];
                
            } else {
                [self dismissViewControllerAnimated:YES completion:nil];
            }
        } else {
            _tripDetail.itineraryList = backItineraryList;
            [SVProgressHUD showHint:@"保存失败"];
        }
    }];
}

- (IBAction)cancel:(id)sender {
    if (_backupTrip.tripIsChange) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"计划发生修改是否忽略？" message:nil delegate:self cancelButtonTitle:@"忽略" otherButtonTitles:@"取消", nil];
        [alertView showAlertViewWithBlock:^(NSInteger buttonIndex) {
            if (buttonIndex == 0) {
                [self dismissViewControllerAnimated:YES completion:nil];
            }
        }];
    } else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)frostedViewController:(REFrostedViewController *)frostedViewController willHideMenuViewController:(UIViewController *)menuViewController
{
    [self.tableView reloadData];
}



@end







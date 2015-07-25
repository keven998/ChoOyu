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
    self.navigationItem.title = @"调整计划";
    
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
    [_tableView setEditing:YES animated:YES];
    _tableView.separatorColor = COLOR_LINE;
    [_tableView registerNib:[UINib nibWithNibName:@"PoiOnEditorTableViewCell" bundle:nil] forCellReuseIdentifier:@"poi_cell_of_edit"];
    _tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _tableView.bounds.size.width, 50+49)];
    [self.view addSubview:_tableView];
    
    UIImageView *tabbarView = [[UIImageView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.view.bounds) - 49, CGRectGetWidth(self.view.bounds), 49)];
    tabbarView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
    tabbarView.userInteractionEnabled = YES;
    tabbarView.image = [[UIImage imageNamed:@"bottom_shadow.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(5, 2, 5, 2)];
    
    [self.view addSubview:tabbarView];
    
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(tabbarView.bounds.size.width-74, 14, 60, 26)];
    btn.layer.cornerRadius = 3.0;
    btn.layer.borderColor = APP_THEME_COLOR.CGColor;
    btn.layer.borderWidth = 1.0;
    [btn setTitle:@"增加一天" forState:UIControlStateNormal];
    btn.titleLabel.font = [UIFont systemFontOfSize:12.0];
    [btn setTitleColor:APP_THEME_COLOR forState:UIControlStateNormal];
    [btn setTitleColor:COLOR_DISABLE forState:UIControlStateHighlighted];
    [btn addTarget:self action:@selector(addOneDay:) forControlEvents:UIControlEventTouchUpInside];
    [tabbarView addSubview:btn];
    
    UIButton *editBtn = [[UIButton alloc] initWithFrame:CGRectMake(20, 14, 60, 26)];
    editBtn.layer.cornerRadius = 3.0;
    editBtn.layer.borderColor = APP_THEME_COLOR.CGColor;
    editBtn.layer.borderWidth = 1.0;
    editBtn.titleLabel.font = [UIFont systemFontOfSize:12.0];
    [editBtn setTitle:@"按天调整" forState:UIControlStateNormal];
    [editBtn setTitleColor:APP_THEME_COLOR forState:UIControlStateNormal];
    [editBtn setTitleColor:COLOR_DISABLE forState:UIControlStateHighlighted];
    [editBtn addTarget:self action:@selector(editDay:) forControlEvents:UIControlEventTouchUpInside];
    [tabbarView addSubview:editBtn];
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

- (void)addOneDay:(id)sender {
    [_backupTrip.itineraryList addObject:[[NSMutableArray alloc] init]];
    NSIndexSet *set = [NSIndexSet indexSetWithIndex:_backupTrip.itineraryList.count-1];
    [self.tableView insertSections:set withRowAnimation:UITableViewRowAnimationAutomatic];
    CGPoint offset = CGPointMake(0, self.tableView.contentSize.height - self.tableView.frame.size.height);
    [self.tableView setContentOffset:offset animated:YES];

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
    [self presentViewController:[[TZNavigationViewController alloc] initWithRootViewController:ctl] animated:YES completion:nil];
}

#pragma mark - addPoiDelegate

- (void)finishEdit
{
    [_tableView reloadData];
}

#pragma mark - UITableViewDataSource & Delegate

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 45;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return CGFLOAT_MIN;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 66;
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
    CGFloat height = 55;
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, height)];
    
    UILabel *headerTitle = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, width-70, height)];
    headerTitle.userInteractionEnabled = NO;
    headerTitle.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    headerTitle.lineBreakMode = NSLineBreakByTruncatingTail;
    headerTitle.font = [UIFont systemFontOfSize:13.];
    
    NSString *dayIndex;
    if (section < 9) {
        dayIndex = [NSString stringWithFormat:@"0%ld.", section+1];
    } else {
        dayIndex = [NSString stringWithFormat:@"%ld.", section+1];
    }
    
    NSString *dayStr = [NSString stringWithFormat:@"%@Day ", dayIndex];
    NSMutableAttributedString *attrstr = [[NSMutableAttributedString alloc] init];
    NSAttributedString *unitAStr = [[NSAttributedString alloc] initWithString:dayStr attributes:@{
                                                                                                  NSForegroundColorAttributeName : COLOR_TEXT_III
                                                                                                  }];
    [attrstr appendAttributedString:unitAStr];
    
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
    
    NSAttributedString *descString = [[NSAttributedString alloc] initWithString:dest attributes:@{
                                                                                                  NSForegroundColorAttributeName : COLOR_TEXT_II
                                                                                                  }];
    [attrstr appendAttributedString:descString];
    headerTitle.attributedText = attrstr;
    [headerView addSubview:headerTitle];
    
    UIButton *addPoiBtn = [[UIButton alloc] initWithFrame:CGRectMake(width-50, 1, 50, height-1)];
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

- (void)dealloc {
    _rootCtl = nil;
    _delegate = nil;
    _tripDetail = nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSMutableArray *poisOfDay = _backupTrip.itineraryList[indexPath.section];
        [poisOfDay removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (UITableViewCellEditingStyle) tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleDelete;
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    return @"删除";
}

-(void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
    NSMutableArray *sourcePois = _backupTrip.itineraryList[sourceIndexPath.section];
    NSMutableArray *destinationPois = _backupTrip.itineraryList[destinationIndexPath.section];
    id poi = [sourcePois objectAtIndex:sourceIndexPath.row];
    [sourcePois removeObjectAtIndex:sourceIndexPath.row];
    [destinationPois insertObject:poi atIndex:destinationIndexPath.row];
}

#pragma mark - IBAction

- (IBAction)saveTripChange:(id)sender
{
    NSMutableArray *backItineraryList = _tripDetail.itineraryList;
    _tripDetail.itineraryList = _backupTrip.itineraryList;
    [_tripDetail saveTrip:^(BOOL isSuccesss) {
        if (isSuccesss) {
            _backupTrip = [_tripDetail backUpTrip];
            [self.frostedViewController.navigationController popViewControllerAnimated:YES];
        } else {
            _tripDetail.itineraryList = backItineraryList;
            [SVProgressHUD showHint:@"保存失败"];
        }
    }];
}

- (IBAction)cancel:(id)sender {
    if (_backupTrip.tripIsChange) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"是否放弃修改直接返回" delegate:self cancelButtonTitle:@"直接返回" otherButtonTitles:@"取消", nil];
        [alertView showAlertViewWithBlock:^(NSInteger buttonIndex) {
            if (buttonIndex == 0) {
                [self.frostedViewController.navigationController popViewControllerAnimated:YES];
            }
        }];
    } else {
        [self.frostedViewController.navigationController popViewControllerAnimated:YES];
    }
}

- (void)frostedViewController:(REFrostedViewController *)frostedViewController willHideMenuViewController:(UIViewController *)menuViewController
{
    [self.tableView reloadData];
}



@end







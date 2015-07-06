//
//  ScheduleEditorViewController.m
//  PeachTravel
//
//  Created by Luo Yong on 15/6/13.
//  Copyright (c) 2015年 com.aizou.www. All rights reserved.
//

#import "ScheduleEditorViewController.h"
#import "PoiOnEditorTableViewCell.h"
#import "FMMoveTableView.h"

@interface ScheduleEditorViewController ()<FMMoveTableViewDataSource, FMMoveTableViewDelegate> {
    NSMutableArray *_cityArray;
}

@property (nonatomic, strong) FMMoveTableView *tableView;
@property (nonatomic, strong) TripDetail *backupTrip;
@end

@implementation ScheduleEditorViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"修改行程";
    UIBarButtonItem *finishBtn = [[UIBarButtonItem alloc]initWithTitle:@"保存" style:UIBarButtonItemStylePlain target:self action:@selector(onScheduleChanged:)];
    UIBarButtonItem *cancelBtn = [[UIBarButtonItem alloc]initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(cancel:)];
    self.navigationItem.rightBarButtonItem = finishBtn;
    self.navigationItem.leftBarButtonItem = cancelBtn;
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    _cityArray = [NSMutableArray array];
    
    _tableView = [[FMMoveTableView alloc] initWithFrame:self.view.bounds];
    _tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _tableView.backgroundColor = APP_PAGE_COLOR;
    _tableView.dataSource = self;
    _tableView.delegate = self;
    [_tableView registerNib:[UINib nibWithNibName:@"PoiOnEditorTableViewCell" bundle:nil] forCellReuseIdentifier:@"poi_cell_of_edit"];
    [self.view addSubview:_tableView];
    
    UIButton *editBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height-150, 100, 25)];
    editBtn.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.9];
    [editBtn setTitle:@"编辑天数" forState:UIControlStateNormal];
    [editBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    editBtn.layer.cornerRadius = 4.0;
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
    [self.frostedViewController presentMenuViewController];
}

#pragma mark - UITableViewDataSource & Delegate

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 64;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 49;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return _backupTrip.itineraryList.count;
}

- (NSInteger)tableView:(FMMoveTableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger numberOfRows = [[_backupTrip.itineraryList objectAtIndex:section] count];
    if (tableView.movingIndexPath && tableView.movingIndexPath.section != tableView.initialIndexPathForMovingRow.section)
    {
        if (section == tableView.movingIndexPath.section) {
            numberOfRows++;
        }
        else if (section == tableView.initialIndexPathForMovingRow.section) {
            numberOfRows--;
        }
    }

    return numberOfRows;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    CGFloat width = tableView.frame.size.width;
    
    UILabel *headerTitle = [[UILabel alloc] initWithFrame:CGRectMake(37, 25, width-80, 24)];
    headerTitle.textColor = COLOR_TEXT_I;
    headerTitle.userInteractionEnabled = NO;
    headerTitle.font = [UIFont systemFontOfSize:15.0];
    headerTitle.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    headerTitle.lineBreakMode = NSLineBreakByTruncatingTail;
    NSString *titleStr = [NSString stringWithFormat:@"DAY%ld ",(long)section+1];
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
                [dest appendFormat:@"-%@", s];
            } else {
                [dest appendString:s];
            }
        }
    }
    else
    {
        [dest appendString:@""];
    }
    NSMutableAttributedString *attributeString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@%@", titleStr, dest]];
    [attributeString addAttributes:@{NSForegroundColorAttributeName:TEXT_COLOR_TITLE_SUBTITLE} range:NSMakeRange(titleStr.length, dest.length)];
    [attributeString addAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:11]} range:NSMakeRange(titleStr.length, dest.length)];
    headerTitle.attributedText = attributeString;
    
    return headerTitle;
}

- (UITableViewCell *)tableView:(FMMoveTableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PoiOnEditorTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"poi_cell_of_edit" forIndexPath:indexPath];
    if ([tableView indexPathIsMovingIndexPath:indexPath])
    {
        [cell prepareForMove];
    }
    else 
    {
        if (tableView.movingIndexPath != nil) {
            indexPath = [tableView adaptedIndexPathForRowAtIndexPath:indexPath];
        }
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

- (BOOL)moveTableView:(FMMoveTableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (NSIndexPath *)moveTableView:(FMMoveTableView *)tableView targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)sourceIndexPath toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath
{
    return proposedDestinationIndexPath;
}


- (void)moveTableView:(FMMoveTableView *)tableView moveRowFromIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
    NSArray *movie = [[_backupTrip.itineraryList objectAtIndex:fromIndexPath.section] objectAtIndex:fromIndexPath.row];
    [[_backupTrip.itineraryList objectAtIndex:fromIndexPath.section] removeObjectAtIndex:fromIndexPath.row];
    [[_backupTrip.itineraryList objectAtIndex:toIndexPath.section] insertObject:movie atIndex:toIndexPath.row];
}

#pragma mark - IBAction

- (IBAction)onScheduleChanged:(id)sender
{
    [_backupTrip saveTrip:^(BOOL isSuccesss) {
        if (isSuccesss) {
            [SVProgressHUD showHint:@"保存成功"];
            _tripDetail.itineraryList = _backupTrip.itineraryList;
        } else {
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



@end







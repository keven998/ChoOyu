//
//  PlanScheduleViewController.m
//  PeachTravel
//
//  Created by Luo Yong on 15/6/12.
//  Copyright (c) 2015年 com.aizou.www. All rights reserved.
//

#import "PlanScheduleViewController.h"
#import "PlanScheduleTableViewCell.h"
#import "DayAgendaViewController.h"
#import "MyTripSpotsMapViewController.h"

@interface PlanScheduleViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;

@end

@implementation PlanScheduleViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = APP_PAGE_COLOR;
    
    _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    _tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _tableView.separatorColor = COLOR_LINE;
    _tableView.dataSource = self;
    _tableView.delegate = self;
    [_tableView registerNib:[UINib nibWithNibName:@"PlanScheduleTableViewCell" bundle:nil] forCellReuseIdentifier:@"schedule_summary_cell"];
    [self.view addSubview:_tableView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)setTripDetail:(TripDetail *)tripDetail
{
    _tripDetail = tripDetail;
    [_tableView reloadData];
}

#pragma mark - UITableViewDataSource & Delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *ds = _tripDetail.itineraryList[indexPath.row];
    NSMutableString *dstr = [[NSMutableString alloc] init];
    NSInteger count = [ds count];
    for (int i = 0; i < count; ++i) {
        SuperPoi *sp = [ds objectAtIndex:i];
        if ([dstr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length == 0) {
            [dstr appendString:[NSString stringWithFormat:@"%@", sp.zhName]];
        } else {
            if ([dstr isBlankString]) {
                [dstr appendString:[NSString stringWithFormat:@"%@", sp.zhName]];
            } else {
                [dstr appendString:[NSString stringWithFormat:@" → %@", sp.zhName]];
            }
        }
    }
    return [PlanScheduleTableViewCell heightOfCellWithContent:dstr];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return CGFLOAT_MIN;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return CGFLOAT_MIN;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _tripDetail.itineraryList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PlanScheduleTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"schedule_summary_cell" forIndexPath:indexPath];
    NSArray *ds = _tripDetail.itineraryList[indexPath.row];
    NSMutableString *dstr = [[NSMutableString alloc] init];
    NSMutableString *title = [[NSMutableString alloc] init];
    NSMutableArray *titleArray = [[NSMutableArray alloc] init];
    NSInteger count = [ds count];
    for (int i = 0; i < count; ++i) {
        SuperPoi *sp = [ds objectAtIndex:i];
        if ([dstr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length == 0) {
            if (sp.locality && sp.locality.zhName) {
                [titleArray addObject:sp.locality.zhName];
                [title appendString:sp.locality.zhName];
            }
            
            [dstr appendString:[NSString stringWithFormat:@"%@", sp.zhName]];
        } else {
            BOOL find = NO;
            for (NSString *str in titleArray) {
                if ([str isEqualToString:sp.locality.zhName]) {
                    find = YES;
                    break;
                }
            }
            if (!find && sp.locality && sp.locality.zhName) {
                if ([title isBlankString]) {
                    [title appendString:[NSString stringWithFormat:@"%@", sp.locality.zhName]];

                } else {
                    [title appendString:[NSString stringWithFormat:@" > %@", sp.locality.zhName]];
                }
                [titleArray addObject:sp.locality.zhName];
            }
            [dstr appendString:[NSString stringWithFormat:@" → %@", sp.zhName]];

        }
    }
    
    cell.content = dstr;
    if (dstr == nil || [dstr isBlankString]) {
        cell.titleLabel.text = @"无安排";
    } else {
        cell.titleLabel.text = title;
    }
    if (indexPath.row < 9) {
        cell.day = [NSString stringWithFormat:@"0%ld.", indexPath.row+1];
    } else {
        cell.day = [NSString stringWithFormat:@"%ld.", indexPath.row+1];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [MobClick event:@"tab_item_trip_detail"];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSArray *ds = _tripDetail.itineraryList[indexPath.row];
    NSMutableString *title = [[NSMutableString alloc] init];
    NSMutableArray *titleArray = [[NSMutableArray alloc] init];
    NSInteger count = [ds count];
    for (int i = 0; i < count; ++i) {
        SuperPoi *sp = [ds objectAtIndex:i];
        if ([title stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length == 0) {
            if (sp.locality && sp.locality.zhName) {
                [titleArray addObject:sp.locality.zhName];
                [title appendString:sp.locality.zhName];
            }
        } else {
            BOOL find = NO;
            for (NSString *str in titleArray) {
                if ([str isEqualToString:sp.locality.zhName]) {
                    find = YES;
                    break;
                }
            }
            if (!find && sp.locality && sp.locality.zhName) {
                [title appendString:[NSString stringWithFormat:@" > %@", sp.locality.zhName]];
                [titleArray addObject:sp.locality.zhName];
            }
        }
    }
    

    DayAgendaViewController *davc = [[DayAgendaViewController alloc] initWithDay:indexPath.row];
    davc.tripDetail = _tripDetail;
    davc.sceenImage = [self imageViewFromScreen];
    
    UIView * sourceView = [tableView cellForRowAtIndexPath:indexPath];
    int y = [sourceView convertPoint:CGPointMake(1, 1) toView:self.tableView].y;
    davc.sep = [self.tableView convertPoint:CGPointMake(0, y) toView:self.view].y + 64 + 45;
    davc.titleStr = title;
    [self.frostedViewController.navigationController pushViewController:davc animated:NO];
}

// capture a screen-sized image of the receiver
- (UIImage *)imageViewFromScreen {
    // make a bitmap copy of the screen
    UIGraphicsBeginImageContextWithOptions([UIScreen mainScreen].bounds.size, YES,[UIScreen mainScreen].scale);
    // get the root layer
    CALayer *layer = self.view.layer;
    while(layer.superlayer) {
        layer = layer.superlayer;
    }
    // render it into the bitmap
    [layer renderInContext:UIGraphicsGetCurrentContext()];
    // get the image
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    // close the context
    UIGraphicsEndImageContext();
    
    return(image);
}

@end

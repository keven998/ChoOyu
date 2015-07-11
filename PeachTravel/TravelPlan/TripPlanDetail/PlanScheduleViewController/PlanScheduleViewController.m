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

@interface PlanScheduleViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;

@end

@implementation PlanScheduleViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = APP_PAGE_COLOR;
    
    // Do any additional setup after loading the view.
    _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    _tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _tableView.separatorColor = COLOR_LINE;
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.contentInset = UIEdgeInsetsMake(2, 0, 2, 0);
    [_tableView registerNib:[UINib nibWithNibName:@"PlanScheduleTableViewCell" bundle:nil] forCellReuseIdentifier:@"schedule_summary_cell"];
    [self.view addSubview:_tableView];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    [self.tableView reloadData];
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
            [dstr appendString:[NSString stringWithFormat:@" > %@", sp.zhName]];
        }
    }
    return [PlanScheduleTableViewCell heightOfCellWithContent:dstr];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 1;
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
                [title appendString:[NSString stringWithFormat:@" > %@", sp.locality.zhName]];
                [titleArray addObject:sp.locality.zhName];
            }
            [dstr appendString:[NSString stringWithFormat:@" > %@", sp.zhName]];

        }
    }
    
    cell.content = dstr;
    if (title == nil || [title isBlankString]) {
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
    davc.titleStr = title;
    [self.frostedViewController.navigationController pushViewController:davc animated:YES];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

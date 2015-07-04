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
    // Do any additional setup after loading the view.
    _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    _tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _tableView.backgroundColor = APP_PAGE_COLOR;
    _tableView.dataSource = self;
    _tableView.delegate = self;
    [_tableView registerNib:[UINib nibWithNibName:@"PlanScheduleTableViewCell" bundle:nil] forCellReuseIdentifier:@"schedule_summary_cell"];
    [self.view addSubview:_tableView];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setTripDetail:(TripDetail *)tripDetail
{
    _tripDetail = tripDetail;
    [_tableView reloadData];
}

#pragma mark - UITableViewDataSource & Delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 66;
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
        if (i == 0) {
            [titleArray addObject:sp.locality.zhName];
            [title appendString:sp.locality.zhName];
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
    
    NSMutableParagraphStyle *ps = [[NSMutableParagraphStyle alloc] init];
    ps.lineSpacing = 8.0;
    NSDictionary *attribs = @{NSFontAttributeName: [UIFont systemFontOfSize:15], NSParagraphStyleAttributeName:ps};
    NSAttributedString *attrstr = [[NSAttributedString alloc] initWithString:dstr attributes:attribs];
    cell.dayScheduleSummary.attributedText = attrstr;
    cell.titleLabel.text = title;
    CGRect frame = cell.dayScheduleSummary.frame;
    CGRect rect = [attrstr boundingRectWithSize:(CGSize){CGRectGetWidth(frame), CGFLOAT_MAX} options:NSStringDrawingUsesLineFragmentOrigin context:nil];
    frame.size.height = ceilf(rect.size.height) + 1;
    cell.dayScheduleSummary.frame = frame;
    cell.dayLabel.text = [NSString stringWithFormat:@"0%ld.\nDay", indexPath.row+1];

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
        if (i == 0) {
            [titleArray addObject:sp.locality.zhName];
            [title appendString:sp.locality.zhName];
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
    [self.navigationController pushViewController:davc animated:YES];
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

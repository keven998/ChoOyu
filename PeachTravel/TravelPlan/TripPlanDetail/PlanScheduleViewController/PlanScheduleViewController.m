//
//  PlanScheduleViewController.m
//  PeachTravel
//
//  Created by Luo Yong on 15/6/12.
//  Copyright (c) 2015年 com.aizou.www. All rights reserved.
//

#import "PlanScheduleViewController.h"
#import "PlanScheduleTableViewCell.h"

@interface PlanScheduleViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;

@end

@implementation PlanScheduleViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _tableView = [[UITableView alloc] initWithFrame:self.view.bounds];
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
    return 128;
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
    NSInteger count = [ds count];
    for (int i = 0; i < count; ++i) {
        SuperPoi *sp = [ds objectAtIndex:i];
        if (i == 0) {
            [dstr appendString:[NSString stringWithFormat:@"1.%@", sp.zhName]];
        } else {
            [dstr appendString:[NSString stringWithFormat:@" > %d.%@", (i+1), sp.zhName]];
        }
    }
    cell.dayScheduleSummary.text = dstr;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
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

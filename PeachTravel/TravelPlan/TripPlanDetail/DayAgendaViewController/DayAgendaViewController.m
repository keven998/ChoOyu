//
//  DayAgendaViewController.m
//  PeachTravel
//
//  Created by Luo Yong on 15/6/12.
//  Copyright (c) 2015年 com.aizou.www. All rights reserved.
//

#import "DayAgendaViewController.h"
#import "POICell.h"
#import "SpotDetailViewController.h"
#import "ScheduleEditorViewController.h"
#import "TripPoiListTableViewCell.h"

@interface DayAgendaViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;

@end

static NSString *tripPoiListReusableIdentifier = @"tripPoiListCell";

@implementation DayAgendaViewController

- (id)initWithDay:(NSInteger)day
{
    if (self = [super init])
    {
        _currentDay = (int)day;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    _tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _tableView.backgroundColor = APP_PAGE_COLOR;
    _tableView.dataSource = self;
    _tableView.delegate = self;
    [_tableView registerNib:[UINib nibWithNibName:@"TripPoiListTableViewCell" bundle:nil] forCellReuseIdentifier:tripPoiListReusableIdentifier];
    [self.view addSubview:_tableView];
    
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 35, 44)];
    btn.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    [btn setTitle:@"编辑" forState:UIControlStateNormal];
    btn.titleLabel.font = [UIFont systemFontOfSize:16.0];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(editSchedule) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [super viewWillAppear:animated];
}

- (void)setTitleStr:(NSString *)titleStr {
    _titleStr = titleStr;
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width-150, 40)];
    titleLabel.numberOfLines = 2.0;
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.textColor = [UIColor whiteColor];
    NSString *dayStr = [NSString stringWithFormat:@"第%d天", _currentDay+1];
    NSString *totalStr = [NSString stringWithFormat:@"第%d天\n%@", _currentDay+1, _titleStr];
    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString: totalStr];
    
    [attrStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:16] range:NSMakeRange(0, dayStr.length)];
    [attrStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:11] range:NSMakeRange(dayStr.length+1, totalStr.length-dayStr.length-1)];
    
    titleLabel.attributedText = attrStr;
    self.navigationItem.titleView = titleLabel;

}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDataSource & Delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 66;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_tripDetail.itineraryList[_currentDay] count];
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
    SpotDetailViewController *spotDetailCtl = [[SpotDetailViewController alloc] init];
    SuperPoi *poi = _tripDetail.itineraryList[_currentDay][indexPath.row];
    spotDetailCtl.spotId = poi.poiId;
    [self.navigationController pushViewController:spotDetailCtl animated:YES];

    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

- (UITableViewCellEditingStyle) tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleDelete;
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    return @"删除";
}


#pragma IBAction - editSchedule
- (void) editSchedule {
    ScheduleEditorViewController *sevc = [[ScheduleEditorViewController alloc] init];
    sevc.tripDetail = _tripDetail;
    [self presentViewController:[[UINavigationController alloc] initWithRootViewController:sevc] animated:YES completion:nil];
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

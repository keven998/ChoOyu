//
//  MakePlanSelectDayViewController.m
//  PeachTravel
//
//  Created by liangpengshuai on 5/16/16.
//  Copyright © 2016 com.aizou.www. All rights reserved.
//

#import "MakePlanSelectDayViewController.h"
#import "MakeOrderSelectCountTableViewCell.h"
#import "CityDestinationPoi.h"
#import "TripDetailRootViewController.h"
#import "TripPlanSettingViewController.h"

@interface MakePlanSelectDayViewController () <UITableViewDelegate, UITableViewDataSource, MakeOrderSelectCountDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) NSMutableArray *destinationDayCount;

@end

@implementation MakePlanSelectDayViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"制作行程";
    _tableView.dataSource = self;
    _tableView.delegate = self;
    [_tableView registerNib:[UINib nibWithNibName:@"MakeOrderSelectCountTableViewCell" bundle:nil] forCellReuseIdentifier:@"makeOrderSelectCountCell"];
    
    UIButton *bbtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
    [bbtn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    [bbtn setImage:[UIImage imageNamed:@"common_icon_navigation_back_normal"] forState:UIControlStateNormal];
    [bbtn addTarget:self action:@selector(dismissCtl) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:bbtn];
    
    UIBarButtonItem *rbi = [[UIBarButtonItem alloc] initWithTitle:@"完成" style:UIBarButtonItemStylePlain target:self action:@selector(makePlan)];
    self.navigationItem.rightBarButtonItem = rbi;
    _destinationDayCount = [[NSMutableArray alloc] init];
    for (int i=0; i<_selectDestinations.count; i++) {
        [_destinationDayCount addObject:[NSNumber numberWithInteger:1]];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)makePlan
{
    TripDetailRootViewController *tripDetailCtl = [[TripDetailRootViewController alloc] init];
    tripDetailCtl.canEdit = YES;
    tripDetailCtl.destinations = self.selectDestinations;
    tripDetailCtl.isMakeNewTrip = YES;
    tripDetailCtl.isNeedRecommend = NO;
    
    
    NSMutableArray *locatlityItems = [[NSMutableArray alloc] init];
    int index = 0;
    for (NSNumber *number in _destinationDayCount) {
        
        CityDestinationPoi *poi = [_selectDestinations objectAtIndex:index];
        for (int i=0; i<[number integerValue]; i++) {
            CityDestinationPoi *newPoi = [[CityDestinationPoi alloc] init];
            newPoi.cityId = poi.cityId;
            newPoi.zhName = poi.zhName;
            newPoi.enName = poi.enName;
            [locatlityItems addObject:newPoi];
        }
        index++;
    }
    
    tripDetailCtl.localityItems = locatlityItems;

    TripPlanSettingViewController *tpvc = [[TripPlanSettingViewController alloc] init];
    
    REFrostedViewController *frostedViewController = [[REFrostedViewController alloc] initWithContentViewController:tripDetailCtl menuViewController:tpvc];
    tpvc.rootViewController = tripDetailCtl;
    frostedViewController.direction = REFrostedViewControllerDirectionRight;
    frostedViewController.liveBlurBackgroundStyle = REFrostedViewControllerLiveBackgroundStyleLight;
    frostedViewController.liveBlur = YES;
    frostedViewController.limitMenuViewSize = YES;
    
    NSMutableArray *ctls = [NSMutableArray arrayWithArray:self.navigationController.childViewControllers];
    [ctls replaceObjectAtIndex:(ctls.count - 1) withObject:frostedViewController];
    [self.navigationController setViewControllers:ctls animated:YES];
}

- (void)dismissCtl
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _selectDestinations.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MakeOrderSelectCountTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"makeOrderSelectCountCell" forIndexPath:indexPath];
    cell.delegate = self;
    CityDestinationPoi *poi = [_selectDestinations objectAtIndex:indexPath.row];
    cell.titleLabel.text = poi.zhName;
    cell.countLabel.tag = indexPath.row;
    return cell;
}

- (void)updateSelectCount:(NSInteger)count andIndex:(NSInteger)index
{
    [_destinationDayCount replaceObjectAtIndex:index withObject:[NSNumber numberWithInteger:count]];
}

@end

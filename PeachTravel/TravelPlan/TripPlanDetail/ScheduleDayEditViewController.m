//
//  ScheduleDayEditViewController.m
//  PeachTravel
//
//  Created by liangpengshuai on 7/4/15.
//  Copyright (c) 2015 com.aizou.www. All rights reserved.
//

#import "ScheduleDayEditViewController.h"
#import "FMMoveTableView.h"
#import "FMMoveTableViewCell.h"

@interface ScheduleDayEditViewController () <FMMoveTableViewDataSource, FMMoveTableViewDelegate>

@property (weak, nonatomic) IBOutlet FMMoveTableView *tableView;

@property (nonatomic, strong) TripDetail *backupTrip;

@end

@implementation ScheduleDayEditViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 64)];
    [_tableView setEditing:YES];
    [_tableView registerClass:[FMMoveTableViewCell class] forCellReuseIdentifier:@"cell"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)setTripDetail:(TripDetail *)tripDetail
{
    _tripDetail = tripDetail;
    _backupTrip = [_tripDetail backUpTrip];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _backupTrip.itineraryList.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (UITableViewCell *)tableView:(FMMoveTableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    FMMoveTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    cell.textLabel.text = [NSString stringWithFormat:@"DAY%ld", indexPath.row];
    
    if ([tableView indexPathIsMovingIndexPath:indexPath]) {
        [cell prepareForMove];
    } else
    {
        if (tableView.movingIndexPath != nil) {
            indexPath = [tableView adaptedIndexPathForRowAtIndexPath:indexPath];
        }
        cell.shouldIndentWhileEditing = NO;
        cell.showsReorderControl = NO;
    }
    return cell;
}

- (void)moveTableView:(FMMoveTableView *)tableView moveRowFromIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
//    [_tableView reloadData];
}

- (void)moveTableView:(FMMoveTableView *)tableView willMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}






@end

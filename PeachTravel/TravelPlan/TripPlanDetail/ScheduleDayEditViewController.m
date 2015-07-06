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
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _tripDetail.itineraryList.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (UITableViewCell *)tableView:(FMMoveTableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    FMMoveTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    cell.textLabel.text = [NSString stringWithFormat:@"DAY%ld", indexPath.row+1];
    
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
    id data = [_tripDetail.itineraryList objectAtIndex:fromIndexPath.row];
    [_tripDetail.itineraryList removeObjectAtIndex:fromIndexPath.row];
    [_tripDetail.itineraryList insertObject:data atIndex:toIndexPath.row];
    [_tableView reloadData];
}

- (void)moveTableView:(FMMoveTableView *)tableView willMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}






@end

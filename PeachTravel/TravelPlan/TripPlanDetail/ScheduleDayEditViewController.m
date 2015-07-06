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
    
    NSArray *ds = _tripDetail.itineraryList[indexPath.row];
    NSMutableString *title = [[NSMutableString alloc] init];
    NSMutableArray *titleArray = [[NSMutableArray alloc] init];
    NSInteger count = [ds count];
    for (int i = 0; i < count; ++i) {
        SuperPoi *sp = [ds objectAtIndex:i];
        if (i == 0) {
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
                [titleArray addObject:sp.locality.zhName];
                [title appendString:[NSString stringWithFormat:@" > %@", sp.locality.zhName]];
            }
        }
    }

    cell.textLabel.text = [NSString stringWithFormat:@"DAY%ld %@", indexPath.row+1, title];

    if ([tableView indexPathIsMovingIndexPath:indexPath]) {
        [cell prepareForMove];
        
    } else {
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

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"确认删除这一天的所有安排?" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确认", nil];
        [alertView showAlertViewWithBlock:^(NSInteger buttonIndex) {
            if (buttonIndex == 1) {
                [_tripDetail.itineraryList removeObjectAtIndex:indexPath.row];
                [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            }
        }];
    }
}





@end





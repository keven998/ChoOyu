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
#import "MakePlanViewController.h"

@interface PlanScheduleViewController ()<UITableViewDelegate, UITableViewDataSource, UpdateDestinationsDelegate>

@property (nonatomic, strong) UITableView *tableView;

@end

@implementation PlanScheduleViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = APP_PAGE_COLOR;
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 64, kWindowWidth, self.view.bounds.size.height-64-49) style:UITableViewStyleGrouped];
    _tableView.separatorColor = COLOR_LINE;
    _tableView.dataSource = self;
    _tableView.delegate = self;
    [_tableView registerNib:[UINib nibWithNibName:@"PlanScheduleTableViewCell" bundle:nil] forCellReuseIdentifier:@"schedule_summary_cell"];
    [self.view addSubview:_tableView];
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    
    UIImageView *tabbarView = [[UIImageView alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height - 49, CGRectGetWidth(self.view.bounds), 49)];
    tabbarView.userInteractionEnabled = YES;
    tabbarView.image = [[UIImage imageNamed:@"bottom_shadow.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(5, 2, 5, 2)];
    
    [self.view addSubview:tabbarView];
    
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(tabbarView.bounds.size.width/2-40, 14, 80, 26)];
    btn.layer.cornerRadius = 3.0;
    btn.backgroundColor = APP_THEME_COLOR;
    [btn setTitle:@"1天" forState:UIControlStateNormal];
    [btn setImage:[UIImage imageNamed:@"trip_add_day.png"] forState:UIControlStateNormal];
    btn.titleEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 0);
    btn.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 10);
    btn.titleLabel.font = [UIFont systemFontOfSize:17.0];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btn setTitleColor:COLOR_DISABLE forState:UIControlStateHighlighted];
    [btn addTarget:self action:@selector(editDestinationCity) forControlEvents:UIControlEventTouchUpInside];
    [tabbarView addSubview:btn];

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

- (void)editDestinationCity
{
    Destinations *destinations = [[Destinations alloc] init];
    MakePlanViewController *makePlanCtl = [[MakePlanViewController alloc] init];
    makePlanCtl.destinations = destinations;
    makePlanCtl.shouldOnlyChangeDestinationWhenClickNextStep = YES;
    makePlanCtl.myDelegate = self;
    UINavigationController *navi = [[UINavigationController alloc] initWithRootViewController:makePlanCtl];
    [self presentViewController:navi animated:YES completion:nil];
}


#pragma mark - UpdateDestinationsDelegate

- (void)updateDestinations:(NSArray *)destinations
{
    self.tripDetail.dayCount++;
    [self.tripDetail.itineraryList addObject:[[NSMutableArray alloc] init]];
    [self.tripDetail.travelNoteItems addObject:[[NSMutableArray alloc] init]];
    [self.tripDetail.trafficItems addObject:[[NSMutableArray alloc] init]];
    [self.tripDetail.localityItems addObject:destinations];
    NSMutableArray *tempArray = [[NSMutableArray alloc] initWithArray:self.tripDetail.destinations];
    for (CityDestinationPoi *poi in destinations) {
        BOOL find = NO;
        for (CityDestinationPoi *poi1 in _tripDetail.destinations) {
            if ([poi.cityId isEqualToString:poi1.cityId]) {
                find = YES;
                break;
            }
        }
        if (!find) {
            [tempArray addObject:poi];
        }
    }
    
    self.tripDetail.destinations = tempArray;
    [_tripDetail saveTrip:^(BOOL isSuccesss) {
        if (!isSuccesss) {
            
        }
    }];
    [_tableView reloadData];
}

- (void)dealloc
{
    self.tableView.delegate = nil;
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
    return _tripDetail.dayCount;
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
        if (indexPath.row < _tripDetail.localityItems.count) {
            if ([[_tripDetail.localityItems objectAtIndex:indexPath.row] count] > 0) {
                for (CityDestinationPoi *locality in [_tripDetail.localityItems objectAtIndex:indexPath.row]) {
                    if ([title isBlankString]) {
                        [title appendString:[NSString stringWithFormat:@"%@", locality.zhName]];
                        
                    } else {
                        [title appendString:[NSString stringWithFormat:@" > %@", locality.zhName]];
                    }
                }
                cell.titleLabel.text = title;
            } else {
                cell.titleLabel.text = @"无安排";
            }

        } else {
            cell.titleLabel.text = @"无安排";

        }
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

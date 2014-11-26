//
//  RestaurantsListViewController.m
//  PeachTravel
//
//  Created by liangpengshuai on 11/24/14.
//  Copyright (c) 2014 com.aizou.www. All rights reserved.
//

#import "RestaurantsListViewController.h"
#import "DKCircleButton.h"
#import "RestaurantListTableViewCell.h"
#import "DestinationsView.h"
#import "RestaurantsOfCityViewController.h"

@interface RestaurantsListViewController () <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) DKCircleButton *editBtn;
@property (strong, nonatomic) UIView *tableViewFooterView;
@property (strong, nonatomic) DestinationsView *destinationsHeaderView;

@end

@implementation RestaurantsListViewController

static NSString *restaurantListReusableIdentifier = @"restaurantListCell";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.view.backgroundColor = APP_PAGE_COLOR;
    [self.view addSubview:self.tableView];
    
    _editBtn = [[DKCircleButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width-60, self.view.frame.size.height-100, 40, 40)];
    _editBtn.backgroundColor = APP_THEME_COLOR;
    _editBtn.titleLabel.font = [UIFont systemFontOfSize:13.0];
    [_editBtn setTitle:@"编辑" forState:UIControlStateNormal];
    [_editBtn addTarget:self action:@selector(editTrip:) forControlEvents:UIControlEventTouchUpInside];
    [self.tableView reloadData];
    [self.view addSubview:_editBtn];
    [self setUpTableViewHeaderView];
    
}

- (void)setUpTableViewHeaderView
{
    self.tableView.tableHeaderView = self.destinationsHeaderView;
}

#pragma mark - setter & getter

- (void)setTripDetail:(TripDetail *)tripDetail
{
    _tripDetail = tripDetail;
    [_tableView reloadData];
}

- (UITableView *)tableView
{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(8, 64+8, self.view.frame.size.width-16, self.view.frame.size.height-64-48)];
        [self.tableView registerNib:[UINib nibWithNibName:@"RestaurantListTableViewCell" bundle:nil] forCellReuseIdentifier:restaurantListReusableIdentifier];
        _tableView.backgroundColor = APP_PAGE_COLOR;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.delegate = self;
        _tableView.dataSource = self;
    }
    return _tableView;
}

- (UIView *)tableViewFooterView
{
    if (!_tableViewFooterView) {
        _tableViewFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 100)];
        UIButton *addOneDayBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 40, 80, 30)];
        [addOneDayBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [addOneDayBtn setTitle:@"添加想去" forState:UIControlStateNormal];
        addOneDayBtn.backgroundColor = APP_THEME_COLOR;
        [addOneDayBtn addTarget:self action:@selector(addWantTo:) forControlEvents:UIControlEventTouchUpInside];
        addOneDayBtn.layer.cornerRadius = 2.0;
        addOneDayBtn.titleLabel.font = [UIFont boldSystemFontOfSize:14.0];
        [_tableViewFooterView addSubview:addOneDayBtn];
        
        UIView *spaceView = [[UIView alloc] initWithFrame:CGRectMake(0, 25, self.tableView.frame.size.width, 1)];
        spaceView.backgroundColor = [UIColor lightGrayColor];
        [_tableViewFooterView addSubview:spaceView];
    }
    return _tableViewFooterView;
}

- (DestinationsView *)destinationsHeaderView
{
    if (!_destinationsHeaderView) {
        _destinationsHeaderView = [[DestinationsView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 60)];
#warning 测试数据
        _destinationsHeaderView.destinations = @[@"大阪",@"香格里拉大酒店",@"洛杉矶",@"大阪",@"香格里拉大酒店",@"洛杉矶"];
    }
    return _destinationsHeaderView;
}


#pragma makr - IBAction Methods

- (IBAction)addWantTo:(id)sender
{
    RestaurantsOfCityViewController *restaurantOfCityCtl = [[RestaurantsOfCityViewController alloc] init];
    [self.rootViewController.navigationController pushViewController:restaurantOfCityCtl animated:YES];
}

- (void)updateTableView
{
    [self.tableView reloadData];
    if (self.tableView.isEditing) {
        self.tableView.tableFooterView = self.tableViewFooterView;
    } else {
        self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 100)];
    }
}

- (IBAction)editTrip:(id)sender
{
    [self.tableView setEditing:!self.tableView.isEditing animated:YES];
    [self performSelector:@selector(updateTableView) withObject:nil afterDelay:0.2];
    if (self.tableView.isEditing) {
        [_editBtn setTitle:@"完成" forState:UIControlStateNormal];
    } else {
        [_editBtn setTitle:@"编辑" forState:UIControlStateNormal];
    }
}

#pragma mark - UITableViewDataSource & Delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.tripDetail.restaurantsList.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 10;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 10)];
    footerView.backgroundColor = APP_PAGE_COLOR;
    return footerView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    RestaurantListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:restaurantListReusableIdentifier forIndexPath:indexPath];
    cell.isEditing = self.tableView.isEditing;
    cell.tripPoi = [_tripDetail.restaurantsList objectAtIndex:indexPath.section];
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (UITableViewCellEditingStyle) tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {

}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
}

- (void)tableView:(UITableView *)tableView willBeginEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"willBeginEditingRowAtIndexPath");
}

- (void)tableView:(UITableView *)tableView didEndEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    CGPoint currentOffset = scrollView.contentOffset;
    NSLog(@"%@",NSStringFromCGPoint(currentOffset));
    
    if ([scrollView isEqual:self.tableView]) {
        if (currentOffset.y < 20) {
            [self.tableView setContentOffset:CGPointZero animated:YES];
        } else if ((currentOffset.y > 20) && (currentOffset.y < 60)) {
            [self.tableView setContentOffset:CGPointMake(0, 60) animated:YES];
        }
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    CGPoint currentOffset = scrollView.contentOffset;
    NSLog(@"***%@",NSStringFromCGPoint(currentOffset));
    
    if ([scrollView isEqual:self.tableView]) {
        if (currentOffset.y < 20) {
            [self.tableView setContentOffset:CGPointZero animated:YES];
        } else if ((currentOffset.y > 20) && (currentOffset.y < 60)) {
            [self.tableView setContentOffset:CGPointMake(0, 60) animated:YES];
        }
    }
}


@end

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

@interface RestaurantsListViewController () <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) DKCircleButton *editBtn;

@end

@implementation RestaurantsListViewController

static NSString *restaurantListReusableIdentifier = @"restaurantListCell";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.view.backgroundColor = APP_PAGE_COLOR;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView registerNib:[UINib nibWithNibName:@"RestaurantListTableViewCell" bundle:nil] forCellReuseIdentifier:restaurantListReusableIdentifier];
    [self.view addSubview:self.tableView];
    
    _editBtn = [[DKCircleButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width-60, self.view.frame.size.height-100, 40, 40)];
    _editBtn.backgroundColor = APP_THEME_COLOR;
    _editBtn.titleLabel.font = [UIFont systemFontOfSize:13.0];
    [_editBtn setTitle:@"编辑" forState:UIControlStateNormal];
    [_editBtn addTarget:self action:@selector(editTrip:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_editBtn];
    
}

#pragma mark - setter & getter

- (UITableView *)tableView
{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(8, 64+8, self.view.frame.size.width-16, self.view.frame.size.height-64-48)];
        _tableView.backgroundColor = APP_PAGE_COLOR;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    return _tableView;
}

#pragma makr - IBAction Methods

- (void)updateTableView
{
    [self.tableView reloadData];
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
    return 10;
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

@end

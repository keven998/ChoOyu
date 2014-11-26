//
//  SpotsListViewController.m
//  PeachTravel
//
//  Created by liangpengshuai on 11/24/14.
//  Copyright (c) 2014 com.aizou.www. All rights reserved.
//

#import "SpotsListViewController.h"
#import "SpotsListTableViewCell.h"
#import "DKCircleButton.h"
#import "RNGridMenu.h"
#import "DestinationsView.h"
#import "AddPoiTableViewController.h"

@interface SpotsListViewController () <UITableViewDataSource, UITableViewDelegate, RNGridMenuDelegate>

@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) DKCircleButton *editBtn;
@property (strong, nonatomic) UIView *tableViewFooterView;
@property (strong, nonatomic) DestinationsView *destinationsHeaderView;


@end

@implementation SpotsListViewController

static NSString *spotsListReusableIdentifier = @"spotsListCell";

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.view.backgroundColor = APP_PAGE_COLOR;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView registerNib:[UINib nibWithNibName:@"SpotsListTableViewCell" bundle:nil] forCellReuseIdentifier:spotsListReusableIdentifier];
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
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.backgroundColor = APP_PAGE_COLOR;
        _tableView.tableFooterView = self.tableViewFooterView;
        _tableView.tableHeaderView = self.destinationsHeaderView;
        [_tableView setContentOffset:CGPointMake(0, 60)];
    }
    return _tableView;
}

- (UIView *)tableViewFooterView
{
    if (!_tableViewFooterView) {
        _tableViewFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 80)];
        UIButton *addOneDayBtn = [[UIButton alloc] initWithFrame:CGRectMake(20, 5, 80, 30)];
        [addOneDayBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [addOneDayBtn setTitle:@"添加一天" forState:UIControlStateNormal];
        addOneDayBtn.backgroundColor = APP_THEME_COLOR;
        [addOneDayBtn addTarget:self action:@selector(addOneDay:) forControlEvents:UIControlEventTouchUpInside];
        addOneDayBtn.layer.cornerRadius = 2.0;
        addOneDayBtn.titleLabel.font = [UIFont boldSystemFontOfSize:14.0];
        [_tableViewFooterView addSubview:addOneDayBtn];
        if (!self.tableView.isEditing) {
            UIView *nodeView = [[UIView alloc] initWithFrame:CGRectMake(1, 16, 8, 8)];
            nodeView.backgroundColor = APP_THEME_COLOR;
            nodeView.layer.cornerRadius = 4.0;
            [_tableViewFooterView addSubview:nodeView];
            
            
            UIView *verticalSpaceViewUp = [[UIView alloc] initWithFrame:CGRectMake(5, 0, 1, 16)];
            verticalSpaceViewUp.backgroundColor = [UIColor lightGrayColor];
            [_tableViewFooterView addSubview:verticalSpaceViewUp];
       
        }
    }
    return _tableViewFooterView;
}

- (DestinationsView *)destinationsHeaderView
{
    if (!_destinationsHeaderView) {
        _destinationsHeaderView = [[DestinationsView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 60) andContentOffsetX:20];
#warning 测试数据
        _destinationsHeaderView.destinations = @[@"大阪",@"香格里拉大酒店",@"洛杉矶",@"大阪",@"香格里拉大酒店",@"洛杉矶"];
    }
    return _destinationsHeaderView;
}

#pragma makr - IBAction Methods

- (IBAction)addOneDay:(id)sender
{
    
}

- (IBAction)showMore:(UIButton *)sender
{
    NSInteger numberOfOptions = 4;
    NSArray *items = @[
                       [[RNGridMenuItem alloc] initWithImage:[UIImage imageNamed:@"ic_menu_circle_chat.png"] title:@"添加目的地"],
                       [[RNGridMenuItem alloc] initWithImage:[UIImage imageNamed:@"ic_menu_add_friend.png"] title:@"替我编排"],
                       [[RNGridMenuItem alloc] initWithImage:[UIImage imageNamed:@"ic_menu_circle_chat.png"] title:@"地图"],
                       [[RNGridMenuItem alloc] initWithImage:[UIImage imageNamed:@"ic_menu_add_friend.png"] title:@"删除"]
                       ];
    
    RNGridMenu *av = [[RNGridMenu alloc] initWithItems:[items subarrayWithRange:NSMakeRange(0, numberOfOptions)]];
    av.backgroundColor = [UIColor clearColor];
    av.delegate = self;
    [av showInViewController:self center:CGPointMake(self.view.bounds.size.width/2.f, self.view.bounds.size.height/2.f)];
}



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

#pragma mark - RNGridMenuDelegate
- (void)gridMenu:(RNGridMenu *)gridMenu willDismissWithSelectedItem:(RNGridMenuItem *)item atIndex:(NSInteger)itemIndex {
    //进入添加目的地界面
    if (itemIndex == 0) {
        AddPoiTableViewController *addPoiCtl = [[AddPoiTableViewController alloc] init];
        [self.rootViewController.navigationController pushViewController:addPoiCtl animated:YES];
    }
    //进入优化界面
    if (itemIndex == 1) {
    }
    //进入地图导航界面
    if (itemIndex == 2) {
    }
    //删除一天
    if (itemIndex == 3) {
    }
}


#pragma mark - UITableViewDataSource & Delegate

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 30;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 20;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 4;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 20)];
    UIView *spaceView = [[UIView alloc] initWithFrame:CGRectMake(5, 0, 1, 20)];
    view.backgroundColor = APP_PAGE_COLOR;
    if (!self.tableView.isEditing) {
        spaceView.backgroundColor = [UIColor lightGrayColor];
        [view addSubview:spaceView];
    }
    return view;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 30)];
    UILabel *headerTitle;
    if (self.tableView.isEditing) {
        headerTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, headerView.frame.size.width-60, 30)];
    } else {
        headerTitle = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, headerView.frame.size.width-80, 30)];
    }
    headerTitle.text = @"  D1 安顺";
    headerTitle.font = [UIFont boldSystemFontOfSize:17.0];
    headerTitle.backgroundColor = [UIColor whiteColor];
    [headerView addSubview:headerTitle];
    
    UIButton *moreBtn = [[UIButton alloc] initWithFrame:CGRectMake(headerView.frame.size.width-80, 0, 80, 30)];
    [moreBtn setBackgroundColor:[UIColor whiteColor]];
    [moreBtn setTitle:@"更多" forState:UIControlStateNormal];
    [moreBtn setTitleColor:APP_THEME_COLOR forState:UIControlStateNormal];
    moreBtn.tag = section;
    [moreBtn addTarget:self action:@selector(showMore:) forControlEvents:UIControlEventTouchUpInside];
    [headerView addSubview:moreBtn];
    
    UIView *horizontalSpaceView = [[UIView alloc] initWithFrame:CGRectMake(0, headerView.frame.size.height-1, headerView.frame.size.width, 1)];
    horizontalSpaceView.backgroundColor = APP_PAGE_COLOR;
    [headerView addSubview:horizontalSpaceView];
    if (!tableView.isEditing) {
        UIView *nodeView = [[UIView alloc] initWithFrame:CGRectMake(1, 11, 8, 8)];
        nodeView.backgroundColor = APP_THEME_COLOR;
        nodeView.layer.cornerRadius = 4.0;
        [headerView addSubview:nodeView];
        
        UIView *verticalSpaceView = [[UIView alloc] initWithFrame:CGRectMake(5, 19, 1, 11)];
        verticalSpaceView.backgroundColor = [UIColor lightGrayColor];
        [headerView addSubview:verticalSpaceView];
        
        if (section != 0) {
            UIView *verticalSpaceViewUp = [[UIView alloc] initWithFrame:CGRectMake(5, 0, 1, 11)];
            verticalSpaceViewUp.backgroundColor = [UIColor lightGrayColor];
            [headerView addSubview:verticalSpaceViewUp];
        }

    }
    
    return headerView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SpotsListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:spotsListReusableIdentifier forIndexPath:indexPath];
    cell.isEditing = self.tableView.isEditing;
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (NSIndexPath *)tableView:(UITableView *)tableView targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)sourceIndexPath toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath {
    
    return proposedDestinationIndexPath;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
    }
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
    
}

- (UITableViewCellEditingStyle) tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleDelete;
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

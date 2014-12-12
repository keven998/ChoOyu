//
//  FavoriteViewController.m
//  PeachTravel
//
//  Created by Luo Yong on 14/12/2.
//  Copyright (c) 2014年 com.aizou.www. All rights reserved.
//

#import "FavoriteViewController.h"
#import "FavoriteTableViewCell.h"
#import "DKCircleButton.h"
#import "AccountManager.h"
#import "Favorite.h"
#import "SpotDetailViewController.h"
#import "RestaurantDetailViewController.h"
#import "ShoppingDetailViewController.h"
#import "CityDetailTableViewController.h"

@interface FavoriteViewController ()
@property (strong, nonatomic) DKCircleButton *editBtn;
@property (nonatomic) BOOL isEditing;

@property (nonatomic, assign) NSInteger selectedIndex;
@property (nonatomic, strong) FavoriteTableViewCell *prototypeCell;

@property (nonatomic, strong) NSMutableArray *dataSource;
@property (nonatomic) NSUInteger currentPage;
@end

@implementation FavoriteViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBar.translucent = YES;
    UIBarButtonItem * backBtn = [[UIBarButtonItem alloc]initWithTitle:nil style:UIBarButtonItemStyleBordered target:self action:@selector(goBackToAllPets)];
    [backBtn setImage:[UIImage imageNamed:@"ic_navigation_back.png"]];
    self.navigationItem.leftBarButtonItem = backBtn;
    
    UIBarButtonItem *rightBtn = [[UIBarButtonItem alloc]initWithTitle:nil style:UIBarButtonItemStyleBordered target:self action:@selector(filtContents)];
    [rightBtn setImage:[UIImage imageNamed:@"ic_nav_filter_normal.png"]];
    self.navigationItem.rightBarButtonItem = rightBtn;
    
    _isEditing = NO;
    self.navigationItem.title = @"收藏夹";
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.view.backgroundColor = APP_PAGE_COLOR;
    [self.tableView registerNib:[UINib nibWithNibName:@"FavoriteTableViewCell" bundle:nil] forCellReuseIdentifier:@"favorite_cell"];
    
    _selectedIndex = -1;
    _currentPage = 0;
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(pullToRefreash:) forControlEvents:UIControlEventValueChanged];
    [self.refreshControl beginRefreshing];
    [self.refreshControl sendActionsForControlEvents:UIControlEventValueChanged];

//    [self loadDataWithPageIndex:_currentPage];

}

- (void)pullToRefreash:(id)sender {
//    UIRefreshControl *refreshControl = (UIRefreshControl *)sender;
    [self loadDataWithPageIndex:0];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController.view addSubview:self.editBtn];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.editBtn removeFromSuperview];
}

- (void)goBackToAllPets
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void) filtContents
{
    
}

- (NSMutableArray *)dataSource
{
    if (!_dataSource) {
        _dataSource = [[NSMutableArray alloc] init];
    }
    return _dataSource;
}

- (DKCircleButton *)editBtn
{
    if (!_editBtn) {
        _editBtn = [[DKCircleButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width-60, self.view.frame.size.height-70.0, 50, 50)];
        [_editBtn setImage:[UIImage imageNamed:@"ic_layer_edit.png"] forState:UIControlStateNormal];
        [_editBtn setImage:[UIImage imageNamed:@"ic_layer_edit_done.png"] forState:UIControlStateSelected];
        [_editBtn addTarget:self action:@selector(editMyGuides:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _editBtn;
}

/**
 *  点击编辑按钮
 *
 *  @param sender
 */
- (IBAction)editMyGuides:(id)sender
{
    UIButton *btn = sender;
    BOOL isEditing = btn.isSelected;
    _isEditing = !isEditing;
    btn.selected = !isEditing;
    [self.tableView reloadData];
}

/**
 *  点击删除攻略按钮
 *
 *  @param sender
 */
- (IBAction)deleteGuide:(UIButton *)sender
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"确定删除吗?" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    [alertView showAlertViewWithBlock:^(NSInteger buttonIndex) {
        if (buttonIndex == 1) {
            
        }
    }];
}


/**
 *  获取我的收藏列表
 */

- (void)loadDataWithPageIndex:(NSInteger)pageIndex
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [manager.requestSerializer setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    AccountManager *accountManager = [AccountManager shareAccountManager];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"%@", accountManager.account.userId] forHTTPHeaderField:@"UserId"];
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params safeSetObject:[NSNumber numberWithInt:15] forKey:@"pageSize"];
    [params safeSetObject:[NSNumber numberWithInt:pageIndex] forKey:@"page"];
    
    if (!self.refreshControl.isRefreshing) {
        [SVProgressHUD show];
    }
    [manager GET:API_GET_FAVORITES parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"%@", responseObject);
        [SVProgressHUD dismiss];
        NSInteger code = [[responseObject objectForKey:@"code"] integerValue];
        if (code == 0) {
            [self bindDataToView:responseObject];
            _currentPage = pageIndex;
        } else {
            [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"%@",[[responseObject objectForKey:@"err"] objectForKey:@"message"]]];
        }
        [self.refreshControl endRefreshing];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@", error);
        [SVProgressHUD dismiss];
        [self.refreshControl endRefreshing];
    }];
    
}

- (void) bindDataToView:(id) responseObject {
    NSArray *datas = [responseObject objectForKey:@"result"];
    if (datas.count == 0) {
        if (_dataSource.count == 0) {
            [self showHint:@"No收藏"];
        } else {
            [self showHint:@"已取完所有内容啦"];
        }
        return;
    }
    if (self.refreshControl.isRefreshing) {
        [_dataSource removeAllObjects];
    }
    for (NSDictionary *favoriteDic in datas) {
        Favorite *favorite = [[Favorite alloc] initWithJson:favoriteDic];
        [self.dataSource addObject:favorite];
    }
    
    [self.tableView reloadData];
}


#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    FavoriteTableViewCell *cell = [tv dequeueReusableCellWithIdentifier:@"favorite_cell" forIndexPath:indexPath];
    cell.isEditing = _isEditing;
    [cell.deleteBtn addTarget:self action:@selector(deleteGuide:) forControlEvents:UIControlEventTouchUpInside];
    Favorite *item = [_dataSource objectAtIndex:indexPath.row];
    
    if (item.images != nil && item.images.count > 0) {
        [cell.standardImageView sd_setImageWithURL:[NSURL URLWithString:((TaoziImage *)[item.images objectAtIndex:0]).imageUrl]];
    } else {
        cell.standardImageView.image = [UIImage imageNamed:@"country.jpg"];
    }
    cell.contentType.text = [item getTypeDesc];
    cell.contentTitle.text = item.zhName;
    cell.contentLocation.text = item.locality.zhName;
    cell.contentTypeFlag.image = [UIImage imageNamed:[item getTypeFlagName]];
    [cell.contentDescExpandView setTitle:item.desc forState:UIControlStateNormal];
    
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:item.createTime/1000];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    cell.timeLabel.text = [dateFormatter stringFromDate:date];
    
    
    if (indexPath.row != _selectedIndex) {
        cell.contentDescExpandView.selected = NO;
    }
    
    [cell.contentDescExpandView addTarget:self action:@selector(expandDesc:) forControlEvents:UIControlEventTouchUpInside];
    
    return cell;
}

- (IBAction)expandDesc:(id)sender {
    UIButton *btn = sender;
    CGPoint viewPos = [btn convertPoint:CGPointZero toView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:viewPos];
    
//    if (_selectedIndex != -1 && _selectedIndex != indexPath.row) {
//        NSIndexPath *pi = [NSIndexPath indexPathForRow:_selectedIndex inSection:0];
//        FavoriteTableViewCell *pc = (FavoriteTableViewCell *)[self.tableView cellForRowAtIndexPath:pi];
//        pc.contentDescExpandView.selected = NO;
//    }
    
    if (!btn.isSelected) {
        _selectedIndex = indexPath.row;
        btn.selected = YES;
    } else {
        _selectedIndex = -1;
        btn.selected = NO;
    }
    
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tv heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == _selectedIndex) {
        NSString *text = ((Favorite *)[_dataSource objectAtIndex:indexPath.row]).desc;
        NSDictionary *attributes = @{NSFontAttributeName: [UIFont systemFontOfSize:13.0]};
        CGRect rect = [text boundingRectWithSize:CGSizeMake(self.tableView.bounds.size.width, MAXFLOAT)
                                              options:NSStringDrawingUsesLineFragmentOrigin
                                           attributes:attributes
                                              context:nil];
        return 210 + rect.size.height - 34.0 + 20.0;
    }
    return 210.;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    Favorite *item = [_dataSource objectAtIndex:indexPath.row];
    NSString *type = item.type;
    if ([type isEqualToString:@"vs"]) {
        [self.navigationController pushViewController:[[SpotDetailViewController alloc] init] animated:YES];
    } else if ([type isEqualToString:@"hotel"]) {
//        [self.navigationController pushViewController:[[SpotDetailViewController alloc] init] animated:YES];
#warning no detailpage
    } else if ([type isEqualToString:@"restaurant"]) {
        [self.navigationController pushViewController:[[RestaurantDetailViewController alloc] init] animated:YES];
    } else if ([type isEqualToString:@"shopping"]) {
        [self.navigationController pushViewController:[[ShoppingDetailViewController alloc] init] animated:YES];
    } else if ([type isEqualToString:@"travelNote"]) {
#warning no detailpage
    } else {
        [self.navigationController pushViewController:[[CityDetailTableViewController alloc] init] animated:YES];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
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

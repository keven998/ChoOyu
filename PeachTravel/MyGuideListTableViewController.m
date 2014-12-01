//
//  MyGuideListTableViewController.m
//  PeachTravel
//
//  Created by liangpengshuai on 11/28/14.
//  Copyright (c) 2014 com.aizou.www. All rights reserved.
//

#import "MyGuideListTableViewController.h"
#import "MyGuidesTableViewCell.h"
#import "DKCircleButton/DKCircleButton.h"
#import "AccountManager.h"
#import "MyGuideSummary.h"
#import "TripDetailRootViewController.h"
#import "ConfirmRouteViewController.h"

@interface MyGuideListTableViewController () <UITableViewDataSource, UITableViewDelegate, UIGestureRecognizerDelegate>

@property (strong, nonatomic) DKCircleButton *editBtn;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic) BOOL isEditing;

@property (nonatomic) NSUInteger currentPage;

@property (nonatomic, strong) NSMutableArray *dataSource;

@property (nonatomic, strong) ConfirmRouteViewController *confirmRouteViewController;

@property (nonatomic, strong) UITapGestureRecognizer *tapRecognizer;

@end

@implementation MyGuideListTableViewController

static NSString *reusableCell = @"myGuidesCell";

- (void)viewDidLoad {
    [super viewDidLoad];
    _tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissPopup:)];
    _tapRecognizer.numberOfTapsRequired = 1;
    _tapRecognizer.delegate = self;
    self.view.backgroundColor = APP_PAGE_COLOR;
    self.navigationItem.title = @"我的攻略";
    _isEditing = NO;
    [self.view addSubview:self.tableView];
    [self.view addSubview:self.editBtn];
    _currentPage = 0;
    [self loadDataWithPageIndex:_currentPage];
}

#pragma mark - setter & getter

- (UITableView *)tableView
{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:self.view.frame];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.backgroundColor = APP_PAGE_COLOR;
        [_tableView registerNib:[UINib nibWithNibName:@"MyGuidesTableViewCell" bundle:nil] forCellReuseIdentifier:reusableCell];

    }
    return _tableView;
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
        _editBtn = [[DKCircleButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width-60, self.view.frame.size.height-100, 40, 40)];
        _editBtn.backgroundColor = APP_THEME_COLOR;
        _editBtn.titleLabel.font = [UIFont systemFontOfSize:13.0];
        [_editBtn setTitle:@"编辑" forState:UIControlStateNormal];
        [_editBtn addTarget:self action:@selector(editMyGuides:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _editBtn;
}

#pragma mark - IBAction Methods

/**
 *  点击编辑按钮
 *
 *  @param sender
 */
- (IBAction)editMyGuides:(id)sender
{
    _isEditing = !_isEditing;
    [self.tableView reloadData];
    if (_isEditing) {
        [_editBtn setTitle:@"完成" forState:UIControlStateNormal];
    } else {
        [_editBtn setTitle:@"编辑" forState:UIControlStateNormal];
    }
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
            MyGuideSummary *guideSummary = [self.dataSource objectAtIndex:sender.tag];
            [self deleteUserGuide:guideSummary];
        }
    }];
}

/**
 *  点击路线列表里的编辑标题按钮
 *
 *  @param sender
 */
- (IBAction)edit:(UIButton *)sender
{
    _confirmRouteViewController = [[ConfirmRouteViewController alloc] init];
    MyGuideSummary *guideSummary = [self.dataSource objectAtIndex:sender.tag];
    [self.view addGestureRecognizer:_tapRecognizer];
    [_confirmRouteViewController.confirmRouteTitle addTarget:self action:@selector(willConfirmRouteTitle:) forControlEvents:UIControlEventTouchUpInside];
    [self presentPopupViewController:_confirmRouteViewController atHeight:70.0 animated:YES completion:^(void) {
    }];
    _confirmRouteViewController.routeTitle.text = guideSummary.title;
    _confirmRouteViewController.confirmRouteTitle.tag = sender.tag;
    [_confirmRouteViewController.confirmRouteTitle addTarget:self action:@selector(willConfirmRouteTitle:) forControlEvents:UIControlEventTouchUpInside];

}

/**
 *  点击修改标题的弹出框的确定按钮
 *
 *  @param sender
 */
- (IBAction)willConfirmRouteTitle:(UIButton *)sender
{
    MyGuideSummary *guideSummary = [self.dataSource objectAtIndex:sender.tag];
    if ([guideSummary.title isEqualToString:_confirmRouteViewController.routeTitle.text]) {
        [SVProgressHUD showSuccessWithStatus:@"修改成功"];
        return;
    }
    [self editGuideTitle:guideSummary andTitle:_confirmRouteViewController.routeTitle.text atIndex:sender.tag];
}

/**
 *  弹出修改标题后点击背景，消除修改标题弹出框
 *
 *  @param sender
 */
- (IBAction)dismissPopup:(id)sender
{
    if (self.popupViewController != nil) {
        if ([_confirmRouteViewController.routeTitle isFirstResponder]) {
            [_confirmRouteViewController.routeTitle resignFirstResponder];
        }
        [self dismissPopupViewControllerAnimated:YES completion:^{
            [self.view removeGestureRecognizer:_tapRecognizer];
        }];
    }
}

#pragma mark - Private Methods

/**
 *  删除我的攻略
 *
 *  @param guideSummary
 */
- (void)deleteUserGuide:(MyGuideSummary *)guideSummary
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [manager.requestSerializer setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    AccountManager *accountManager = [AccountManager shareAccountManager];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"%@", accountManager.account.userId] forHTTPHeaderField:@"UserId"];

    
    NSString *urlStr = [NSString stringWithFormat:@"%@%@",API_DELETE_GUIDE ,guideSummary.guideId];
    
    [SVProgressHUD show];
    
    [manager DELETE:urlStr parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"%@", responseObject);
        NSInteger code = [[responseObject objectForKey:@"code"] integerValue];
        if (code == 0) {
            [SVProgressHUD showSuccessWithStatus:@"删除成功"];
            NSInteger index = [self.dataSource indexOfObject:guideSummary];
            [self.dataSource removeObject:guideSummary];
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
            [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        } else {
            [SVProgressHUD showErrorWithStatus:@"删除失败"];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@", error);
        [SVProgressHUD showErrorWithStatus:@"删除失败"];
    }];
    
}

/**
 *  修改攻略名称
 *
 *  @param guideSummary 被修改的攻略
 *  @param title        新的标题
 */
- (void)editGuideTitle:(MyGuideSummary *)guideSummary andTitle:(NSString *)title atIndex:(NSInteger)index
{
    AccountManager *accountManager = [AccountManager shareAccountManager];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [SVProgressHUD show];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [manager.requestSerializer setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
//    [manager.requestSerializer setValue:[NSString stringWithFormat:@"%@", accountManager.account.userId] forHTTPHeaderField:@"UserId"];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"100035"] forHTTPHeaderField:@"UserId"];
    
    NSString *requestUrl = [NSString stringWithFormat:@"%@%@",API_SAVE_TRIPINFO, guideSummary.guideId];
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:title forKey:@"title"];

    [manager POST:requestUrl parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"%@", responseObject);
        NSInteger code = [[responseObject objectForKey:@"code"] integerValue];
        if (code == 0) {
            [SVProgressHUD showSuccessWithStatus:@"修改成功"];
            guideSummary.title = title;
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
            [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];

        } else {
            
            [SVProgressHUD showErrorWithStatus:@"修改失败"];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [SVProgressHUD showErrorWithStatus:@"修改失败"];
    }];

}

/**
 *  获取我的攻略列表
 */

- (void)loadDataWithPageIndex:(NSInteger)pageIndex
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [manager.requestSerializer setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    AccountManager *accountManager = [AccountManager shareAccountManager];
//    [manager.requestSerializer setValue:[NSString stringWithFormat:@"%@", accountManager.account.userId] forHTTPHeaderField:@"UserId"];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"100035"] forHTTPHeaderField:@"UserId"];

    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params safeSetObject:[NSNumber numberWithInt:10] forKey:@"pageSize"];
    [params safeSetObject:[NSNumber numberWithInt:pageIndex] forKey:@"page"];
    
    [SVProgressHUD show];
    
    //获取我的攻略列表
    [manager GET:API_GET_GUIDELIST parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"%@", responseObject);
        [SVProgressHUD dismiss];
        NSInteger code = [[responseObject objectForKey:@"code"] integerValue];
        if (code == 0) {
            for (NSDictionary *guideSummaryDic in [responseObject objectForKey:@"result"]) {
                MyGuideSummary *guideSummary = [[MyGuideSummary alloc] initWithJson:guideSummaryDic];
                [self.dataSource addObject:guideSummary];
                
            }
            [self.tableView reloadData];
            _currentPage ++;
        } else {
            [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"%@",[[responseObject objectForKey:@"err"] objectForKey:@"message"]]];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@", error);
        [SVProgressHUD dismiss];
    }];
    
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return self.dataSource.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 216;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MyGuidesTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reusableCell forIndexPath:indexPath];
    cell.deleteBtn.tag = indexPath.row;
    cell.editTitleBtn.tag = indexPath.row;
    [cell.deleteBtn addTarget:self action:@selector(deleteGuide:) forControlEvents:UIControlEventTouchUpInside];
    [cell.editTitleBtn addTarget:self action:@selector(edit:) forControlEvents:UIControlEventTouchUpInside];

    cell.isEditing = self.isEditing;
    cell.guideSummary = [self.dataSource objectAtIndex:indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    MyGuideSummary *guideSummary = [self.dataSource objectAtIndex:indexPath.row];
    TripDetailRootViewController *tripDetailRootCtl = [[TripDetailRootViewController alloc] init];
    tripDetailRootCtl.isMakeNewTrip = NO;
    tripDetailRootCtl.tripId = guideSummary.guideId;
    [self.navigationController pushViewController:tripDetailRootCtl animated:YES];
    
}



















@end

//
//  MyOrderListViewController.h.m
//  PeachTravel
//
//  Created by liangpengshuai on 11/18/15.
//  Copyright © 2015 com.aizou.www. All rights reserved.
//

#import "MyOrderListViewController.h"
#import "MyOrderTableViewCell.h"
#import "OrderDetailViewController.h"
#import "MJRefresh.h"
#import "OrderManager.h"
#import "ChatViewController.h"
#import "ChatGroupSettingViewController.h"
#import "ChatSettingViewController.h"
#import "REFrostedViewController.h"
#import "SelectPayPlatformViewController.h"

#define pageCount 15    //每页加载数量


@interface MyOrderListViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) NSArray<OrderDetailModel *> *dataSource;

@end

@implementation MyOrderListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.rowHeight = 160.0;
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.backgroundColor = APP_PAGE_COLOR;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView registerNib:[UINib nibWithNibName:@"MyOrderTableViewCell" bundle:nil] forCellReuseIdentifier:@"myOrderCell"];
    
    MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(refreshData)];
    self.tableView.header = header;
    header.lastUpdatedTimeLabel.hidden = YES;
    [header beginRefreshing];
    
    self.tableView.footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreData)];
}

- (void)setDataSource:(NSArray *)dataSource
{
    _dataSource = dataSource;
    [self.tableView reloadData];
}

- (void)refreshData
{
    NSMutableArray *statusArray = [[NSMutableArray alloc] init];
    for (NSNumber *status in _orderTypes) {
        NSString *orderServerStatus = [OrderManager orderServerStatusWithLocalStatus:[status integerValue]];
        [statusArray addObject:orderServerStatus];
    }
    [OrderManager asyncLoadOrdersFromServerOfUser:[AccountManager shareAccountManager].account.userId orderType:statusArray startIndex:0 count:pageCount completionBlock:^(BOOL isSuccess, NSArray<OrderDetailModel *> *orderList) {
        if (isSuccess) {
            _dataSource = orderList;
            [self.tableView reloadData];
            [_tableView.footer resetNoMoreData];
        }
        [self.tableView.header endRefreshing];
    }];
}

- (void)loadMoreData
{
    NSMutableArray *statusArray = [[NSMutableArray alloc] init];
    for (NSNumber *status in _orderTypes) {
        NSString *orderServerStatus = [OrderManager orderServerStatusWithLocalStatus:[status integerValue]];
        [statusArray addObject:orderServerStatus];
    }
    [OrderManager asyncLoadOrdersFromServerOfUser:[AccountManager shareAccountManager].account.userId orderType:statusArray startIndex:_dataSource.count count:pageCount completionBlock:^(BOOL isSuccess, NSArray<OrderDetailModel *> *orderList) {
        [self.tableView.footer endRefreshing];
        if (isSuccess) {
            NSMutableArray *array = [[NSMutableArray alloc] initWithArray:_dataSource];
            [array addObjectsFromArray:orderList];
            _dataSource = array;
            [self.tableView reloadData];
            if (orderList.count < pageCount) {
                [_tableView.footer endRefreshingWithNoMoreData];
            }
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


- (IBAction)contactBusiness:(UIButton *)sender
{
    OrderDetailModel *order = _dataSource[sender.tag];
    
    IMClientManager *clientManager = [IMClientManager shareInstance];
    ChatConversation *conversation = [clientManager.conversationManager getConversationWithChatterId:order.goods.store.business.userId chatType:IMChatTypeIMChatSingleType];
    ChatViewController *chatController = [[ChatViewController alloc] initWithConversation:conversation];
   
    chatController.chatterName = order.goods.store.business.nickName;
    
    ChatSettingViewController *menuViewController = [[ChatSettingViewController alloc] init];
    menuViewController.currentConversation= conversation;
    menuViewController.chatterId = conversation.chatterId;
    
    REFrostedViewController *frostedViewController = [[REFrostedViewController alloc] initWithContentViewController:chatController menuViewController:menuViewController];
    menuViewController.containerCtl = frostedViewController;
    
    frostedViewController.hidesBottomBarWhenPushed = YES;
    frostedViewController.direction = REFrostedViewControllerDirectionRight;
    frostedViewController.liveBlurBackgroundStyle = REFrostedViewControllerLiveBackgroundStyleLight;
    frostedViewController.liveBlur = YES;
    frostedViewController.limitMenuViewSize = YES;
    chatController.backBlock = ^{
        [frostedViewController.navigationController popViewControllerAnimated:YES];
    };
    
    [self.navigationController pushViewController:frostedViewController animated:YES];

}

- (void)payOrder:(UIButton *)sender
{
    SelectPayPlatformViewController *ctl = [[SelectPayPlatformViewController alloc] init];
    OrderDetailModel *orderDetail = _dataSource[sender.tag];
    ctl.orderDetail = orderDetail;
    [self.navigationController pushViewController:ctl animated:YES];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _dataSource.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.01;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0.01;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    OrderDetailModel *order = [_dataSource objectAtIndex:indexPath.row];
    MyOrderTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"myOrderCell" forIndexPath:indexPath];
    cell.orderDetail = order;
    cell.contactBusiness.tag = indexPath.row;
    cell.payOrderBtn.tag = indexPath.row;
    [cell.payOrderBtn addTarget:self action:@selector(payOrder:) forControlEvents:UIControlEventTouchUpInside];
    [cell.contactBusiness addTarget:self action:@selector(contactBusiness:) forControlEvents:UIControlEventTouchUpInside];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    OrderDetailViewController *ctl = [[OrderDetailViewController alloc] init];
    ctl.orderDetail = [_dataSource objectAtIndex:indexPath.row];
    ctl.orderId = [_dataSource objectAtIndex:indexPath.row].orderId;
    [self.navigationController pushViewController:ctl animated:YES];
}

@end

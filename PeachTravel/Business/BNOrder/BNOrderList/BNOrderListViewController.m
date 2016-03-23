//
//  BNOrderListViewController.m
//  PeachTravel
//
//  Created by liangpengshuai on 3/9/16.
//  Copyright © 2016 com.aizou.www. All rights reserved.
//

#import "BNOrderListViewController.h"
#import "BNOrderListTableViewCell.h"
#import "OrderManager+BNOrderManager.h"
#import "PeachTravel-swift.h"
#import "ChatViewController.h"
#import "ChatSettingViewController.h"
#import "REFrostedViewController.h"
#import "BNRefundMoneyWithSoldOutViewController.h"
#import "BNDeliverGoodsDetailViewController.h"
#import "BNAgreeRefundMoneyViewController.h"
#import "BNRefuseRefundMoneyViewController.h"
#import "BNOrderDetailViewController.h"
#import "MJRefresh.h"

#define pageCount 15    //每页加载数量

@interface BNOrderListViewController () <UITableViewDataSource, UITableViewDelegate, BNOrderListTableViewCellDelegate, UIActionSheetDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, strong) NSMutableArray<BNOrderDetailModel *> *dataSource;

@property (nonatomic, strong) NSArray *cancelOrderReason;

@end

@implementation BNOrderListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [_tableView registerNib:[UINib nibWithNibName:@"BNOrderListTableViewCell" bundle:nil] forCellReuseIdentifier:@"BNOrderListTableViewCell"];
    
    _cancelOrderReason = @[@"未及时付款", @"买家不想买", @"买家信息填写有误，重拍", @"恶意买家/同行捣乱", @"缺货", @"买家拍错了", @"其它原因"];
    self.tableView.footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreData)];
    [self.tableView.header beginRefreshing];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    NSMutableArray *statusArray = [[NSMutableArray alloc] init];
    for (NSNumber *status in _orderTypes) {
        NSString *orderServerStatus = [OrderManager orderServerStatusWithLocalStatus:[status integerValue]];
        [statusArray addObject:orderServerStatus];
    }
    
    if (![self.tableView.header isRefreshing]) {
        [self refreshData];
    }
}

- (void)refreshData
{
    NSMutableArray *statusArray = [[NSMutableArray alloc] init];
    for (NSNumber *status in _orderTypes) {
        NSString *orderServerStatus = [OrderManager orderServerStatusWithLocalStatus:[status integerValue]];
        [statusArray addObject:orderServerStatus];
    }
    NSInteger orderCount = _dataSource.count ? _dataSource.count : pageCount;
    [OrderManager asyncLoadOrdersFromServerOfStore:[AccountManager shareAccountManager].account.userId orderType:statusArray startIndex:0 count:orderCount completionBlock:^(BOOL isSuccess, NSArray<OrderDetailModel *> *orderList) {
        if (isSuccess) {
            _dataSource = [orderList mutableCopy];
            [_tableView reloadData];
            if (orderList.count < pageCount) {
                [_tableView.footer endRefreshingWithNoMoreData];
            } else {
                [_tableView.footer resetNoMoreData];
            }
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
    [OrderManager asyncLoadOrdersFromServerOfStore:[AccountManager shareAccountManager].account.userId orderType:statusArray startIndex:_dataSource.count count:pageCount completionBlock:^(BOOL isSuccess, NSArray<OrderDetailModel *> *orderList) {
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

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 5;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return CGFLOAT_MIN;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return _dataSource.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 180;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    BNOrderListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BNOrderListTableViewCell" forIndexPath:indexPath];
    cell.orderDetail = [_dataSource objectAtIndex:indexPath.section];
    cell.delegate = self;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    BNOrderDetailViewController *ctl = [[BNOrderDetailViewController alloc] init];
    ctl.orderId = [_dataSource objectAtIndex:indexPath.section].orderId;
    [self.navigationController pushViewController:ctl animated:YES];
}

#pragma mark - BNOrderListTableViewCellDelegate

- (void)chatWithUser:(NSInteger)userId
{
    IMClientManager *clientManager = [IMClientManager shareInstance];
    ChatConversation *conversation = [clientManager.conversationManager getConversationWithChatterId:userId chatType:IMChatTypeIMChatSingleType];
    ChatViewController *chatController = [[ChatViewController alloc] initWithConversation:conversation];
    
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

//同意退款
- (void)agreeRefundMoney:(OrderDetailModel *)orderDetail
{
    BNAgreeRefundMoneyViewController *ctl = [[BNAgreeRefundMoneyViewController alloc] init];
    ctl.orderId = orderDetail.orderId;
    [self.navigationController pushViewController:ctl animated:YES];
}

//拒绝退款
- (void)refuseRefundMoney:(OrderDetailModel *)orderDetail
{
    BNRefuseRefundMoneyViewController *ctl = [[BNRefuseRefundMoneyViewController alloc] init];
    ctl.orderId = orderDetail.orderId;
    [self.navigationController pushViewController:ctl animated:YES];
}

//发货
- (void)deliveryGoods:(OrderDetailModel *)orderDetail
{
    BNDeliverGoodsDetailViewController *ctl = [[BNDeliverGoodsDetailViewController alloc] init];
    ctl.orderId = orderDetail.orderId;
    [self.navigationController pushViewController:ctl animated:YES];
}

//关闭交易
- (void)closeOrder:(OrderDetailModel *)orderDetail
{
    NSInteger index = [_dataSource indexOfObject:(BNOrderDetailModel *)orderDetail];
    UIActionSheet *acctionSheet = [[UIActionSheet alloc] initWithTitle:@"选择关闭交易理由" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"未及时付款", @"买家不想买", @"买家信息填写有误，重拍", @"恶意买家/同行捣乱", @"缺货", @"买家拍错了", @"其它原因", nil];
    acctionSheet.tag = index;
    [acctionSheet showInView:self.view];
}

//缺货退款
- (void)refundMoneyWithSoldOut:(OrderDetailModel *)orderDetail
{
    BNRefundMoneyWithSoldOutViewController *ctl = [[BNRefundMoneyWithSoldOutViewController alloc] init];
    ctl.orderId = orderDetail.orderId;
    [self.navigationController pushViewController:ctl animated:YES];
}

#pragma mark - UIActionSheetDeleage

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex >= _cancelOrderReason.count) {
        return;
    }
    NSString *content = [_cancelOrderReason objectAtIndex:buttonIndex];
    OrderDetailModel *detail = [_dataSource objectAtIndex:actionSheet.tag];
    [OrderManager asyncBNCancelOrderWithOrderId:[_dataSource objectAtIndex:actionSheet.tag].orderId reason:content leaveMessage:nil completionBlock:^(BOOL isSuccess, NSString *errorStr) {
        if (isSuccess) {
            [SVProgressHUD showHint:@"订单关闭成功"];
            detail.orderStatus = kOrderCanceled;
            [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:actionSheet.tag]] withRowAnimation:UITableViewRowAnimationNone];
        } else {
            [SVProgressHUD showHint:@"订单关闭失败"];
        }
    }];
}

@end

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

@interface BNOrderListViewController () <UITableViewDataSource, UITableViewDelegate, BNOrderListTableViewCellDelegate, UIActionSheetDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, strong) NSMutableArray<BNOrderDetailModel *> *dataSource;

@end

@implementation BNOrderListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [_tableView registerNib:[UINib nibWithNibName:@"BNOrderListTableViewCell" bundle:nil] forCellReuseIdentifier:@"BNOrderListTableViewCell"];
    
    NSMutableArray *statusArray = [[NSMutableArray alloc] init];
    for (NSNumber *status in _orderTypes) {
        NSString *orderServerStatus = [OrderManager orderServerStatusWithLocalStatus:[status integerValue]];
        [statusArray addObject:orderServerStatus];
    }

    [OrderManager asyncLoadOrdersFromServerOfStore:[AccountManager shareAccountManager].account.userId orderType:statusArray startIndex:0 count:15 completionBlock:^(BOOL isSuccess, NSArray<OrderDetailModel *> *orderList) {
        if (isSuccess) {
            _dataSource = [orderList mutableCopy];
            [_tableView reloadData];
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
    UIActionSheet *acctionSheet = [[UIActionSheet alloc] initWithTitle:@"选择关闭交易理由" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"未及时付款", @"买家不想买", @"买家信息填写有误，重拍", @"恶意买家/同行捣乱", @"缺货", @"买家拍错了", @"其它原因", nil];
    [acctionSheet showInView:self.view];
}

//缺货退款
- (void)refundMoneyWithSoldOut:(OrderDetailModel *)orderDetail
{
    BNRefundMoneyWithSoldOutViewController *ctl = [[BNRefundMoneyWithSoldOutViewController alloc] init];
    ctl.orderId = orderDetail.orderId;
    [self.navigationController pushViewController:ctl animated:YES];
}

@end

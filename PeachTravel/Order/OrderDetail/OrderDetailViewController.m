//
//  OrderDetailViewController.m
//  PeachTravel
//
//  Created by liangpengshuai on 11/13/15.
//  Copyright © 2015 com.aizou.www. All rights reserved.
//

#import "OrderDetailViewController.h"
#import "OrderDetailStoreInfoTableViewCell.h"
#import "OrderDetailContentTableViewCell.h"
#import "OrderDetailTravelerTableViewCell.h"
#import "OrderDetailContactTableViewCell.h"
#import "OrderDetailStatusTableViewCell.h"
#import "TravelerListViewController.h"
#import "SelectPayPlatformViewController.h"
#import "AskRefundMoneyViewController.h"
#import "GoodsDetailViewController.h"
#import "OrderManager.h"

@interface OrderDetailViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UIView *toolBar;
@end

@implementation OrderDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"订单详情";
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.separatorColor = COLOR_LINE;
    [_tableView registerNib:[UINib nibWithNibName:@"OrderDetailStatusTableViewCell" bundle:nil] forCellReuseIdentifier:@"orderDetailStatusCell"];

    [_tableView registerNib:[UINib nibWithNibName:@"OrderDetailContentTableViewCell" bundle:nil] forCellReuseIdentifier:@"orderDetailContentCell"];
    [_tableView registerNib:[UINib nibWithNibName:@"OrderDetailStoreInfoTableViewCell" bundle:nil] forCellReuseIdentifier:@"orderDetailStoreCell"];
    [_tableView registerNib:[UINib nibWithNibName:@"OrderDetailTravelerTableViewCell" bundle:nil] forCellReuseIdentifier:@"orderDetailTravelerCell"];
    [_tableView registerNib:[UINib nibWithNibName:@"OrderDetailContactTableViewCell" bundle:nil] forCellReuseIdentifier:@"orderDetailContactCell"];
    
    _tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _tableView.bounds.size.width, 55)];
    [OrderManager asyncLoadOrderDetailWithOrderId:1448694682614 completionBlock:^(BOOL isSuccess, OrderDetailModel *orderDetail) {
        _orderDetail = orderDetail;
        [self.tableView reloadData];
    }];

    [self setupToolBar];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)setupToolBar
{
    if (_toolBar.superview) {
        [_toolBar removeFromSuperview];
    }
    if (_orderDetail.orderStatus == kOrderRefunding) {
        return;
    }
    _toolBar = [[UIView alloc] initWithFrame:CGRectMake(0, kWindowHeight-55, kWindowWidth, 55)];
    _toolBar.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:_toolBar];
    
    UIView *spaceView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _toolBar.bounds.size.width, 0.5)];
    spaceView.backgroundColor = COLOR_LINE;
    [_toolBar addSubview:spaceView];

    if (_orderDetail.orderStatus == kOrderCanceled || _orderDetail.orderStatus == kOrderRefunded || _orderDetail.orderStatus == kOrderCompletion) {
        UIButton *orderAgainBtn = [[UIButton alloc] initWithFrame:_toolBar.bounds];
        [orderAgainBtn setTitle:@"再次预订" forState:UIControlStateNormal];
        [orderAgainBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [orderAgainBtn setBackgroundImage:[ConvertMethods createImageWithColor:UIColorFromRGB(0xFC4E27)] forState:UIControlStateNormal];
        orderAgainBtn.titleLabel.font = [UIFont systemFontOfSize:17];
        [_toolBar addSubview:orderAgainBtn];
        
    } else if (_orderDetail.orderStatus == kOrderInProgress) {
        UIButton *requestRefundMoneyBtn = [[UIButton alloc] initWithFrame:_toolBar.bounds];
        [requestRefundMoneyBtn setTitle:@"申请退款" forState:UIControlStateNormal];
        [requestRefundMoneyBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [requestRefundMoneyBtn setBackgroundImage:[ConvertMethods createImageWithColor:UIColorFromRGB(0xFC4E27)] forState:UIControlStateNormal];
        requestRefundMoneyBtn.titleLabel.font = [UIFont systemFontOfSize:17];
        [requestRefundMoneyBtn addTarget:self action:@selector(requestRefundMoney:) forControlEvents:UIControlEventTouchUpInside];
        [_toolBar addSubview:requestRefundMoneyBtn];
        
    } else if (_orderDetail.orderStatus == kOrderWaitPay) {
        UIButton *cancelOrderBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, _toolBar.bounds.size.width/2, _toolBar.bounds.size.height)];
        [cancelOrderBtn setTitle:@"取消订单" forState:UIControlStateNormal];
        [cancelOrderBtn setTitleColor:COLOR_TEXT_II forState:UIControlStateNormal];
        cancelOrderBtn.titleLabel.font = [UIFont systemFontOfSize:17];
        [_toolBar addSubview:cancelOrderBtn];
        
        UIButton *payOrderBtn = [[UIButton alloc] initWithFrame:CGRectMake(_toolBar.bounds.size.width/2, 0, _toolBar.bounds.size.width/2, _toolBar.bounds.size.height)];
        [payOrderBtn setTitle:@"立即支付" forState:UIControlStateNormal];
        [payOrderBtn setTitleColor: [UIColor whiteColor] forState:UIControlStateNormal];
        [payOrderBtn setBackgroundImage:[ConvertMethods createImageWithColor:UIColorFromRGB(0xFC4E27)] forState:UIControlStateNormal];
        payOrderBtn.titleLabel.font = [UIFont systemFontOfSize:17];
        [payOrderBtn addTarget:self action:@selector(payOrder:) forControlEvents:UIControlEventTouchUpInside];
        [_toolBar addSubview:payOrderBtn];
    }
}

- (void)payOrder:(UIButton *)sender
{
    SelectPayPlatformViewController *ctl = [[SelectPayPlatformViewController alloc] init];
    [self.navigationController pushViewController:ctl animated:YES];
}

- (void)requestRefundMoney:(UIButton *)sender
{
    AskRefundMoneyViewController *ctl = [[AskRefundMoneyViewController alloc] init];
    [self.navigationController pushViewController:ctl animated:YES];
}

- (void)goodsDetailAction:(UIButton *)sender
{
    GoodsDetailViewController *ctl = [[GoodsDetailViewController alloc] init];
    ctl.goodsId = _orderDetail.goods.goodsId;
    [self.navigationController pushViewController:ctl animated:YES];
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 5;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 10;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 10;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1) {
        return [OrderDetailContentTableViewCell heightOfCell];
    } else if (indexPath.section == 4) {
        return [OrderDetailContactTableViewCell heightOfCellWithContactInfo:_orderDetail.orderContact andLeaveMessage:_orderDetail.leaveMessage];
    }
    return 50;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        OrderDetailStatusTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"orderDetailStatusCell" forIndexPath:indexPath];
        cell.statusLabel.text = _orderDetail.orderStatusDesc;
        return cell;
        
    } else if (indexPath.section == 1) {
        OrderDetailContentTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"orderDetailContentCell" forIndexPath:indexPath];
        if (_orderDetail.goods.goodsName) {
            NSMutableAttributedString *string= [[NSMutableAttributedString alloc] initWithString:_orderDetail.goods.goodsName];
            [string addAttributes:@{
                                    NSForegroundColorAttributeName: APP_THEME_COLOR,
                                    NSUnderlineStyleAttributeName: @(NSUnderlineStyleSingle),
                                    } range:NSMakeRange(0, _orderDetail.goods.goodsName.length)];
            
            [cell.goodsNameBtn setAttributedTitle:string forState:UIControlStateNormal];
        }
        
        [cell.goodsNameBtn addTarget:self action:@selector(goodsDetailAction:) forControlEvents:UIControlEventTouchUpInside];
        cell.orderNumberLabel.text = [NSString stringWithFormat:@"%ld", _orderDetail.orderId];
        cell.dateLabel.text = _orderDetail.useDateStr;
        cell.countLabel.text = [NSString stringWithFormat:@"%ld", _orderDetail.count];
        cell.priceLabel.text = [NSString stringWithFormat:@"%d", (int)_orderDetail.totalPrice];
        return cell;
        
    } else if (indexPath.section == 2) {
        OrderDetailStoreInfoTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"orderDetailStoreCell" forIndexPath:indexPath];
        cell.storeNameLabel.text = _orderDetail.goods.store.storeName;
        return cell;
        
    } else if (indexPath.section == 3) {
        OrderDetailTravelerTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"orderDetailTravelerCell" forIndexPath:indexPath];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.travelerCountLabel.text = [NSString stringWithFormat:@"(%ld)", _orderDetail.travelerList.count];
        return cell;
        
    } else {
        OrderDetailContactTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"orderDetailContactCell" forIndexPath:indexPath];
        cell.contact = _orderDetail.orderContact;
        cell.leaveMessage = _orderDetail.leaveMessage;
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 3 && indexPath.row == 0) {
        TravelerListViewController *ctl = [[TravelerListViewController alloc] init];
        ctl.travelerList = _orderDetail.travelerList;
        [self.navigationController pushViewController:ctl animated:YES];
    }
}


@end

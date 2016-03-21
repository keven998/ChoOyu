//
//  BNOrderDetailViewController.m
//  PeachTravel
//
//  Created by liangpengshuai on 11/13/15.
//  Copyright © 2015 com.aizou.www. All rights reserved.
//

#import "BNOrderDetailViewController.h"
#import "OrderDetailStoreInfoTableViewCell.h"
#import "OrderDetailContentTableViewCell.h"
#import "OrderDetailTravelerTableViewCell.h"
#import "OrderDetailContactTableViewCell.h"
#import "OrderDetailStatusTableViewCell.h"
#import "OrderDetailStatusListTableViewCell.h"
#import "TravelerListViewController.h"
#import "SelectPayPlatformViewController.h"
#import "AskRefundMoneyViewController.h"
#import "GoodsDetailViewController.h"
#import "OrderManager+BNOrderManager.h"
#import "ChatViewController.h"
#import "ChatGroupSettingViewController.h"
#import "ChatSettingViewController.h"
#import "REFrostedViewController.h"
#import "TZPayManager.h"
#import "MakeGoodsCommentViewController.h"
#import "BNAgreeRefundMoneyViewController.h"
#import "BNRefuseRefundMoneyViewController.h"
#import "BNRefundMoneyWithSoldOutViewController.h"
#import "BNDeliverGoodsDetailViewController.h"

@interface BNOrderDetailViewController () <UITableViewDataSource, UITableViewDelegate, UIActionSheetDelegate> {
    NSTimer *timer;
}

@property (nonatomic, strong) UIView *toolBar;
@property (nonatomic) NSInteger payCutdown;   //付款倒计时
@property (nonatomic, strong) NSArray *cancelOrderReason;
@end

@implementation BNOrderDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
     _cancelOrderReason = @[@"未及时付款", @"买家不想买", @"买家信息填写有误，重拍", @"恶意买家/同行捣乱", @"缺货", @"买家拍错了", @"其它原因"];
    self.navigationItem.title = @"订单详情";
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.separatorColor = COLOR_LINE;
    [_tableView registerNib:[UINib nibWithNibName:@"OrderDetailStatusTableViewCell" bundle:nil] forCellReuseIdentifier:@"orderDetailStatusCell"];
    
    [_tableView registerNib:[UINib nibWithNibName:@"OrderDetailContentTableViewCell" bundle:nil] forCellReuseIdentifier:@"orderDetailContentCell"];
    [_tableView registerNib:[UINib nibWithNibName:@"OrderDetailStoreInfoTableViewCell" bundle:nil] forCellReuseIdentifier:@"orderDetailStoreCell"];
    [_tableView registerNib:[UINib nibWithNibName:@"OrderDetailTravelerTableViewCell" bundle:nil] forCellReuseIdentifier:@"orderDetailTravelerCell"];
    [_tableView registerNib:[UINib nibWithNibName:@"OrderDetailContactTableViewCell" bundle:nil] forCellReuseIdentifier:@"orderDetailContactCell"];
    [_tableView registerNib:[UINib nibWithNibName:@"OrderDetailStatusListTableViewCell" bundle:nil] forCellReuseIdentifier:@"orderDetailStatusListTableViewCell"];
    
    _tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _tableView.bounds.size.width, 55)];
    
    [self setupToolBar];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self updateOrderDetail];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)setOrderDetail:(BNOrderDetailModel *)orderDetail
{
    _orderDetail = orderDetail;
    if (_orderDetail.orderStatus == kOrderWaitPay) {
        if (_orderDetail.expireTime - _orderDetail.currentTime > 0) {
            _payCutdown = _orderDetail.expireTime - _orderDetail.currentTime;
            if (timer) {
                [timer invalidate];
                timer = nil;
            }
            timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(updateLeftTime) userInfo:nil repeats:YES];
        } else {
            _payCutdown = 0;
            if (timer) {
                [timer invalidate];
                timer = nil;
            }
        }
        
    } else {
        if (timer) {
            [timer invalidate];
            timer = nil;
        }
    }
}

- (void)setPayCutdown:(NSInteger)payCutdown
{
    _payCutdown = payCutdown;
    if (_orderDetail.orderStatus == kOrderWaitPay) {
        OrderDetailStatusTableViewCell *cell = [_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]];
        cell.statusLabel.attributedText = [self orderStatusDescWhenWaitPay];
    }
}

- (void)updateLeftTime
{
    if (_payCutdown == 0) {
        if (timer) {
            [timer invalidate];
            timer = nil;
            [self updateOrderDetail];
        }
        return;
    }
    --self.payCutdown;
    [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForItem:0 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
}

- (void)updateOrderDetail
{
    [OrderManager asyncLoadBNOrderDetailWithOrderId:_orderId completionBlock:^(BOOL isSuccess, BNOrderDetailModel *orderDetail) {
        self.orderDetail = orderDetail;
        [self.tableView reloadData];
        [self setupToolBar];
    }];
}

- (void)setupToolBar
{
    if (_toolBar.superview) {
        [_toolBar removeFromSuperview];
    }
    _toolBar = [[UIView alloc] initWithFrame:CGRectMake(0, kWindowHeight-55, kWindowWidth, 55)];
    _toolBar.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:_toolBar];
    
    UIView *spaceView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _toolBar.bounds.size.width, 0.5)];
    spaceView.backgroundColor = COLOR_LINE;
    [_toolBar addSubview:spaceView];
    
    UIButton *chatButton = [[UIButton alloc] initWithFrame:CGRectMake(kWindowWidth-66, 12.5, 60, 30)];
    [chatButton setTitle:@"联系买家" forState:UIControlStateNormal];
    [chatButton setTitleColor:COLOR_PRICE_RED forState:UIControlStateNormal];
    chatButton.layer.borderColor = COLOR_PRICE_RED.CGColor;
    chatButton.layer.borderWidth = 1;
    chatButton.titleLabel.font = [UIFont systemFontOfSize:12.0];
    [chatButton addTarget:self action:@selector(contactUser:) forControlEvents:UIControlEventTouchUpInside];
    chatButton.layer.cornerRadius = 3.0;
    [_toolBar addSubview:chatButton];
    
    if (_orderDetail.orderStatus == kOrderPaid) {
        UIButton *refundWithSoldOutButton = [[UIButton alloc] initWithFrame:CGRectMake(kWindowWidth-136, 12.5, 60, 30)];
        [refundWithSoldOutButton setTitle:@"缺货退款" forState:UIControlStateNormal];
        [refundWithSoldOutButton setTitleColor:COLOR_PRICE_RED forState:UIControlStateNormal];
        refundWithSoldOutButton.layer.borderColor = COLOR_PRICE_RED.CGColor;
        refundWithSoldOutButton.layer.borderWidth = 1;
        refundWithSoldOutButton.titleLabel.font = [UIFont systemFontOfSize:12.0];
        [refundWithSoldOutButton addTarget:self action:@selector(refundMoneyWithSoldOut:) forControlEvents:UIControlEventTouchUpInside];
        refundWithSoldOutButton.layer.cornerRadius = 3.0;
        [_toolBar addSubview:refundWithSoldOutButton];
        
        UIButton *deliveryGoodsButton = [[UIButton alloc] initWithFrame:CGRectMake(kWindowWidth-202, 12.5, 60, 30)];
        [deliveryGoodsButton setTitle:@"发货" forState:UIControlStateNormal];
        [deliveryGoodsButton setTitleColor:COLOR_PRICE_RED forState:UIControlStateNormal];
        deliveryGoodsButton.layer.borderColor = COLOR_PRICE_RED.CGColor;
        deliveryGoodsButton.layer.borderWidth = 1;
        deliveryGoodsButton.titleLabel.font = [UIFont systemFontOfSize:12.0];
        [deliveryGoodsButton addTarget:self action:@selector(deliveryGoods:) forControlEvents:UIControlEventTouchUpInside];
        deliveryGoodsButton.layer.cornerRadius = 3.0;
        [_toolBar addSubview:deliveryGoodsButton];
        
    } else if (_orderDetail.orderStatus == kOrderRefunding) {
        if (_orderDetail.hasDeliverGoods) {
            UIButton *refundAgreeButton = [[UIButton alloc] initWithFrame:CGRectMake(kWindowWidth-136, 12.5, 60, 30)];
            [refundAgreeButton setTitle:@"同意退款" forState:UIControlStateNormal];
            [refundAgreeButton setTitleColor:COLOR_PRICE_RED forState:UIControlStateNormal];
            refundAgreeButton.layer.borderColor = COLOR_PRICE_RED.CGColor;
            refundAgreeButton.layer.borderWidth = 1;
            refundAgreeButton.titleLabel.font = [UIFont systemFontOfSize:12.0];
            [refundAgreeButton addTarget:self action:@selector(agreeRefundMoney:) forControlEvents:UIControlEventTouchUpInside];
            refundAgreeButton.layer.cornerRadius = 3.0;
            [_toolBar addSubview:refundAgreeButton];
            
            UIButton *refundRefuseButton = [[UIButton alloc] initWithFrame:CGRectMake(kWindowWidth-202, 12.5, 60, 30)];
            [refundRefuseButton setTitle:@"拒绝退款" forState:UIControlStateNormal];
            [refundRefuseButton setTitleColor:COLOR_PRICE_RED forState:UIControlStateNormal];
            refundRefuseButton.layer.borderColor = COLOR_PRICE_RED.CGColor;
            refundRefuseButton.layer.borderWidth = 1;
            refundRefuseButton.titleLabel.font = [UIFont systemFontOfSize:12.0];
            [refundRefuseButton addTarget:self action:@selector(refuseRefundMoney:) forControlEvents:UIControlEventTouchUpInside];
            refundRefuseButton.layer.cornerRadius = 3.0;
            [_toolBar addSubview:refundRefuseButton];
            
        } else {
            UIButton *refundAgreeButton = [[UIButton alloc] initWithFrame:CGRectMake(kWindowWidth-136, 12.5, 60, 30)];
            [refundAgreeButton setTitle:@"同意退款" forState:UIControlStateNormal];
            [refundAgreeButton setTitleColor:COLOR_PRICE_RED forState:UIControlStateNormal];
            refundAgreeButton.layer.borderColor = COLOR_PRICE_RED.CGColor;
            refundAgreeButton.layer.borderWidth = 1;
            refundAgreeButton.titleLabel.font = [UIFont systemFontOfSize:12.0];
            [refundAgreeButton addTarget:self action:@selector(agreeRefundMoney:) forControlEvents:UIControlEventTouchUpInside];
            refundAgreeButton.layer.cornerRadius = 3.0;
            [_toolBar addSubview:refundAgreeButton];
            
            UIButton *deliveryGoodsButton = [[UIButton alloc] initWithFrame:CGRectMake(kWindowWidth-202, 12.5, 60, 30)];
            [deliveryGoodsButton setTitle:@"发货" forState:UIControlStateNormal];
            [deliveryGoodsButton setTitleColor:COLOR_PRICE_RED forState:UIControlStateNormal];
            deliveryGoodsButton.layer.borderColor = COLOR_PRICE_RED.CGColor;
            deliveryGoodsButton.layer.borderWidth = 1;
            deliveryGoodsButton.titleLabel.font = [UIFont systemFontOfSize:12.0];
            [deliveryGoodsButton addTarget:self action:@selector(deliveryGoods:) forControlEvents:UIControlEventTouchUpInside];
            deliveryGoodsButton.layer.cornerRadius = 3.0;
            [_toolBar addSubview:deliveryGoodsButton];
        }
        
    } else if (_orderDetail.orderStatus == kOrderWaitPay) {
        UIButton *closeOrderButton = [[UIButton alloc] initWithFrame:CGRectMake(kWindowWidth-136, 12.5, 60, 30)];
        [closeOrderButton setTitle:@"关闭交易" forState:UIControlStateNormal];
        [closeOrderButton setTitleColor:COLOR_PRICE_RED forState:UIControlStateNormal];
        closeOrderButton.layer.borderColor = COLOR_PRICE_RED.CGColor;
        closeOrderButton.layer.borderWidth = 1;
        closeOrderButton.titleLabel.font = [UIFont systemFontOfSize:12.0];
        [closeOrderButton addTarget:self action:@selector(closeOrder:) forControlEvents:UIControlEventTouchUpInside];
        closeOrderButton.layer.cornerRadius = 3.0;
        [_toolBar addSubview:closeOrderButton];
    }
}

- (NSAttributedString *)orderStatusDescWhenWaitPay
{
    NSInteger days = _payCutdown/24/60/60;
    NSInteger hours = (_payCutdown - days*24*3600)/3600;
    NSInteger minute = (_payCutdown - days*24*3600 - hours*3600)/60;
    NSInteger second = (_payCutdown - days*24*3600 - hours*3600 - minute*60);
    NSMutableString *str = [[NSMutableString alloc] initWithString:_orderDetail.orderStatusDesc];
    [str appendFormat:@"  请在"];
    if (days) {
        [str appendFormat:@"%ld天", days];
    }
    if (hours) {
        [str appendFormat:@"%ld小时", hours];
    }
    if (minute) {
        [str appendFormat:@"%ld分钟", minute];
    }
    if (second >= 0) {
        [str appendFormat:@"%ld秒 ", second];
    }
    [str appendString:@"内完成支付"];
    NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] initWithString:str];
    [attr addAttributes:@{
                          NSFontAttributeName:[UIFont systemFontOfSize:14],
                          NSForegroundColorAttributeName: COLOR_TEXT_II,
                          } range:NSMakeRange(_orderDetail.orderStatusDesc.length, str.length - _orderDetail.orderStatusDesc.length)];
    return attr;
}

- (void)contactUser:(UIButton *)sender
{
    IMClientManager *clientManager = [IMClientManager shareInstance];
    ChatConversation *conversation = [clientManager.conversationManager getConversationWithChatterId:_orderDetail.consumerId chatType:IMChatTypeIMChatSingleType];
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
- (void)agreeRefundMoney:(UIButton *)sender
{
    BNAgreeRefundMoneyViewController *ctl = [[BNAgreeRefundMoneyViewController alloc] init];
    ctl.orderId = _orderId;
    [self.navigationController pushViewController:ctl animated:YES];
}

//拒绝退款
- (void)refuseRefundMoney:(UIButton *)sender
{
    BNRefuseRefundMoneyViewController *ctl = [[BNRefuseRefundMoneyViewController alloc] init];
    ctl.orderId = _orderId;
    [self.navigationController pushViewController:ctl animated:YES];
}

//发货
- (void)deliveryGoods:(UIButton *)sender
{
    BNDeliverGoodsDetailViewController *ctl = [[BNDeliverGoodsDetailViewController alloc] init];
    ctl.orderId = _orderId;
    [self.navigationController pushViewController:ctl animated:YES];
}

//关闭交易
- (void)closeOrder:(UIButton *)sender
{
    UIActionSheet *acctionSheet = [[UIActionSheet alloc] initWithTitle:@"选择关闭交易理由" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"未及时付款", @"买家不想买", @"买家信息填写有误，重拍", @"恶意买家/同行捣乱", @"缺货", @"买家拍错了", @"其它原因", nil];
    [acctionSheet showInView:self.view];
}

//缺货退款
- (void)refundMoneyWithSoldOut:(UIButton *)sender
{
    BNRefundMoneyWithSoldOutViewController *ctl = [[BNRefundMoneyWithSoldOutViewController alloc] init];
    ctl.orderId = _orderId;
    [self.navigationController pushViewController:ctl animated:YES];
}

#pragma mark - UIActionSheetDeleage

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex >= _cancelOrderReason.count) {
        return;
    }
    NSString *content = [_cancelOrderReason objectAtIndex:buttonIndex];

    [OrderManager asyncBNCancelOrderWithOrderId:_orderId reason:content leaveMessage:nil completionBlock:^(BOOL isSuccess, NSString *errorStr) {
        if (isSuccess) {
            [SVProgressHUD showHint:@"订单关闭成功"];
            [self updateOrderDetail];
            
        } else {
            [SVProgressHUD showHint:@"订单关闭失败"];
        }
    }];
}


- (void)makeCommentAction:(UIButton *)sender
{
    MakeGoodsCommentViewController *ctl = [[MakeGoodsCommentViewController alloc] init];
    ctl.goodsId = _orderDetail.goods.goodsId;
    ctl.orderId = _orderDetail.orderId;
    [self.navigationController pushViewController:ctl animated:YES];
}

- (void)orderAgainAction:(UIButton *)sender
{
    GoodsDetailViewController *ctl = [[GoodsDetailViewController alloc] init];
    ctl.goodsId = _orderDetail.goods.goodsId;
    [self.navigationController pushViewController:ctl animated:YES];
}

- (void)requestRefundMoney:(UIButton *)sender
{
    AskRefundMoneyViewController *ctl = [[AskRefundMoneyViewController alloc] init];
    ctl.orderId = _orderId;
    [self.navigationController pushViewController:ctl animated:YES];
}

- (void)goodsDetailAction:(UIButton *)sender
{
    GoodsDetailViewController *ctl = [[GoodsDetailViewController alloc] init];
    ctl.goodsId = _orderDetail.goods.goodsId;
    ctl.isSnapshot = YES;
    ctl.goodsVersion = _orderDetail.goods.goodsVersion;
    [self.navigationController pushViewController:ctl animated:YES];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 6;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return CGFLOAT_MIN;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 10;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1) {
        return [OrderDetailContentTableViewCell heightOfCellWithOrderDetail:_orderDetail];
    }
    if (indexPath.section == 4) {
        return [OrderDetailContactTableViewCell heightOfCellWithContactInfo:_orderDetail.orderContact andLeaveMessage:_orderDetail.leaveMessage];
    }
    if (indexPath.section == 5) {
        return [OrderDetailStatusListTableViewCell heightOfCellWithStatusList:_orderDetail.orderActivityList];
    }
    return 50;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        OrderDetailStatusTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"orderDetailStatusCell" forIndexPath:indexPath];
        if (_orderDetail.orderStatus == kOrderWaitPay) {
            cell.statusLabel.attributedText = [self orderStatusDescWhenWaitPay];
        } else {
            cell.statusLabel.text = _orderDetail.orderStatusDesc;
        }
        return cell;
        
    } else if (indexPath.section == 1) {
        OrderDetailContentTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"orderDetailContentCell" forIndexPath:indexPath];
        cell.orderDetail = _orderDetail;
        [cell.goodsNameBtn addTarget:self action:@selector(goodsDetailAction:) forControlEvents:UIControlEventTouchUpInside];
        return cell;
        
    } else if (indexPath.section == 2) {
        OrderDetailStoreInfoTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"orderDetailStoreCell" forIndexPath:indexPath];
        cell.chatBtn.hidden = YES;
        cell.storeNameLabel.text = _orderDetail.goods.store.storeName;
        return cell;
        
    } else if (indexPath.section == 3) {
        OrderDetailTravelerTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"orderDetailTravelerCell" forIndexPath:indexPath];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.travelerCountLabel.text = [NSString stringWithFormat:@"(%ld)", _orderDetail.travelerList.count];
        return cell;
        
    } else if (indexPath.section == 4) {
        OrderDetailContactTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"orderDetailContactCell" forIndexPath:indexPath];
        cell.contact = _orderDetail.orderContact;
        cell.leaveMessage = _orderDetail.leaveMessage;
        return cell;
        
    } else {
        OrderDetailStatusListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"orderDetailStatusListTableViewCell" forIndexPath:indexPath];
        cell.statusList = _orderDetail.orderActivityList;
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

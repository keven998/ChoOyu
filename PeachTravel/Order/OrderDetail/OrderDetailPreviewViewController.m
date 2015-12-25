//
//  OrderDetailPreviewViewController.m
//  PeachTravel
//
//  Created by liangpengshuai on 11/13/15.
//  Copyright © 2015 com.aizou.www. All rights reserved.
//

#import "OrderDetailPreviewViewController.h"
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
#import "ChatViewController.h"
#import "ChatGroupSettingViewController.h"
#import "ChatSettingViewController.h"
#import "REFrostedViewController.h"
#import "TZPayManager.h"
#import "OrderDetailTravelerPreviewTableViewCell.h"

@interface OrderDetailPreviewViewController () <UITableViewDataSource, UITableViewDelegate> {
    NSTimer *timer;
}

@property (nonatomic, strong) UIView *toolBar;
@property (nonatomic) NSInteger payCutdown;   //付款倒计时
@end

@implementation OrderDetailPreviewViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"确认订单";
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.separatorColor = COLOR_LINE;
    [_tableView registerNib:[UINib nibWithNibName:@"OrderDetailStatusTableViewCell" bundle:nil] forCellReuseIdentifier:@"orderDetailStatusCell"];
    
    [_tableView registerNib:[UINib nibWithNibName:@"OrderDetailContentTableViewCell" bundle:nil] forCellReuseIdentifier:@"orderDetailContentCell"];
    [_tableView registerNib:[UINib nibWithNibName:@"OrderDetailStoreInfoTableViewCell" bundle:nil] forCellReuseIdentifier:@"orderDetailStoreCell"];
    [_tableView registerNib:[UINib nibWithNibName:@"OrderDetailTravelerPreviewTableViewCell" bundle:nil] forCellReuseIdentifier:@"orderDetailTravelerPreviewCell"];
    [_tableView registerNib:[UINib nibWithNibName:@"OrderDetailContactTableViewCell" bundle:nil] forCellReuseIdentifier:@"orderDetailContactCell"];
    
    _tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _tableView.bounds.size.width, 55)];
    [OrderManager asyncLoadOrderDetailWithOrderId:_orderId completionBlock:^(BOOL isSuccess, OrderDetailModel *orderDetail) {
        self.orderDetail = orderDetail;
        [self.tableView reloadData];
        [self setupToolBar];
    }];
    [self setupToolBar];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)setOrderDetail:(OrderDetailModel *)orderDetail
{
    _orderDetail = orderDetail;
    if (_orderDetail.orderStatus == kOrderWaitPay) {
        if (_orderDetail.expireTime - _orderDetail.currentTime > 0) {
            _payCutdown = _orderDetail.expireTime - _orderDetail.currentTime;
        } else {
            _payCutdown = 0;
        }
        if (timer) {
            [timer invalidate];
            timer = nil;
        }
        timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(updateLeftTime) userInfo:nil repeats:YES];
        
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
        }
        return;
    }
    --self.payCutdown;
    if (_orderDetail.expireTime - _orderDetail.currentTime < 0) {
        _payCutdown = 0;
    }
    [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForItem:0 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
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
    
    UIButton *payOrderBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, _toolBar.bounds.size.width, _toolBar.bounds.size.height)];
    [payOrderBtn setTitle:@"立即支付" forState:UIControlStateNormal];
    [payOrderBtn setTitleColor: [UIColor whiteColor] forState:UIControlStateNormal];
    [payOrderBtn setBackgroundImage:[ConvertMethods createImageWithColor:UIColorFromRGB(0xFC4E27)] forState:UIControlStateNormal];
    payOrderBtn.titleLabel.font = [UIFont systemFontOfSize:17];
    [payOrderBtn addTarget:self action:@selector(payOrder:) forControlEvents:UIControlEventTouchUpInside];
    [_toolBar addSubview:payOrderBtn];
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
    if (second) {
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

- (void)payOrder:(UIButton *)sender
{
    SelectPayPlatformViewController *ctl = [[SelectPayPlatformViewController alloc] init];
    ctl.orderDetail = _orderDetail;
    [self.navigationController pushViewController:ctl animated:YES];
}

- (IBAction)contactBusiness:(UIButton *)sender
{
    
    IMClientManager *clientManager = [IMClientManager shareInstance];
    ChatConversation *conversation = [clientManager.conversationManager getConversationWithChatterId:_orderDetail.goods.store.business.userId chatType:IMChatTypeIMChatSingleType];
    ChatViewController *chatController = [[ChatViewController alloc] initWithConversation:conversation];
    
    chatController.chatterName = _orderDetail.goods.store.business.nickName;
    
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

- (void)orderAgainAction:(UIButton *)sender
{
    GoodsDetailViewController *ctl = [[GoodsDetailViewController alloc] init];
    ctl.goodsId = _orderDetail.goods.goodsId;
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
        return [OrderDetailContentTableViewCell heightOfCellWithOrderDetail:_orderDetail];
    } else if (indexPath.section == 3) {
        return [OrderDetailTravelerPreviewTableViewCell heightOfCellWithTravelerList:_orderDetail.travelerList];
        
    } else if (indexPath.section == 4) {
        return [OrderDetailContactTableViewCell heightOfCellWithContactInfo:_orderDetail.orderContact andLeaveMessage:_orderDetail.leaveMessage];
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
        [cell.chatBtn addTarget:self action:@selector(contactBusiness:) forControlEvents:UIControlEventTouchUpInside];
        cell.storeNameLabel.text = _orderDetail.goods.store.storeName;
        return cell;
        
    } else if (indexPath.section == 3) {
        OrderDetailTravelerPreviewTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"orderDetailTravelerPreviewCell" forIndexPath:indexPath];
        cell.travelerList = _orderDetail.travelerList;
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

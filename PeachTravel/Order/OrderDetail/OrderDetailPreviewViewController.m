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
#import "DownSheet.h"
#import "TZPayManager.h"

@interface OrderDetailPreviewViewController () <UITableViewDataSource, UITableViewDelegate, DownSheetDelegate>

@property (nonatomic, strong) UIView *toolBar;
@property (nonatomic, strong) DownSheet *payDownSheet;
@property (nonatomic, strong) TZPayManager *payManager;
@property (nonatomic) BOOL isHasCreateNewOrder;  //是否已经创建了订单

@end

@implementation OrderDetailPreviewViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"确认订单";
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.separatorColor = COLOR_LINE;
    
    [_tableView registerNib:[UINib nibWithNibName:@"OrderDetailContentTableViewCell" bundle:nil] forCellReuseIdentifier:@"orderDetailContentCell"];
    [_tableView registerNib:[UINib nibWithNibName:@"OrderDetailStoreInfoTableViewCell" bundle:nil] forCellReuseIdentifier:@"orderDetailStoreCell"];
    [_tableView registerNib:[UINib nibWithNibName:@"OrderDetailTravelerPreviewTableViewCell" bundle:nil] forCellReuseIdentifier:@"orderDetailTravelerPreviewCell"];
    [_tableView registerNib:[UINib nibWithNibName:@"OrderDetailContactTableViewCell" bundle:nil] forCellReuseIdentifier:@"orderDetailContactCell"];
    
    _tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _tableView.bounds.size.width, 55)];
    
    [self setupToolBar];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)setOrderDetail:(OrderDetailModel *)orderDetail
{
    _orderDetail = orderDetail;
    [self.tableView reloadData];
}

- (TZPayManager *)payManager
{
    if (!_payManager) {
        _payManager = [[TZPayManager alloc] init];
    }
    return _payManager;
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

- (void)payOrder:(UIButton *)sender
{
    if (_isHasCreateNewOrder) {
        [self showPayActionSheet];


    } else {
        [OrderManager asyncMakeOrderWithGoodsId:_orderDetail.goods.goodsId travelers:_travelerIdList packageId:_orderDetail.selectedPackage.packageId playDate:_orderDetail.useDate quantity:_orderDetail.count contactModel:_orderDetail.orderContact leaveMessage:_orderDetail.leaveMessage completionBlock:^(BOOL isSuccess, OrderDetailModel *orderDetail) {
            if (isSuccess) {
                _isHasCreateNewOrder = YES;
                _orderDetail = orderDetail;
                
                [self showPayActionSheet];
            } else {
                [SVProgressHUD showHint:@"订单创建失败"];
            }
        }];

    }
}

- (void)showPayActionSheet
{
    DownSheetModel *modelOne = [[DownSheetModel alloc] init];
    modelOne.title = @"支付宝";
    modelOne.icon= @"icon_pay_alipay";
    
    DownSheetModel *modelTwo = [[DownSheetModel alloc] init];
    modelTwo.title = @"微信";
    modelTwo.icon = @"icon_pay_wechat";
    
    _payDownSheet = [[DownSheet alloc] initWithlist:@[modelOne, modelTwo] height:40 andTitle:@"选择支付方式"];
    _payDownSheet.delegate = self;
    [_payDownSheet showInView:self];
}

#pragma mark - DownSheetDelegate

- (void)didSelectIndex:(NSInteger)index
{
    _payManager = [[TZPayManager alloc] init];
    TZPayPlatform platform;
    if (index == 0) {
        platform = kAlipay;
    } else {
        platform = kWeichatPay;
    }
    [_payManager asyncPayOrder:_orderDetail.orderId payPlatform:platform completionBlock:^(BOOL isSuccess, NSString *errorStr) {
        if (isSuccess) {
            [SVProgressHUD showHint:@"支付成功"];
            [_payDownSheet tappedCancel];
            
        } else {
            [SVProgressHUD showHint:errorStr];
        }
    }];
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 4;
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
    if (indexPath.section == 0) {
        return [OrderDetailContentTableViewCell heightOfCellWithOrderDetail:_orderDetail];
        
    } else if (indexPath.section == 2) {
        return [OrderDetailTravelerPreviewTableViewCell heightOfCellWithTravelerList:_orderDetail.travelerList];
        
    } else if (indexPath.section == 3) {
        return [OrderDetailContactTableViewCell heightOfCellWithContactInfo:_orderDetail.orderContact andLeaveMessage:_orderDetail.leaveMessage];
    }
    return 50;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        OrderDetailContentTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"orderDetailContentCell" forIndexPath:indexPath];
        cell.orderDetail = _orderDetail;
        cell.goodsNameBtn.userInteractionEnabled = NO;
        return cell;
        
    } else if (indexPath.section == 1) {
        OrderDetailStoreInfoTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"orderDetailStoreCell" forIndexPath:indexPath];
        cell.chatBtn.hidden = YES;
        cell.storeNameLabel.text = _orderDetail.goods.store.storeName;
        return cell;
        
    } else if (indexPath.section == 2) {
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
}


@end

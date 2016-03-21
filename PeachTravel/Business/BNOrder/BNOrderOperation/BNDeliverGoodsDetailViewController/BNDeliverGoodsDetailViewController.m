//
//  BNDeliverGoodsDetailViewController.m
//  PeachTravel
//
//  Created by liangpengshuai on 3/14/16.
//  Copyright © 2016 com.aizou.www. All rights reserved.
//

#import "BNDeliverGoodsDetailViewController.h"
#import "OrderManager+BNOrderManager.h"

@interface BNDeliverGoodsDetailViewController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, strong)BNOrderDetailModel *orderDetail;

@end

@implementation BNDeliverGoodsDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"发货";
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.rowHeight = UITableViewAutomaticDimension;
    _tableView.backgroundColor = APP_PAGE_COLOR;
    _tableView.separatorColor = COLOR_LINE;
    [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
    [_tableView registerNib:[UINib nibWithNibName:@"BNRefundMoneyRemarkTableViewCell" bundle:nil] forCellReuseIdentifier:@"BNRefundMoneyRemarkTableViewCell"];
    
    [OrderManager asyncLoadBNOrderDetailWithOrderId:_orderId completionBlock:^(BOOL isSuccess, BNOrderDetailModel *orderDetail) {
        if (isSuccess) {
            self.orderDetail = orderDetail;
            [self setupToolBar];
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)setupToolBar
{
    UIView *toolBar = [[UIView alloc] initWithFrame:CGRectMake(0, kWindowHeight-55, kWindowWidth, 55)];
    toolBar.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:toolBar];
    
    UIButton *confirmDeliverButton = [[UIButton alloc] initWithFrame:toolBar.bounds];
    [confirmDeliverButton setTitle:@"确认发货" forState:UIControlStateNormal];
    [confirmDeliverButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [confirmDeliverButton setBackgroundImage:[ConvertMethods createImageWithColor:UIColorFromRGB(0xFC4E27)] forState:UIControlStateNormal];
    confirmDeliverButton.titleLabel.font = [UIFont systemFontOfSize:17];
    [confirmDeliverButton addTarget:self action:@selector(confirmDeliverAction:) forControlEvents:UIControlEventTouchUpInside];
    [toolBar addSubview:confirmDeliverButton];
}

- (void)setOrderDetail:(BNOrderDetailModel *)orderDetail
{
    _orderDetail = orderDetail;
    [self.tableView reloadData];
}

- (void)confirmDeliverAction:(UIButton *)sender
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"确认发货？" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    [alertView showAlertViewWithBlock:^(NSInteger buttonIndex) {
        if (buttonIndex == 1) {
            if (_orderDetail.hasRequest2RefundMoney) {
                [OrderManager asyncBNRefuseRefundMoneyOrderWithOrderId:_orderId reason:nil leaveMessage:nil completionBlock:^(BOOL isSuccess, NSString *errorStr) {
                    if (isSuccess) {
                        if (isSuccess) {
                            [SVProgressHUD showHint:@"发货成功"];
                            [self.navigationController popViewControllerAnimated:YES];
                        } else {
                            [SVProgressHUD showHint:@"发货失败，请重试"];
                        }
                    } else {
                        [SVProgressHUD showHint:@"发货失败，请重试"];
                    }
                }];
            } else {
                [OrderManager asyncBNDeliverOrderWithOrderId:_orderId completionBlock:^(BOOL isSuccess, NSString *errorStr) {
                    if (isSuccess) {
                        [SVProgressHUD showHint:@"发货成功"];
                        [self.navigationController popViewControllerAnimated:YES];
                    } else {
                        [SVProgressHUD showHint:@"发货失败，请重试"];
                    }
                }];
            }
            
        }
    }];
}

#pragma mark - UITableViewDataSource

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (_orderDetail) {
        return 2;
    } else {
        return 0;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 10;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return CGFLOAT_MIN;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
        cell.textLabel.numberOfLines = 0;
        
        NSMutableString *content = [[NSMutableString alloc] init];
        [content appendFormat:@"商品订单信息\n"];
        [content appendFormat:@"商品名: %@\n", _orderDetail.goods.goodsName];
        [content appendFormat:@"所选套餐: %@\n", _orderDetail.selectedPackage.packageName];
        [content appendFormat:@"购买数量: %ld\n", _orderDetail.count];
        [content appendFormat:@"支付总价格: %@\n", _orderDetail.formatPayPrice];
        [content appendFormat:@"订单编号: %ld", _orderDetail.orderId];

        NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] initWithString:content];
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.lineSpacing = 10;
        [attr addAttributes:@{NSParagraphStyleAttributeName:paragraphStyle}
                      range:NSMakeRange(0, attr.length)];
        
        [attr addAttributes:@{NSFontAttributeName: [UIFont boldSystemFontOfSize:17.0], NSForegroundColorAttributeName: COLOR_TEXT_I} range:NSMakeRange(0, 6)];
        
        cell.textLabel.textColor = COLOR_TEXT_II;
        cell.textLabel.font = [UIFont systemFontOfSize:14];
        cell.textLabel.attributedText = attr;
        return cell;

        
    } else if (indexPath.section == 1) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
        cell.textLabel.numberOfLines = 0;
        
        NSMutableString *content = [[NSMutableString alloc] init];
        [content appendFormat:@"买家信息\n"];
        [content appendFormat:@"联系人: %@ %@\n", _orderDetail.orderContact.lastName, _orderDetail.orderContact.firstName];
        [content appendFormat:@"手机: %@\n", _orderDetail.orderContact.telDesc];
        [content appendFormat:@"使用日期: %@\n", _orderDetail.useDate];
        if (_orderDetail.leaveMessage) {
            [content appendFormat:@"留言: %@\n", _orderDetail.leaveMessage];
        } else {
            [content appendFormat:@"留言: -"];
        }
        
        NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] initWithString:content];
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.lineSpacing = 10;
        [attr addAttributes:@{NSParagraphStyleAttributeName:paragraphStyle}
                      range:NSMakeRange(0, attr.length)];
        [attr addAttributes:@{NSFontAttributeName: [UIFont boldSystemFontOfSize:17.0], NSForegroundColorAttributeName: COLOR_TEXT_I} range:NSMakeRange(0, 4)];
        cell.textLabel.textColor = COLOR_TEXT_II;
        cell.textLabel.font = [UIFont systemFontOfSize:14];
        cell.textLabel.attributedText = attr;
        return cell;
        
    }
    return nil;
}

@end

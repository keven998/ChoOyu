//
//  BNOrderListTableViewCell.m
//  PeachTravel
//
//  Created by liangpengshuai on 3/8/16.
//  Copyright © 2016 com.aizou.www. All rights reserved.
//

#import "BNOrderListTableViewCell.h"

@interface BNOrderListTableViewCell ()

@property (nonatomic, strong) UIButton *chatButton;                 //联系买家
@property (nonatomic, strong) UIButton *deliveryGoodsButton;        //发货
@property (nonatomic, strong) UIButton *refundWithSoldOutButton;    //缺货退款
@property (nonatomic, strong) UIButton *closeOrderButton;           //关闭交易
@property (nonatomic, strong) UIButton *refundAgreeButton;          //同意退款
@property (nonatomic, strong) UIButton *refundRefuseButton;         //拒绝退款

@end

@implementation BNOrderListTableViewCell

- (void)awakeFromNib {
    _timeLabel.adjustsFontSizeToFitWidth = YES;
}

- (void)setOrderDetail:(BNOrderDetailModel *)orderDetail
{
    _orderDetail = orderDetail;
    [_headerImageView sd_setImageWithURL:[NSURL URLWithString:_orderDetail.goods.coverImage.imageUrl] placeholderImage:nil];
    _titleLabel.text = _orderDetail.goods.goodsName;
    _numberLabel.text = [NSString stringWithFormat:@"商品编号: %ld", _orderDetail.goods.goodsId];
    _priceLabel.text = [NSString stringWithFormat:@"订单总价: %@  共%ld件", _orderDetail.formatTotalPrice, _orderDetail.count];
    _orderNumberLabel.text = [NSString stringWithFormat:@"订单号: %ld", _orderDetail.orderId];
    NSString *createTime = [ConvertMethods dateToString:[NSDate dateWithTimeIntervalSince1970:_orderDetail.createTime] withFormat:@"yyyy-MM-dd HH:mm:ss" withTimeZone:[NSTimeZone systemTimeZone]];
    _timeLabel.text = [NSString stringWithFormat:@"下单时间: %@", createTime];
    NSString *telStr = _orderDetail.orderContact.telDesc;
    NSString *contactName = [NSString stringWithFormat:@"%@ %@", _orderDetail.orderContact.lastName, _orderDetail.orderContact.firstName];
    _contactLabel.text = [NSString stringWithFormat:@"联系人: %@  %@", contactName, telStr];
    _statusLabel.text = _orderDetail.BNOrderStatusDesc;
    
    [self setupActionButtons];
}

//不同的状态设置不同的操作按钮
- (void)setupActionButtons
{
    if (_chatButton) {
        [_chatButton removeFromSuperview];
    }
    _chatButton = [[UIButton alloc] initWithFrame:CGRectMake(kWindowWidth-66, 147, 60, 28)];
    [_chatButton setTitle:@"联系买家" forState:UIControlStateNormal];
    [_chatButton setTitleColor:COLOR_TEXT_II forState:UIControlStateNormal];
    _chatButton.layer.borderColor = COLOR_LINE.CGColor;
    _chatButton.layer.borderWidth = 1;
    _chatButton.titleLabel.font = [UIFont systemFontOfSize:12.0];
    [_chatButton addTarget:self action:@selector(chatAction:) forControlEvents:UIControlEventTouchUpInside];
    _chatButton.layer.cornerRadius = 3.0;
    [self.contentView addSubview:_chatButton];
    
    if (_deliveryGoodsButton) {
        [_deliveryGoodsButton removeFromSuperview];
    }
    if (_refundAgreeButton) {
        [_refundAgreeButton removeFromSuperview];
    }
    if (_refundWithSoldOutButton) {
        [_refundWithSoldOutButton removeFromSuperview];
    }
    if (_refundRefuseButton) {
        [_refundRefuseButton removeFromSuperview];
    }
    if (_closeOrderButton) {
        [_closeOrderButton removeFromSuperview];
    }
    if (_orderDetail.orderStatus == kOrderPaid) {
        _refundWithSoldOutButton = [[UIButton alloc] initWithFrame:CGRectMake(kWindowWidth-136, 147, 60, 28)];
        [_refundWithSoldOutButton setTitle:@"缺货退款" forState:UIControlStateNormal];
        [_refundWithSoldOutButton setTitleColor:COLOR_TEXT_II forState:UIControlStateNormal];
        _refundWithSoldOutButton.layer.borderColor = COLOR_LINE.CGColor;
        _refundWithSoldOutButton.layer.borderWidth = 1;
        _refundWithSoldOutButton.titleLabel.font = [UIFont systemFontOfSize:12.0];
        [_refundWithSoldOutButton addTarget:self action:@selector(refundMoneyWithSoldOutAction:) forControlEvents:UIControlEventTouchUpInside];
        _refundWithSoldOutButton.layer.cornerRadius = 3.0;
        [self.contentView addSubview:_refundWithSoldOutButton];
        
        _deliveryGoodsButton = [[UIButton alloc] initWithFrame:CGRectMake(kWindowWidth-202, 147, 60, 28)];
        [_deliveryGoodsButton setTitle:@"发货" forState:UIControlStateNormal];
        [_deliveryGoodsButton setTitleColor:COLOR_TEXT_II forState:UIControlStateNormal];
        _deliveryGoodsButton.layer.borderColor = COLOR_LINE.CGColor;
        _deliveryGoodsButton.layer.borderWidth = 1;
        _deliveryGoodsButton.titleLabel.font = [UIFont systemFontOfSize:12.0];
        [_deliveryGoodsButton addTarget:self action:@selector(deliveryGoodsAction:) forControlEvents:UIControlEventTouchUpInside];
        _deliveryGoodsButton.layer.cornerRadius = 3.0;
        [self.contentView addSubview:_deliveryGoodsButton];
        
    } else if (_orderDetail.orderStatus == kOrderRefunding) {
        if (_orderDetail.hasDeliverGoods) {
            _refundAgreeButton = [[UIButton alloc] initWithFrame:CGRectMake(kWindowWidth-136, 147, 60, 28)];
            [_refundAgreeButton setTitle:@"同意退款" forState:UIControlStateNormal];
            [_refundAgreeButton setTitleColor:COLOR_TEXT_II forState:UIControlStateNormal];
            _refundAgreeButton.layer.borderColor = COLOR_LINE.CGColor;
            _refundAgreeButton.layer.borderWidth = 1;
            _refundAgreeButton.titleLabel.font = [UIFont systemFontOfSize:12.0];
            [_refundAgreeButton addTarget:self action:@selector(agreeRefundMoneyAction:) forControlEvents:UIControlEventTouchUpInside];
            _refundAgreeButton.layer.cornerRadius = 3.0;
            [self.contentView addSubview:_refundAgreeButton];
            
            _refundRefuseButton = [[UIButton alloc] initWithFrame:CGRectMake(kWindowWidth-202, 147, 60, 28)];
            [_refundRefuseButton setTitle:@"拒绝退款" forState:UIControlStateNormal];
            [_refundRefuseButton setTitleColor:COLOR_TEXT_II forState:UIControlStateNormal];
            _refundRefuseButton.layer.borderColor = COLOR_LINE.CGColor;
            _refundRefuseButton.layer.borderWidth = 1;
            _refundRefuseButton.titleLabel.font = [UIFont systemFontOfSize:12.0];
            [_refundRefuseButton addTarget:self action:@selector(refuseRefundMoneyAction:) forControlEvents:UIControlEventTouchUpInside];
            _refundRefuseButton.layer.cornerRadius = 3.0;
            [self.contentView addSubview:_refundRefuseButton];

        } else {
            _refundAgreeButton = [[UIButton alloc] initWithFrame:CGRectMake(kWindowWidth-136, 147, 60, 28)];
            [_refundAgreeButton setTitle:@"同意退款" forState:UIControlStateNormal];
            [_refundAgreeButton setTitleColor:COLOR_TEXT_II forState:UIControlStateNormal];
            _refundAgreeButton.layer.borderColor = COLOR_LINE.CGColor;
            _refundAgreeButton.layer.borderWidth = 1;
            _refundAgreeButton.titleLabel.font = [UIFont systemFontOfSize:12.0];
            [_refundAgreeButton addTarget:self action:@selector(agreeRefundMoneyAction:) forControlEvents:UIControlEventTouchUpInside];
            _refundAgreeButton.layer.cornerRadius = 3.0;
            [self.contentView addSubview:_refundAgreeButton];
            
            _deliveryGoodsButton = [[UIButton alloc] initWithFrame:CGRectMake(kWindowWidth-202, 147, 60, 28)];
            [_deliveryGoodsButton setTitle:@"发货" forState:UIControlStateNormal];
            [_deliveryGoodsButton setTitleColor:COLOR_TEXT_II forState:UIControlStateNormal];
            _deliveryGoodsButton.layer.borderColor = COLOR_LINE.CGColor;
            _deliveryGoodsButton.layer.borderWidth = 1;
            _deliveryGoodsButton.titleLabel.font = [UIFont systemFontOfSize:12.0];
            [_deliveryGoodsButton addTarget:self action:@selector(deliveryGoodsAction:) forControlEvents:UIControlEventTouchUpInside];
            _deliveryGoodsButton.layer.cornerRadius = 3.0;
            [self.contentView addSubview:_deliveryGoodsButton];
        }
        
    } else if (_orderDetail.orderStatus == kOrderWaitPay) {
        _closeOrderButton = [[UIButton alloc] initWithFrame:CGRectMake(kWindowWidth-136, 147, 60, 28)];
        [_closeOrderButton setTitle:@"关闭交易" forState:UIControlStateNormal];
        [_closeOrderButton setTitleColor:COLOR_TEXT_II forState:UIControlStateNormal];
        _closeOrderButton.layer.borderColor = COLOR_LINE.CGColor;
        _closeOrderButton.layer.borderWidth = 1;
        _closeOrderButton.titleLabel.font = [UIFont systemFontOfSize:12.0];
        [_closeOrderButton addTarget:self action:@selector(closeOrderAction:) forControlEvents:UIControlEventTouchUpInside];
        _closeOrderButton.layer.cornerRadius = 3.0;
        [self.contentView addSubview:_closeOrderButton];
    }
}

- (void)chatAction:(UIButton *)sender
{
    if ([_delegate respondsToSelector:@selector(chatWithUser:)]) {
        [_delegate chatWithUser:_orderDetail.consumerId];
    }
}

- (void)agreeRefundMoneyAction:(UIButton *)sender
{
    if ([_delegate respondsToSelector:@selector(agreeRefundMoney:)]) {
        [_delegate agreeRefundMoney:_orderDetail];
    }
}

- (void)refuseRefundMoneyAction:(UIButton *)sender
{
    if ([_delegate respondsToSelector:@selector(refuseRefundMoney:)]) {
        [_delegate refuseRefundMoney:_orderDetail];
    }
}

- (void)closeOrderAction:(UIButton *)sender
{
    if ([_delegate respondsToSelector:@selector(closeOrder:)]) {
        [_delegate closeOrder:_orderDetail];
    }
}

- (void)refundMoneyWithSoldOutAction:(UIButton *)sender
{
    if ([_delegate respondsToSelector:@selector(refundMoneyWithSoldOut:)]) {
        [_delegate refundMoneyWithSoldOut:_orderDetail];
    }
}

- (void)deliveryGoodsAction:(UIButton *)sender
{
    if ([_delegate respondsToSelector:@selector(deliveryGoods:)]) {
        [_delegate deliveryGoods:_orderDetail];
    }
}

@end

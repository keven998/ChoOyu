//
//  BNOrderListTableViewCell.m
//  PeachTravel
//
//  Created by liangpengshuai on 3/8/16.
//  Copyright © 2016 com.aizou.www. All rights reserved.
//

#import "BNOrderListTableViewCell.h"

@interface BNOrderListTableViewCell ()

@property (nonatomic, strong) UIButton *chatButton;

@end

@implementation BNOrderListTableViewCell

- (void)awakeFromNib {
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
    _chatButton.titleLabel.font = [UIFont systemFontOfSize:13.0];
    [_chatButton addTarget:self action:@selector(chatAction:) forControlEvents:UIControlEventTouchUpInside];
    _chatButton.layer.cornerRadius = 3.0;
    [self.contentView addSubview:_chatButton];
}

- (void)chatAction:(UIButton *)sender
{
    if ([_delegate respondsToSelector:@selector(chatWithUser:)]) {
        [_delegate chatWithUser:_orderDetail.consumerId];
    }
}

@end

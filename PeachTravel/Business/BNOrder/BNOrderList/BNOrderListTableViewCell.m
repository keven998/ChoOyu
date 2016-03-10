//
//  BNOrderListTableViewCell.m
//  PeachTravel
//
//  Created by liangpengshuai on 3/8/16.
//  Copyright © 2016 com.aizou.www. All rights reserved.
//

#import "BNOrderListTableViewCell.h"

@implementation BNOrderListTableViewCell

- (void)awakeFromNib {
}

- (void)setOrderDetail:(OrderDetailModel *)orderDetail
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
    _statusLabel.text = _orderDetail.orderStatusDesc;
}

@end

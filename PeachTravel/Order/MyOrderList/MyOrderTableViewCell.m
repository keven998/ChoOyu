//
//  MyOrderTableViewCell.m
//  PeachTravel
//
//  Created by liangpengshuai on 11/18/15.
//  Copyright © 2015 com.aizou.www. All rights reserved.
//

#import "MyOrderTableViewCell.h"

@implementation MyOrderTableViewCell

- (void)awakeFromNib {
    _payOrderBtn.layer.cornerRadius = 4.0;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}


- (void)setOrderDetail:(OrderDetailModel *)orderDetail
{
    _orderDetail = orderDetail;
    [_goodsImageView sd_setImageWithURL:[NSURL URLWithString:_orderDetail.goods.image.imageUrl] placeholderImage:nil];
    _goodsNameLabel.text = _orderDetail.goods.goodsName;
    _packageNameLabel.text = [NSString stringWithFormat:@"%@ *%ld", _orderDetail.selectedPackage.packageName, _orderDetail.count];
    
    _dateLabel.text = [NSString stringWithFormat:@"出行日期: %@", _orderDetail.useDateStr];
    if (_orderDetail.orderStatus == kOrderWaitPay) {
        _payOrderBtnWidthConstraint.constant = 100;
        _statusLabel.text = [NSString stringWithFormat:@"%@: %d", _orderDetail.orderStatusDesc, (int)orderDetail.totalPrice];
    } else {
        _payOrderBtnWidthConstraint.constant = 0;
        _statusLabel.text = _orderDetail.orderStatusDesc;
    }
}
@end

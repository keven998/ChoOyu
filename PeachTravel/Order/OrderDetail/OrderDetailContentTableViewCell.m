//
//  OrderDetailContentTableViewCell.m
//  PeachTravel
//
//  Created by liangpengshuai on 11/13/15.
//  Copyright © 2015 com.aizou.www. All rights reserved.
//

#import "OrderDetailContentTableViewCell.h"

@implementation OrderDetailContentTableViewCell

+ (CGFloat)heightOfCellWithOrderDetail:(OrderDetailModel *)orderDetail;
{
    CGFloat retHeight = 238;
    NSDictionary *attribs = @{NSFontAttributeName: [UIFont systemFontOfSize:13]};
    if (orderDetail.goods.goodsName) {
        NSAttributedString *attrstr = [[NSAttributedString alloc] initWithString: orderDetail.goods.goodsName attributes:attribs];
        CGRect rect = [attrstr boundingRectWithSize:(CGSize){kWindowWidth-100, CGFLOAT_MAX} options:NSStringDrawingUsesLineFragmentOrigin context:nil];
        if (rect.size.height > 21) {
            retHeight += (rect.size.height-21+6);
        }
    }
   
    if (orderDetail.selectedPackage.packageName) {
        NSAttributedString *attrstr1 = [[NSAttributedString alloc] initWithString: orderDetail.selectedPackage.packageName attributes:attribs];
        CGRect rect1 = [attrstr1 boundingRectWithSize:(CGSize){kWindowWidth-100, CGFLOAT_MAX} options:NSStringDrawingUsesLineFragmentOrigin context:nil];
        if (rect1.size.height > 21) {
            retHeight += (rect1.size.height-21+6);
        }
    }
    
    return retHeight;
}

- (void)awakeFromNib {
    _goodsNameBtn.titleLabel.numberOfLines = 0;
}

- (void)setOrderDetail:(OrderDetailModel *)orderDetail
{
    _orderDetail = orderDetail;
    if (_orderDetail.goods.goodsName) {
        NSMutableAttributedString *string= [[NSMutableAttributedString alloc] initWithString:_orderDetail.goods.goodsName];
        [string addAttributes:@{
                                NSForegroundColorAttributeName: APP_THEME_COLOR,
                                NSUnderlineStyleAttributeName: @(NSUnderlineStyleSingle),
                                } range:NSMakeRange(0, _orderDetail.goods.goodsName.length)];
        
        [self.goodsNameBtn setAttributedTitle:string forState:UIControlStateNormal];
    } else {
        [self.goodsNameBtn setAttributedTitle:nil forState:UIControlStateNormal];
    }
    
    self.packageNameLabel.text = _orderDetail.selectedPackage.packageName;
    self.dateLabel.text = _orderDetail.useDate;
    self.orderNumberLabel.text = [NSString stringWithFormat:@"%ld", _orderDetail.orderId];
    self.dateLabel.text = _orderDetail.useDate;
    self.countLabel.text = [NSString stringWithFormat:@"%ld", _orderDetail.count];
    self.priceLabel.text = [NSString stringWithFormat:@"￥%@", _orderDetail.formatTotalPrice];

    NSDictionary *attribs = @{NSFontAttributeName: [UIFont systemFontOfSize:13]};

    if (orderDetail.goods.goodsName) {
        NSAttributedString *attrstr = [[NSAttributedString alloc] initWithString: orderDetail.goods.goodsName attributes:attribs];
        CGRect rect = [attrstr boundingRectWithSize:(CGSize){kWindowWidth-100, CGFLOAT_MAX} options:NSStringDrawingUsesLineFragmentOrigin context:nil];
        if (rect.size.height > 21) {
            _goodsNameHeightConstraint.constant = rect.size.height + 6;
        } else {
            _goodsNameHeightConstraint.constant = 21;
        }
    } else {
        _goodsNameHeightConstraint.constant = 21;
    }
    
    if (orderDetail.selectedPackage.packageName) {
        NSAttributedString *attrstr1 = [[NSAttributedString alloc] initWithString: orderDetail.selectedPackage.packageName attributes:attribs];
        CGRect rect1 = [attrstr1 boundingRectWithSize:(CGSize){kWindowWidth-100, CGFLOAT_MAX} options:NSStringDrawingUsesLineFragmentOrigin context:nil];
        if (rect1.size.height > 21) {
            _packageNameHeightConstarint.constant = rect1.size.height + 6;
        } else {
            _packageNameHeightConstarint.constant = 21;
        }
    } else {
        _packageNameHeightConstarint.constant = 21;
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

}

@end

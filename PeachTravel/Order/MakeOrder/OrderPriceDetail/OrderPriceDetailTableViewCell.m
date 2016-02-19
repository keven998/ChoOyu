//
//  OrderPriceDetailTableViewCell.m
//  PeachTravel
//
//  Created by liangpengshuai on 2/19/16.
//  Copyright © 2016 com.aizou.www. All rights reserved.
//

#import "OrderPriceDetailTableViewCell.h"

@implementation OrderPriceDetailTableViewCell

- (void)awakeFromNib {
    _contentLabel.textColor = COLOR_TEXT_II;
    _priceLabel.textColor = COLOR_PRICE_RED;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

@end

//
//  BNGoodsListTableViewCell.m
//  PeachTravel
//
//  Created by liangpengshuai on 3/7/16.
//  Copyright © 2016 com.aizou.www. All rights reserved.
//

#import "BNGoodsListTableViewCell.h"

@implementation BNGoodsListTableViewCell

- (void)awakeFromNib {
}

- (void)setGoodsDetail:(BNGoodsDetailModel *)goodsDetail
{
    _goodsDetail = goodsDetail;
    [_headerImageView sd_setImageWithURL:[NSURL URLWithString:_goodsDetail.coverImage.imageUrl] placeholderImage:nil];
    _titleLabel.text = _goodsDetail.goodsName;
    _goodsNumberLabel.text = [NSString stringWithFormat:@"商品编号: %ld", _goodsDetail.goodsId];
    _priceLabel.text = [NSString stringWithFormat:@"价格: %@起", _goodsDetail.formatCurrentPrice];
    _timeLabel.text = [NSString stringWithFormat:@"创建时间: 2016-02-03"];
    
    if (_goodsDetail.goodsStatus == kOnSale) {
        [_actionButton setTitle:@"下架" forState:UIControlStateNormal];
    } else if (_goodsDetail.goodsStatus == kOffSale) {
        [_actionButton setTitle:@"上架" forState:UIControlStateNormal];
    } else {
        _actionButton.hidden = YES;
    }
}


@end

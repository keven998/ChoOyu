//
//  StoreDetailCollectionViewCell.m
//  PeachTravel
//
//  Created by liangpengshuai on 12/21/15.
//  Copyright © 2015 com.aizou.www. All rights reserved.
//

#import "StoreDetailCollectionViewCell.h"

@implementation StoreDetailCollectionViewCell

- (void)awakeFromNib {
    self.layer.borderColor = COLOR_LINE.CGColor;
    self.layer.borderWidth = 0.25;
    _saleCountLabel.adjustsFontSizeToFitWidth = YES;
}

- (void)setGoodsDetail:(GoodsDetailModel *)goodsDetail
{
    _goodsDetail = goodsDetail;
    _goodsNameLabel.text = _goodsDetail.goodsName;
    [_goodsImageView sd_setImageWithURL:[NSURL URLWithString:_goodsDetail.coverImage.imageUrl] placeholderImage:nil];
    _saleCountLabel.text = [NSString stringWithFormat:@"%ld已售", _goodsDetail.saleCount];
    
    NSString *oldPrice = [NSString stringWithFormat:@"￥%d", (int)_goodsDetail.primePrice];
    NSString *nowPrice = [NSString stringWithFormat:@"￥%d", (int)_goodsDetail.currentPrice];
    
    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@%@", oldPrice, nowPrice]];
    [attrStr addAttributes:@{NSFontAttributeName: [UIFont systemFontOfSize:12],
                             NSForegroundColorAttributeName: COLOR_TEXT_III,
                             } range:NSMakeRange(0, oldPrice.length)];
    
    [attrStr addAttribute:NSStrikethroughStyleAttributeName value:[NSNumber numberWithInt:NSUnderlineStyleSingle] range:NSMakeRange(0, oldPrice.length)];
    
    [attrStr addAttributes:@{NSFontAttributeName: [UIFont systemFontOfSize:14],
                             NSForegroundColorAttributeName: COLOR_PRICE_RED,
                             } range:NSMakeRange(oldPrice.length, nowPrice.length)];
    _priceLabel.attributedText = attrStr;
    
}

@end

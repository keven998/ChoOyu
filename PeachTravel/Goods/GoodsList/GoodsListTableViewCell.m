//
//  GoodsListTableViewCell.m
//  PeachTravel
//
//  Created by liangpengshuai on 11/6/15.
//  Copyright © 2015 com.aizou.www. All rights reserved.
//

#import "GoodsListTableViewCell.h"

@implementation GoodsListTableViewCell

- (void)awakeFromNib {
    _headerImageView.clipsToBounds = YES;
    _titleBtn.titleLabel.numberOfLines = 2;
}

- (void)setGoodsDetail:(GoodsDetailModel *)goodsDetail
{
    _goodsDetail = goodsDetail;
    [_headerImageView sd_setImageWithURL:[NSURL URLWithString:_goodsDetail.coverImage.imageUrl] placeholderImage:nil];
    _titleBtn.titleLabel.numberOfLines = 2;
    [_titleBtn setTitle:_goodsDetail.goodsName forState:UIControlStateNormal];
    
    NSString *oldPrice = [NSString stringWithFormat:@"￥%@", _goodsDetail.formatPrimePrice];
    NSString *nowPrice = [NSString stringWithFormat:@"￥%@", _goodsDetail.formatCurrentPrice];
    
    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@%@起", oldPrice, nowPrice]];
    [attrStr addAttributes:@{NSFontAttributeName: [UIFont systemFontOfSize:12],
                             NSForegroundColorAttributeName: COLOR_TEXT_III,
                             } range:NSMakeRange(0, oldPrice.length)];
    
    [attrStr addAttribute:NSStrikethroughStyleAttributeName value:[NSNumber numberWithInt:NSUnderlineStyleSingle] range:NSMakeRange(0, oldPrice.length)];
    
    [attrStr addAttributes:@{NSFontAttributeName: [UIFont systemFontOfSize:14],
                             NSForegroundColorAttributeName: COLOR_PRICE_RED,
                             } range:NSMakeRange(oldPrice.length, nowPrice.length)];
    _priceLabel.attributedText = attrStr;
    NSString *propertyStrig = [NSString stringWithFormat:@"%d%%满意  已售: %ld", (int)(_goodsDetail.rating), _goodsDetail.saleCount];
    [_propertyBtn setTitle:propertyStrig forState:UIControlStateNormal];
    [_storeNameBtn setTitle:_goodsDetail.store.storeName forState:UIControlStateNormal];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

@end

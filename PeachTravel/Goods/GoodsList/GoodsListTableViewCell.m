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
    _priceLabel.adjustsFontSizeToFitWidth = YES;
    _ratingView.starImage = [UIImage imageNamed:@"icon_rating_gray.png"];
    _ratingView.starHighlightedImage = [UIImage imageNamed:@"icon_rating_yellow.png"];
    _ratingView.maxRating = 5.0;
    _ratingView.editable = NO;
    _ratingView.horizontalMargin = 1;
    _ratingView.displayMode = EDStarRatingDisplayAccurate;
    _ratingView.userInteractionEnabled = NO;
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
    _saleCountLabel.text = [NSString stringWithFormat:@"%ld已售", _goodsDetail.saleCount];
    _saleCountLabel.adjustsFontSizeToFitWidth = YES;
    [_storeNameBtn setTitle:_goodsDetail.store.storeName forState:UIControlStateNormal];
    
    [_ratingView setRating:_goodsDetail.rating*5];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

@end

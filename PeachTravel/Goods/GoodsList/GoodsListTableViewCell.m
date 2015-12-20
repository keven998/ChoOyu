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
}

- (void)setGoodsDetail:(GoodsDetailModel *)goodsDetail
{
    _goodsDetail = goodsDetail;
    _storeNameLabel.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
    [_headerImageView sd_setImageWithURL:[NSURL URLWithString:_goodsDetail.image.imageUrl] placeholderImage:nil];
    _titleLabel.text = _goodsDetail.goodsName;
    _subtitleLabel.text = _goodsDetail.goodsDesc;
    _tagCollectionView.backgroundColor = [UIColor clearColor];
    
    NSString *oldPrice = [NSString stringWithFormat:@"￥%d", (int)_goodsDetail.primePrice];
    NSString *nowPrice = [NSString stringWithFormat:@"￥%d", (int)_goodsDetail.currentPrice];
    
    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@%@", oldPrice, nowPrice]];
    [attrStr addAttributes:@{NSFontAttributeName: [UIFont systemFontOfSize:12],
                             NSForegroundColorAttributeName: COLOR_TEXT_III,
                             } range:NSMakeRange(0, oldPrice.length)];
    
    [attrStr addAttribute:NSStrikethroughStyleAttributeName value:[NSNumber numberWithInt:NSUnderlineStyleSingle] range:NSMakeRange(0, oldPrice.length)];
    
    [attrStr addAttributes:@{NSFontAttributeName: [UIFont systemFontOfSize:14],
                             NSForegroundColorAttributeName: APP_THEME_COLOR,
                             } range:NSMakeRange(oldPrice.length, nowPrice.length)];
    _priceLabel.attributedText = attrStr;
    _tagCollectionView.tagsList = _goodsDetail.store.tags;
    NSString *propertyStrig = [NSString stringWithFormat:@"%d%%满意  |  销量: %ld", (int)(_goodsDetail.rating), _goodsDetail.saleCount];
    [_propertyBtn setTitle:propertyStrig forState:UIControlStateNormal];
    _storeNameLabel.text = _goodsDetail.store.storeName;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

@end

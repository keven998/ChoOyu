//
//  GoodsOfCityTableViewCell.m
//  PeachTravel
//
//  Created by liangpengshuai on 11/5/15.
//  Copyright © 2015 com.aizou.www. All rights reserved.
//

#import "GoodsOfCityTableViewCell.h"

@implementation GoodsOfCityTableViewCell

- (void)awakeFromNib {
    _avatarImageView.layer.cornerRadius = 25.0;
    _avatarBkgView.layer.cornerRadius = 27.0;
    _avatarBkgView.clipsToBounds = YES;
    _avatarImageView.clipsToBounds = YES;
    _avatarImageView.image = [UIImage imageNamed:@"avatar_default.png"];
    _headerImageView.clipsToBounds = YES;
    [_ratingBtn setImage:[UIImage imageNamed:@"icon_rating"] forState:UIControlStateNormal];

}

- (void)setGoodsDetail:(GoodsDetailModel *)goodsDetail
{
    _goodsDetail = goodsDetail;
    _sellCountLabel.text = [NSString stringWithFormat:@"%ld", _goodsDetail.saleCount];
    
    [_headerImageView sd_setImageWithURL:[NSURL URLWithString:_goodsDetail.image.imageUrl] placeholderImage:nil];
    [_ratingBtn setTitle:[NSString stringWithFormat:@"%d%%", (int)_goodsDetail.rating] forState:UIControlStateNormal];
    NSString *oldPrice = [NSString stringWithFormat:@"￥%d", (int)_goodsDetail.primePrice];
    NSString *nowPrice = [NSString stringWithFormat:@"￥%d", (int)_goodsDetail.currentPrice];
    
    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@  %@", oldPrice, nowPrice]];
    [attrStr addAttributes:@{NSFontAttributeName: [UIFont systemFontOfSize:13],
                             NSForegroundColorAttributeName: COLOR_TEXT_II,
                             } range:NSMakeRange(0, oldPrice.length)];
    
    [attrStr addAttribute:NSStrikethroughStyleAttributeName value:[NSNumber numberWithInt:NSUnderlineStyleSingle] range:NSMakeRange(0, oldPrice.length)];
    
    [attrStr addAttributes:@{NSFontAttributeName: [UIFont systemFontOfSize:20],
                             NSForegroundColorAttributeName: UIColorFromRGB(0xff3300),
                             } range:NSMakeRange(oldPrice.length+2, nowPrice.length)];
    _priceLabel.attributedText = attrStr;

}

@end

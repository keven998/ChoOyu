//
//  GoodsRecommendTableViewCell.m
//  PeachTravel
//
//  Created by liangpengshuai on 10/23/15.
//  Copyright © 2015 com.aizou.www. All rights reserved.
//

#import "GoodsRecommendTableViewCell.h"

@interface GoodsRecommendTableViewCell()
@property (weak, nonatomic) IBOutlet UIImageView *goodsImageView;
@property (weak, nonatomic) IBOutlet UILabel *oldPriceLabel;
@property (weak, nonatomic) IBOutlet UILabel *nowPriceLabel;
@property (weak, nonatomic) IBOutlet UILabel *userNickName;
@property (weak, nonatomic) IBOutlet UILabel *cityNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *goodsNameLabel;
@property (weak, nonatomic) IBOutlet UIView *bgView;


@end

@implementation GoodsRecommendTableViewCell

- (void)awakeFromNib {
    _goodsImageView.clipsToBounds = YES;
    _bgView.layer.cornerRadius = 2.0;
    _bgView.clipsToBounds = YES;
}

- (void)setGoodsModel:(GoodsDetailModel *)goodsModel
{
    _goodsModel = goodsModel;
    [_goodsImageView sd_setImageWithURL:[NSURL URLWithString:_goodsModel.coverImage.imageUrl] placeholderImage:nil];
    _goodsNameLabel.text = _goodsModel.goodsName;
    NSString *primePriceStr = [NSString stringWithFormat:@"￥%d", (int)goodsModel.primePrice];
    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString: primePriceStr];
    [attrStr addAttribute:NSStrikethroughStyleAttributeName value:[NSNumber numberWithInt:NSUnderlineStyleSingle] range:NSMakeRange(0, primePriceStr.length)];
    _oldPriceLabel.attributedText = attrStr;
    _nowPriceLabel.text = [NSString stringWithFormat:@"￥%d", (int)goodsModel.currentPrice];

    _cityNameLabel.text = goodsModel.locality.zhName;
    _userNickName.text = goodsModel.store.storeName;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

}

@end

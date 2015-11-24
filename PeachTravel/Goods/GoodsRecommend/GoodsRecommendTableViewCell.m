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
@property (weak, nonatomic) IBOutlet UIImageView *bgImageView;
@property (weak, nonatomic) IBOutlet UILabel *oldPriceLabel;
@property (weak, nonatomic) IBOutlet UILabel *nowPriceLabel;
@property (weak, nonatomic) IBOutlet UILabel *userNickName;
@property (weak, nonatomic) IBOutlet UICollectionView *tagCollectionView;
@property (weak, nonatomic) IBOutlet UILabel *cityNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *goodsNameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *contentImageView;


@end

@implementation GoodsRecommendTableViewCell

- (void)awakeFromNib {
    [_contentImageView setImage:[[UIImage imageNamed: @"icon_goods_list_cell_bg.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(5, 5, 5, 5)]];
    [_bgImageView setImage:[[UIImage imageNamed:@"icon_goods_cell_mask"] resizableImageWithCapInsets:UIEdgeInsetsMake(5, 5, 5, 5)]];
    _tagCollectionView.backgroundColor = [UIColor clearColor];
}

- (void)setGoodsModel:(GoodsDetailModel *)goodsModel
{
    _goodsModel = goodsModel;
    [_goodsImageView sd_setImageWithURL:[NSURL URLWithString:_goodsModel.image.imageUrl] placeholderImage:nil];
    _goodsNameLabel.text = _goodsModel.goodsName;
    NSString *primePriceStr = [NSString stringWithFormat:@"%d", (int)goodsModel.primePrice];
    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString: primePriceStr];
    [attrStr addAttribute:NSStrikethroughStyleAttributeName value:[NSNumber numberWithInt:NSUnderlineStyleSingle] range:NSMakeRange(0, primePriceStr.length)];
    _oldPriceLabel.attributedText = attrStr;

}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

}

@end

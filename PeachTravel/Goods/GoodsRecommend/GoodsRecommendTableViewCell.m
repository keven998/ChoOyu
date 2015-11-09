//
//  GoodsRecommendTableViewCell.m
//  PeachTravel
//
//  Created by liangpengshuai on 10/23/15.
//  Copyright © 2015 com.aizou.www. All rights reserved.
//

#import "GoodsRecommendTableViewCell.h"

@interface GoodsRecommendTableViewCell()
@property (weak, nonatomic) IBOutlet UIImageView *goodImageView;
@property (weak, nonatomic) IBOutlet UIImageView *bgImageView;
@property (weak, nonatomic) IBOutlet UILabel *oldPriceLabel;
@property (weak, nonatomic) IBOutlet UILabel *nowPriceLabel;
@property (weak, nonatomic) IBOutlet UILabel *userNickName;
@property (weak, nonatomic) IBOutlet UICollectionView *tagCollectionView;
@property (weak, nonatomic) IBOutlet UILabel *cityName;
@property (weak, nonatomic) IBOutlet UILabel *goodName;
@property (weak, nonatomic) IBOutlet UIImageView *contentImageView;


@end

@implementation GoodsRecommendTableViewCell

- (void)awakeFromNib {
    [_contentImageView setImage:[[UIImage imageNamed: @"icon_goods_list_cell_bg.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(5, 5, 5, 5)]];
    [_bgImageView setImage:[[UIImage imageNamed:@"icon_goods_cell_mask"] resizableImageWithCapInsets:UIEdgeInsetsMake(5, 5, 5, 5)]];
     [_goodImageView sd_setImageWithURL:[NSURL URLWithString:@"http://images.taozilvxing.com/28c2d1ef35c12100e99fecddb63c436a?imageView2/2/w/1200"] placeholderImage:nil];
    _tagCollectionView.backgroundColor = [UIColor clearColor];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

}

@end

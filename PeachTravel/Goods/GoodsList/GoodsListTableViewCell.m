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
    _storeNameLabel.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
     [_headerImageView sd_setImageWithURL:[NSURL URLWithString:@"http://images.taozilvxing.com/28c2d1ef35c12100e99fecddb63c436a?imageView2/2/w/1200"] placeholderImage:nil];
    _titleLabel.text = @"保价德家庭式酒店";
    _subtitleLabel.text = @"我是一段¥自我介绍,我是一段¥自我介绍我是一段¥自我介绍我是一段¥自我介绍我是一段¥自我介绍.";
    _tagCollectionView.backgroundColor = [UIColor clearColor];
    
    NSString *oldPrice = @"$2198";
    NSString *nowPrice = @"$1198";
    
    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ %@", oldPrice, nowPrice]];
    [attrStr addAttributes:@{NSFontAttributeName: [UIFont systemFontOfSize:13],
                             NSForegroundColorAttributeName: COLOR_TEXT_III,
                             } range:NSMakeRange(0, oldPrice.length)];
    
    [attrStr addAttribute:NSStrikethroughStyleAttributeName value:[NSNumber numberWithInt:NSUnderlineStyleSingle] range:NSMakeRange(0, oldPrice.length)];
    
    [attrStr addAttributes:@{NSFontAttributeName: [UIFont systemFontOfSize:15],
                             NSForegroundColorAttributeName: APP_THEME_COLOR,
                             } range:NSMakeRange(oldPrice.length+1, nowPrice.length)];
    _priceLabel.attributedText = attrStr;

}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

@end

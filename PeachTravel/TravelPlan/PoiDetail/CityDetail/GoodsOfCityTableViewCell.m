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
    [_headerImageView sd_setImageWithURL:[NSURL URLWithString:@"http://images.taozilvxing.com/28c2d1ef35c12100e99fecddb63c436a?imageView2/2/w/1200"] placeholderImage:nil];
    _avatarImageView.layer.cornerRadius = 25.0;
    _avatarBkgView.layer.cornerRadius = 27.0;
    _avatarBkgView.clipsToBounds = YES;
    _avatarImageView.clipsToBounds = YES;
    _avatarImageView.image = [UIImage imageNamed:@"avatar_default.png"];
    
    [_ratingBtn setImage:[UIImage imageNamed:@"icon_rating"] forState:UIControlStateNormal];
    [_ratingBtn setTitle:@"100%" forState:UIControlStateNormal];
    
    NSString *oldPrice = @"$2198";
    NSString *nowPrice = @"$1198";
    
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

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

@end

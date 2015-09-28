//
//  PoiRecommendTableViewCell.m
//  PeachTravel
//
//  Created by liangpengshuai on 9/24/15.
//  Copyright © 2015 com.aizou.www. All rights reserved.
//

#import "PoiRecommendTableViewCell.h"

@implementation PoiRecommendTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

}


- (void)setPoi:(PoiRecommend *)poi
{
    _poi = poi;
    TaoziImage *image = [poi.images firstObject];
    [_backGroundImageView sd_setImageWithURL:[NSURL URLWithString:image.imageUrl]];
    _titleLabel.text = poi.zhName;
}
@end

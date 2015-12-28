//
//  CitySearchTableViewCell.m
//  PeachTravel
//
//  Created by liangpengshuai on 12/28/15.
//  Copyright © 2015 com.aizou.www. All rights reserved.
//

#import "CitySearchTableViewCell.h"

@implementation CitySearchTableViewCell

- (void)awakeFromNib {
    _headerImageView.clipsToBounds = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end

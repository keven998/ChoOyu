//
//  SearchResultTableViewCell.m
//  PeachTravel
//
//  Created by liangpengshuai on 12/9/14.
//  Copyright (c) 2014 com.aizou.www. All rights reserved.
//

#import "SearchResultTableViewCell.h"

@implementation SearchResultTableViewCell

- (void)awakeFromNib {
    self.layer.borderColor = APP_PAGE_COLOR.CGColor;
    self.layer.borderWidth = 0.8;
    self.layer.cornerRadius = 2.0;
    self.headerImageView.layer.cornerRadius = 2.0;
    self.headerImageView.clipsToBounds = YES;

}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end

//
//  PoiOnEditorTableViewCell.m
//  PeachTravel
//
//  Created by Luo Yong on 15/6/13.
//  Copyright (c) 2015年 com.aizou.www. All rights reserved.
//

#import "PoiOnEditorTableViewCell.h"

@implementation PoiOnEditorTableViewCell

- (void)awakeFromNib {
    // Initialization code
    UIView *bgview = [[UIView alloc] initWithFrame:self.frame];
    bgview.backgroundColor = [UIColor whiteColor];
    self.selectedBackgroundView = bgview;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)prepareForMove {
    _poiNameLabel.text = @"";
}

@end

//
//  GuiderCollectionCell.m
//  PeachTravel
//
//  Created by dapiao on 15/7/8.
//  Copyright (c) 2015年 com.aizou.www. All rights reserved.
//

#import "GuiderCollectionCell.h"
#import "PeachTravel-swift.h"

@implementation GuiderCollectionCell

- (void)awakeFromNib
{
    _headerImageView.clipsToBounds = YES;
    [_bkgImageView setImage:[[UIImage imageNamed:@"guider_cell_bg.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 10, 10)]];
    [_levelBtn setBackgroundImage:[UIImage imageNamed:@"master_level_bg.png"] forState:UIControlStateNormal];
}

- (void)setGuiderModel:(FrendModel *)guiderModel
{
    _guiderModel = guiderModel;
    
    _titleLabel.text = _guiderModel.nickName;
    
    NSString *subtitle;
    if (_guiderModel.age == 0) {
        subtitle = _guiderModel.residence;
    } else {
        subtitle = [NSString stringWithFormat:@"%@ %ld 岁", _guiderModel.residence, _guiderModel.age];
    }
    _subtitleLabel.text = subtitle;
    
    [_headerImageView sd_setImageWithURL:[NSURL URLWithString:_guiderModel.avatar] placeholderImage:nil];
}

@end

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
    [_levelBtn setTitle:[NSString stringWithFormat:@"V%ld", (long)_guiderModel.level] forState:UIControlStateNormal];
    
    NSString *subtitle;
    if (_guiderModel.age == 0) {
        subtitle = _guiderModel.residence;
    } else {
        subtitle = [NSString stringWithFormat:@"%@  %ld岁", _guiderModel.residence, (long)_guiderModel.age];
    }
    _subtitleLabel.text = subtitle;
    
    
    NSMutableAttributedString *cityStr = [[NSMutableAttributedString alloc] initWithString:@"服务城市: "];

    [cityStr addAttribute:NSForegroundColorAttributeName value:APP_THEME_COLOR range:NSMakeRange(0, 5)];
    _cityLabel.attributedText = cityStr;
    
    NSMutableAttributedString *commentStr = [[NSMutableAttributedString alloc] initWithString:@"派派点评: "];
    
    [commentStr addAttribute:NSForegroundColorAttributeName value:APP_THEME_COLOR range:NSMakeRange(0, 5)];
    _commentLabel.attributedText = commentStr;
    
    [_headerImageView sd_setImageWithURL:[NSURL URLWithString:_guiderModel.avatar] placeholderImage:nil];
}

@end

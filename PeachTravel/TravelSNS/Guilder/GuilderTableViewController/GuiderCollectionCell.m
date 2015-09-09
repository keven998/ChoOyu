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

- (void)setGuiderModel:(ExpertModel *)guiderModel
{
    _guiderModel = guiderModel;
    
//    _guiderModel.allZone = @[@"上海",@"北京",@"安徽",@"黑龙江"];
//    _guiderModel.profile = @"我真的很牛逼,,不管你信不信,反正我是信了";
    
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
    
    NSMutableString *allCityStr = [NSMutableString string];
    int i = 0;
    for (NSString *cityName in _guiderModel.allZone) {
        if(i > 0) {
            NSString *newCityName = [NSString stringWithFormat:@"·%@",cityName];
            [allCityStr appendString:newCityName];
        } else {
            NSString *newCityName = [NSString stringWithFormat:@"%@",cityName];
            [allCityStr appendString:newCityName];
        }
        i++;
    }
    
    NSAttributedString *allCityAttr = [[NSAttributedString alloc] initWithString:allCityStr];
    [cityStr appendAttributedString:allCityAttr];

    [cityStr addAttribute:NSForegroundColorAttributeName value:APP_THEME_COLOR range:NSMakeRange(0, 5)];
    [cityStr addAttribute:NSForegroundColorAttributeName value:TEXT_COLOR_TITLE range:NSMakeRange(5, cityStr.length-5)];
    _cityLabel.attributedText = cityStr;
    
    
    NSString *realCommentStr = [NSString stringWithFormat:@"派派点评: %@",_guiderModel.profile];
    NSMutableAttributedString *commentStr = [[NSMutableAttributedString alloc] initWithString:realCommentStr];
    
    [commentStr addAttribute:NSForegroundColorAttributeName value:APP_THEME_COLOR range:NSMakeRange(0, 5)];
    [commentStr addAttribute:NSForegroundColorAttributeName value:TEXT_COLOR_TITLE range:NSMakeRange(5, commentStr.length-5)];
    _commentLabel.attributedText = commentStr;
    
    [_headerImageView sd_setImageWithURL:[NSURL URLWithString:_guiderModel.avatar] placeholderImage:nil];
}

@end

//
//  GoodsRecommendSectionHeaderView.m
//  PeachTravel
//
//  Created by liangpengshuai on 10/23/15.
//  Copyright © 2015 com.aizou.www. All rights reserved.
//

#import "GoodsRecommendSectionHeaderView.h"

@interface GoodsRecommendSectionHeaderView()

@property (weak, nonatomic) IBOutlet UIButton *titleBtn;

@end

@implementation GoodsRecommendSectionHeaderView

+ (id)initViewFromNib
{
    return [[[NSBundle mainBundle] loadNibNamed:@"GoodsRecommendSectionHeaderView" owner:nil options:nil] lastObject];
}

- (void)setTitle:(NSString *)title
{
    _title = title;
    [_titleBtn setTitle:_title forState:UIControlStateNormal];
    if ([title isEqualToString:@"特价折扣"]) {
        [_titleBtn setImage:[UIImage imageNamed:@"icon_goods_discount"] forState:UIControlStateNormal];
        [_titleBtn setTitleColor:UIColorFromRGB(0xFB4D53) forState:UIControlStateNormal];
        
    } else if ([title isEqualToString:@"热门玩乐"]) {
        [_titleBtn setImage:[UIImage imageNamed:@"icon_goods_hot"] forState:UIControlStateNormal];
        [_titleBtn setTitleColor:UIColorFromRGB(0xFB4D53) forState:UIControlStateNormal];
        
    } else {
        [_titleBtn setImage:[UIImage imageNamed:@"icon_goods_recommend"] forState:UIControlStateNormal];
        [_titleBtn setTitleColor:APP_THEME_COLOR forState:UIControlStateNormal];
    }
    
}


@end

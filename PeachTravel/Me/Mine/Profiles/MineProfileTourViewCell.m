//
//  MineProfileTourViewCell.m
//  PeachTravel
//
//  Created by 王聪 on 15/9/6.
//  Copyright (c) 2015年 com.aizou.www. All rights reserved.
//

#import "MineProfileTourViewCell.h"

@implementation MineProfileTourViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self setupMainView];
    }
    return self;
}

- (void)setupMainView
{
    ExpertTourView *footprintBtn = [[ExpertTourView alloc] initWithFrame:CGRectMake(0, 0, kWindowWidth/2, self.frame.size.height)];
    footprintBtn.iconImage.image = [UIImage imageNamed:@"travel"];
    self.footprintBtn = footprintBtn;
    [self addSubview:footprintBtn];
    
    ExpertTourView *planBtn = [[ExpertTourView alloc] initWithFrame:CGRectMake(kWindowWidth/2, 0, kWindowWidth/2, self.frame.size.height)];
    planBtn.iconImage.image = [UIImage imageNamed:@"plan"];
    self.planBtn = planBtn;
    [self addSubview:planBtn];
    
}

- (void)setUserInfo:(AccountModel *)userInfo
{
    _userInfo = userInfo;
    
    NSString *coutryCount = [NSString stringWithFormat:@"%ld",_userInfo.countryCount];
    NSString *cityCount = [NSString stringWithFormat:@"%ld",_userInfo.cityCount];
    NSString *footprint = [NSString stringWithFormat:@"旅行%ld个国家 共%ld个城市",_userInfo.countryCount,_userInfo.cityCount];
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:footprint];
    [str addAttribute:NSForegroundColorAttributeName value:APP_THEME_COLOR range:NSMakeRange(2, coutryCount.length)];
    [str addAttribute:NSForegroundColorAttributeName value:APP_THEME_COLOR range:NSMakeRange(footprint.length-cityCount.length-3, cityCount.length)];
    self.footprintBtn.titleLab.attributedText = str;
    
    NSString *guiderCount = [NSString stringWithFormat:@"%ld",_userInfo.guideCnt];
    NSString *plan = [NSString stringWithFormat:@"共%ld份旅行计划",_userInfo.guideCnt];
    NSMutableAttributedString *planStr = [[NSMutableAttributedString alloc] initWithString:plan];
    [planStr addAttribute:NSForegroundColorAttributeName value:APP_THEME_COLOR range:NSMakeRange(1, guiderCount.length)];
    self.planBtn.titleLab.attributedText = planStr;

}


@end

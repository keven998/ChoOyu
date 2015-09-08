//
//  GuiderProfileTourViewCell.m
//  PeachTravel
//
//  Created by 王聪 on 8/28/15.
//  Copyright (c) 2015 com.aizou.www. All rights reserved.
//

#import "GuiderProfileTourViewCell.h"
#import "PeachTravel-swift.h"
@implementation GuiderProfileTourViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self setupMainView];
    }
    return self;
}

- (void)setupMainView
{
    ExpertTourView *footprintBtn = [[ExpertTourView alloc] initWithFrame:CGRectMake(0, 0, kWindowWidth/3, 132)];
    footprintBtn.iconImage.image = [UIImage imageNamed:@"travel"];
    footprintBtn.titleLab.numberOfLines = 0;
    self.footprintBtn = footprintBtn;
    [self addSubview:footprintBtn];
    
    
    ExpertTourView *planBtn = [[ExpertTourView alloc] initWithFrame:CGRectMake(kWindowWidth/3, 0, kWindowWidth/3, 132)];
    planBtn.iconImage.image = [UIImage imageNamed:@"plan"];
    self.planBtn = planBtn;
    [self addSubview:planBtn];
    
    
    ExpertTourView *tourBtn = [[ExpertTourView alloc] initWithFrame:CGRectMake(kWindowWidth/3*2, 0, kWindowWidth/3, 132)];
    tourBtn.iconImage.image = [UIImage imageNamed:@"youji"];
    self.tourBtn = tourBtn;
    [self addSubview:tourBtn];
}

- (void)setUserInfo:(FrendModel *)userInfo
{
    _userInfo = userInfo;
    
    NSLog(@"%@",_userInfo);
    
    NSString *coutryCount = [NSString stringWithFormat:@"%ld",_userInfo.footprintCountryCount];
    NSString *cityCount = [NSString stringWithFormat:@"%ld",_userInfo.footprintCityCount];
    NSString *footprint = [NSString stringWithFormat:@"旅行%ld个国家 共%ld个城市",_userInfo.footprintCountryCount,_userInfo.footprintCityCount];
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:footprint];
    [str addAttribute:NSForegroundColorAttributeName value:APP_THEME_COLOR range:NSMakeRange(2, coutryCount.length)];
    [str addAttribute:NSForegroundColorAttributeName value:APP_THEME_COLOR range:NSMakeRange(footprint.length-cityCount.length-3, cityCount.length)];
    self.footprintBtn.titleLab.attributedText = str;
    
    NSString *guiderCount = [NSString stringWithFormat:@"%ld",_userInfo.guideCount];
    NSString *plan = [NSString stringWithFormat:@"共%ld份旅行计划",_userInfo.guideCount];
    NSMutableAttributedString *planStr = [[NSMutableAttributedString alloc] initWithString:plan];
    [planStr addAttribute:NSForegroundColorAttributeName value:APP_THEME_COLOR range:NSMakeRange(1, guiderCount.length)];
    self.planBtn.titleLab.attributedText = planStr;
    
    NSString *tourCount = [NSString stringWithFormat:@"%ld",_userInfo.guideCount];
    NSString *tour = [NSString stringWithFormat:@"完成%ld篇旅行游记",_userInfo.guideCount];
    NSMutableAttributedString *tourStr = [[NSMutableAttributedString alloc] initWithString:tour];
    [tourStr addAttribute:NSForegroundColorAttributeName value:APP_THEME_COLOR range:NSMakeRange(2, tourCount.length)];
    self.tourBtn.titleLab.attributedText = tourStr;

}

@end

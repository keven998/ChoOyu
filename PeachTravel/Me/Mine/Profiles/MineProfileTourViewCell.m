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
    ExpertTourView *footprintBtn = [[ExpertTourView alloc] initWithFrame:CGRectMake(0, 0, kWindowWidth/3, self.frame.size.height)];
    footprintBtn.iconImage.image = [UIImage imageNamed:@"travel"];
    self.footprintBtn = footprintBtn;
    [self addSubview:footprintBtn];
    
    
    ExpertTourView *planBtn = [[ExpertTourView alloc] initWithFrame:CGRectMake(kWindowWidth/3, 0, kWindowWidth/3, self.frame.size.height)];
    planBtn.iconImage.image = [UIImage imageNamed:@"plan"];
    self.planBtn = planBtn;
    [self addSubview:planBtn];
    
    
    ExpertTourView *tourBtn = [[ExpertTourView alloc] initWithFrame:CGRectMake(kWindowWidth/3*2, 0, kWindowWidth/3, self.frame.size.height)];
    tourBtn.iconImage.image = [UIImage imageNamed:@"youji"];
    self.tourBtn = tourBtn;
    [self addSubview:tourBtn];
}


@end

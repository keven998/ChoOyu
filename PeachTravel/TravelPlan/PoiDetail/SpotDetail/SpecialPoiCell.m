//
//  SpecialPoiCell.m
//  PeachTravel
//
//  Created by dapiao on 15/7/2.
//  Copyright (c) 2015年 com.aizou.www. All rights reserved.
//

#import "SpecialPoiCell.h"

@implementation SpecialPoiCell

- (void)awakeFromNib {
    _planBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 80, 80)];
    [_planBtn setBackgroundImage:[UIImage imageNamed:@"poi_button_raid_default.png"] forState:UIControlStateNormal];
    [self addSubview:_planBtn];
    
    _tipsBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 80, 80)];
    [_tipsBtn setBackgroundImage:[UIImage imageNamed:@"poi_button_tip_default.png"] forState:UIControlStateNormal];
    [self addSubview:_tipsBtn];
    
    _trafficBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 80, 80)];
    [_trafficBtn setBackgroundImage:[UIImage imageNamed:@"poi_button_traffic_default.png"] forState:UIControlStateNormal];
    [self addSubview:_trafficBtn];

}

- (void)layoutSubviews{
    CGFloat spaceWidth = (self.bounds.size.width-3*_planBtn.bounds.size.width)/4;
    [_planBtn setFrame:CGRectMake(spaceWidth, 23, _planBtn.bounds.size.width, _planBtn.bounds.size.height)];
    [_tipsBtn setFrame:CGRectMake(spaceWidth*2 + _planBtn.bounds.size.width, 23, _planBtn.bounds.size.width, _planBtn.bounds.size.height)];
    [_trafficBtn setFrame:CGRectMake(spaceWidth*3 + _planBtn.bounds.size.width*2, 23, _planBtn.bounds.size.width, _planBtn.bounds.size.height)];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end

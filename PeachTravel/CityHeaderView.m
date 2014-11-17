//
//  CityHeaderView.m
//  PeachTravel
//
//  Created by liangpengshuai on 11/13/14.
//  Copyright (c) 2014 com.aizou.www. All rights reserved.
//

#import "CityHeaderView.h"

@interface CityHeaderView ()

@property (weak, nonatomic) IBOutlet UIImageView *cityImageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIButton *likeBtn;
@property (weak, nonatomic) IBOutlet UILabel *descLabel;
@property (weak, nonatomic) IBOutlet UILabel *costTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *seasonLabel;

@end

@implementation CityHeaderView

+ (CityHeaderView *)instanceHeaderView
{
    NSArray* nibView =  [[NSBundle mainBundle] loadNibNamed:@"CityHeaderView" owner:nil options:nil];
    return [nibView objectAtIndex:0];
}


- (void)setTitle:(NSString *)title
{
    _title = title;
    _titleLabel.text = _title;
}

- (void)setCityImage:(NSString *)cityImage
{
    _cityImage = cityImage;
    [_cityImageView sd_setImageWithURL:[NSURL URLWithString:cityImage] placeholderImage:nil];
}

- (void)setTimeCost:(double)timeCost
{
    _timeCost = timeCost;
    _costTimeLabel.text = [NSString stringWithFormat:@"%f天", timeCost];
}

- (void)setDesc:(NSString *)desc
{
    _desc = desc;
    _descLabel.text = _desc;
}

- (void)setTravelMonth:(NSString *)travelMonth
{
    _travelMonth = travelMonth;
    _seasonLabel.text = _travelMonth;
}

@end

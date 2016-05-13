//
//  CityHeaderView.h
//  PeachTravel
//
//  Created by liangpengshuai on 11/13/14.
//  Copyright (c) 2014 com.aizou.www. All rights reserved.
//

#import "CityDetailHeaderView.h"
#import "CityDescDetailViewController.h"
#import "SuperWebViewController.h"
#import "AddPoiViewController.h"
#import "TravelNoteListViewController.h"
#import "PoisOfCityViewController.h"
#import "TripDetailRootViewController.h"
#import "TripPlanSettingViewController.h"

@interface CityDetailHeaderView ()

@property (nonatomic, strong) UILabel *zhNameLabel;
@property (nonatomic, strong) UILabel *enNameLabel;
@property (nonatomic, strong) UIButton *allPictureBtn;

@end

@implementation CityDetailHeaderView

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = APP_PAGE_COLOR;
        
    }
    return self;
}

- (void)setUpView
{
    CGRect frame = self.frame;
    _headerImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, 174)];
    _headerImageView.contentMode = UIViewContentModeScaleAspectFill;
    _headerImageView.clipsToBounds = YES;
    TaoziImage *image = [self.cityPoi.images firstObject];
    [_headerImageView sd_setImageWithURL:[NSURL URLWithString:image.imageUrl] placeholderImage:nil];
    _headerImageView.userInteractionEnabled = YES;
    [self addSubview:_headerImageView];
    
    _zhNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 110, frame.size.width, 25)];
    _zhNameLabel.textColor = [UIColor whiteColor];
    _zhNameLabel.font = [UIFont boldSystemFontOfSize:23];
    _zhNameLabel.text = _cityPoi.zhName;
    
    [self addSubview:_zhNameLabel];
    
    _enNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 140, _zhNameLabel.bounds.size.width, 20)];
    _enNameLabel.textColor = [UIColor whiteColor];
    _enNameLabel.font = [UIFont systemFontOfSize:16];
    _enNameLabel.text = _cityPoi.enName;
    [self addSubview:_enNameLabel];
    
    _allPictureBtn = [[UIButton alloc] initWithFrame:CGRectMake(frame.size.width-50, 135, 40, 20)];
    _allPictureBtn.titleLabel.font = [UIFont systemFontOfSize:12.0];
    [_allPictureBtn setTitle:@"图集" forState:UIControlStateNormal];
    [_allPictureBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    _allPictureBtn.layer.borderColor = [UIColor whiteColor].CGColor;
    _allPictureBtn.layer.borderWidth = 0.5;
    _allPictureBtn.layer.cornerRadius = 3.0;
    _allPictureBtn.userInteractionEnabled = NO;
    [self addSubview:_allPictureBtn];
}

- (void)setCityPoi:(CityPoi *)cityPoi
{
    _cityPoi = cityPoi;
    [self setUpView];
}


@end




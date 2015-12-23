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

@interface CityDetailHeaderView ()

@property (nonatomic, strong) UIImageView *headerImageView;
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
    
    UIView *btnBkgView = [[UIView alloc] initWithFrame:CGRectMake(0, 174, frame.size.width, 170)];
    btnBkgView.backgroundColor = [UIColor whiteColor];
    [self addSubview:btnBkgView];
    
    NSArray *buttonArray = @[
                             @{@"picN":@"icon_cityDetail_desc",@"title":@"简介",@"selector":@"cityDescAction"},
                             @{@"picN":@"icon_cityDetail_guide",@"title":@"指南",@"selector":@"cityGuideAction"},
                             @{@"picN":@"icon_cityDetail_traffic",@"title":@"交通",@"selector":@"cityTrafficAction"},
                             @{@"picN":@"icon_cityDetail_spot",@"title":@"景点",@"selector":@"spotsOfCityAction"},
                             @{@"picN":@"icon_cityDetail_travel",@"title":@"行程",@"selector":@"guidesOfCityAction"},
                             @{@"picN":@"icon_cityDetail_travelNote",@"title":@"游记",@"selector":@"travelNoteOfCityAction"},
                             @{@"picN":@"icon_cityDetail_restaurant",@"title":@"美食",@"selector":@"foodsOfCityAction"},
                             @{@"picN":@"icon_cityDetail_shopping",@"title":@"购物",@"selector":@"shoppingAction"},
                             ];
    
    
    CGFloat itemMargin = 5;
    CGFloat itemWidth = 50;
    CGFloat itemHeight = 70;
    CGFloat itemSpace = (frame.size.width-10-itemWidth*4)/5;
    
    for (int i=0; i<4; i++) {
        TZButton *buttonTop = [[TZButton alloc] initWithFrame:CGRectMake(itemMargin+itemSpace*(i+1)+itemWidth*i, 15, itemWidth, itemHeight)];
        buttonTop.spaceHight = 8;
        [buttonTop setTitleColor:COLOR_TEXT_II forState:UIControlStateNormal];
        buttonTop.titleLabel.font = [UIFont systemFontOfSize:14];
        TZButton *buttonButtom = [[TZButton alloc] initWithFrame:CGRectMake(itemMargin+itemSpace*(i+1)+itemWidth*i, 20+ itemHeight, itemWidth, itemHeight)];
        buttonButtom.spaceHight = 8;
        [buttonButtom setTitleColor:COLOR_TEXT_II forState:UIControlStateNormal];
        buttonButtom.titleLabel.font = [UIFont systemFontOfSize:14];
        NSString *buttomBtnSelector = [[buttonArray objectAtIndex:i+4] objectForKey:@"selector"];
        [buttonButtom addTarget:self action:NSSelectorFromString(buttomBtnSelector) forControlEvents:UIControlEventTouchUpInside];
        NSString *topBtnSelector = [[buttonArray objectAtIndex:i] objectForKey:@"selector"];
        [buttonTop addTarget:self action:NSSelectorFromString(topBtnSelector) forControlEvents:UIControlEventTouchUpInside];
        [buttonTop setImage:[UIImage imageNamed:[[buttonArray objectAtIndex:i] objectForKey:@"picN"]] forState:UIControlStateNormal];
        [buttonTop setTitle:[[buttonArray objectAtIndex:i] objectForKey:@"title"] forState:UIControlStateNormal];
        [buttonButtom setImage:[UIImage imageNamed:[[buttonArray objectAtIndex:i+4] objectForKey:@"picN"]] forState:UIControlStateNormal];
        [buttonButtom setTitle:[[buttonArray objectAtIndex:i+4] objectForKey:@"title"] forState:UIControlStateNormal];
        [btnBkgView addSubview:buttonTop];
        [btnBkgView addSubview:buttonButtom];
        
    }
}

- (void)setCityPoi:(CityPoi *)cityPoi
{
    _cityPoi = cityPoi;
    [self setUpView];
}

- (void)cityDescAction
{
    CityDescDetailViewController *ctl = [[CityDescDetailViewController alloc] init];

    ctl.desc = _cityPoi.desc;
    [self.containerViewController.navigationController pushViewController:ctl animated:YES];
    
}

- (void)cityGuideAction
{
    SuperWebViewController *funOfCityWebCtl = [[SuperWebViewController alloc] init];
    funOfCityWebCtl.urlStr = _cityPoi.playGuide;
    funOfCityWebCtl.titleStr = @"旅游指南";;
    [self.containerViewController.navigationController pushViewController:funOfCityWebCtl animated:YES];
}

- (void)cityTrafficAction
{
    SuperWebViewController *funOfCityWebCtl = [[SuperWebViewController alloc] init];
    funOfCityWebCtl.urlStr = _cityPoi.playGuide;
    funOfCityWebCtl.titleStr = @"旅游指南";
    [self.containerViewController.navigationController pushViewController:funOfCityWebCtl animated:YES];
}

- (void)spotsOfCityAction
{
    AddPoiViewController *addCtl = [[AddPoiViewController alloc] init];
    addCtl.cityId = _cityPoi.poiId;
    addCtl.cityName = self.cityPoi.zhName;
    addCtl.shouldEdit = NO;
    addCtl.poiType = kSpotPoi;
    [self.containerViewController.navigationController pushViewController:addCtl animated:YES];
    
}

- (void)guidesOfCityAction
{
    
}

- (void)travelNoteOfCityAction
{
    TravelNoteListViewController *travelListCtl = [[TravelNoteListViewController alloc] init];
    travelListCtl.isSearch = NO;
    travelListCtl.cityId = _cityPoi.poiId;
    travelListCtl.cityName = _cityPoi.zhName;
    [self.containerViewController.navigationController pushViewController:travelListCtl animated:YES];
}

- (void)foodsOfCityAction
{
    PoisOfCityViewController *restaurantOfCityCtl = [[PoisOfCityViewController alloc] init];
    restaurantOfCityCtl.shouldEdit = NO;
    restaurantOfCityCtl.cityId = _cityPoi.poiId;
    restaurantOfCityCtl.descDetail = _cityPoi.diningTitles;
    restaurantOfCityCtl.zhName = _cityPoi.zhName;
    restaurantOfCityCtl.poiType = kRestaurantPoi;
    [self.containerViewController.navigationController pushViewController:restaurantOfCityCtl animated:YES];
}

- (void)shoppingAction
{
    PoisOfCityViewController *shoppingOfCityCtl = [[PoisOfCityViewController alloc] init];
    shoppingOfCityCtl.shouldEdit = NO;
    shoppingOfCityCtl.descDetail = _cityPoi.shoppingTitles;
    shoppingOfCityCtl.cityId = _cityPoi.poiId;
    shoppingOfCityCtl.zhName = _cityPoi.zhName;
    shoppingOfCityCtl.poiType = kShoppingPoi;
    [self.containerViewController.navigationController pushViewController:shoppingOfCityCtl animated:YES];
    
}

@end




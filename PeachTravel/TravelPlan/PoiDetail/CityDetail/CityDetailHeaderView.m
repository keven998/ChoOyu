//
//  CityHeaderView.h
//  PeachTravel
//
//  Created by liangpengshuai on 11/13/14.
//  Copyright (c) 2014 com.aizou.www. All rights reserved.
//

#import "CityDetailHeaderView.h"
#import "AutoSlideScrollView.h"

@interface CityDetailHeaderView ()

@property (nonatomic, strong) AutoSlideScrollView *scrollView;
@property (nonatomic, strong) UILabel *travelMonthLabel;
@property (nonatomic, strong) UILabel *zhNameLabel;
@property (nonatomic, strong) UILabel *enNameLabel;
@property (nonatomic, strong) UIButton *pictureIndexBtn;
@property (nonatomic, strong) UIButton *goodsCountBtn;

@end

@implementation CityDetailHeaderView

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.contentView.backgroundColor = APP_PAGE_COLOR;
        _scrollView = [[AutoSlideScrollView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, 214)];
        _scrollView.backgroundColor = APP_THEME_COLOR;
        [self addSubview:_scrollView];
        
        _zhNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 150, frame.size.width, 25)];
        _zhNameLabel.textColor = [UIColor whiteColor];
        _zhNameLabel.font = [UIFont boldSystemFontOfSize:23];
        _zhNameLabel.text = @"韩国";

        [self addSubview:_zhNameLabel];
        
        _enNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 180, _zhNameLabel.bounds.size.width, 20)];
        _enNameLabel.textColor = [UIColor whiteColor];
        _enNameLabel.font = [UIFont systemFontOfSize:16];
        _enNameLabel.text = @"Korea";
        [self addSubview:_enNameLabel];
        
        _pictureIndexBtn = [[UIButton alloc] initWithFrame:CGRectMake(frame.size.width-50, 190, 45, 15)];
        [_pictureIndexBtn setImage:[UIImage imageNamed:@"icon_cityDetail_imageCnt"] forState:UIControlStateNormal];
        _pictureIndexBtn.titleLabel.font = [UIFont systemFontOfSize:12.0];
        [_pictureIndexBtn setTitle:@"1/2" forState:UIControlStateNormal];
        _pictureIndexBtn.titleEdgeInsets = UIEdgeInsetsMake(0, 5, 0, 0);
        [_pictureIndexBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self addSubview:_pictureIndexBtn];
        
        _travelMonthLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 214, frame.size.width-90, 40)];
        _travelMonthLabel.textColor = COLOR_TEXT_II;
        _travelMonthLabel.font = [UIFont systemFontOfSize:14];
        _travelMonthLabel.text = [NSString stringWithFormat:@"推荐旅行时间: %@", _cityPoi.travelMonth];
        [self addSubview:_travelMonthLabel];

        _goodsCountBtn = [[UIButton alloc] initWithFrame:CGRectMake(frame.size.width-80, 214, 50, 40)];
        [_goodsCountBtn setImage:[UIImage imageNamed:@"icon_cityDetail_goodsCnt"] forState:UIControlStateNormal];
        [_goodsCountBtn setTitle:[NSString stringWithFormat:@"%ld", _cityPoi.goodsCount] forState:UIControlStateNormal];
        _goodsCountBtn.titleEdgeInsets = UIEdgeInsetsMake(0, 5, 0, 0);
        [_goodsCountBtn setTitleColor:COLOR_TEXT_II forState:UIControlStateNormal];
        _goodsCountBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        _goodsCountBtn.userInteractionEnabled = NO;
        [self addSubview:_goodsCountBtn];
        
        UIView *btnBkgView = [[UIView alloc] initWithFrame:CGRectMake(0, 254, frame.size.width, 196)];
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
            TZButton *buttonButtom = [[TZButton alloc] initWithFrame:CGRectMake(itemMargin+itemSpace*(i+1)+itemWidth*i, 15 + 20+ itemHeight, itemWidth, itemHeight)];
            buttonButtom.spaceHight = 8;
            [buttonButtom setTitleColor:COLOR_TEXT_II forState:UIControlStateNormal];
            buttonButtom.titleLabel.font = [UIFont systemFontOfSize:14];
            NSString *buttomBtnSelector = [[buttonArray objectAtIndex:i] objectForKey:@"selector"];
            [buttonButtom addTarget:self action:NSSelectorFromString(buttomBtnSelector) forControlEvents:UIControlEventTouchUpInside];

            [buttonTop setImage:[UIImage imageNamed:[[buttonArray objectAtIndex:i] objectForKey:@"picN"]] forState:UIControlStateNormal];
            [buttonTop setTitle:[[buttonArray objectAtIndex:i] objectForKey:@"title"] forState:UIControlStateNormal];
            [buttonButtom setImage:[UIImage imageNamed:[[buttonArray objectAtIndex:i+4] objectForKey:@"picN"]] forState:UIControlStateNormal];
            [buttonButtom setTitle:[[buttonArray objectAtIndex:i+4] objectForKey:@"title"] forState:UIControlStateNormal];
            [btnBkgView addSubview:buttonTop];
            [btnBkgView addSubview:buttonButtom];
            
        }
        
    }
    return self;
}

- (void)cityDescAction
{
    
}

- (void)cityGuideAction
{
    
}

- (void)cityTrafficAction
{
    
}

- (void)spotsOfCityAction
{
    
}

- (void)guidesOfCityAction
{
    
}

- (void)travelNoteOfCityAction
{
    
}

- (void)foodsOfCityAction
{
    
}

- (void)shoppingAction
{
    
}

@end




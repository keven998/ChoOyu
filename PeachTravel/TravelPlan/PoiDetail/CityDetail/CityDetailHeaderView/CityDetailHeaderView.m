//
//  CityDetailHeaderView.m
//  CityDetailHeaderView
//
//  Created by 冯宁 on 15/9/21.
//  Copyright © 2015年 PeachTravel. All rights reserved.
//

#import "CityDetailHeaderView.h"
#import "TopImageView.h"
#import "ArgumentsOfCityDetailHeaderView.h"
#import "Constants.h"
#import "CityDetailHeaderBtnSqure.h"
#import "ResizableView.h"
#import "MWPhotoBrowser.h"
#import "CityDetailTableViewController.h"
#import "CityImageAlbum.h"

#import "CityDetailHeaderBottomView.h"

@interface CityDetailHeaderView () <CityDetailHeaderBottomViewDelegate>

@property (nonatomic, strong) TopImageView* topView;
@property (nonatomic, strong) CityDetailHeaderBottomView* bottomView;
@property (nonatomic, strong) UILabel* bestTravelTimeLabel;
@property (nonatomic, strong) UILabel* descriptionLabel;
@property (nonatomic, strong) UILabel* checkAllLabel;

@end

@implementation CityDetailHeaderView

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithReuseIdentifier:reuseIdentifier]) {
        
    }
    return self;
}
- (void)layoutSubviews{
    [super layoutSubviews];
}
- (void)layoutSublayersOfLayer:(CALayer *)layer{
    [super layoutSublayersOfLayer:layer];
}

- (CGFloat)headerHeight{
//    CityDetailHeaderView* head = [[CityDetailHeaderView alloc] init];
    [super layoutIfNeeded];
    return CGRectGetMaxY(self.bottomView.frame);
}

- (void)setUpViews{
    [self.contentView addSubview:self.topView];
    [self.contentView addSubview:self.bestTravelTimeLabel];
    [self.contentView addSubview:self.descriptionLabel];
    [self.descriptionLabel addSubview:self.checkAllLabel];
    [self.contentView addSubview:self.bottomView];
    
    self.bestTravelTimeLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.descriptionLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.topView.translatesAutoresizingMaskIntoConstraints = NO;
    self.checkAllLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.bottomView.translatesAutoresizingMaskIntoConstraints = NO;
    
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    
    NSDictionary* metrics = @{@"margins":[NSNumber numberWithInteger:MARGIN_S],@"marginm":[NSNumber numberWithInteger:MARGIN_M],@"titleSize":@TITLE_FONT_SIZE,@"detailSize":@DETAIL_FONT_SIZE,@"minBestHeight":@DETAIL_FONT_SIZE,@"minDesHeight":@(DESCRIPTION_FONT_SIZE*3 + 3),@"topWidth":@(screenWidth - MARGIN_S * 2),@"topHeight":@(self.topView.height)};
    NSDictionary* dict = @{@"top":self.topView,@"best":self.bestTravelTimeLabel,@"description":self.descriptionLabel,@"check":self.checkAllLabel,@"bottom":self.bottomView,};
    
//    self.topView.frame = CGRectMake(0, 0, screenWidth, 200);
//    self.bestTravelTimeLabel.frame = CGRectMake(0, 0, screenWidth, 200);
//    self.descriptionLabel.frame = CGRectMake(0, 0, screenWidth, 200);
//    self.checkAllLabel.frame =CGRectMake(0, 0, screenWidth, 200);
//    self.bottomView.frame = CGRectMake(0, 0, screenWidth, 200);
    
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.topView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0]];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.topView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:screenWidth - MARGIN_S * 2]];
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(==margins)-[top(==topHeight)]-[best]-[description]-[bottom]" options:0 metrics:metrics views:dict]];
//    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(==margins)-[best]-[description]-[bottom]" options:0 metrics:metrics views:dict]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(==margins)-[best]-(==margins)-|" options:0 metrics:metrics views:dict]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(==margins)-[description]-(==margins)-|" options:0 metrics:metrics views:dict]];
    
    [self.descriptionLabel addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[check]-0-|" options:0 metrics:nil views:dict]];
    [self.descriptionLabel addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[check]-0-|" options:0 metrics:nil views:dict]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[bottom]-0-|" options:0 metrics:nil views:dict]];
    
    
    if (self.descriptionLabel.text) {
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc]initWithString:self.descriptionLabel.text];;
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc]init];
        [paragraphStyle setLineSpacing:5];
        [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, self.descriptionLabel.text.length)];
        
        self.descriptionLabel.attributedText = attributedString;
    }
}

#pragma mark - delegate

- (void)restaurantBtnAction{
    if ([self.delegate respondsToSelector:@selector(restaurantBtnAction)]) {
        [self.delegate restaurantBtnAction];
    }
}
- (void)spotBtnAction{
    if ([self.delegate respondsToSelector:@selector(spotBtnAction)]) {
        [self.delegate spotBtnAction];
    }
}
- (void)guideBtnAction{
    if ([self.delegate respondsToSelector:@selector(guideBtnAction)]) {
        [self.delegate guideBtnAction];
    }
}
- (void)shoppingBtnAction{
    if ([self.delegate respondsToSelector:@selector(shoppingBtnAction)]) {
        [self.delegate shoppingBtnAction];
    }
}
- (void)planBtnAction{
    if ([self.delegate respondsToSelector:@selector(planBtnAction)]) {
        [self.delegate planBtnAction];
    }
}
- (void)journeyBtnAction{
    if ([self.delegate respondsToSelector:@selector(journeyBtnAction)]) {
        [self.delegate journeyBtnAction];
    }
}
- (void)imageListAction{

        [self performSelector:@selector(viewImage:)];

}
- (void)travelMonthAction{
    if ([self.delegate respondsToSelector:@selector(travelMonthAction)]) {
        [self.delegate travelMonthAction];
    }
}
- (void)descriptionAction{
    if ([self.delegate respondsToSelector:@selector(descriptionAction)]) {
        [self.delegate descriptionAction];
    }
}


#pragma mark - setter & getter
- (TopImageView *)topView{
    if (_topView == nil) {
        _topView = [[TopImageView alloc] init];
        [_topView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageListAction)]];
    }
    return _topView;
}
- (UILabel *)bestTravelTimeLabel{
    if (_bestTravelTimeLabel == nil) {
        _bestTravelTimeLabel = [[UILabel alloc] init];
        _bestTravelTimeLabel.font = [UIFont systemFontOfSize:DETAIL_FONT_SIZE];
        _bestTravelTimeLabel.textColor = TEXT_COLOR_TITLE_SUBTITLE;
        _bestTravelTimeLabel.text = @"最佳游玩时间 · 03-05月 08-10月";
        _bestTravelTimeLabel.userInteractionEnabled = YES;
        [_bestTravelTimeLabel addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(travelMonthAction)]];
    }
    return _bestTravelTimeLabel;
}
- (UILabel *)descriptionLabel{
    if (_descriptionLabel == nil) {
        _descriptionLabel = [[UILabel alloc] init];
        _descriptionLabel.font = [UIFont systemFontOfSize:DESCRIPTION_FONT_SIZE];
        _descriptionLabel.textColor = TEXT_COLOR_TITLE;
        _descriptionLabel.numberOfLines = 2;
        _descriptionLabel.text = @"哔哩哔哩哔哩比巴拉巴拉巴拉巴拉巴拉巴拉哔哩哔哩哔哩比巴拉巴拉巴拉巴拉巴拉巴拉哔哩哔哩哔哩比巴拉巴拉巴拉巴拉巴拉巴拉哔哩哔哩哔哩比巴拉巴拉巴拉巴拉巴拉巴拉";
        _descriptionLabel.userInteractionEnabled = YES;
        [_descriptionLabel addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(descriptionAction)]];
    }
    return _descriptionLabel;
}

- (UILabel*)checkAllLabel{
    if (_checkAllLabel == nil) {
        _checkAllLabel = [[UILabel alloc] init];
        NSMutableAttributedString* attStr = [[NSMutableAttributedString alloc] initWithAttributedString:[[NSAttributedString alloc] initWithString:@"全文"]];
        [attStr addAttribute:NSForegroundColorAttributeName value:APP_THEME_COLOR range:NSMakeRange(0, attStr.length)];
        [attStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:DESCRIPTION_FONT_SIZE] range:NSMakeRange(0, attStr.length)];
        _checkAllLabel.attributedText = [attStr copy];
    }
    return _checkAllLabel;
}
- (CityDetailHeaderBottomView *)bottomView{
    if (_bottomView == nil) {
        _bottomView = [[CityDetailHeaderBottomView alloc] init];
        _bottomView.delegate = self;
    }
    return _bottomView;
}

- (void)setFrame:(CGRect)frame{
    [super setFrame:frame];
    
    
    if ([self.delegate respondsToSelector:@selector(headerFrameDidChange:)]) {
        [self.delegate headerFrameDidChange:self];
    }
    
    NSLog(@"----  设置了 head 的frame  %@",NSStringFromCGRect(frame));
}

- (void)setCityPoi:(CityPoi *)cityPoi{
    _cityPoi = cityPoi;
    self.topView.cityPoi = cityPoi;
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    
//    NSString* bestSeason = [_cityPoi.travelMonth substringWithRange:NSMakeRange(0, 15)];
    
    NSString* tm = _cityPoi.travelMonth;
    CGSize timeCostLabelSize = [tm boundingRectWithSize:CGSizeMake(width-116, MAXFLOAT)
                                                options:NSStringDrawingUsesLineFragmentOrigin
                                             attributes:@{
                                                          NSFontAttributeName : self.bestTravelTimeLabel.font,
                                                          }
                                                context:nil].size;
    
    if (timeCostLabelSize.height > 16) {
        NSAttributedString *more = [[NSAttributedString alloc] initWithString:@"攻略" attributes:@{NSForegroundColorAttributeName : APP_THEME_COLOR, NSFontAttributeName: [UIFont systemFontOfSize:12]}];
        NSMutableAttributedString *attrstr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"~最佳季节: %@... ", [tm substringToIndex:20]] attributes:nil];
        [attrstr appendAttributedString:more];
        self.bestTravelTimeLabel.attributedText = attrstr;
//        [self sizeToFit];
    } else {
        self.bestTravelTimeLabel.text = tm;
    }

    NSString *descStr = _cityPoi.desc;
    CGRect minRect = [descStr boundingRectWithSize:CGSizeMake(width-36, [UIFont systemFontOfSize:13].lineHeight * 1.2)
                                           options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                        attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:13]}
                                           context:nil];
    CGRect maxRect = [descStr boundingRectWithSize:CGSizeMake(width-36, CGFLOAT_MAX)
                                           options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                        attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:13]}
                                           context:nil];
    NSInteger totalLine = ceilf(maxRect.size.height / minRect.size.height);
    NSInteger ccount = descStr.length;
    NSInteger count = ccount * 2/totalLine;
    if (count < ccount && count > 3) {
        NSString *truncateStr = [descStr substringWithRange:NSMakeRange(0, count - 3)];
        NSMutableParagraphStyle *ps = [[NSMutableParagraphStyle alloc] init];
        ps.lineSpacing = 4.0;
        NSDictionary *attribs = @{NSFontAttributeName: [UIFont systemFontOfSize:13], NSParagraphStyleAttributeName:ps};
        truncateStr = [NSString stringWithFormat:@"%@... ", truncateStr];
        NSMutableAttributedString *attrstr = [[NSMutableAttributedString alloc] initWithString:truncateStr attributes:attribs];

        self.descriptionLabel.attributedText = attrstr;
        [self.descriptionLabel sizeToFit];
    } else {
        self.descriptionLabel.text = descStr;
    }
    [self setUpViews];
}

@end

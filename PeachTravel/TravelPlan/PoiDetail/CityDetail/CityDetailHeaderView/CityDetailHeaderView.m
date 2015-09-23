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

#import "CityDetailHeaderBottomView.h"

@interface CityDetailHeaderView () <CityDetailHeaderBottomViewDelegate>

@property (nonatomic, strong) TopImageView* topView;
@property (nonatomic, strong) CityDetailHeaderBottomView* bottomView;
@property (nonatomic, strong) UILabel* bestTravelTimeLabel;
@property (nonatomic, strong) UILabel* descriptionLabel;
@property (nonatomic, strong) UILabel* checkAllLabel;

@end

@implementation CityDetailHeaderView

- (instancetype)init{
    if (self = [super init]) {
        [self setUpViews];
    }
    return self;
}

+ (CGFloat)headerHeight{
    CityDetailHeaderView* head = [[CityDetailHeaderView alloc] init];
    return CGRectGetMaxY(head.bottomView.frame);
}

- (void)setUpViews{
    [self addSubview:self.topView];
    [self addSubview:self.bestTravelTimeLabel];
    [self addSubview:self.descriptionLabel];
    [self.descriptionLabel addSubview:self.checkAllLabel];
    [self addSubview:self.bottomView];
//    UIButton* btn = [[UIButton alloc] initWithFrame:CGRectMake(100, 100, 100, 100)];
//    [btn setBackgroundColor:[UIColor redColor]];
//    [self addSubview:btn];
//    [btn addTarget:self action:@selector(touchesBegan:withEvent:) forControlEvents:UIControlEventTouchUpInside];
    
    
    self.bestTravelTimeLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.descriptionLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.topView.translatesAutoresizingMaskIntoConstraints = NO;
    self.checkAllLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.bottomView.translatesAutoresizingMaskIntoConstraints = NO;
    
    NSDictionary* metrics = @{@"margins":[NSNumber numberWithInteger:MARGIN_S],@"marginm":[NSNumber numberWithInteger:MARGIN_M],@"titleSize":@TITLE_FONT_SIZE,@"detailSize":@DETAIL_FONT_SIZE};
    NSDictionary* dict = @{@"top":self.topView,@"best":self.bestTravelTimeLabel,@"description":self.descriptionLabel,@"check":self.checkAllLabel,@"bottom":self.bottomView};
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(==margins)-[top]-(==margins)-|" options:0 metrics:metrics views:dict]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(==margins)-[top]-[best]-[description]-[bottom]-12-|" options:0 metrics:metrics views:dict]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(==margins)-[best]-(==margins)-|" options:0 metrics:metrics views:dict]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(==margins)-[description]-(==margins)-|" options:0 metrics:metrics views:dict]];
    
    [self.descriptionLabel addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[check]-0-|" options:0 metrics:nil views:dict]];
    [self.descriptionLabel addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[check]-0-|" options:0 metrics:nil views:dict]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[bottom]-0-|" options:0 metrics:nil views:dict]];
    
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc]initWithString:self.descriptionLabel.text];;
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc]init];
    [paragraphStyle setLineSpacing:5];
    [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, self.descriptionLabel.text.length)];
    
    self.descriptionLabel.attributedText = attributedString;
    
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    NSLog(@"%s %@",__FUNCTION__,[self class]);
}

#pragma mark - delegate
- (void)restaurantBtnAction{
    
}
- (void)spotBtnAction{
    
}
- (void)guideBtnAction{
    
}
- (void)shoppingBtnAction{
    
}
- (void)planBtnAction{
    
}
- (void)journeyBtnAction{
    
}


#pragma mark - setter & getter
- (TopImageView *)topView{
    if (_topView == nil) {
        _topView = [[TopImageView alloc] init];
    }
    return _topView;
}
- (UILabel *)bestTravelTimeLabel{
    if (_bestTravelTimeLabel == nil) {
        _bestTravelTimeLabel = [[UILabel alloc] init];
        _bestTravelTimeLabel.font = [UIFont systemFontOfSize:DETAIL_FONT_SIZE];
        _bestTravelTimeLabel.textColor = TEXT_COLOR_TITLE_SUBTITLE;
        _bestTravelTimeLabel.text = @"最佳游玩时间 · 03-05月 08-10月";
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
        NSMutableAttributedString *attrstr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@... ", [tm substringToIndex:20]] attributes:nil];
        [attrstr appendAttributedString:more];
        self.bestTravelTimeLabel.attributedText = attrstr;
    } else {
        self.bestTravelTimeLabel.text = tm;
    }
    

    
    
    
    NSString *descStr = _cityPoi.desc;
    CGRect minRect = [descStr boundingRectWithSize:CGSizeMake(width-36, 12)
                                           options:NSStringDrawingUsesLineFragmentOrigin
                                        attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:13]}
                                           context:nil];
    CGRect maxRect = [descStr boundingRectWithSize:CGSizeMake(width-36, CGFLOAT_MAX)
                                           options:NSStringDrawingUsesLineFragmentOrigin
                                        attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:13]}
                                           context:nil];
    NSInteger totalLine = ceilf(maxRect.size.height / minRect.size.height);
    NSInteger ccount = descStr.length;
    NSInteger count = ccount * 2/totalLine;
    if (count < ccount) {
        NSString *truncateStr = [descStr substringWithRange:NSMakeRange(0, count - 3)];
        
        NSMutableParagraphStyle *ps = [[NSMutableParagraphStyle alloc] init];
        ps.lineSpacing = 4.0;
        NSDictionary *attribs = @{NSFontAttributeName: [UIFont systemFontOfSize:13], NSParagraphStyleAttributeName:ps};
        truncateStr = [NSString stringWithFormat:@"%@... ", truncateStr];
        NSMutableAttributedString *attrstr = [[NSMutableAttributedString alloc] initWithString:truncateStr attributes:attribs];
//        NSAttributedString *more1 = [[NSAttributedString alloc] initWithString:@"全文" attributes:@{NSForegroundColorAttributeName : APP_THEME_COLOR, NSFontAttributeName: [UIFont systemFontOfSize:13]}];
//        [attrstr appendAttributedString:more1];
        self.descriptionLabel.attributedText = attrstr;

    } else {
        self.descriptionLabel.text = descStr;
    }
    
    
}

@end

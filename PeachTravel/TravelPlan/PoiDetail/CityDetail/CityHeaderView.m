//
//  CityHeaderView.m
//  PeachTravel
//
//  Created by liangpengshuai on 11/13/14.
//  Copyright (c) 2014 com.aizou.www. All rights reserved.
//

#import "CityHeaderView.h"
#import "ResizableView.h"
#import "MWPhotoBrowser.h"
#import "CityDetailTableViewController.h"

@interface CityHeaderView () <UIScrollViewDelegate>

@property (nonatomic, strong) UIScrollView *galleryPageView;

@property (nonatomic, strong) UIView *headerView;
@property (nonatomic, strong) UIImageView *detailView;

@property (nonatomic, strong) UILabel *imagePageIndicator;
@property (nonatomic, strong) NSMutableArray *imageViews;
@property (nonatomic, strong) UILabel *titleBtn;
@property (nonatomic, strong) UIButton *showMoreDescContentBtn;
@property (nonatomic, strong) ResizableView *travelMonthBtn;
@property (nonatomic, strong) UIButton *showMoreInfoContentBtn;
@property (nonatomic, strong) UIButton *timeCostBtn;



@end

@implementation CityHeaderView

- (void)setCityPoi:(CityPoi *)cityPoi
{
    _cityPoi = cityPoi;
    [self setupSubView];
}

- (void)setupSubView
{
    self.backgroundColor = [UIColor clearColor];
    CGFloat width = self.frame.size.width;
    
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, width, kWindowWidth*0.6)];
    button.backgroundColor = [UIColor clearColor];
    [button addTarget:self action:@selector(viewImage:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:button];
    
    CGFloat oy = CGRectGetHeight(button.frame);
    
    _imagePageIndicator = [[UILabel alloc] initWithFrame:CGRectMake(width/2.0 - 20, oy - 33, 40, 23)];
    _imagePageIndicator.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.75];
    _imagePageIndicator.textColor = [UIColor whiteColor];
    _imagePageIndicator.layer.cornerRadius = 4.0;
    _imagePageIndicator.clipsToBounds = YES;
    _imagePageIndicator.font = [UIFont fontWithName:@"MicrosoftYaHei" size:12];
    _imagePageIndicator.text = @"画册";//[NSString stringWithFormat:@"%ld图", _cityPoi.imageCount];
    _imagePageIndicator.textAlignment = NSTextAlignmentCenter;
    [self addSubview:_imagePageIndicator];
    
    _favoriteBtn = [[UIButton alloc] initWithFrame:CGRectMake(width - 45, oy - 45, 40, 40)];
    [_favoriteBtn setImage:[UIImage imageNamed:@"ic_city_unFavorite.png"] forState:UIControlStateNormal];
    [_favoriteBtn setImage:[UIImage imageNamed:@"ic_city_favorite.png"] forState:UIControlStateHighlighted];
    [_favoriteBtn setImage:[UIImage imageNamed:@"ic_city_favorite.png"] forState:UIControlStateSelected];
    _favoriteBtn.selected = _cityPoi.isMyFavorite;
    [self addSubview:_favoriteBtn];
    
    UIButton *guideBtn = [[UIButton alloc] initWithFrame:CGRectMake(10, oy - 18, 75, 75)];
    [guideBtn setImage:[UIImage imageNamed:@"ic_city_intro.png"] forState:UIControlStateNormal];
    [guideBtn setImage:[UIImage imageNamed:@"ic_city_intro_highlight.png"] forState:UIControlStateHighlighted];

    guideBtn.titleLabel.font = [UIFont systemFontOfSize:14.0];
    guideBtn.titleLabel.numberOfLines = 2;
    [guideBtn setTitleColor:TEXT_COLOR_TITLE_SUBTITLE forState:UIControlStateNormal];
    guideBtn.layer.cornerRadius = 37.5;
    [self addSubview:guideBtn];
    _playNotes = guideBtn;
    
    _titleBtn = [[UILabel alloc] initWithFrame:CGRectMake(105, oy + 16, width - 130, 20)];
    _titleBtn.text = _cityPoi.zhName;
    _titleBtn.textColor = TEXT_COLOR_TITLE_SUBTITLE;
    _titleBtn.font = [UIFont boldSystemFontOfSize:17.0];
    [self addSubview:_titleBtn];
    
    UILabel *entitle = [[UILabel alloc] initWithFrame:CGRectMake(105, oy + 32, width - 130, 15)];
    entitle.text = _cityPoi.enName;
    entitle.textColor = TEXT_COLOR_TITLE_PH;
    entitle.font = [UIFont systemFontOfSize:12];
    [self addSubview:entitle];
    
    _detailView = [[UIImageView alloc] initWithFrame:CGRectMake(10, oy + 75, width - 20, 20)];
    _detailView.userInteractionEnabled = YES;
    _detailView.image = [[UIImage imageNamed:@"ic_city_card_bkg.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(3, 6, 12, 6)];
    [self addSubview:_detailView];
    
    oy = 0;
    
    UIView *spaceView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width - 20, 3)];
    spaceView.backgroundColor = APP_THEME_COLOR;
    [_detailView addSubview:spaceView];
    
    UILabel *ttitle = [[UILabel alloc] initWithFrame:CGRectMake(45, oy + 20, width - 110, 30)];
    ttitle.textColor = TEXT_COLOR_TITLE;
    ttitle.text = [NSString stringWithFormat:@"玩在%@", _cityPoi.zhName];
    ttitle.font = [UIFont fontWithName:@"MicrosoftYaHei" size:14.0];
    ttitle.textAlignment = NSTextAlignmentCenter;
    [_detailView addSubview:ttitle];
    
    oy += 50 + 4;
    
    _timeCostBtn = [[UIButton alloc] init];
    _timeCostBtn.titleLabel.numberOfLines = 0;
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.lineSpacing = 2.0;
    CGSize timeCostLabelSize = [_cityPoi.timeCostDesc boundingRectWithSize:CGSizeMake(width-70, MAXFLOAT)
                                                                   options:NSStringDrawingUsesLineFragmentOrigin
                                                                attributes:@{
                                                                             NSFontAttributeName : [UIFont fontWithName:@"MicrosoftYaHei" size:13.0],
                                                                             NSParagraphStyleAttributeName : style
                                                                             }
                                                                   context:nil].size;
    CGFloat timeCostHeight = timeCostLabelSize.height + 10;
    _timeCostBtn.frame = CGRectMake(25, oy, width - 70, timeCostHeight);
    [_timeCostBtn setAttributedTitle:[[NSString stringWithFormat:@"推荐旅程安排: %@", _cityPoi.timeCostDesc] stringByAddLineSpacingAndTextColor:TEXT_COLOR_TITLE_SUBTITLE] forState:UIControlStateNormal];
    _timeCostBtn.titleLabel.font = [UIFont fontWithName:@"MicrosoftYaHei" size:13.0];
    _timeCostBtn.contentVerticalAlignment = UIControlContentVerticalAlignmentTop;
    [_timeCostBtn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    [_detailView addSubview:_timeCostBtn];
    
    oy += _timeCostBtn.frame.size.height;
    
    _travelMonthBtn = [[ResizableView alloc] initWithFrame:CGRectMake(25, oy, width-70, 42) andNumberOfLine:2];
    _travelMonthBtn.contentFont = [UIFont fontWithName:@"MicrosoftYaHei" size:13.0];
    _travelMonthBtn.contentColor = TEXT_COLOR_TITLE_SUBTITLE;
    _travelMonthBtn.content = [NSString stringWithFormat:@"最佳旅行时节: %@", _cityPoi.travelMonth];
    _travelMonthBtn.backgroundColor = [UIColor whiteColor];
    [_detailView addSubview:_travelMonthBtn];
    
    oy += 52;
    
    if (_travelMonthBtn.maxNumberOfLine > 2) {
        [_travelMonthBtn addTarget:self action:@selector(showMoreInfo:) forControlEvents:UIControlEventTouchUpInside];
        _showMoreInfoContentBtn = [[UIButton alloc] initWithFrame:CGRectMake(width - 90, oy-15, 65, 14)];
        [_showMoreInfoContentBtn setImage:[UIImage imageNamed:@"ic_city_tra_down.png"] forState:UIControlStateNormal];
        [_showMoreInfoContentBtn addTarget:self action:@selector(showMoreInfo:) forControlEvents:UIControlEventTouchUpInside];
        _showMoreInfoContentBtn.backgroundColor = [UIColor whiteColor];
        [_detailView addSubview:_showMoreInfoContentBtn];
        oy += 20;
    }
    
    _headerView = [[UIView alloc] initWithFrame:CGRectMake(1, oy, width - 22, 72)];
    _headerView.backgroundColor = [UIColor whiteColor];
    [_detailView addSubview:_headerView];
    
    UIImageView *showSpotBkg = [[UIImageView alloc] initWithFrame:CGRectMake(25, 0, 72, 72)];
    showSpotBkg.image = [UIImage imageNamed:@"ic_city_btn_border.png"];
    showSpotBkg.userInteractionEnabled = YES;
    [_headerView addSubview:showSpotBkg];
    
    _showSpotsBtn = [[TZButton alloc] initWithFrame:CGRectMake(0, 0, 72, 72)];
    _showSpotsBtn.topSpaceHight = 10;
    _showSpotsBtn.spaceHight = 5;
    [_showSpotsBtn setTitle:@"景点" forState:UIControlStateNormal];
    [_showSpotsBtn setTitleColor:APP_THEME_COLOR forState:UIControlStateNormal];
    [_showSpotsBtn setTitleColor:APP_THEME_COLOR_HIGHLIGHT forState:UIControlStateHighlighted];
    _showSpotsBtn.titleLabel.font = [UIFont systemFontOfSize:17];
    [_showSpotsBtn setImage:[UIImage imageNamed:@"ic_city_travel.png"] forState:UIControlStateNormal];
    [showSpotBkg addSubview:_showSpotsBtn];
    
    UIImageView *showResBkg = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 72, 72)];
    showResBkg.image = [UIImage imageNamed:@"ic_city_btn_border.png"];
    showResBkg.userInteractionEnabled = YES;
    showResBkg.center = CGPointMake((width - 20)/2.0, 36);

    [_headerView addSubview:showResBkg];
    
    _showRestaurantsBtn = [[TZButton alloc] initWithFrame:CGRectMake(0, 0, 72, 72)];
    _showRestaurantsBtn.topSpaceHight = 10;
    _showRestaurantsBtn.spaceHight = 5;
    [_showRestaurantsBtn setTitle:@"美食" forState:UIControlStateNormal];
    [_showRestaurantsBtn setTitleColor:APP_THEME_COLOR forState:UIControlStateNormal];
    [_showRestaurantsBtn setTitleColor:APP_THEME_COLOR_HIGHLIGHT forState:UIControlStateHighlighted];
    _showRestaurantsBtn.titleLabel.font = [UIFont systemFontOfSize:17];
    [_showRestaurantsBtn setImage:[UIImage imageNamed:@"ic_city_restaurant.png"] forState:UIControlStateNormal];
    [showResBkg addSubview:_showRestaurantsBtn];
    
    UIImageView *showShoppingBkg = [[UIImageView alloc] initWithFrame:CGRectMake(width - 20 - 25 - 72, 0, 72, 72)];
    showShoppingBkg.image = [UIImage imageNamed:@"ic_city_btn_border.png"];
    showShoppingBkg.userInteractionEnabled = YES;
    [_headerView addSubview:showShoppingBkg];
    
    _showShoppingBtn = [[TZButton alloc] initWithFrame:CGRectMake(0, 0, 72, 72)];
    _showShoppingBtn.topSpaceHight = 10;
    _showShoppingBtn.spaceHight = 5;
    [_showShoppingBtn setTitle:@"购物" forState:UIControlStateNormal];
    [_showShoppingBtn setTitleColor:APP_THEME_COLOR forState:UIControlStateNormal];
    [_showShoppingBtn setTitleColor:APP_THEME_COLOR_HIGHLIGHT forState:UIControlStateHighlighted];
    _showShoppingBtn.titleLabel.font = [UIFont systemFontOfSize:17];
    [_showShoppingBtn setImage:[UIImage imageNamed:@"ic_city_shopping.png"] forState:UIControlStateNormal];
    [showShoppingBkg addSubview:_showShoppingBtn];
    

    oy += 72 + 20;
    
    CGRect frame = _detailView.frame;
    frame.size.height = oy;
    _detailView.frame = frame;
    
    CGRect frame1 = self.frame;
    frame1.size.height = oy + _detailView.frame.origin.y;
    frame1.size.width = width;
    self.frame = frame1;
    
}

#pragma mark - IBAction Methods

- (IBAction)showMoreInfo:(id)sender {
    [_travelMonthBtn showMoreContent];
    [UIView animateWithDuration:0.2 animations:^{
        CGRect frame = _showMoreInfoContentBtn.frame;
        frame.origin.y += _travelMonthBtn.resizeHeight;
        _showMoreInfoContentBtn.frame = frame;
        
        frame = _detailView.frame;
        frame.size.height += _travelMonthBtn.resizeHeight;
        _detailView.frame = frame;
        
        frame = _headerView.frame;
        frame.origin.y += _travelMonthBtn.resizeHeight;
        _headerView.frame = frame;
    } completion:^(BOOL finished) {
        [_showMoreInfoContentBtn setImage:[UIImage imageNamed:@"ic_city_tra_up.png"] forState:UIControlStateNormal];
        [_showMoreInfoContentBtn removeTarget:self action:@selector(showMoreInfo:) forControlEvents:UIControlEventTouchUpInside];
        [_showMoreInfoContentBtn addTarget:self action:@selector(hideInfo:) forControlEvents:UIControlEventTouchUpInside];
        [_travelMonthBtn removeTarget:self action:@selector(showMoreInfo:) forControlEvents:UIControlEventTouchUpInside];
        [_travelMonthBtn addTarget:self action:@selector(hideInfo:) forControlEvents:UIControlEventTouchUpInside];
    }];
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, _detailView.frame.origin.y + _detailView.frame.size.height);
    [self.delegate updateCityHeaderView];
}

- (IBAction)hideInfo:(id)sender
{
    [_travelMonthBtn hideContent];
    [UIView animateWithDuration:0.2 animations:^{
        CGRect frame = _showMoreInfoContentBtn.frame;
        frame.origin.y -= _travelMonthBtn.resizeHeight;
        _showMoreInfoContentBtn.frame = frame;
        
        frame = _detailView.frame;
        frame.size.height -= _travelMonthBtn.resizeHeight;
        _detailView.frame = frame;
        
        frame = _headerView.frame;
        frame.origin.y -= _travelMonthBtn.resizeHeight;
        _headerView.frame = frame;
    } completion:^(BOOL finished) {
        [_showMoreInfoContentBtn setImage:[UIImage imageNamed:@"ic_city_tra_down.png"] forState:UIControlStateNormal];
        [_showMoreInfoContentBtn removeTarget:self action:@selector(hideInfo:) forControlEvents:UIControlEventTouchUpInside];
        [_showMoreInfoContentBtn addTarget:self action:@selector(showMoreInfo:) forControlEvents:UIControlEventTouchUpInside];
        [_travelMonthBtn removeTarget:self action:@selector(hideInfo:) forControlEvents:UIControlEventTouchUpInside];
        [_travelMonthBtn addTarget:self action:@selector(showMoreInfo:) forControlEvents:UIControlEventTouchUpInside];
    }];
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, _detailView.frame.origin.y + _detailView.frame.size.height);
    [self.delegate updateCityHeaderView];
}

#pragma mark - private methods

- (void)loadScrollViewWithPage:(NSUInteger)page {
    if (page >= _cityPoi.images.count) {
        return;
    }
    
    UIImageView *img = [_imageViews objectAtIndex:page];

    if ((NSNull *)img == [NSNull null]) {
        img = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0.0, CGRectGetWidth(self.galleryPageView.frame), CGRectGetHeight(self.galleryPageView.frame))];
        img.contentMode = UIViewContentModeScaleAspectFill;
        img.clipsToBounds = YES;
        img.userInteractionEnabled = YES;
        [_imageViews replaceObjectAtIndex:page withObject:img];
        img.tag = page;
        UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewImage:)];
        [img addGestureRecognizer:tap];
    }
    
    if (img.superview == nil) {
        CGRect frame = img.frame;
        frame.origin.x = CGRectGetWidth(frame) * page;
        img.frame = frame;
        [self.galleryPageView insertSubview:img atIndex:0];
        TaoziImage *taoziImage = [_cityPoi.images objectAtIndex:page];
        NSString *url = taoziImage.imageUrl;
        [img sd_setImageWithURL:[NSURL URLWithString:url] placeholderImage:[UIImage imageNamed:@"spot_detail_default.png"]];
    }
}

- (CGFloat)headerViewHightWithCityData:(CityPoi *)poi
{
    return 200;
}

#pragma mark - UITabGestureAction
- (void)viewImage:(UITapGestureRecognizer *)viewImage {
    MWPhotoBrowser *browser = [[MWPhotoBrowser alloc] init];
    for (UIView* next = [self superview]; next; next = next.superview)
    {
        UIResponder* nextResponder = [next nextResponder];
        
        if ([nextResponder isKindOfClass:[UIViewController class]])
        {
             UIViewController *ctl = (UIViewController*)nextResponder;
            [self loadAlbumDataWithAlbumCtl:browser];
            [ctl.navigationController pushViewController:browser animated:YES];
            break;
        }
    }
}

/**
 *  获取城市的图集信息
 */
- (void)loadAlbumDataWithAlbumCtl:(MWPhotoBrowser *)albumCtl
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    AppUtils *utils = [[AppUtils alloc] init];
    [manager.requestSerializer setValue:utils.appVersion forHTTPHeaderField:@"Version"];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"iOS %@",utils.systemVersion] forHTTPHeaderField:@"Platform"];
    
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [manager.requestSerializer setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    
    NSString *requsetUrl = [NSString stringWithFormat:@"%@%@/album", API_GET_ALBUM, _cityPoi.cityId];
    
    UIViewController *ctl;
    for (UIView* next = [self superview]; next; next = next.superview)
    {
        UIResponder* nextResponder = [next nextResponder];
        
        if ([nextResponder isKindOfClass:[UIViewController class]])
        {
            ctl = (UIViewController*)nextResponder;
            break;
        }
    }
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:@0 forKey:@"page"];
    [params setObject:@100 forKey:@"pageSize"];
    NSNumber *imageWidth = [NSNumber numberWithInt:(kWindowWidth/3)*2];
    [params setObject:imageWidth forKey:@"imgWidth"];
    
    [manager GET:requsetUrl parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"%@", responseObject);
        NSInteger code = [[responseObject objectForKey:@"code"] integerValue];
        if (code == 0) {
            NSMutableArray *tempArray = [[NSMutableArray alloc] init];
            for (id imageDic in [[responseObject objectForKey:@"result"] objectForKey:@"album"]) {
                [tempArray addObject:imageDic];
            }
            albumCtl.imageList = tempArray;
        } else {
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (((CityDetailTableViewController *)ctl).isShowing) {
            [SVProgressHUD showHint:@"呃～好像没找到网络"];
        }
    }];
}



@end
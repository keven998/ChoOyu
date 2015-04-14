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

@property (nonatomic, strong) UIScrollView *galleryPageView; //unuse

@property (nonatomic, strong) UIView *headerView;
@property (nonatomic, strong) UILabel *cityDesc;

@property (nonatomic, strong) UIView *detailView;

@property (nonatomic, strong) UILabel *imagePageIndicator;
@property (nonatomic, strong) NSMutableArray *imageViews;
@property (nonatomic, strong) UILabel *cityName;
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
    
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, width, width*0.6)];
    button.backgroundColor = [UIColor clearColor];
    button.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [button addTarget:self action:@selector(viewImage:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:button];
    
    CGFloat oy = CGRectGetHeight(button.frame);
    
    _imagePageIndicator = [[UILabel alloc] initWithFrame:CGRectMake(width/2.0 - 30, oy - 33, 60, 23)];
    _imagePageIndicator.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.75];
    _imagePageIndicator.textColor = [UIColor whiteColor];
    _imagePageIndicator.layer.cornerRadius = 4.0;
    _imagePageIndicator.clipsToBounds = YES;
    _imagePageIndicator.font = [UIFont systemFontOfSize:12];
    _imagePageIndicator.text = @"城市画册";
    _imagePageIndicator.textAlignment = NSTextAlignmentCenter;
    [self addSubview:_imagePageIndicator];
    
//    UIButton *guideBtn = [[UIButton alloc] initWithFrame:CGRectMake(10, oy - 18, 75, 75)];
//    [guideBtn setImage:[UIImage imageNamed:@"ic_city_intro.png"] forState:UIControlStateNormal];
//    [guideBtn setImage:[UIImage imageNamed:@"ic_city_intro_highlight.png"] forState:UIControlStateHighlighted];
//    guideBtn.titleLabel.font = [UIFont systemFontOfSize:14.0];
//    guideBtn.titleLabel.numberOfLines = 2;
//    [guideBtn setTitleColor:TEXT_COLOR_TITLE_SUBTITLE forState:UIControlStateNormal];
//    guideBtn.layer.cornerRadius = 37.5;
//    [self addSubview:guideBtn];
//    _playNotes = guideBtn;
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, oy, width, 0)];
    view.backgroundColor = [UIColor whiteColor];
    [self addSubview:view];
    
    _cityName = [[UILabel alloc] initWithFrame:CGRectMake(0, 15, width, 20)];
    _cityName.text = _cityPoi.zhName;
    _cityName.textColor = TEXT_COLOR_TITLE_SUBTITLE;
    _cityName.textAlignment = NSTextAlignmentCenter;
    _cityName.font = [UIFont boldSystemFontOfSize:17.0];
    [view addSubview:_cityName];
    
    CGRect dframe = CGRectMake(10, 20 + 20, width-20, 0);
    _cityDesc = [[UILabel alloc] init];
    _cityDesc.textColor = TEXT_COLOR_TITLE_SUBTITLE;
    _cityDesc.numberOfLines = 0;
    NSMutableParagraphStyle *ps = [[NSMutableParagraphStyle alloc] init];
    ps.lineSpacing = 3.0;
    NSDictionary *attribs = @{NSFontAttributeName: [UIFont systemFontOfSize:13], NSParagraphStyleAttributeName:ps};
    NSAttributedString *attrstr = [[NSAttributedString alloc] initWithString:_cityPoi.desc attributes:attribs];
    CGRect rect = [attrstr boundingRectWithSize:(CGSize){dframe.size.width, CGFLOAT_MAX} options:NSStringDrawingUsesLineFragmentOrigin context:nil];
    dframe.size.height = ceilf(rect.size.height);
    _cityDesc.frame = dframe;
    _cityDesc.attributedText = attrstr;
    [view addSubview:_cityDesc];
    
    view.frame = CGRectMake(0, view.frame.origin.y, width, dframe.origin.y + dframe.size.height + 15);
    
    oy += view.frame.size.height + 6;
    
//    UILabel *entitle = [[UILabel alloc] initWithFrame:CGRectMake(0, oy + 32, width, 15)];
//    entitle.text = _cityPoi.enName;
//    entitle.textAlignment = NSTextAlignmentCenter;
//    entitle.textColor = TEXT_COLOR_TITLE_PH;
//    entitle.font = [UIFont systemFontOfSize:12];
//    [self addSubview:entitle];
    
    _detailView = [[UIView alloc] initWithFrame:CGRectMake(0, oy, width, 0)];
    _detailView.userInteractionEnabled = YES;
    _detailView.backgroundColor = [UIColor whiteColor];
    [self addSubview:_detailView];
    
    oy = 0;
    
    UILabel *ttitle = [[UILabel alloc] initWithFrame:CGRectMake(45, oy + 5, width - 90, 30)];
    ttitle.textColor = TEXT_COLOR_TITLE;
    ttitle.text = [NSString stringWithFormat:@"玩在%@", _cityPoi.zhName];
    ttitle.font = [UIFont systemFontOfSize:14.0];
    ttitle.textAlignment = NSTextAlignmentCenter;
    [_detailView addSubview:ttitle];
    
    oy += 30 + 5;
    
    _timeCostBtn = [[UIButton alloc] init];
    _timeCostBtn.titleLabel.numberOfLines = 0;
    CGSize timeCostLabelSize = [_cityPoi.timeCostDesc boundingRectWithSize:CGSizeMake(width-20, MAXFLOAT)
                                                                   options:NSStringDrawingUsesLineFragmentOrigin
                                                                attributes:@{
                                                                             NSFontAttributeName : [UIFont systemFontOfSize:13.0],
                                                                             }
                                                                   context:nil].size;
    CGFloat timeCostHeight = timeCostLabelSize.height + 10;
    _timeCostBtn.frame = CGRectMake(10, oy, width - 20, timeCostHeight);
    [_timeCostBtn setAttributedTitle:[[NSString stringWithFormat:@"推荐旅途安排: %@", _cityPoi.timeCostDesc] stringByAddLineSpacingAndTextColor:TEXT_COLOR_TITLE_SUBTITLE] forState:UIControlStateNormal];
    _timeCostBtn.titleLabel.font = [UIFont systemFontOfSize:13.0];
    _timeCostBtn.contentVerticalAlignment = UIControlContentVerticalAlignmentTop;
    [_timeCostBtn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    [_detailView addSubview:_timeCostBtn];
    
    oy += _timeCostBtn.frame.size.height;
    
    _travelMonthBtn = [[ResizableView alloc] initWithFrame:CGRectMake(10, oy, width-20, 36) andNumberOfLine:2];
    _travelMonthBtn.contentFont = [UIFont systemFontOfSize:13.0];
    _travelMonthBtn.contentColor = TEXT_COLOR_TITLE_SUBTITLE;
    _travelMonthBtn.content = [NSString stringWithFormat:@"最佳旅行时节: %@", _cityPoi.travelMonth];
    _travelMonthBtn.backgroundColor = [UIColor whiteColor];
    [_detailView addSubview:_travelMonthBtn];
    
    oy += 46;
    
    if (_travelMonthBtn.maxNumberOfLine > 2) {
        [_travelMonthBtn addTarget:self action:@selector(showMoreInfo:) forControlEvents:UIControlEventTouchUpInside];
        _showMoreInfoContentBtn = [[UIButton alloc] initWithFrame:CGRectMake(width - 40, oy-15, 40, 14)];
        [_showMoreInfoContentBtn setImage:[UIImage imageNamed:@"ic_city_tra_down.png"] forState:UIControlStateNormal];
        [_showMoreInfoContentBtn addTarget:self action:@selector(showMoreInfo:) forControlEvents:UIControlEventTouchUpInside];
        _showMoreInfoContentBtn.backgroundColor = [UIColor whiteColor];
        [_detailView addSubview:_showMoreInfoContentBtn];
        oy += 10;
    }
    
    _headerView = [[UIView alloc] initWithFrame:CGRectMake(0, oy, width - 22, 72)];
    _headerView.backgroundColor = [UIColor whiteColor];
    [_detailView addSubview:_headerView];
    
    CGSize btnItemSize = CGSizeMake(55, 55);
    CGFloat spaceWidth = ((CGRectGetWidth(self.bounds) - btnItemSize.width*4)/5);
    _showTipsBtn  = [[TZButton alloc] initWithFrame:CGRectMake(spaceWidth, 0, btnItemSize.width, btnItemSize.height)];
    _showTipsBtn.topSpaceHight = 10;
    _showTipsBtn.spaceHight = 5;
    [_showTipsBtn setTitle:@"旅游指南" forState:UIControlStateNormal];
    [_showTipsBtn setTitleColor:APP_THEME_COLOR forState:UIControlStateNormal];
    [_showTipsBtn setTitleColor:APP_THEME_COLOR_HIGHLIGHT forState:UIControlStateHighlighted];
    _showTipsBtn.titleLabel.font = [UIFont systemFontOfSize:17];
    [_showTipsBtn setImage:[UIImage imageNamed:@"ic_city_travel.png"] forState:UIControlStateNormal];
    [_showTipsBtn setBackgroundImage:[UIImage imageNamed:@"ic_city_btn_border.png"] forState:UIControlStateNormal];
    [_headerView addSubview:_showTipsBtn];
    
    _showSpotsBtn = [[TZButton alloc] initWithFrame:CGRectMake(spaceWidth * 2 + btnItemSize.width, 0, btnItemSize.width, btnItemSize.height)];
    _showSpotsBtn.topSpaceHight = 10;
    _showSpotsBtn.spaceHight = 5;
    [_showSpotsBtn setTitle:@"景点" forState:UIControlStateNormal];
    [_showSpotsBtn setTitleColor:APP_THEME_COLOR forState:UIControlStateNormal];
    [_showSpotsBtn setTitleColor:APP_THEME_COLOR_HIGHLIGHT forState:UIControlStateHighlighted];
    _showSpotsBtn.titleLabel.font = [UIFont systemFontOfSize:17];
    [_showSpotsBtn setImage:[UIImage imageNamed:@"ic_city_travel.png"] forState:UIControlStateNormal];
    [_showSpotsBtn setBackgroundImage:[UIImage imageNamed:@"ic_city_btn_border.png"] forState:UIControlStateNormal];
    [_headerView addSubview:_showSpotsBtn];
    
    _showRestaurantsBtn = [[TZButton alloc] initWithFrame:CGRectMake(spaceWidth * 3 + 2*btnItemSize.width, 0, btnItemSize.width, btnItemSize.height)];
    _showRestaurantsBtn.topSpaceHight = 10;
    _showRestaurantsBtn.spaceHight = 5;
    [_showRestaurantsBtn setTitle:@"美食" forState:UIControlStateNormal];
    [_showRestaurantsBtn setTitleColor:APP_THEME_COLOR forState:UIControlStateNormal];
    [_showRestaurantsBtn setTitleColor:APP_THEME_COLOR_HIGHLIGHT forState:UIControlStateHighlighted];
    _showRestaurantsBtn.titleLabel.font = [UIFont systemFontOfSize:17];
    [_showRestaurantsBtn setImage:[UIImage imageNamed:@"ic_city_restaurant.png"] forState:UIControlStateNormal];
    [_showRestaurantsBtn setBackgroundImage:[UIImage imageNamed:@"ic_city_btn_border.png"] forState:UIControlStateNormal];
    [_headerView addSubview:_showRestaurantsBtn];
    
    _showShoppingBtn = [[TZButton alloc] initWithFrame:CGRectMake(spaceWidth * 4 + 3*btnItemSize.width, 0, btnItemSize.width, btnItemSize.height)];
    _showShoppingBtn.topSpaceHight = 10;
    _showShoppingBtn.spaceHight = 5;
    [_showShoppingBtn setTitle:@"购物" forState:UIControlStateNormal];
    [_showShoppingBtn setTitleColor:APP_THEME_COLOR forState:UIControlStateNormal];
    [_showShoppingBtn setTitleColor:APP_THEME_COLOR_HIGHLIGHT forState:UIControlStateHighlighted];
    _showShoppingBtn.titleLabel.font = [UIFont systemFontOfSize:17];
    [_showShoppingBtn setImage:[UIImage imageNamed:@"ic_city_shopping.png"] forState:UIControlStateNormal];
    [_showShoppingBtn setBackgroundImage:[UIImage imageNamed:@"ic_city_btn_border.png"] forState:UIControlStateNormal];
    [_headerView addSubview:_showShoppingBtn];
    

    oy += btnItemSize.height + 20;
    
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
    [MobClick event:@"event_city_photoes"];
    MWPhotoBrowser *browser = [[MWPhotoBrowser alloc] init];
    for (UIView* next = [self superview]; next; next = next.superview)
    {
        UIResponder* nextResponder = [next nextResponder];
        
        if ([nextResponder isKindOfClass:[UIViewController class]])
        {
             UIViewController *ctl = (UIViewController*)nextResponder;
            [self loadAlbumDataWithAlbumCtl:browser];
            [browser setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];
            UINavigationController *navc = [[UINavigationController alloc] initWithRootViewController:browser];
            [ctl presentViewController:navc animated:YES completion:nil];
//            [ctl.navigationController pushViewController:browser animated:YES];
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
    
    NSString *requsetUrl = [NSString stringWithFormat:@"%@%@/album", API_GET_ALBUM, _cityPoi.poiId];
    
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
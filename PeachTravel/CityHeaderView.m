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
@property (nonatomic, strong) UIView *detailView;

@property (nonatomic, strong) UIButton *imagePageIndicator;
@property (nonatomic, strong) NSMutableArray *imageViews;
@property (nonatomic, strong) UIButton *titleBtn;
@property (nonatomic, strong) ResizableView *descView;
@property (nonatomic, strong) UIButton *showMoreDescContentBtn;
@property (nonatomic, strong) UIButton *travelMonthBtn;
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
    CGFloat oy = 0;
    CGFloat width = self.frame.size.width;
    _headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, 270)];
    _headerView.backgroundColor = [UIColor whiteColor];
    _headerView.layer.cornerRadius = 2.0;
    _headerView.clipsToBounds = YES;
    
    UIScrollView *gallery = [[UIScrollView alloc]initWithFrame:CGRectMake(0, oy, width, 167.5)];
    gallery.scrollEnabled = NO;
    gallery.showsHorizontalScrollIndicator = NO;
    gallery.showsVerticalScrollIndicator = NO;
    gallery.delegate = self;
    gallery.bounces = YES;
    gallery.layer.borderColor = APP_BORDER_COLOR.CGColor;
    gallery.layer.borderWidth = 0.5;
    gallery.backgroundColor = APP_IMAGEVIEW_COLOR;
    self.backgroundColor = APP_PAGE_COLOR;
    
    [_headerView addSubview:gallery];
    _galleryPageView = gallery;
    
    _imagePageIndicator = [[UIButton alloc] initWithFrame:CGRectMake(_headerView.frame.size.width-53.5, gallery.frame.size.height-30, 47.5, 23)];
    _imagePageIndicator.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.6];
    [_imagePageIndicator setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    _imagePageIndicator.userInteractionEnabled = NO;
    _imagePageIndicator.layer.cornerRadius = 2.0;
    _imagePageIndicator.titleLabel.font = [UIFont systemFontOfSize:12.0];
    [_imagePageIndicator setTitle:[NSString stringWithFormat:@"共%ld图", (unsigned long)_cityPoi.imageCount] forState:UIControlStateNormal];
    [_headerView addSubview:_imagePageIndicator];
    
    NSInteger count = _cityPoi.images.count;
    _galleryPageView.contentSize = CGSizeMake(CGRectGetWidth(_galleryPageView.frame), CGRectGetHeight(_galleryPageView.frame));
    
    NSMutableArray *images = [[NSMutableArray alloc] init];
    for (NSUInteger i = 0; i < count; i++)
    {
        [images addObject:[NSNull null]];
    }
    _imageViews = images;
    [self loadScrollViewWithPage:0];
    
    oy += 175;
    
    _titleBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, oy, width, 30)];
    [_titleBtn setTitle:_cityPoi.zhName forState:UIControlStateNormal];
    [_titleBtn setTitleColor:TEXT_COLOR_TITLE forState:UIControlStateNormal];
    [_titleBtn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    [_titleBtn setImage:[UIImage imageNamed:nil] forState:UIControlStateNormal];
    _titleBtn.titleLabel.font = [UIFont boldSystemFontOfSize:15.0];
    [_titleBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, 8, 0, 0)];
    _titleBtn.userInteractionEnabled = NO;
    [_headerView addSubview:_titleBtn];
    
    _favoriteBtn = [[UIButton alloc] initWithFrame:CGRectMake(width-65, oy, 60, 30)];
    [_favoriteBtn setImage:[UIImage imageNamed:@"ic_unFavorite.png"] forState:UIControlStateNormal];
    [_favoriteBtn setImage:[UIImage imageNamed:@"ic_Favorite.png"] forState:UIControlStateHighlighted];
    [_favoriteBtn setImage:[UIImage imageNamed:@"ic_Favorite.png"] forState:UIControlStateSelected];
    if (_cityPoi.isMyFavorite) {
        _favoriteBtn.selected = YES;
    }
    
    [_headerView addSubview:_favoriteBtn];
    
    oy += 40;
    
    _descView = [[ResizableView alloc] initWithFrame:CGRectMake(8, oy, width-16, 40) andNumberOfLine:2];
    _descView.contentFont = [UIFont systemFontOfSize:11.0];
    _descView.contentColor = TEXT_COLOR_TITLE_SUBTITLE;
    _descView.content = _cityPoi.desc;
    [_descView addTarget:self action:@selector(showMoreContent:) forControlEvents:UIControlEventTouchUpInside];
    [_headerView addSubview:_descView];
    
    oy += 40;
    
    if (_descView.maxNumberOfLine > 2) {
        _showMoreDescContentBtn = [[UIButton alloc] initWithFrame:CGRectMake(width-30, oy+3, 20, 10)];
        [_showMoreDescContentBtn setImage:[UIImage imageNamed:@"cell_accessory_pink_down.png"] forState:UIControlStateNormal];
        [_showMoreDescContentBtn addTarget:self action:@selector(showMoreContent:) forControlEvents:UIControlEventTouchUpInside];
        [_headerView addSubview:_showMoreDescContentBtn];
    }
    [self addSubview:_headerView];
    
    _detailView = [[UIView alloc] init];
    [self addSubview:_detailView];
    
    CGFloat doy = 0.0;
    _detailView.backgroundColor = APP_PAGE_COLOR;
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.lineSpacing = 2.0;
    
    _timeCostBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, doy, width, 0)];
    _timeCostBtn.titleLabel.numberOfLines = 0;

    CGSize timeCostLabelSize = [_cityPoi.timeCostDesc boundingRectWithSize:CGSizeMake(self.bounds.size.width-108, MAXFLOAT)
                                              options:NSStringDrawingUsesLineFragmentOrigin
                                           attributes:@{
                                                        NSFontAttributeName : [UIFont systemFontOfSize:11.0],
                                                        NSParagraphStyleAttributeName : style
                                                        }
                                              context:nil].size;
    
    CGFloat timeCostHeight = timeCostLabelSize.height + 20;
    
    _timeCostBtn.frame = CGRectMake(0, doy, width, timeCostHeight);

    [_timeCostBtn setAttributedTitle:[_cityPoi.timeCostDesc stringByAddLineSpacingAndTextColor:TEXT_COLOR_TITLE_SUBTITLE] forState:UIControlStateNormal];
    _timeCostBtn.backgroundColor = [UIColor whiteColor];
    _timeCostBtn.titleLabel.font = [UIFont systemFontOfSize:11.0];
    _timeCostBtn.titleEdgeInsets = UIEdgeInsetsMake(0, 100, 0, 8);
    [_timeCostBtn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    
    UIButton *timeCostSubTitle = [[UIButton alloc] initWithFrame:CGRectMake(8, 0, 80, _timeCostBtn.frame.size.height)];
    [timeCostSubTitle setTitle:@"建议游玩时间" forState:UIControlStateNormal];
    [timeCostSubTitle setTitleColor:TEXT_COLOR_TITLE forState:UIControlStateNormal];
    timeCostSubTitle.titleLabel.font = [UIFont systemFontOfSize:12.0];
    [_timeCostBtn addSubview:timeCostSubTitle];
    timeCostSubTitle.userInteractionEnabled = NO;
    
    UIImageView *spaceImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, width, 1)];
    spaceImageView.image = [UIImage imageNamed:@"ic_dotted_line.png"];
    [_timeCostBtn addSubview:spaceImageView];
    
    [_detailView addSubview:_timeCostBtn];
    
    doy += _timeCostBtn.frame.size.height;
    
    
    _travelMonthBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, doy, width, 0)];
    _travelMonthBtn.titleLabel.numberOfLines = 0;
    
    CGSize travelMonthLabelSize = [_cityPoi.travelMonth boundingRectWithSize:CGSizeMake(self.bounds.size.width-108, MAXFLOAT)
                                                                   options:NSStringDrawingUsesLineFragmentOrigin
                                                                attributes:@{
                                                                             NSFontAttributeName : [UIFont systemFontOfSize:11.0],
                                                                             NSParagraphStyleAttributeName : style
                                                                             }
                                                                   context:nil].size;
    
    CGFloat travelMonthHeight = travelMonthLabelSize.height + 20;

    
    _travelMonthBtn.frame = CGRectMake(0, doy, width, travelMonthHeight);
    _travelMonthBtn.layer.cornerRadius = 1.0;
    [_travelMonthBtn setAttributedTitle:[_cityPoi.travelMonth stringByAddLineSpacingAndTextColor:TEXT_COLOR_TITLE_SUBTITLE] forState:UIControlStateNormal];
    _travelMonthBtn.titleLabel.font = [UIFont systemFontOfSize:11.0];
    _travelMonthBtn.backgroundColor = [UIColor whiteColor];
    
    _travelMonthBtn.titleEdgeInsets = UIEdgeInsetsMake(0, 100, 0, 8);
    [_travelMonthBtn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    
    UIButton *subTitle = [[UIButton alloc] initWithFrame:CGRectMake(8, 0, 80, _travelMonthBtn.frame.size.height)];
    [subTitle setTitle:@"最佳旅行时节" forState:UIControlStateNormal];
    [subTitle setTitleColor:TEXT_COLOR_TITLE forState:UIControlStateNormal];
    subTitle.titleLabel.font = [UIFont systemFontOfSize:12.0];
    [_travelMonthBtn addSubview:subTitle];
    subTitle.userInteractionEnabled = NO;
    
    [_detailView addSubview:_travelMonthBtn];
    
    doy += _travelMonthBtn.frame.size.height + 10;
    
    CGFloat widthPerItem = width/3;
    
    _showSpotsBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, doy, widthPerItem-0.5, 50)];
    [_showSpotsBtn setTitle:@"玩" forState:UIControlStateNormal];
    [_showSpotsBtn setTitleColor:TEXT_COLOR_TITLE forState:UIControlStateNormal];
    [_showSpotsBtn setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
    _showSpotsBtn.titleLabel.font = [UIFont boldSystemFontOfSize:14.0];
    [_showSpotsBtn setImage:[UIImage imageNamed:@"ic_standard_travel.png"] forState:UIControlStateNormal];
    [_showSpotsBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, 8, 0, 0)];
    [_showSpotsBtn setBackgroundImage:[ConvertMethods createImageWithColor:[UIColor whiteColor]] forState:UIControlStateNormal];
    [_showSpotsBtn setBackgroundImage:[ConvertMethods createImageWithColor:[[UIColor whiteColor] colorWithAlphaComponent:0.5]] forState:UIControlStateHighlighted];
    _showSpotsBtn.clipsToBounds = YES;
    _showSpotsBtn.layer.cornerRadius = 2.0;
    [_detailView addSubview:_showSpotsBtn];
    
    _showRestaurantsBtn = [[UIButton alloc] initWithFrame:CGRectMake(widthPerItem+0.5, doy, widthPerItem-0.5, 50)];
    [_showRestaurantsBtn setTitle:@"吃" forState:UIControlStateNormal];
    [_showRestaurantsBtn setTitleColor:TEXT_COLOR_TITLE forState:UIControlStateNormal];
    [_showRestaurantsBtn setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
    _showRestaurantsBtn.titleLabel.font = [UIFont boldSystemFontOfSize:14.0];
    [_showRestaurantsBtn setImage:[UIImage imageNamed:@"ic_standard_food.png"] forState:UIControlStateNormal];
    [_showRestaurantsBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, 8, 0, 0)];
    [_showRestaurantsBtn setBackgroundImage:[ConvertMethods createImageWithColor:[UIColor whiteColor]] forState:UIControlStateNormal];
    [_showRestaurantsBtn setBackgroundImage:[ConvertMethods createImageWithColor:[[UIColor whiteColor] colorWithAlphaComponent:0.5]] forState:UIControlStateHighlighted];
    _showRestaurantsBtn.clipsToBounds = YES;
    _showRestaurantsBtn.layer.cornerRadius = 2.0;
    [_detailView addSubview:_showRestaurantsBtn];
    
    _showShoppingBtn = [[UIButton alloc] initWithFrame:CGRectMake(widthPerItem*2+1, doy, widthPerItem-0.5, 50)];
    [_showShoppingBtn setTitle:@"买" forState:UIControlStateNormal];
    [_showShoppingBtn setTitleColor:TEXT_COLOR_TITLE forState:UIControlStateNormal];
    [_showShoppingBtn setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
    _showShoppingBtn.titleLabel.font = [UIFont boldSystemFontOfSize:14.0];
    [_showShoppingBtn setImage:[UIImage imageNamed:@"ic_standard_shopping.png"] forState:UIControlStateNormal];
    [_showShoppingBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, 8, 0, 0)];
    [_showShoppingBtn setBackgroundImage:[ConvertMethods createImageWithColor:[UIColor whiteColor]] forState:UIControlStateNormal];
    [_showShoppingBtn setBackgroundImage:[ConvertMethods createImageWithColor:[[UIColor whiteColor] colorWithAlphaComponent:0.5]] forState:UIControlStateHighlighted];
    _showShoppingBtn.clipsToBounds = YES;
    _showShoppingBtn.layer.cornerRadius = 2.0;
    [_detailView addSubview:_showShoppingBtn];
    
    doy += 60;
    
     [_detailView setFrame:CGRectMake(0, _headerView.frame.size.height+_headerView.frame.origin.y, width, doy)];
    
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, width, _detailView.frame.origin.y + _detailView.frame.size.height);
    
}

#pragma mark - IBAction Methods

- (IBAction)showMoreContent:(id)sender
{
    [_descView showMoreContent];
    [UIView animateWithDuration:0.3 animations:^{
        [_headerView setFrame:CGRectMake(_headerView.frame.origin.x, _headerView.frame.origin.y, _headerView.frame.size.width, _headerView.frame.size.height + _descView.resizeHeight)];
        [_showMoreDescContentBtn setFrame:CGRectMake(_showMoreDescContentBtn.frame.origin.x, _showMoreDescContentBtn.frame.origin.y+_descView.resizeHeight, _showMoreDescContentBtn.frame.size.width, _showMoreDescContentBtn.frame.size.height)];
        [_detailView setFrame:CGRectMake(_detailView.frame.origin.x, _detailView.frame.origin.y+_descView.resizeHeight, _detailView.frame.size.width, _detailView.frame.size.height)];
        _showMoreDescContentBtn.transform = CGAffineTransformMakeRotation(180 *M_PI / 180.0);
    } completion:^(BOOL finished) {
    }];
    
     self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, _detailView.frame.origin.y + _detailView.frame.size.height);
    [_showMoreDescContentBtn removeTarget:self action:@selector(showMoreContent:) forControlEvents:UIControlEventTouchUpInside];
    [_showMoreDescContentBtn addTarget:self action:@selector(hideContent:) forControlEvents:UIControlEventTouchUpInside];
    [_descView removeTarget:self action:@selector(showMoreContent:) forControlEvents:UIControlEventTouchUpInside];
    [_descView addTarget:self action:@selector(hideContent:) forControlEvents:UIControlEventTouchUpInside];
    [self.delegate updateCityHeaderView];
}

- (IBAction)hideContent:(id)sender
{
    [_descView hideContent];
    [UIView animateWithDuration:0.3 animations:^{
        [_headerView setFrame:CGRectMake(_headerView.frame.origin.x, _headerView.frame.origin.y, _headerView.frame.size.width, _headerView.frame.size.height - _descView.resizeHeight)];
        [_showMoreDescContentBtn setFrame:CGRectMake(_showMoreDescContentBtn.frame.origin.x, _showMoreDescContentBtn.frame.origin.y - _descView.resizeHeight, _showMoreDescContentBtn.frame.size.width, _showMoreDescContentBtn.frame.size.height)];
        _descView.contentVerticalAlignment = UIControlContentVerticalAlignmentTop;
        [_detailView setFrame:CGRectMake(_detailView.frame.origin.x, _detailView.frame.origin.y-_descView.resizeHeight, _detailView.frame.size.width, _detailView.frame.size.height)];
        _showMoreDescContentBtn.transform = CGAffineTransformMakeRotation(360 *M_PI / 180.0);

    }];
    
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, _detailView.frame.origin.y + _detailView.frame.size.height);
    [_showMoreDescContentBtn removeTarget:self action:@selector(hideContent:) forControlEvents:UIControlEventTouchUpInside];
    [_showMoreDescContentBtn addTarget:self action:@selector(showMoreContent:) forControlEvents:UIControlEventTouchUpInside];
    [_descView removeTarget:self action:@selector(hideContent:) forControlEvents:UIControlEventTouchUpInside];
    [_descView addTarget:self action:@selector(showMoreContent:) forControlEvents:UIControlEventTouchUpInside];
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
    
    [manager GET:requsetUrl parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"%@", responseObject);
        NSInteger code = [[responseObject objectForKey:@"code"] integerValue];
        if (code == 0) {
            NSMutableArray *tempArray = [[NSMutableArray alloc] init];
            for (id imageDic in [[responseObject objectForKey:@"result"] objectForKey:@"album"]) {
                [tempArray addObject:[imageDic objectForKey:@"url"]];
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
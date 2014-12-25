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
    
    [_headerView addSubview:gallery];
    _galleryPageView = gallery;
    
    _imagePageIndicator = [[UIButton alloc] initWithFrame:CGRectMake(_headerView.frame.size.width-53.5, gallery.frame.size.height-33, 47.5, 23)];
    _imagePageIndicator.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.6];
    [_imagePageIndicator setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    _imagePageIndicator.userInteractionEnabled = NO;
    _imagePageIndicator.layer.cornerRadius = 1.0;
    _imagePageIndicator.titleLabel.font = [UIFont systemFontOfSize:12.0];
    [_imagePageIndicator setTitle:[NSString stringWithFormat:@"共%d张", _cityPoi.imageCount] forState:UIControlStateNormal];
    [_headerView addSubview:_imagePageIndicator];
    
    int count = _cityPoi.images.count;
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
    if (_cityPoi.isMyFavorite) {
        [_favoriteBtn setImage:[UIImage imageNamed:@"ic_Favorite.png"] forState:UIControlStateNormal];
    } else {
        [_favoriteBtn setImage:[UIImage imageNamed:@"ic_unFavorite.png"] forState:UIControlStateNormal];
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
    
    CGFloat doy = 0;
    _detailView.backgroundColor = APP_PAGE_COLOR;
    
    NSAttributedString *timeCostDetail = [[NSAttributedString alloc] initWithString:_cityPoi.timeCostDesc
                                                                         attributes:@{
                                                                                      NSFontAttributeName : [UIFont systemFontOfSize:11.0],
                                                                                      NSForegroundColorAttributeName : TEXT_COLOR_TITLE_SUBTITLE
                                                                                      }];
    
    CGSize timeCostSize = timeCostDetail.size;
    NSInteger timeCostLineCount = (timeCostSize.width / (width-80-70)) + 1;
    CGFloat timeCostHeight = timeCostLineCount * 13.1+10;
    _timeCostBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, doy, width, timeCostHeight)];
    [_timeCostBtn setAttributedTitle:timeCostDetail forState:UIControlStateNormal];
    _timeCostBtn.titleLabel.numberOfLines = timeCostLineCount;
    _timeCostBtn.backgroundColor = [UIColor whiteColor];
    _timeCostBtn.titleEdgeInsets = UIEdgeInsetsMake(0, 100, 0, 8);
    _timeCostBtn.frame = CGRectMake(_timeCostBtn.frame.origin.x, _timeCostBtn.frame.origin.y, _timeCostBtn.frame.size.width, timeCostHeight);
    [_timeCostBtn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    UIButton *timeCostSubTitle = [[UIButton alloc] initWithFrame:CGRectMake(8, 0, 80, _timeCostBtn.frame.size.height)];
    [timeCostSubTitle setTitle:@"最佳游玩时间" forState:UIControlStateNormal];
    [timeCostSubTitle setTitleColor:TEXT_COLOR_TITLE forState:UIControlStateNormal];
    timeCostSubTitle.titleLabel.font = [UIFont systemFontOfSize:12.0];
    [_timeCostBtn addSubview:timeCostSubTitle];
    timeCostSubTitle.userInteractionEnabled = NO;
    
    UIImageView *spaceImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, width, 1)];
    spaceImageView.image = [UIImage imageNamed:@"ic_dotted_line.png"];
    [_timeCostBtn addSubview:spaceImageView];
    
    [_detailView addSubview:_timeCostBtn];
    
    doy += _timeCostBtn.frame.size.height;
    
    NSAttributedString *travelStr = [[NSAttributedString alloc] initWithString:_cityPoi.travelMonth
                                                                         attributes:@{
                                                                                      NSFontAttributeName : [UIFont systemFontOfSize:11.0],
                                                                                      NSForegroundColorAttributeName : TEXT_COLOR_TITLE_SUBTITLE
                                                                                      }];

    CGSize size = travelStr.size;
    NSInteger lineCount = (size.width / (width-80-70)) + 1;
    CGFloat height = lineCount * 13.1+10;
    
    _travelMonthBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, doy, width, height)];
    _travelMonthBtn.layer.cornerRadius = 1.0;
    [_travelMonthBtn setAttributedTitle:travelStr forState:UIControlStateNormal];
    _travelMonthBtn.titleLabel.numberOfLines = lineCount;
    
    _travelMonthBtn.backgroundColor = [UIColor whiteColor];
    
    _travelMonthBtn.titleEdgeInsets = UIEdgeInsetsMake(0, 100, 0, 8);
    _travelMonthBtn.frame = CGRectMake(_travelMonthBtn.frame.origin.x, _travelMonthBtn.frame.origin.y, _travelMonthBtn.frame.size.width, height);
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
    _showSpotsBtn.titleLabel.font = [UIFont boldSystemFontOfSize:14.0];
    [_showSpotsBtn setImage:[UIImage imageNamed:@"ic_standard_travel.png"] forState:UIControlStateNormal];
    [_showSpotsBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, 10, 0, 0)];
    _showSpotsBtn.backgroundColor = [UIColor whiteColor];
    _showSpotsBtn.layer.cornerRadius = 2.0;
    [_detailView addSubview:_showSpotsBtn];
    
    _showRestaurantsBtn = [[UIButton alloc] initWithFrame:CGRectMake(widthPerItem+0.5, doy, widthPerItem-0.5, 50)];
    [_showRestaurantsBtn setTitle:@"吃" forState:UIControlStateNormal];
    [_showRestaurantsBtn setTitleColor:TEXT_COLOR_TITLE forState:UIControlStateNormal];
    _showRestaurantsBtn.titleLabel.font = [UIFont boldSystemFontOfSize:14.0];
    [_showRestaurantsBtn setImage:[UIImage imageNamed:@"ic_standard_food.png"] forState:UIControlStateNormal];
    [_showRestaurantsBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, 10, 0, 0)];
    _showRestaurantsBtn.backgroundColor = [UIColor whiteColor];
    _showRestaurantsBtn.layer.cornerRadius = 2.0;
    [_detailView addSubview:_showRestaurantsBtn];
    
    _showShoppingBtn = [[UIButton alloc] initWithFrame:CGRectMake(widthPerItem*2+1, doy, widthPerItem-0.5, 50)];
    [_showShoppingBtn setTitle:@"买" forState:UIControlStateNormal];
    [_showShoppingBtn setTitleColor:TEXT_COLOR_TITLE forState:UIControlStateNormal];
    _showShoppingBtn.titleLabel.font = [UIFont boldSystemFontOfSize:14.0];
    [_showShoppingBtn setImage:[UIImage imageNamed:@"ic_standard_shopping.png"] forState:UIControlStateNormal];
    [_showShoppingBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, 10, 0, 0)];
    _showShoppingBtn.backgroundColor = [UIColor whiteColor];
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
    
    [SVProgressHUD show];
    
    [manager GET:requsetUrl parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"%@", responseObject);
//        [SVProgressHUD dismiss];
        NSInteger code = [[responseObject objectForKey:@"code"] integerValue];
        if (code == 0) {
            [SVProgressHUD dismiss];
            NSMutableArray *tempArray = [[NSMutableArray alloc] init];
            for (id imageDic in [[responseObject objectForKey:@"result"] objectForKey:@"album"]) {
                [tempArray addObject:[imageDic objectForKey:@"url"]];
            }
            albumCtl.imageList = tempArray;
        } else {
//            [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"%@",[[responseObject objectForKey:@"err"] objectForKey:@"message"]]];
//            [self showHint:@"请求也是失败了"];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [SVProgressHUD showHint:@"呃～好像没找到网络"];
    }];
}



@end
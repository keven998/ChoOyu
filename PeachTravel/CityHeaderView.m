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

@property (nonatomic, strong) UILabel *imagePageIndicator;
@property (nonatomic, strong) NSMutableArray *imageViews;
@property (nonatomic, strong) UILabel *titleBtn;
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
    self.backgroundColor = APP_PAGE_COLOR;
    CGFloat width = self.frame.size.width;
    
    UIScrollView *gallery = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, width, 167.5)];
    gallery.scrollEnabled = NO;
    gallery.showsHorizontalScrollIndicator = NO;
    gallery.showsVerticalScrollIndicator = NO;
    gallery.delegate = self;
    gallery.layer.borderColor = APP_BORDER_COLOR.CGColor;
    gallery.layer.borderWidth = 0.5;
    gallery.backgroundColor = APP_IMAGEVIEW_COLOR;
    [self addSubview:gallery];
    _galleryPageView = gallery;
    
    _imagePageIndicator = [[UILabel alloc] initWithFrame:CGRectMake(10, 167.5-33, 47.5, 23)];
    _imagePageIndicator.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.75];
    _imagePageIndicator.textColor = [UIColor whiteColor];
    _imagePageIndicator.layer.cornerRadius = 4.0;
    _imagePageIndicator.font = [UIFont systemFontOfSize:13];
    _imagePageIndicator.text = @"画册";
    _imagePageIndicator.textAlignment = NSTextAlignmentCenter;
    [self addSubview:_imagePageIndicator];
    
    NSInteger count = 1;//_cityPoi.images.count;
    _galleryPageView.contentSize = CGSizeMake(CGRectGetWidth(_galleryPageView.frame), CGRectGetHeight(_galleryPageView.frame));
    
    NSMutableArray *images = [[NSMutableArray alloc] init];
    for (NSUInteger i = 0; i < count; i++)
    {
        [images addObject:[NSNull null]];
    }
    _imageViews = images;
    [self loadScrollViewWithPage:0];
    
    _detailView = [[UIView alloc] init];
    _detailView.backgroundColor = [UIColor whiteColor];
    [self addSubview:_detailView];
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, 30)];
    view.backgroundColor = APP_THEME_COLOR;
    [_detailView addSubview:view];
    
    _titleBtn = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, width - 108, 30)];
    _titleBtn.text = _cityPoi.zhName;
    _titleBtn.textColor = [UIColor whiteColor];
    _titleBtn.font = [UIFont boldSystemFontOfSize:15.0];
    _titleBtn.userInteractionEnabled = YES;
    [view addSubview:_titleBtn];
    
    _favoriteBtn = [[UIButton alloc] initWithFrame:CGRectMake(width-65, 0, 60, 30)];
    [_favoriteBtn setImage:[UIImage imageNamed:@"ic_unFavorite.png"] forState:UIControlStateNormal];
    [_favoriteBtn setImage:[UIImage imageNamed:@"ic_Favorite.png"] forState:UIControlStateHighlighted];
    [_favoriteBtn setImage:[UIImage imageNamed:@"ic_Favorite.png"] forState:UIControlStateSelected];
    _favoriteBtn.selected = _cityPoi.isMyFavorite;
    [view addSubview:_favoriteBtn];
    
    CGFloat oy = 30;
    
    _descView = [[ResizableView alloc] initWithFrame:CGRectMake(10, oy + 15, width-20, 32) andNumberOfLine:2];
    _descView.contentFont = [UIFont systemFontOfSize:12.0];
    _descView.contentColor = TEXT_COLOR_TITLE_SUBTITLE;
    _descView.content = _cityPoi.desc;
    _descView.backgroundColor = [UIColor whiteColor];
    [_descView addTarget:self action:@selector(showMoreContent:) forControlEvents:UIControlEventTouchUpInside];
    [_detailView addSubview:_descView];
    
    oy += (15 + 32);
    
    if (_descView.maxNumberOfLine > 2) {
        _showMoreDescContentBtn = [[UIButton alloc] initWithFrame:CGRectMake(width - 50, oy, 50, 20)];
        [_showMoreDescContentBtn setImage:[UIImage imageNamed:@"cell_accessory_pink_down.png"] forState:UIControlStateNormal];
        [_showMoreDescContentBtn addTarget:self action:@selector(showMoreContent:) forControlEvents:UIControlEventTouchUpInside];
        _showMoreDescContentBtn.backgroundColor = [UIColor whiteColor];
        [_detailView addSubview:_showMoreDescContentBtn];
        oy += 24;
    }
    
    _headerView = [[UIView alloc] initWithFrame:CGRectMake(0, oy, width, 0)];
    [_detailView addSubview:_headerView];
    
    oy = 0;
    
    UIImageView *spaceImageView = [[UIImageView alloc] initWithFrame:CGRectMake(20, oy+3, width-40, 1)];
    spaceImageView.image = [UIImage imageNamed:@"ic_dotted_line.png"];
    [_headerView addSubview:spaceImageView];
    
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.lineSpacing = 2.0;
    
    oy += 4 + 15;
    
    _timeCostBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, oy, width, 0)];
    _timeCostBtn.titleLabel.numberOfLines = 0;

    CGSize timeCostLabelSize = [_cityPoi.timeCostDesc boundingRectWithSize:CGSizeMake(self.bounds.size.width-114, MAXFLOAT)
                                              options:NSStringDrawingUsesLineFragmentOrigin
                                           attributes:@{
                                                        NSFontAttributeName : [UIFont systemFontOfSize:13.0],
                                                        NSParagraphStyleAttributeName : style
                                                        }
                                              context:nil].size;
    
    CGFloat timeCostHeight = timeCostLabelSize.height + 20;
    _timeCostBtn.frame = CGRectMake(0, oy, width, timeCostHeight);
    [_timeCostBtn setAttributedTitle:[_cityPoi.timeCostDesc stringByAddLineSpacingAndTextColor:TEXT_COLOR_TITLE_SUBTITLE] forState:UIControlStateNormal];
    _timeCostBtn.titleLabel.font = [UIFont systemFontOfSize:13.0];
    _timeCostBtn.titleEdgeInsets = UIEdgeInsetsMake(0, 110, 0, 10);
    _timeCostBtn.contentVerticalAlignment = UIControlContentVerticalAlignmentTop;
    [_timeCostBtn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    
    UIButton *timeCostSubTitle = [[UIButton alloc] initWithFrame:CGRectMake(10, 0, 92, _timeCostBtn.frame.size.height)];
    [timeCostSubTitle setTitle:@"建议旅程安排" forState:UIControlStateNormal];
    [timeCostSubTitle setTitleColor:APP_THEME_COLOR forState:UIControlStateNormal];
    timeCostSubTitle.titleLabel.font = [UIFont systemFontOfSize:14.0];
    timeCostSubTitle.contentVerticalAlignment = UIControlContentVerticalAlignmentTop;
    [_timeCostBtn addSubview:timeCostSubTitle];
    timeCostSubTitle.userInteractionEnabled = NO;
    
    [_headerView addSubview:_timeCostBtn];
    
    oy += _timeCostBtn.frame.size.height;
    
    _travelMonthBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, oy, width, 0)];
    _travelMonthBtn.titleLabel.numberOfLines = 0;
    
    CGSize travelMonthLabelSize = [_cityPoi.travelMonth boundingRectWithSize:CGSizeMake(self.bounds.size.width-114, MAXFLOAT)
                                                                   options:NSStringDrawingUsesLineFragmentOrigin
                                                                attributes:@{
                                                                             NSFontAttributeName : [UIFont systemFontOfSize:13.0],
                                                                             NSParagraphStyleAttributeName : style
                                                                             }
                                                                   context:nil].size;
    
    CGFloat travelMonthHeight = travelMonthLabelSize.height + 20;

    
    _travelMonthBtn.frame = CGRectMake(0, oy, width, travelMonthHeight);
    _travelMonthBtn.layer.cornerRadius = 1.0;
    [_travelMonthBtn setAttributedTitle:[_cityPoi.travelMonth stringByAddLineSpacingAndTextColor:TEXT_COLOR_TITLE_SUBTITLE] forState:UIControlStateNormal];
    _travelMonthBtn.titleLabel.font = [UIFont systemFontOfSize:13.0];
    _travelMonthBtn.contentVerticalAlignment = UIControlContentVerticalAlignmentTop;
    _travelMonthBtn.backgroundColor = [UIColor whiteColor];
    
    _travelMonthBtn.titleEdgeInsets = UIEdgeInsetsMake(0, 110, 0, 10);
    [_travelMonthBtn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    
    UIButton *subTitle = [[UIButton alloc] initWithFrame:CGRectMake(10, 0, 92, _travelMonthBtn.frame.size.height)];
    [subTitle setTitle:@"最佳旅行季节" forState:UIControlStateNormal];
    [subTitle setTitleColor:APP_THEME_COLOR forState:UIControlStateNormal];
    subTitle.titleLabel.font = [UIFont systemFontOfSize:14.0];
    subTitle.contentVerticalAlignment = UIControlContentVerticalAlignmentTop;
    [_travelMonthBtn addSubview:subTitle];
    subTitle.userInteractionEnabled = NO;
    
    [_headerView addSubview:_travelMonthBtn];
    
    oy += _travelMonthBtn.frame.size.height + 10;
    
    CGFloat widthPerItem = width/3;
    
    _showSpotsBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, oy, widthPerItem-0.5, 50)];
    [_showSpotsBtn setTitle:@"游玩攻略" forState:UIControlStateNormal];
    [_showSpotsBtn setTitleColor:TEXT_COLOR_TITLE forState:UIControlStateNormal];
    [_showSpotsBtn setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
    _showSpotsBtn.titleLabel.font = [UIFont boldSystemFontOfSize:14.0];
    [_showSpotsBtn setImage:[UIImage imageNamed:@"ic_standard_travel.png"] forState:UIControlStateNormal];
    [_showSpotsBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, 8, 0, 0)];
    [_showSpotsBtn setBackgroundImage:[ConvertMethods createImageWithColor:[UIColor whiteColor]] forState:UIControlStateNormal];
    [_showSpotsBtn setBackgroundImage:[ConvertMethods createImageWithColor:[[UIColor whiteColor] colorWithAlphaComponent:0.5]] forState:UIControlStateHighlighted];
    _showSpotsBtn.clipsToBounds = YES;
    _showSpotsBtn.layer.cornerRadius = 2.0;
    [_headerView addSubview:_showSpotsBtn];
    
    _showRestaurantsBtn = [[UIButton alloc] initWithFrame:CGRectMake(widthPerItem+0.5, oy, widthPerItem-0.5, 50)];
    [_showRestaurantsBtn setTitle:@"美食攻略" forState:UIControlStateNormal];
    [_showRestaurantsBtn setTitleColor:TEXT_COLOR_TITLE forState:UIControlStateNormal];
    [_showRestaurantsBtn setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
    _showRestaurantsBtn.titleLabel.font = [UIFont boldSystemFontOfSize:14.0];
    [_showRestaurantsBtn setImage:[UIImage imageNamed:@"ic_standard_food.png"] forState:UIControlStateNormal];
    [_showRestaurantsBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, 8, 0, 0)];
    [_showRestaurantsBtn setBackgroundImage:[ConvertMethods createImageWithColor:[UIColor whiteColor]] forState:UIControlStateNormal];
    [_showRestaurantsBtn setBackgroundImage:[ConvertMethods createImageWithColor:[[UIColor whiteColor] colorWithAlphaComponent:0.5]] forState:UIControlStateHighlighted];
    _showRestaurantsBtn.clipsToBounds = YES;
    _showRestaurantsBtn.layer.cornerRadius = 2.0;
    [_headerView addSubview:_showRestaurantsBtn];
    
    _showShoppingBtn = [[UIButton alloc] initWithFrame:CGRectMake(widthPerItem*2+1, oy, widthPerItem-0.5, 50)];
    [_showShoppingBtn setTitle:@"购物攻略" forState:UIControlStateNormal];
    [_showShoppingBtn setTitleColor:TEXT_COLOR_TITLE forState:UIControlStateNormal];
    [_showShoppingBtn setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
    _showShoppingBtn.titleLabel.font = [UIFont boldSystemFontOfSize:14.0];
    [_showShoppingBtn setImage:[UIImage imageNamed:@"ic_standard_shopping.png"] forState:UIControlStateNormal];
    [_showShoppingBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, 8, 0, 0)];
    [_showShoppingBtn setBackgroundImage:[ConvertMethods createImageWithColor:[UIColor whiteColor]] forState:UIControlStateNormal];
    [_showShoppingBtn setBackgroundImage:[ConvertMethods createImageWithColor:[[UIColor whiteColor] colorWithAlphaComponent:0.5]] forState:UIControlStateHighlighted];
    _showShoppingBtn.clipsToBounds = YES;
    _showShoppingBtn.layer.cornerRadius = 2.0;
    [_headerView addSubview:_showShoppingBtn];
    
    oy += 60;
    
//    view = [[UIView alloc] initWithFrame:CGRectMake(0, oy, width, 20)];
//    view.backgroundColor = APP_PAGE_COLOR;
//    [_headerView addSubview:view];
//    
//    oy += 20;
//    
//    view = [[UIView alloc] initWithFrame:CGRectMake(0, oy, width, 30)];
//    view.backgroundColor = APP_THEME_COLOR;
//    [_headerView addSubview:view];
//    
//    UILabel *text = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 108, 30)];
//    text.text = @"精选游记";
//    text.textColor = [UIColor whiteColor];
//    text.font = [UIFont boldSystemFontOfSize:15.0];
//    text.userInteractionEnabled = YES;
//    [view addSubview:text];
//    
//    UIButton *allNotes = [[UIButton alloc] initWithFrame:CGRectMake(width - 108, 0, 108, 30)];
//    [allNotes setTitle:@"更多游记" forState:UIControlStateNormal];
//    [allNotes setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//    allNotes.titleLabel.font = [UIFont systemFontOfSize:13.0];
//    [allNotes setImage:[UIImage imageNamed:@"cell_accessory_gray.png"] forState:UIControlStateNormal];
//    allNotes.imageEdgeInsets = UIEdgeInsetsMake(0, 90, 0, 0);
//    allNotes.titleEdgeInsets = UIEdgeInsetsMake(0, 5, 0, 0);
//    [view addSubview:allNotes];
//    
//    oy += 30;
    
    CGRect frame = _headerView.frame;
    frame.size.height = oy + 20;
    _headerView.frame = frame;
     [_detailView setFrame:CGRectMake(0, gallery.frame.size.height+gallery.frame.origin.y+20, width, frame.origin.y + frame.size.height)];
    
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, width, _detailView.frame.origin.y + _detailView.frame.size.height);
    
}

#pragma mark - IBAction Methods

- (IBAction)showMoreContent:(id)sender
{
    [_descView showMoreContent];
   [UIView animateWithDuration:0.3 animations:^{
       CGRect frame = _showMoreDescContentBtn.frame;
       frame.origin.y += _descView.resizeHeight;
       _showMoreDescContentBtn.frame = frame;
       
       frame = _detailView.frame;
       frame.size.height += _descView.resizeHeight;
       _detailView.frame = frame;
       
       frame = _headerView.frame;
       frame.origin.y += _descView.resizeHeight;
       _headerView.frame = frame;
        _showMoreDescContentBtn.transform = CGAffineTransformMakeRotation(180 *M_PI / 180.0);
    } completion:^(BOOL finished) {
        self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, _detailView.frame.origin.y + _detailView.frame.size.height);
        [_showMoreDescContentBtn removeTarget:self action:@selector(showMoreContent:) forControlEvents:UIControlEventTouchUpInside];
        [_showMoreDescContentBtn addTarget:self action:@selector(hideContent:) forControlEvents:UIControlEventTouchUpInside];
        [_descView removeTarget:self action:@selector(showMoreContent:) forControlEvents:UIControlEventTouchUpInside];
        [_descView addTarget:self action:@selector(hideContent:) forControlEvents:UIControlEventTouchUpInside];
        [self.delegate updateCityHeaderView];
    }];
}

- (IBAction)hideContent:(id)sender
{
    [UIView animateWithDuration:0.3 animations:^{
        CGRect frame = _showMoreDescContentBtn.frame;
        frame.origin.y -= _descView.resizeHeight;
        _showMoreDescContentBtn.frame = frame;
        
        frame = _detailView.frame;
        frame.size.height -= _descView.resizeHeight;
        _detailView.frame = frame;
        
        frame = _headerView.frame;
        frame.origin.y -= _descView.resizeHeight;
        _headerView.frame = frame;
        
        _showMoreDescContentBtn.transform = CGAffineTransformMakeRotation(360 *M_PI / 180.0);
    } completion:^(BOOL finished) {
        [_descView hideContent];
        self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, _detailView.frame.origin.y + _detailView.frame.size.height);
        [_showMoreDescContentBtn removeTarget:self action:@selector(hideContent:) forControlEvents:UIControlEventTouchUpInside];
        [_showMoreDescContentBtn addTarget:self action:@selector(showMoreContent:) forControlEvents:UIControlEventTouchUpInside];
        [_descView removeTarget:self action:@selector(hideContent:) forControlEvents:UIControlEventTouchUpInside];
        [_descView addTarget:self action:@selector(showMoreContent:) forControlEvents:UIControlEventTouchUpInside];
        [self.delegate updateCityHeaderView];
    }];
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
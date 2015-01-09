//
//  CommonPoiDetailView.m
//  PeachTravel
//
//  Created by liangpengshuai on 11/22/14.
//  Copyright (c) 2014 com.aizou.www. All rights reserved.
//

#import "CommonPoiDetailView.h"
#import "ResizableView.h"
#import "LocationTableViewCell.h"
#import "RecommendsTableViewCell.h"
#import "CommentTableViewCell.h"
#import "EDStarRating.h"
#import "CycleScrollView.h"
#import "RestaurantDetailViewController.h"
#import "ShoppingDetailViewController.h"

@interface CommonPoiDetailView () <UIScrollViewDelegate, UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) CycleScrollView *galleryPageView;

@property (nonatomic, strong) UIView *headerView;

@property (nonatomic, strong) NSMutableArray *imageViews;
@property (nonatomic, strong) UIButton *titleBtn;
@property (nonatomic, strong) ResizableView *descView;
@property (nonatomic, strong) UIButton *showMoreDescContentBtn;
@property (nonatomic, strong) EDStarRating *ratingView;
@property (nonatomic, strong) UIButton *priceBtn;
@property (nonatomic, strong) UIButton *favoriteBtn;

@property (nonatomic) CGRect finalFrame;

@property (nonatomic, strong) UIButton *telephoneBtn;


@end

@implementation CommonPoiDetailView

static NSString *locationCellIdentifier = @"locationCell";
static NSString *recommendCellIdentifier = @"recommendCell";
static NSString *commentCellIdentifier = @"commentCell";


- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = APP_PAGE_COLOR;
    }
    return self;
}

- (void)setPoi:(PoiSummary *)poi
{
    _poi = poi;
    [self setupSubView];
}

- (void)setupSubView
{
    self.dataSource = self;
    self.delegate = self;
    self.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.showsVerticalScrollIndicator = NO;
    self.showsHorizontalScrollIndicator = NO;

    CGFloat oy = 10;
    CGFloat width = self.frame.size.width;
    
    _headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, 293)];
    _headerView.backgroundColor = [UIColor whiteColor];
    _headerView.layer.cornerRadius = 2.0;
    _headerView.clipsToBounds = YES;
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, 10)];
    view.backgroundColor = APP_PAGE_COLOR;
    [_headerView addSubview:view];
    
    _galleryPageView = [[CycleScrollView alloc]initWithFrame:CGRectMake(0, oy, width, 130.0) animationDuration:0];
    
    _galleryPageView.layer.borderColor = APP_BORDER_COLOR.CGColor;
    _galleryPageView.layer.borderWidth = 0.5;
    _galleryPageView.backgroundColor = APP_IMAGEVIEW_COLOR;
    self.backgroundColor = APP_PAGE_COLOR;
    
    NSInteger count = _poi.images.count;
    NSMutableArray *images = [[NSMutableArray alloc] init];
    for (NSUInteger i = 0; i < count; i++)
    {
        [images addObject:[NSNull null]];
    }
    _imageViews = images;
    
    __weak typeof(CommonPoiDetailView *)weakSelf = self;
    
    _galleryPageView.fetchContentViewAtIndex = ^UIView *(NSInteger pageIndex){
        return (UIView *)[weakSelf loadScrollViewWithPage:pageIndex];
    };
    
    _galleryPageView.totalPagesCount = ^NSInteger(void){
        return count;
    };
    
    _galleryPageView.TapActionBlock = ^(NSInteger pageIndex){
    };

    [_headerView addSubview:_galleryPageView];
    
    _favoriteBtn = [[UIButton alloc] initWithFrame:CGRectMake(width-65, oy+10, 60, 30)];
    [_favoriteBtn setImage:[UIImage imageNamed:@"ic_unFavorite.png"] forState:UIControlStateNormal];
    [_favoriteBtn setImage:[UIImage imageNamed:@"ic_Favorite.png"] forState:UIControlStateHighlighted];
    [_favoriteBtn setImage:[UIImage imageNamed:@"ic_Favorite.png"] forState:UIControlStateSelected];
    if (_poi.isMyFavorite) {
        _favoriteBtn.selected = YES;
    }
    [_favoriteBtn addTarget:self action:@selector(favorite:) forControlEvents:UIControlEventTouchUpInside];
    [_headerView addSubview:_favoriteBtn];
    
    oy += 140;

    UIButton *decorationView = [[UIButton alloc] initWithFrame:CGRectMake((width-30)/2, oy, 20, 20)];
    [decorationView setImage:[UIImage imageNamed:@"ic_decoration.png"] forState:UIControlStateNormal];
    [_headerView addSubview:decorationView];
    oy += 30;
    
    _titleBtn = [[UIButton alloc] initWithFrame:CGRectMake(10, oy, width-20, 20)];
    [_titleBtn setTitle:_poi.zhName forState:UIControlStateNormal];
    [_titleBtn setTitleColor:TEXT_COLOR_TITLE forState:UIControlStateNormal];
    [_titleBtn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentCenter];
    _titleBtn.titleLabel.font = [UIFont boldSystemFontOfSize:15.0];
    _titleBtn.userInteractionEnabled = NO;
    [_headerView addSubview:_titleBtn];
    
    oy += 30;
    
    _ratingView = [[EDStarRating alloc] initWithFrame:CGRectMake((width - 73.0)/2, oy, 73.0
                                                                 , 15)];
    _ratingView.starImage = [UIImage imageNamed:@"ic_star_gray.png"];
    _ratingView.starHighlightedImage = [UIImage imageNamed:@"rating_star.png"];
    _ratingView.maxRating = 5.0;
    _ratingView.horizontalMargin = 5.0;
    _ratingView.editable = NO;
    _ratingView.displayMode = EDStarRatingDisplayAccurate;
    _ratingView.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    [_ratingView setRating:_poi.rating];
    [_headerView addSubview:_ratingView];
    
    oy += 10;
    
    _priceBtn = [[UIButton alloc] initWithFrame:CGRectMake(10, oy, width-20, 20)];
    [_priceBtn setTitle:_poi.priceDesc forState:UIControlStateNormal];
    [_priceBtn setTitleColor:APP_THEME_COLOR forState:UIControlStateNormal];
    [_priceBtn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentCenter];
    _priceBtn.titleLabel.font = [UIFont systemFontOfSize:11.0];
    _priceBtn.userInteractionEnabled = NO;
    [_headerView addSubview:_priceBtn];
    
    oy += 20;
    
    _descView = [[ResizableView alloc] initWithFrame:CGRectMake(10, oy, width-20, 30) andNumberOfLine:2];
    _descView.contentFont = [UIFont systemFontOfSize:12.0];
    _descView.contentColor = TEXT_COLOR_TITLE_SUBTITLE;
    _descView.content = _poi.desc;
    _descView.numberOfLine = 2.0;

    [_headerView addSubview:_descView];
    
    oy += 25;
    
    if (_descView.maxNumberOfLine > 2) {
        [_descView addTarget:self action:@selector(showMoreContent:) forControlEvents:UIControlEventTouchUpInside];
        _showMoreDescContentBtn = [[UIButton alloc] initWithFrame:CGRectMake(width-30, oy, 20, 20)];
        [_showMoreDescContentBtn setImage:[UIImage imageNamed:@"cell_accessory_pink_down.png"] forState:UIControlStateNormal];
        [_headerView addSubview:_showMoreDescContentBtn];
    }
    
    if (_descView.maxNumberOfLine > 2) {
        [_showMoreDescContentBtn addTarget:self action:@selector(showMoreContent:) forControlEvents:UIControlEventTouchUpInside];
        [_headerView addSubview:_showMoreDescContentBtn];
    }
    
    if (_descView.maxNumberOfLine == 1) {
        oy += 10;
    } else {
        oy += 25;
    }

    _headerView.frame = CGRectMake(0, 0, width, oy);
    
    _finalFrame = _headerView.frame;
    
    self.tableHeaderView = _headerView;
    
    [self registerNib:[UINib nibWithNibName:@"LocationTableViewCell" bundle:nil] forCellReuseIdentifier:locationCellIdentifier];
    [self registerNib:[UINib nibWithNibName:@"RecommendsTableViewCell" bundle:nil] forCellReuseIdentifier:recommendCellIdentifier];
    [self registerNib:[UINib nibWithNibName:@"CommentTableViewCell" bundle:nil] forCellReuseIdentifier:commentCellIdentifier];
}

- (UIImageView *)loadScrollViewWithPage:(NSUInteger)page {
    if (page >= _poi.images.count) {
        return nil;
    }
    
    UIImageView *img = [_imageViews objectAtIndex:page];
    if ((NSNull *)img == [NSNull null]) {
        img = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0.0, self.bounds.size.width, CGRectGetHeight(self.galleryPageView.frame))];
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
        TaoziImage *taoziImage = [_poi.images objectAtIndex:page];
        NSString *url = taoziImage.imageUrl;
        [img sd_setImageWithURL:[NSURL URLWithString:url] placeholderImage:[UIImage imageNamed:@"spot_detail_default.png"]];
    }
    return img;
}

#pragma mark - IBAction Methods

- (void)showMoreComments:(id)sender
{
    
}

#pragma mark - UITableview datasource & delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 1;
    }
    if (section == 1) {
        return 1;
    }
    if (section == 2) {
        return _poi.comments.count;
    }
    return 0;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return 0;
    } else {
        return 43.0;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        
        return [LocationTableViewCell heightForAddressCellWithAddress:_poi.address];
    }
    if (indexPath.section == 1) {
        return 95;
    }
    if (indexPath.section == 2) {
        NSString *commentDetail = ((CommentDetail *)[_poi.comments objectAtIndex:indexPath.row]).commentDetails;
        return [CommentTableViewCell heightForCommentCellWithComment:commentDetail];
    }
    return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return nil;
    }
    UIView *sectionView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 43)];
    sectionView.backgroundColor = APP_PAGE_COLOR;
    UIButton *sectionBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 9, self.frame.size.width, 33)];
    [sectionBtn setTitleColor:TEXT_COLOR_TITLE forState:UIControlStateNormal];
    sectionBtn.titleLabel.font = [UIFont boldSystemFontOfSize:12];
    sectionBtn.backgroundColor = [UIColor whiteColor];
    sectionBtn.layer.cornerRadius = 1.0;
    sectionBtn.userInteractionEnabled = NO;
    [sectionBtn setContentEdgeInsets:UIEdgeInsetsMake(0, 9, 0, 0)];
    [sectionBtn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    if (section == 1) {
        [sectionBtn setImage:[UIImage imageNamed:@"ic_recommend.png"] forState:UIControlStateNormal];
        [sectionBtn setTitle:@"网友推荐" forState:UIControlStateNormal];
    }
    if (section == 2) {
        [sectionBtn setImage:[UIImage imageNamed:@"ic_comment.png"] forState:UIControlStateNormal];

        [sectionBtn setTitle:@"网友点评" forState:UIControlStateNormal];
        
        UIButton *moreCommentBtn = [[UIButton alloc] initWithFrame:CGRectMake(sectionBtn.frame.size.width-60, 0, 60, 29)];
        [moreCommentBtn setTitle:@"更多点评" forState:UIControlStateNormal];
        [moreCommentBtn setTitleColor:APP_THEME_COLOR forState:UIControlStateNormal];
        moreCommentBtn.titleLabel.font = [UIFont systemFontOfSize:11.0];
        [sectionBtn addSubview:moreCommentBtn];
        [moreCommentBtn addTarget:self action:@selector(showMoreComments:) forControlEvents:UIControlEventTouchUpInside];
    }
    [sectionView addSubview:sectionBtn];

    return sectionView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        LocationTableViewCell *locationCell = [tableView dequeueReusableCellWithIdentifier:locationCellIdentifier];
        locationCell.address = _poi.address;
        return locationCell;
    }
    if (indexPath.section == 1) {
        RecommendsTableViewCell *recommendsCell = [tableView dequeueReusableCellWithIdentifier:recommendCellIdentifier];
        recommendsCell.recommends = _poi.recommends;
        return recommendsCell;
        
    } if (indexPath.section == 2) {
        CommentTableViewCell *commentCell = [tableView dequeueReusableCellWithIdentifier:commentCellIdentifier];
        commentCell.commentDetail = [_poi.comments objectAtIndex:indexPath.row];
        return commentCell;
    }
    return nil;
}

#pragma mark - IBAction Methods

- (IBAction)viewImage:(id)sender
{
    
}

- (IBAction)showMoreContent:(id)sender
{
    [_descView showMoreContent];

    [UIView animateWithDuration:0.2 animations:^{
        [_headerView setFrame:CGRectMake(_headerView.frame.origin.x, _headerView.frame.origin.y, _headerView.frame.size.width, _headerView.frame.size.height + _descView.resizeHeight)];
        [_showMoreDescContentBtn setFrame:CGRectMake(_showMoreDescContentBtn.frame.origin.x, _showMoreDescContentBtn.frame.origin.y+_descView.resizeHeight, _showMoreDescContentBtn.frame.size.width, _showMoreDescContentBtn.frame.size.height)];
        _showMoreDescContentBtn.transform = CGAffineTransformMakeRotation(180 *M_PI / 180.0);

    }];
    [self setContentSize:CGSizeMake(self.contentSize.width, self.contentSize.height+_descView.resizeHeight)];
    
    [_showMoreDescContentBtn removeTarget:self action:@selector(showMoreContent:) forControlEvents:UIControlEventTouchUpInside];
    [_showMoreDescContentBtn addTarget:self action:@selector(hideContent:) forControlEvents:UIControlEventTouchUpInside];
    [_descView removeTarget:self action:@selector(showMoreContent:) forControlEvents:UIControlEventTouchUpInside];
    [_descView addTarget:self action:@selector(hideContent:) forControlEvents:UIControlEventTouchUpInside];
    
    [self setTableHeaderView:_headerView];

    [self beginUpdates];
    [self endUpdates];

}

- (IBAction)hideContent:(id)sender
{
    [_descView hideContent];
    
    [UIView animateWithDuration:0.2 animations:^{
        [_headerView setFrame:CGRectMake(_headerView.frame.origin.x, _headerView.frame.origin.y, _headerView.frame.size.width, _headerView.frame.size.height - _descView.resizeHeight)];
        [_showMoreDescContentBtn setFrame:CGRectMake(_showMoreDescContentBtn.frame.origin.x, _showMoreDescContentBtn.frame.origin.y - _descView.resizeHeight, _showMoreDescContentBtn.frame.size.width, _showMoreDescContentBtn.frame.size.height)];
        _showMoreDescContentBtn.transform = CGAffineTransformMakeRotation(360 *M_PI / 180.0);

    }];
    [_showMoreDescContentBtn removeTarget:self action:@selector(hideContent:) forControlEvents:UIControlEventTouchUpInside];
    [_showMoreDescContentBtn addTarget:self action:@selector(showMoreContent:) forControlEvents:UIControlEventTouchUpInside];
    [_descView removeTarget:self action:@selector(hideContent:) forControlEvents:UIControlEventTouchUpInside];
    [_descView addTarget:self action:@selector(showMoreContent:) forControlEvents:UIControlEventTouchUpInside];
    
    [self setTableHeaderView:_headerView];

    [self beginUpdates];
    [self endUpdates];
}

- (IBAction)favorite:(id)sender
{
    //先将收藏的状态改变
    _favoriteBtn.selected = !_poi.isMyFavorite;
    _favoriteBtn.userInteractionEnabled = NO;

    for (UIView* next = [self superview]; next; next = next.superview)
    {
        UIResponder* nextResponder = [next nextResponder];
        
        if ([nextResponder isKindOfClass:[ShoppingDetailViewController class]])
        {
            ShoppingDetailViewController *rootCtl;
            rootCtl = (ShoppingDetailViewController*)nextResponder;
            [rootCtl asyncFavorite:_poi.poiId poiType:_poi.poiTypeDesc isFavorite:!_poi.isMyFavorite completion:^(BOOL isSuccess) {
                _favoriteBtn.userInteractionEnabled = YES;
                if (isSuccess) {
                    _poi.isMyFavorite = !_poi.isMyFavorite;
                } else {      //如果失败了，再把状态改回来
                    _favoriteBtn.selected = !_poi.isMyFavorite;
                }
            }];
            break;
        }
        
        if ([nextResponder isKindOfClass:[RestaurantDetailViewController class]])
        {
            RestaurantDetailViewController *rootCtl;
            rootCtl = (RestaurantDetailViewController*)nextResponder;
            [rootCtl asyncFavorite:_poi.poiId poiType:_poi.poiTypeDesc isFavorite:!_poi.isMyFavorite completion:^(BOOL isSuccess) {
                _favoriteBtn.userInteractionEnabled = YES;
                if (isSuccess) {
                    _poi.isMyFavorite = !_poi.isMyFavorite;
                } else {      //如果失败了，再把状态改回来
                    _favoriteBtn.selected = !_poi.isMyFavorite;
                }
            }];
            break;
        }
    }
}

@end










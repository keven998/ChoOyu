//
//  RestaurantDetailView.m
//  PeachTravel
//
//  Created by liangpengshuai on 11/22/14.
//  Copyright (c) 2014 com.aizou.www. All rights reserved.
//

#import "RestaurantDetailView.h"
#import "ResizableView.h"
#import "LocationTableViewCell.h"
#import "RecommendsTableViewCell.h"
#import "CommentTableViewCell.h"
#import "AXRatingView.h"

@interface RestaurantDetailView () <UIScrollViewDelegate, UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UIScrollView *galleryPageView;

@property (nonatomic, strong) UIView *headerView;

@property (nonatomic, strong) NSMutableArray *imageViews;
@property (nonatomic, strong) UIButton *titleBtn;
@property (nonatomic, strong) ResizableView *descView;
@property (nonatomic, strong) UIButton *showMoreDescContentBtn;
@property (nonatomic, strong) AXRatingView *ratingView;
@property (nonatomic, strong) UIButton *priceBtn;


@property (nonatomic, strong) UIButton *telephoneBtn;


@end

@implementation RestaurantDetailView

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

- (void)setRestaurantPoi:(RestaurantPoi *)restaurantPoi
{
    _restaurantPoi = restaurantPoi;
    [self setupSubView];
}

- (void)setupSubView
{
    self.dataSource = self;
    self.delegate = self;
    self.separatorStyle = UITableViewCellSeparatorStyleNone;

    CGFloat oy = 0;
    CGFloat width = self.frame.size.width;
    
    _headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, 283)];
    _headerView.backgroundColor = [UIColor whiteColor];
    _headerView.layer.cornerRadius = 2.0;
    _headerView.clipsToBounds = YES;
    
    UIScrollView *gallery = [[UIScrollView alloc]initWithFrame:CGRectMake(0, oy, width, 130.0)];
    gallery.pagingEnabled = YES;
    gallery.showsHorizontalScrollIndicator = NO;
    gallery.showsVerticalScrollIndicator = NO;
    gallery.delegate = self;
    gallery.bounces = YES;
    [_headerView addSubview:gallery];
    _galleryPageView = gallery;
    
    int count = _restaurantPoi.images.count;
    _galleryPageView.contentSize = CGSizeMake(CGRectGetWidth(_galleryPageView.frame) * count, CGRectGetHeight(_galleryPageView.frame));
    
    NSMutableArray *images = [[NSMutableArray alloc] init];
    for (NSUInteger i = 0; i < count; i++)
    {
        [images addObject:[NSNull null]];
    }
    _imageViews = images;
    [self loadScrollViewWithPage:0];
    if (count > 1) {
        [self loadScrollViewWithPage:1];
    }
    oy += 140;

    UIButton *decorationView = [[UIButton alloc] initWithFrame:CGRectMake((width-30)/2, oy, 20, 20)];
    [decorationView setImage:[UIImage imageNamed:@"ic_decoration.png"] forState:UIControlStateNormal];
    [_headerView addSubview:decorationView];
    oy += 30;
    
    _titleBtn = [[UIButton alloc] initWithFrame:CGRectMake(10, oy, width-20, 20)];
    [_titleBtn setTitle:_restaurantPoi.zhName forState:UIControlStateNormal];
    [_titleBtn setTitleColor:TEXT_COLOR_TITLE forState:UIControlStateNormal];
    [_titleBtn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentCenter];
    _titleBtn.titleLabel.font = [UIFont boldSystemFontOfSize:15.0];
    _titleBtn.userInteractionEnabled = NO;
    [_headerView addSubview:_titleBtn];
    
    oy += 30;
    
    _ratingView = [[AXRatingView alloc] initWithFrame:CGRectMake((width-40)/2, oy, 40
                                                                 , 15)];
    _ratingView.userInteractionEnabled = NO;
    _ratingView.markImage = [UIImage imageNamed:@"ic_star_gray.png"];
    [_ratingView sizeToFit];
    _ratingView.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    [_ratingView setValue:_restaurantPoi.rating];
    [_headerView addSubview:_ratingView];
    
    oy += 10;
    
    _priceBtn = [[UIButton alloc] initWithFrame:CGRectMake(10, oy, width-20, 20)];
    [_priceBtn setTitle:_restaurantPoi.priceDesc forState:UIControlStateNormal];
    [_priceBtn setTitleColor:APP_THEME_COLOR forState:UIControlStateNormal];
    [_priceBtn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentCenter];
    _priceBtn.titleLabel.font = [UIFont systemFontOfSize:11.0];
    _priceBtn.userInteractionEnabled = NO;
    [_headerView addSubview:_priceBtn];
    
    oy += 20;
    
    _descView = [[ResizableView alloc] initWithFrame:CGRectMake(10, oy, width-20, 30)];
    _descView.contentFont = [UIFont systemFontOfSize:12.0];
    _descView.contentColor = TEXT_COLOR_TITLE_SUBTITLE;
    _descView.content = _restaurantPoi.desc;
    _descView.numberOfLine = 2.0;

    [_headerView addSubview:_descView];
    
    oy += 25;
    
    _showMoreDescContentBtn = [[UIButton alloc] initWithFrame:CGRectMake(width-30, oy, 20, 20)];
    [_showMoreDescContentBtn setImage:[UIImage imageNamed:@"cell_accessory_pink_down.png"] forState:UIControlStateNormal];
    
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
    
    
    UIView *tempHeaderView = [[UIView alloc] initWithFrame:_headerView.frame];
    tempHeaderView.backgroundColor = [UIColor clearColor];
    self.tableHeaderView = tempHeaderView;
    
    [self addSubview:_headerView];
    [self registerNib:[UINib nibWithNibName:@"LocationTableViewCell" bundle:nil] forCellReuseIdentifier:locationCellIdentifier];
    [self registerNib:[UINib nibWithNibName:@"RecommendsTableViewCell" bundle:nil] forCellReuseIdentifier:recommendCellIdentifier];
    [self registerNib:[UINib nibWithNibName:@"CommentTableViewCell" bundle:nil] forCellReuseIdentifier:commentCellIdentifier];
    

}

- (void)loadScrollViewWithPage:(NSUInteger)page {
    if (page >= _restaurantPoi.images.count) {
        return;
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
        TaoziImage *taoziImage = [_restaurantPoi.images objectAtIndex:page];
        NSString *url = taoziImage.imageUrl;
        [img sd_setImageWithURL:[NSURL URLWithString:url] placeholderImage:[UIImage imageNamed:@"spot_detail_default.png"]];
    }
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
        return _restaurantPoi.comments.count;
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
        CGSize size = [_restaurantPoi.address sizeWithAttributes:@{NSFontAttributeName :[UIFont systemFontOfSize:15.0]}];
        NSInteger lineCount = (size.width / (self.frame.size.width-60)) + 1;
        CGFloat addressHeight = lineCount*size.height+10;
        return addressHeight+60;
    }
    if (indexPath.section == 1) {
        return 95;
    }
    if (indexPath.section == 2) {
        NSString *commentDetail = ((CommentDetail *)[_restaurantPoi.comments objectAtIndex:indexPath.row]).commentDetails;
        
        commentDetail = @"sdklfjsdlfjsdds离开家法拉克减肥撒龙卷风快上课了打飞机塞德里克福建师大";
        
        CGSize size = [commentDetail sizeWithAttributes:@{NSFontAttributeName :[UIFont systemFontOfSize:11.0]}];
        NSInteger lineCount = (size.width / (self.frame.size.width-16)) + 1;
        CGFloat commentHeight = lineCount*size.height+10;
        return commentHeight+60;
    }
    return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return nil;
    }
    UIView *sectionView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 43)];
    sectionView.backgroundColor = UIColorFromRGB(0xf5f5f5);
    UIButton *sectionBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 9, self.frame.size.width, 33)];
    [sectionBtn setTitleColor:TEXT_COLOR_TITLE forState:UIControlStateNormal];
    sectionBtn.titleLabel.font = [UIFont boldSystemFontOfSize:12];
    sectionBtn.backgroundColor = [UIColor whiteColor];
    sectionBtn.layer.cornerRadius = 1.0;
    [sectionBtn setContentEdgeInsets:UIEdgeInsetsMake(0, 9, 0, 0)];
    [sectionBtn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    if (section == 1) {
        [sectionBtn setImage:[UIImage imageNamed:@"ic_recommend.png"] forState:UIControlStateNormal];
        [sectionBtn setTitle:@"网友推荐" forState:UIControlStateNormal];
    }
    if (section == 2) {
        [sectionBtn setImage:[UIImage imageNamed:@"ic_comment.png"] forState:UIControlStateNormal];

        [sectionBtn setTitle:@"网友点评" forState:UIControlStateNormal];
    }
    [sectionView addSubview:sectionBtn];

    return sectionView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        LocationTableViewCell *locationCell = [tableView dequeueReusableCellWithIdentifier:locationCellIdentifier];
        locationCell.address = _restaurantPoi.address;
        return locationCell;
    }
    if (indexPath.section == 1) {
        RecommendsTableViewCell *recommendsCell = [tableView dequeueReusableCellWithIdentifier:recommendCellIdentifier];
        recommendsCell.recommends = _restaurantPoi.recommends;
        return recommendsCell;
        
    } if (indexPath.section == 2) {
        CommentTableViewCell *commentCell = [tableView dequeueReusableCellWithIdentifier:commentCellIdentifier];
        commentCell.commentDetail = [_restaurantPoi.comments objectAtIndex:indexPath.row];
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
    UIView *tempHeaderView = [[UIView alloc] initWithFrame:CGRectMake(_headerView.frame.origin.x, _headerView.frame.origin.y, _headerView.frame.size.width, _headerView.frame.size.height + _descView.resizeHeight+64+10)];
    [self beginUpdates];
    self.tableHeaderView = tempHeaderView;
    [self endUpdates];
    [self bringSubviewToFront:_headerView];

    [UIView animateWithDuration:0.2 animations:^{
        [_headerView setFrame:CGRectMake(_headerView.frame.origin.x, _headerView.frame.origin.y, _headerView.frame.size.width, _headerView.frame.size.height + _descView.resizeHeight)];
        [_showMoreDescContentBtn setFrame:CGRectMake(_showMoreDescContentBtn.frame.origin.x, _showMoreDescContentBtn.frame.origin.y+_descView.resizeHeight, _showMoreDescContentBtn.frame.size.width, _showMoreDescContentBtn.frame.size.height)];
    }];
    [self setContentSize:CGSizeMake(self.contentSize.width, self.contentSize.height+_descView.resizeHeight)];
    [_showMoreDescContentBtn removeTarget:self action:@selector(showMoreContent:) forControlEvents:UIControlEventTouchUpInside];
    [_showMoreDescContentBtn addTarget:self action:@selector(hideContent:) forControlEvents:UIControlEventTouchUpInside];
}

- (IBAction)hideContent:(id)sender
{
    [_descView hideContent];
    UIView *tempHeaderView = [[UIView alloc] initWithFrame:CGRectMake(_headerView.frame.origin.x, _headerView.frame.origin.y, _headerView.frame.size.width, _headerView.frame.size.height - _descView.resizeHeight+64+10)];
    
    [self beginUpdates];
    self.tableHeaderView = tempHeaderView;
    [self endUpdates];
    [self bringSubviewToFront:_headerView];
    [UIView animateWithDuration:0.2 animations:^{
        [_headerView setFrame:CGRectMake(_headerView.frame.origin.x, _headerView.frame.origin.y, _headerView.frame.size.width, _headerView.frame.size.height - _descView.resizeHeight)];
        [_showMoreDescContentBtn setFrame:CGRectMake(_showMoreDescContentBtn.frame.origin.x, _showMoreDescContentBtn.frame.origin.y - _descView.resizeHeight, _showMoreDescContentBtn.frame.size.width, _showMoreDescContentBtn.frame.size.height)];
    }];
    [_showMoreDescContentBtn removeTarget:self action:@selector(hideContent:) forControlEvents:UIControlEventTouchUpInside];
    [_showMoreDescContentBtn addTarget:self action:@selector(showMoreContent:) forControlEvents:UIControlEventTouchUpInside];
}


@end










//
//  ShoppingDetailView.m
//  PeachTravel
//
//  Created by liangpengshuai on 11/24/14.
//  Copyright (c) 2014 com.aizou.www. All rights reserved.
//

#import "ShoppingDetailView.h"
#import "ResizableView.h"
#import "LocationTableViewCell.h"
#import "RecommendsTableViewCell.h"
#import "CommentTableViewCell.h"


@interface ShoppingDetailView () <UIScrollViewDelegate, UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UIScrollView *galleryPageView;

@property (nonatomic, strong) UIView *headerView;

@property (nonatomic, strong) NSMutableArray *imageViews;
@property (nonatomic, strong) UIButton *titleBtn;
@property (nonatomic, strong) ResizableView *descView;
@property (nonatomic, strong) UIButton *showMoreDescContentBtn;
@property (nonatomic, strong) UIButton *scoreBtn;
@property (nonatomic, strong) UIButton *priceBtn;


@property (nonatomic, strong) UIButton *telephoneBtn;


@end

@implementation ShoppingDetailView

static NSString *locationCellIdentifier = @"locationCell";
static NSString *recommendCellIdentifier = @"recommendCell";
static NSString *commentCellIdentifier = @"commentCell";


- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = UIColorFromRGB(0xf4f4f4);
    }
    return self;
}

- (void)setShoppingPoi:(ShoppingPoi *)shoppingPoi
{
    _shoppingPoi = shoppingPoi;
    [self setupSubView];
}

- (void)setupSubView
{
    self.dataSource = self;
    self.delegate = self;
    self.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    CGFloat oy = 0;
    CGFloat width = self.frame.size.width;
    
    _headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 10+64, width, 380)];
    _headerView.backgroundColor = [UIColor whiteColor];
    _headerView.layer.cornerRadius = 2.0;
    
    UIScrollView *gallery = [[UIScrollView alloc]initWithFrame:CGRectMake(0, oy, width, 176.0)];
    gallery.pagingEnabled = YES;
    gallery.showsHorizontalScrollIndicator = NO;
    gallery.showsVerticalScrollIndicator = NO;
    gallery.delegate = self;
    gallery.bounces = YES;
    [_headerView addSubview:gallery];
    _galleryPageView = gallery;
    
    int count = _shoppingPoi.images.count;
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
    oy += 180;
    
    UIButton *decorationView = [[UIButton alloc] initWithFrame:CGRectMake((width-30)/2, oy, 30, 30)];
    decorationView.layer.cornerRadius = 15.0;
    decorationView.backgroundColor = UIColorFromRGB(0xee528c);
    [_headerView addSubview:decorationView];
    oy += 35;
    
    _titleBtn = [[UIButton alloc] initWithFrame:CGRectMake(10, oy, width-20, 30)];
    [_titleBtn setTitle:_shoppingPoi.zhName forState:UIControlStateNormal];
    [_titleBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_titleBtn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentCenter];
    _titleBtn.titleLabel.font = [UIFont boldSystemFontOfSize:17.0];
    _titleBtn.userInteractionEnabled = NO;
    [_headerView addSubview:_titleBtn];
    
    oy += 35;
    
    _scoreBtn = [[UIButton alloc] initWithFrame:CGRectMake((width-100)/2, oy, 100, 20)];
    _scoreBtn.backgroundColor = UIColorFromRGB(0xee528c);
    _scoreBtn.userInteractionEnabled = NO;
    [_headerView addSubview:_scoreBtn];
    
    oy += 25;
    
    _priceBtn = [[UIButton alloc] initWithFrame:CGRectMake(10, oy, width-20, 30)];
    [_priceBtn setTitle:_shoppingPoi.priceDesc forState:UIControlStateNormal];
    [_priceBtn setTitleColor:UIColorFromRGB(0xee528c) forState:UIControlStateNormal];
    [_priceBtn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentCenter];
    _priceBtn.titleLabel.font = [UIFont boldSystemFontOfSize:14.0];
    _priceBtn.userInteractionEnabled = NO;
    [_headerView addSubview:_priceBtn];
    
    oy += 30;
    
    _descView = [[ResizableView alloc] initWithFrame:CGRectMake(10, oy, width-20, 40)];
    _descView.contentFont = [UIFont systemFontOfSize:15.0];
    _descView.contentColor = [UIColor grayColor];
    _descView.content = _shoppingPoi.desc;
    
    [_headerView addSubview:_descView];
    
    oy += 45;
    
    _showMoreDescContentBtn = [[UIButton alloc] initWithFrame:CGRectMake(width-50, oy, 20, 10)];
    [_showMoreDescContentBtn setBackgroundColor:[UIColor grayColor]];
    [_showMoreDescContentBtn addTarget:self action:@selector(showMoreContent:) forControlEvents:UIControlEventTouchUpInside];
    [_headerView addSubview:_showMoreDescContentBtn];
    
    oy += 30;
    
    UIView *tempHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _headerView.frame.size.width, _headerView.frame.size.height+64+10)];
    tempHeaderView.backgroundColor = [UIColor clearColor];
    self.tableHeaderView = tempHeaderView;
    
    [self addSubview:_headerView];
    [self registerNib:[UINib nibWithNibName:@"LocationTableViewCell" bundle:nil] forCellReuseIdentifier:locationCellIdentifier];
    [self registerNib:[UINib nibWithNibName:@"RecommendsTableViewCell" bundle:nil] forCellReuseIdentifier:recommendCellIdentifier];
    [self registerNib:[UINib nibWithNibName:@"CommentTableViewCell" bundle:nil] forCellReuseIdentifier:commentCellIdentifier];
    
    
}

- (void)loadScrollViewWithPage:(NSUInteger)page {
    if (page >= _shoppingPoi.images.count) {
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
        TaoziImage *taoziImage = [_shoppingPoi.images objectAtIndex:page];
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
        return _shoppingPoi.comments.count;
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
        return 40.0;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        CGSize size = [_shoppingPoi.address sizeWithAttributes:@{NSFontAttributeName :[UIFont systemFontOfSize:15.0]}];
        NSInteger lineCount = (size.width / (self.frame.size.width-60)) + 1;
        CGFloat addressHeight = lineCount*size.height+10;
        return addressHeight+60;
    }
    if (indexPath.section == 1) {
        return 130;
    }
    if (indexPath.section == 2) {
        NSString *commentDetail = ((CommentDetail *)[_shoppingPoi.comments objectAtIndex:indexPath.row]).commentDetails;
        CGSize size = [commentDetail sizeWithAttributes:@{NSFontAttributeName :[UIFont systemFontOfSize:15.0]}];
        NSInteger lineCount = (size.width / (self.frame.size.width-16)) + 1;
        CGFloat commentHeight = lineCount*size.height+10;
        return commentHeight+90;
    }
    return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return nil;
    }
    UIView *sectionView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 40)];
    sectionView.backgroundColor = UIColorFromRGB(0xf5f5f5);
    UIButton *sectionBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 9, self.frame.size.width, 30)];
    [sectionBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    sectionBtn.titleLabel.font = [UIFont boldSystemFontOfSize:17];
    sectionBtn.backgroundColor = [UIColor whiteColor];
    sectionBtn.layer.cornerRadius = 1.0;
    [sectionBtn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    if (section == 1) {
        [sectionBtn setTitle:@"网友推荐" forState:UIControlStateNormal];
    }
    if (section == 2) {
        [sectionBtn setTitle:@"网友点评" forState:UIControlStateNormal];
    }
    [sectionView addSubview:sectionBtn];
    
    return sectionView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        LocationTableViewCell *locationCell = [tableView dequeueReusableCellWithIdentifier:locationCellIdentifier];
        locationCell.address = _shoppingPoi.address;
        return locationCell;
    }
    if (indexPath.section == 1) {
        RecommendsTableViewCell *recommendsCell = [tableView dequeueReusableCellWithIdentifier:recommendCellIdentifier];
        recommendsCell.recommends = _shoppingPoi.recommends;
        return recommendsCell;
        
    } if (indexPath.section == 2) {
        CommentTableViewCell *commentCell = [tableView dequeueReusableCellWithIdentifier:commentCellIdentifier];
        commentCell.commentDetail = [_shoppingPoi.comments objectAtIndex:indexPath.row];
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

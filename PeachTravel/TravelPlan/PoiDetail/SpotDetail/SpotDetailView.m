//
//  SpotDetailView.m
//  PeachTravel
//
//  Created by liangpengshuai on 11/17/14.
//  Copyright (c) 2014 com.aizou.www. All rights reserved.
//

#import "SpotDetailView.h"
#import "ResizableView.h"
#import "EDStarRating.h"
#import "MJPhoto.h"
#import "MJPhotoBrowser.h"
#import "CommentDetail.h"
#import "SuperWebViewController.h"
#import "SwipeView.h"

@interface SpotDetailView ()<SwipeViewDataSource, SwipeViewDelegate>


@property (nonatomic, strong) UIView *headerView;
@property (nonatomic, strong) UIView *detailView;

@property (nonatomic, strong) UIView *scrollView;
@property (nonatomic, strong) EDStarRating *ratingView;
@property (nonatomic, strong) UIButton *travelMonthBtn;
@property (nonatomic, strong) UIButton *openTimeBtn;
@property (nonatomic, strong) UIButton *timeCostBtn;
//@property (nonatomic, strong) UIButton *phoneButton;
@property (nonatomic, strong) UIButton *readAllBtn;
@property (nonatomic, strong) UIPageControl *pageControl;

@end

@implementation SpotDetailView


- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = APP_PAGE_COLOR;
        _scrollView = [[UIScrollView alloc] init];
        _scrollView.frame = self.bounds;
//        _scrollView.showsHorizontalScrollIndicator = NO;
//        _scrollView.showsVerticalScrollIndicator = NO;
        [self addSubview:_scrollView];

    }
    return self;
}

- (void)setSpot:(SpotPoi *)spot
{
    _spot = spot;
    [self setupSubView];

}

- (void)setupSubView{
    CGFloat offsetY = 0;
    
    SwipeView *swipeView = [[SwipeView alloc] initWithFrame:CGRectMake(0, offsetY, CGRectGetWidth(self.bounds), 350)];
    swipeView.dataSource = self;
    swipeView.delegate = self;
    swipeView.bounces = NO;
    swipeView.backgroundColor = APP_BORDER_COLOR;
    swipeView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleWidth;
    swipeView.pagingEnabled = YES;
    swipeView.itemsPerPage = 1;
    [_scrollView addSubview:swipeView];
    
    _pageControl = [[UIPageControl alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.bounds), 20)];
    _pageControl.center = CGPointMake(CGRectGetWidth(self.bounds)/2, 350-20);
    _pageControl.numberOfPages = _spot.images.count;
    _pageControl.currentPageIndicatorTintColor = APP_THEME_COLOR;
    _pageControl.pageIndicatorTintColor = [UIColor whiteColor];
    _pageControl.hidesForSinglePage = YES;
    [_scrollView addSubview:_pageControl];
    
    offsetY += swipeView.frame.size.height;
    
    UIButton *tagBtn = [[UIButton alloc] initWithFrame:CGRectMake(self.bounds.size.width-132, offsetY + 10, 116, 40)];
    [tagBtn setTitle:@"高等学府" forState:UIControlStateNormal];
    [tagBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    tagBtn.userInteractionEnabled = NO;
    [_scrollView addSubview:tagBtn];
    
    _ratingView = [[EDStarRating alloc] initWithFrame:CGRectMake(20, offsetY+18, 105, 15)];
    _ratingView.starImage = [UIImage imageNamed:@"star_biankuang"];
    _ratingView.starHighlightedImage = [UIImage imageNamed:@"star_couler"];
    _ratingView.maxRating = 5.0;
    _ratingView.editable = NO;
    _ratingView.horizontalMargin = 3;
    _ratingView.displayMode = EDStarRatingDisplayAccurate;
    _ratingView.rating = _spot.rating;
    [_scrollView addSubview:_ratingView];
    
    offsetY += 60;
   
    _descDetailBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, offsetY, _scrollView.bounds.size.width, 114)];
    _descDetailBtn.backgroundColor = [UIColor whiteColor];
    [_descDetailBtn setTitleColor:TEXT_COLOR_TITLE forState:UIControlStateNormal];
    [_descDetailBtn setTitleColor:TEXT_COLOR_TITLE_DESC forState:UIControlStateHighlighted];
    _descDetailBtn.titleLabel.font = [UIFont systemFontOfSize:12];
    _descDetailBtn.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    [_descDetailBtn setTitle:_spot.desc forState:UIControlStateNormal];
    _descDetailBtn.titleLabel.numberOfLines = 3;
    [_descDetailBtn setContentEdgeInsets:UIEdgeInsetsMake(0, 14, 0, 14)];
    _descDetailBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [_scrollView addSubview:_descDetailBtn];
    
    _readAllBtn = [[UIButton alloc]initWithFrame:CGRectMake(SCREEN_WIDTH - 269/3 * SCREEN_WIDTH/414, _descDetailBtn.bounds.size.height- 126/3, 269/3 * SCREEN_WIDTH/414, 19 * SCREEN_WIDTH / 414)];
    [_readAllBtn setTitle:@"全文" forState:UIControlStateNormal];
    [_readAllBtn setTitleColor:APP_THEME_COLOR forState:UIControlStateNormal];
    _readAllBtn.titleLabel.font = [UIFont systemFontOfSize:18 * 736/SCREEN_HEIGHT];
    [_descDetailBtn addSubview:_readAllBtn];
    
    offsetY += 114;
        
    UIView *spaceView5 = [[UIView alloc] initWithFrame:CGRectMake(20, offsetY, _scrollView.bounds.size.width, 1)];
    spaceView5.backgroundColor = APP_DIVIDER_COLOR;
    [_scrollView addSubview:spaceView5];
    
    offsetY += 10;
    
//    _addressBtn = [[TZButton alloc] initWithFrame:CGRectMake(0, offsetY, _scrollView.bounds.size.width, 66)];
//    _addressBtn.titleLabel.font = [UIFont systemFontOfSize:14.0];
//    [_addressBtn setTitleColor:TEXT_COLOR_TITLE forState:UIControlStateNormal];
//    [_addressBtn setTitleColor:TEXT_COLOR_TITLE_DESC forState:UIControlStateHighlighted];
//    _addressBtn.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
//    _addressBtn.titleLabel.numberOfLines = 2;
//    _addressBtn.layer.cornerRadius = 4.0;
//    _addressBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
//    //    [_addressBtn setContentEdgeInsets:UIEdgeInsetsMake(2, 10, 0, 10)];
//    //    _addressBtn.layer.borderColor = APP_DIVIDER_COLOR.CGColor;
//    //    _addressBtn.layer.borderWidth = 0.5;
//    _addressBtn.autoresizingMask = UIViewAutoresizingFlexibleWidth;
//    
//    if ([_spot.address isBlankString] || !_spot.address) {
//        [_addressBtn setTitle:_spot.zhName forState:UIControlStateNormal];
//    } else {
//        [_addressBtn setTitle:_spot.address forState:UIControlStateNormal];
//    }
//    [_scrollView addSubview:_addressBtn];
//    UIImageView *addressImageView = [[UIImageView alloc] initWithFrame:CGRectMake(15, 23, 18, 18)];
//    addressImageView.image = [UIImage imageNamed:@"map"];
//    [_addressBtn addSubview:addressImageView];
    
    
    /*
    UILabel *address = [[UILabel   alloc]initWithFrame:CGRectMake(50, 0, 100, _travelBtn.bounds.size.height)];
    address.font = [UIFont systemFontOfSize:14];
    address.textColor = TEXT_COLOR_TITLE;
    address.text = @"地图";
    [_addressBtn addSubview:address];
    
    _bookBtn = [[UIButton alloc] initWithFrame:CGRectMake(_scrollView.bounds.size.width-100, offsetY+20, 80, 30)];
    [_bookBtn setBackgroundImage:[ConvertMethods createImageWithColor:APP_THEME_COLOR] forState:UIControlStateNormal];
    [_bookBtn setBackgroundImage:[ConvertMethods createImageWithColor:UIColorFromRGB(0xeeeeee)] forState:UIControlStateDisabled];
    _bookBtn.clipsToBounds = YES;
    _bookBtn.layer.cornerRadius = 5;
    [_bookBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_bookBtn setTitleColor:UIColorFromRGB(0xd5d5d5) forState:UIControlStateDisabled];
    _bookBtn.titleEdgeInsets = UIEdgeInsetsMake(2, 0, 0, 0);
    [_bookBtn setTitle:@"预订" forState:UIControlStateNormal];
    _bookBtn.titleLabel.font = [UIFont systemFontOfSize:14.0];
//    [_scrollView addSubview:_bookBtn];
    if ([_spot.bookUrl isBlankString] || !_spot.bookUrl) {
        _bookBtn.enabled = NO;
    }
    CGFloat width = _scrollView.bounds.size.width;
    UIView *spaceView = [[UIView alloc] initWithFrame:CGRectMake(10, offsetY, width-20, 1)];
    spaceView.backgroundColor = APP_DIVIDER_COLOR;
    [_scrollView addSubview:spaceView];
    offsetY += 15;
    
    
    UILabel *destTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, offsetY, width, 25)];
    destTitle.text = @"实用信息";
    destTitle.font = [UIFont systemFontOfSize:20];
    destTitle.textColor = TEXT_COLOR_TITLE;
    destTitle.textAlignment = NSTextAlignmentCenter;
    [_scrollView addSubview:destTitle];
    offsetY += 37;
    

    if ([_spot.priceDesc isBlankString]||_spot.priceDesc == nil) {
    }
    else{
    _ticketBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, offsetY, width-5, 20)];
    [_ticketBtn setTitleColor:TEXT_COLOR_TITLE forState:UIControlStateNormal];
    [_ticketBtn setTitleColor:TEXT_COLOR_TITLE_DESC forState:UIControlStateHighlighted];
    _ticketBtn.titleLabel.font = [UIFont systemFontOfSize:13];
    [_ticketBtn setTitleColor:TEXT_COLOR_TITLE forState:UIControlStateNormal];
    _ticketBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    _ticketBtn.contentEdgeInsets = UIEdgeInsetsMake(0, width/2.5, 0, 0);
    [_ticketBtn setTitle:_spot.priceDesc forState:UIControlStateNormal];
    [_scrollView addSubview:_ticketBtn];
    UILabel *priceLabel = [[UILabel alloc]initWithFrame:CGRectMake(50, 0, 100, _ticketBtn.bounds.size.height)];
    priceLabel.text = @"门票";
    priceLabel.font = [UIFont systemFontOfSize:14];
    priceLabel.textColor = TEXT_COLOR_TITLE;
    [_ticketBtn addSubview:priceLabel];
    UIImageView *ticketImageView = [[UIImageView alloc] initWithFrame:CGRectMake(15, 3, 18, 18)];
    ticketImageView.image = [UIImage imageNamed:@"ticket"];
    [_ticketBtn addSubview:ticketImageView];
    offsetY += 25;
    
    UIView *spaceView2 = [[UIView alloc] initWithFrame:CGRectMake(20, offsetY, width, 1)];
    spaceView2.backgroundColor = APP_DIVIDER_COLOR;
    [_scrollView addSubview:spaceView2];
    }
    
    
    NSMutableString *content = [[NSMutableString alloc] init];
    if (_spot.timeCostStr && ![_spot.timeCostStr isBlankString]) {
        [content appendString:[NSString stringWithFormat:@"%@\n", _spot.timeCostStr]];
    }
    [content appendString:[NSString stringWithFormat:@"%@", _spot.openTime]];
    _travelBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, offsetY - 5, width-5, 65)];
    [_travelBtn setTitleColor:TEXT_COLOR_TITLE forState:UIControlStateNormal];
    [_travelBtn setTitleColor:TEXT_COLOR_TITLE_DESC forState:UIControlStateHighlighted];
    _travelBtn.titleLabel.font = [UIFont systemFontOfSize:13];
//    _travelBtn.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
//    [_travelBtn setTitleColor:TEXT_COLOR_TITLE_DESC forState:UIControlStateNormal];
    
    _travelBtn.titleLabel.numberOfLines = 2;
    [_travelBtn setTitle:_spot.desc forState:UIControlStateNormal];
    [_travelBtn setContentEdgeInsets:UIEdgeInsetsMake(0, width/2.5, 0, 0)];
    [_travelBtn setTitle:content forState:UIControlStateNormal];
    _travelBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [_scrollView addSubview:_travelBtn];
    if ([_spot.timeCostStr isBlankString]||!_spot.timeCostStr) {
        
    }else{
    NSMutableString *content1 = [[NSMutableString alloc] init];
//    if (_spot.timeCostStr && ![_spot.timeCostStr isBlankString]) {
        [content1 appendString:[NSString stringWithFormat:@"建议游玩:\n"]];
//    }
    [content1 appendString:[NSString stringWithFormat:@"开放时间:"]];

    UILabel *travelLabel = [[UILabel alloc]initWithFrame:CGRectMake(50, 0, 100, _travelBtn.bounds.size.height)];
    travelLabel.numberOfLines = 2;
    travelLabel.font = [UIFont systemFontOfSize:14];
    travelLabel.textColor = TEXT_COLOR_TITLE;
    travelLabel.text = content1;
    [_travelBtn addSubview:travelLabel];
    UIImageView *travelImageView = [[UIImageView alloc] initWithFrame:CGRectMake(15, 23, 18, 18)];
    travelImageView.image = [UIImage imageNamed:@"travel suggest"];
    [_travelBtn addSubview:travelImageView];
    
    
    
    offsetY += 55;
    UIView *spaceView3 = [[UIView alloc] initWithFrame:CGRectMake(20, offsetY, width, 1)];
    spaceView3.backgroundColor = APP_DIVIDER_COLOR;
    [_scrollView addSubview:spaceView3];
    }
    
    if ([_spot.telephone isBlankString]||_spot.telephone == nil) {
        
    }
    else{
        _phoneButton = [[UIButton alloc]initWithFrame:CGRectMake(0, offsetY, width, 65)];
        [_phoneButton setTitle:_spot.telephone forState:UIControlStateNormal];
        [_phoneButton setTitleColor:TEXT_COLOR_TITLE forState:UIControlStateNormal];
        _phoneButton.titleLabel.font = [UIFont systemFontOfSize:14];
        [_phoneButton setContentEdgeInsets:UIEdgeInsetsMake(0, width/2.5, 0, 0)];
        _phoneButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        
        [_scrollView addSubview:_phoneButton];
        UILabel *phoneLabel = [[UILabel   alloc]initWithFrame:CGRectMake(50, 0, 100, _travelBtn.bounds.size.height)];
        phoneLabel.font = [UIFont systemFontOfSize:14];
        phoneLabel.textColor = TEXT_COLOR_TITLE;
        phoneLabel.text = @"电话";
        [_phoneButton addSubview:phoneLabel];
        UIImageView *phoneImageView = [[UIImageView alloc] initWithFrame:CGRectMake(15, 23, 18, 18)];
        phoneImageView.image = [UIImage imageNamed:@"phone"];
        [_phoneButton addSubview:phoneImageView];

        
        offsetY += 44;
        UIView *spaceView1 = [[UIView alloc] initWithFrame:CGRectMake(20, offsetY, width, 1)];
        spaceView1.backgroundColor = APP_DIVIDER_COLOR;
        [_scrollView addSubview:spaceView1];
    }
    
    
    offsetY += 44;

    
    UIView *spaceView4 = [[UIView alloc] initWithFrame:CGRectMake(20, offsetY, width, 1)];
    spaceView4.backgroundColor = APP_DIVIDER_COLOR;
    [_scrollView addSubview:spaceView4];
    
    
    UIView *btnBackView = [[UIView alloc] initWithFrame:CGRectMake(0, offsetY, _scrollView.bounds.size.width, 75)];
    btnBackView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [_scrollView addSubview:btnBackView];
    
    CGFloat spaceWidth = (btnBackView.bounds.size.width-48*3-70)/3;
    
    _kendieBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 48, 48)];
    [_kendieBtn setBackgroundImage:[UIImage imageNamed:@"ic_little notes"] forState:UIControlStateNormal];
    [_kendieBtn setBackgroundImage:[UIImage imageNamed:@"ic_little_normal"] forState:UIControlStateDisabled];
//    [_kendieBtn setTitle:@"小贴士" forState:UIControlStateNormal];
    _kendieBtn.titleLabel.font = [UIFont boldSystemFontOfSize:13];
    _kendieBtn.titleLabel.numberOfLines = 2;
    [_kendieBtn.titleLabel setTextAlignment: NSTextAlignmentCenter];
//    _kendieBtn.backgroundColor = [UIColor blackColor];
    _kendieBtn.center = CGPointMake(CGRectGetWidth(btnBackView.frame)/2, 32);
    [_kendieBtn setTitleColor:APP_THEME_COLOR forState:UIControlStateNormal];
    [_kendieBtn setTitleColor:APP_THEME_COLOR_HIGHLIGHT forState:UIControlStateHighlighted];
    [_kendieBtn setTitleColor:UIColorFromRGB(0xdddddd) forState:UIControlStateDisabled];
    [btnBackView addSubview:_kendieBtn];
    
    _travelGuideBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 48, 48)];
    [_travelGuideBtn setBackgroundImage:[UIImage imageNamed:@"ic_spots experience"] forState:UIControlStateNormal];
    [_travelGuideBtn setBackgroundImage:[UIImage imageNamed:@"ic_spots_normal"] forState:UIControlStateDisabled];
    _travelGuideBtn.titleLabel.font = [UIFont boldSystemFontOfSize:13];
    _travelGuideBtn.titleLabel.numberOfLines = 2;
    [_travelGuideBtn setTitleColor:APP_THEME_COLOR forState:UIControlStateNormal];
    [_travelGuideBtn setTitleColor:APP_THEME_COLOR_HIGHLIGHT forState:UIControlStateHighlighted];
    [_travelGuideBtn setTitleColor:UIColorFromRGB(0xdddddd) forState:UIControlStateDisabled];

    _travelGuideBtn.center = CGPointMake(_kendieBtn.center.x - spaceWidth - 48, 32);
    [btnBackView addSubview:_travelGuideBtn];
    
    _trafficGuideBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 48, 48)];
    [_trafficGuideBtn setBackgroundImage:[UIImage imageNamed:@"ic_travel"] forState:UIControlStateNormal];
    [_trafficGuideBtn setBackgroundImage:[UIImage imageNamed:@"ic_travel_normal"] forState:UIControlStateDisabled];
//    [_trafficGuideBtn setTitle:@"交通" forState:UIControlStateNormal];
    _trafficGuideBtn.titleLabel.font = [UIFont boldSystemFontOfSize:13];
    _trafficGuideBtn.titleLabel.numberOfLines = 2;
    [_trafficGuideBtn setTitleColor:APP_THEME_COLOR forState:UIControlStateNormal];
    [_trafficGuideBtn setTitleColor:APP_THEME_COLOR_HIGHLIGHT forState:UIControlStateHighlighted];
    [_trafficGuideBtn setTitleColor:UIColorFromRGB(0xdddddd) forState:UIControlStateDisabled];
    _trafficGuideBtn.center = CGPointMake(_kendieBtn.center.x + spaceWidth + 48, 32);
    [btnBackView addSubview:_trafficGuideBtn];
    offsetY += 50;
    
    UILabel *guideLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 68, 15)];
    guideLabel.center = CGPointMake(_kendieBtn.center.x - spaceWidth - 48, offsetY+25);
    if (_trafficGuideBtn.enabled ) {
        guideLabel.textColor = TEXT_COLOR_TITLE;
    }
    else{
        guideLabel.textColor = UIColorFromRGB(0xdddddd);
    }
    guideLabel.text = @"景点攻略";
    guideLabel.textAlignment = NSTextAlignmentCenter;
    guideLabel.font = [UIFont systemFontOfSize:13];
    [_scrollView addSubview:guideLabel];
    
    UILabel *tipsLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 48, 15)];
    tipsLabel.center = CGPointMake(CGRectGetWidth(btnBackView.frame)/2, offsetY + 25);
    tipsLabel.textColor = _kendieBtn.enabled?TEXT_COLOR_TITLE:UIColorFromRGB(0xdddddd);
    tipsLabel.text = @"小贴士";
    tipsLabel.textAlignment = NSTextAlignmentCenter;
    tipsLabel.font = [UIFont systemFontOfSize:13];
    [_scrollView addSubview:tipsLabel];
    
    UILabel *trafficLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 48, 15)];
    trafficLabel.center = CGPointMake(_kendieBtn.center.x + spaceWidth + 48, offsetY + 25);
    trafficLabel.textColor = _trafficGuideBtn.enabled?TEXT_COLOR_TITLE:UIColorFromRGB(0xdddddd);
    trafficLabel.text = @"交通";
    trafficLabel.textAlignment = NSTextAlignmentCenter;
    trafficLabel.font = [UIFont systemFontOfSize:13];
    [_scrollView addSubview:trafficLabel];
    
    
    offsetY +=50;
    UIView *spaceView6 = [[UIView alloc] initWithFrame:CGRectMake(20, offsetY, width, 1)];
    spaceView6.backgroundColor = APP_DIVIDER_COLOR;
    [_scrollView addSubview:spaceView6];
    
    

    
    UILabel *commentTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 70, 14)];
    commentTitle.text = @"网友点评";
    commentTitle.textAlignment = NSTextAlignmentCenter;
    commentTitle.font = [UIFont systemFontOfSize:16.0];
    commentTitle.textColor = TEXT_COLOR_TITLE;
    commentTitle.center = CGPointMake(_scrollView.bounds.size.width/2, offsetY+20);

    [_scrollView addSubview:commentTitle];
    
    if (_spot.comments.count != 0){
    UIButton *moreCommentBtn = [[UIButton alloc] initWithFrame:CGRectMake(_scrollView.bounds.size.width-80, offsetY, 80, 40)];
    [moreCommentBtn setTitle:@"更多点评>>" forState:UIControlStateNormal];
    [moreCommentBtn addTarget:self action:@selector(showMoreComments:) forControlEvents:UIControlEventTouchUpInside];
    [moreCommentBtn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    [moreCommentBtn setTitleColor:APP_SUB_THEME_COLOR forState:UIControlStateNormal];
    [moreCommentBtn setTitleColor:APP_SUB_THEME_COLOR_HIGHLIGHT forState:UIControlStateHighlighted];
    moreCommentBtn.titleLabel.font = [UIFont systemFontOfSize:12];
    [_scrollView addSubview:moreCommentBtn];
    }
    offsetY += 40;
        if (_spot.comments.count >= 1) {
        
        UIImageView *dotImageViewLeft = [[UIImageView alloc] initWithFrame:CGRectMake(10, offsetY-10, 20, 17)];
        dotImageViewLeft.image = [UIImage imageNamed:@"ic_quotation_l.png"];
        dotImageViewLeft.contentMode = UIViewContentModeScaleAspectFit;
        [_scrollView addSubview:dotImageViewLeft];
        
        CommentDetail *comment = [_spot.comments objectAtIndex:0];
        UILabel *commentLabel = [[UILabel alloc] initWithFrame:CGRectMake(40, offsetY, _scrollView.bounds.size.width-80, 40)];
        commentLabel.numberOfLines = 3.0;
        commentLabel.textColor = TEXT_COLOR_TITLE_SUBTITLE;
        commentLabel.font = [UIFont systemFontOfSize:12];
        commentLabel.text = comment.commentDetails;
        [_scrollView addSubview:commentLabel];
        offsetY += 40;
        UILabel *commentSubLabel = [[UILabel alloc] initWithFrame:CGRectMake(40, offsetY, _scrollView.bounds.size.width-80, 15)];
        commentSubLabel.textColor = TEXT_COLOR_TITLE_PH;
        commentSubLabel.font = [UIFont systemFontOfSize:10];
        commentSubLabel.textAlignment = NSTextAlignmentRight;
        NSString *s = [NSString stringWithFormat:@"%@  %@", comment.nickName, comment.commentTime];
        commentSubLabel.text = s;
        [_scrollView addSubview:commentSubLabel];
        offsetY += 15;
    }

    offsetY += 10;
    if (_spot.comments.count >= 2) {
        CommentDetail *comment = [_spot.comments objectAtIndex:1];
        UILabel *commentLabel = [[UILabel alloc] initWithFrame:CGRectMake(40, offsetY, _scrollView.bounds.size.width-80, 40)];
        commentLabel.numberOfLines = 3.0;
        commentLabel.textColor = TEXT_COLOR_TITLE_SUBTITLE;
        commentLabel.font = [UIFont systemFontOfSize:12];
        commentLabel.text = comment.commentDetails;
        [_scrollView addSubview:commentLabel];
        offsetY += 40;
        UILabel *commentSubLabel = [[UILabel alloc] initWithFrame:CGRectMake(40, offsetY, _scrollView.bounds.size.width-80, 15)];
        commentSubLabel.textColor = TEXT_COLOR_TITLE_PH;
        commentSubLabel.font = [UIFont systemFontOfSize:10];
        commentSubLabel.textAlignment = NSTextAlignmentRight;
        NSString *s = [NSString stringWithFormat:@"%@  %@", comment.nickName, comment.commentTime];
        commentSubLabel.text = s;
        [_scrollView addSubview:commentSubLabel];
        offsetY += 15;
    }
    
    if (_spot.comments.count > 0) {
        offsetY += 10;
        UIImageView *dotImageViewRight = [[UIImageView alloc] initWithFrame:CGRectMake(_scrollView.bounds.size.width-30, offsetY-20, 20, 17)];
        dotImageViewRight.image = [UIImage imageNamed:@"ic_quotation_r.png"];
        dotImageViewRight.contentMode = UIViewContentModeScaleAspectFit;
        [_scrollView addSubview:dotImageViewRight];
    }
    
    
    
    offsetY += 50;
*/
    
    _scrollView.frame = CGRectMake(0, 0, SCREEN_WIDTH, offsetY + 75);
//    [_scrollView setContentSize:CGSizeMake(_scrollView.bounds.size.width, offsetY+75)];
    
}

- (void)showMoreComments:(id)sender
{
    SuperWebViewController *webCtl = [[SuperWebViewController alloc] init];
    webCtl.titleStr = @"全部点评";
    webCtl.urlStr = _spot.moreCommentsUrl;
    webCtl.hideToolBar = YES;
    [_rootCtl.navigationController pushViewController:webCtl animated:YES];
}

#pragma mark - vc
#pragma mark - SwipeViewDataSource

- (NSInteger)numberOfItemsInSwipeView:(SwipeView *)swipeView {
    return _spot.images.count;
}

- (UIView *)swipeView:(SwipeView *)swipeView viewForItemAtIndex:(NSInteger)index reusingView:(UIView *)view {
    UIImageView *imageView = (UIImageView *)view;
    if (imageView == nil)
    {
        imageView = [[UIImageView alloc] initWithFrame:swipeView.bounds];
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.clipsToBounds = YES;
        imageView.backgroundColor = APP_BORDER_COLOR;
    }
    
    TaoziImage *image = [_spot.images objectAtIndex:index];
    [imageView sd_setImageWithURL:[NSURL URLWithString:image.imageUrl]];
    [_pageControl setCurrentPage:index];
    return imageView;
}

- (void)swipeView:(SwipeView *)swipeView didSelectItemAtIndex:(NSInteger)index
{
    NSInteger count = _spot.images.count;
    // 1.封装图片数据
    NSMutableArray *photos = [NSMutableArray arrayWithCapacity:count];
    for (NSInteger i = 0; i<count; i++) {
        // 替换为中等尺寸图片
        TaoziImage *image = [_spot.images objectAtIndex:i];
        MJPhoto *photo = [[MJPhoto alloc] init];
        photo.url = image.imageUrl; // 图片路径
        photo.srcImageView = (UIImageView *)[swipeView itemViewAtIndex:index]; // 来源于哪个UIImageView
        [photos addObject:photo];
    }
    
    // 2.显示相册
    MJPhotoBrowser *browser = [[MJPhotoBrowser alloc] init];
    browser.currentPhotoIndex = index; // 弹出相册时显示的第一张图片是？
    browser.photos = photos; // 设置所有的图片
    [browser show];
}

@end

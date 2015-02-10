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
#import "CommonPoiDetailViewController.h"
#import "CommonPoiDetailViewController.h"
#import "SuperWebViewController.h"
#import "RecommendDetail.h"

@interface CommonPoiDetailView () <UIScrollViewDelegate, UIActionSheetDelegate>

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) NSMutableArray *imageViews;
@property (nonatomic, strong) ResizableView *descView;
@property (nonatomic, strong) ResizableView *commentDescView;
@property (nonatomic, strong) UIButton *commentBtn;
@property (nonatomic, strong) UIButton *showMoreRecommendContentBtn;
@property (nonatomic, strong) UIButton *showMoreDescContentBtn;
@property (nonatomic, strong) EDStarRating *ratingView;
@property (nonatomic, strong) UILabel *priceLabel;
@property (nonatomic, strong) UIButton *favoriteBtn;
@property (nonatomic, strong) UIButton *telephoneBtn;
@property (nonatomic, strong) UIButton *bookBtn;

@end

@implementation CommonPoiDetailView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = APP_PAGE_COLOR;
        _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 5, CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds) - 10)];
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.contentSize = CGSizeMake(_scrollView.bounds.size.width, _scrollView.bounds.size.height+1);
        [self addSubview:_scrollView];
        
        _closeBtn = [[UIButton alloc] initWithFrame:CGRectMake(self.bounds.size.width-40, 0, 40, 40)];
        [_closeBtn setImage:[UIImage imageNamed:@"ic_dialog_window_close.png"] forState:UIControlStateNormal];
        [_closeBtn setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 10, 0)];
        [self addSubview:_closeBtn];
        
        _imageView = [[UIImageView alloc] init];
        [_scrollView addSubview:_imageView];
        
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
    CGFloat offsetY = 20;
    
    _imageView.frame = CGRectMake(0, offsetY, _scrollView.bounds.size.width, 140);
    _imageView.layer.borderColor = APP_BORDER_COLOR.CGColor;
    _imageView.layer.cornerRadius = 2.0;
    _imageView.layer.borderWidth = 0.5;
    _imageView.backgroundColor = APP_IMAGEVIEW_COLOR;
    _imageView.userInteractionEnabled = YES;
    [_scrollView addSubview:_imageView];
    TaoziImage *image = [_poi.images firstObject];
    [_imageView sd_setImageWithURL:[NSURL URLWithString:image.imageUrl]];
    
    UIView *imageMaskView = [[UIView alloc] initWithFrame:_imageView.bounds];
    imageMaskView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.4];
    [_imageView addSubview:imageMaskView];
    
    _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 15, _imageView.bounds.size.width-20, 20)];
    _titleLabel.textColor = [UIColor whiteColor];
    _titleLabel.text = _poi.zhName;
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    _titleLabel.font = [UIFont boldSystemFontOfSize:25.];
    [_imageView addSubview:_titleLabel];
    
    UIButton *viewImageBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 60, 60)];
    viewImageBtn.center = CGPointMake(_imageView.bounds.size.width/2, 80);
    [viewImageBtn setImage:[UIImage imageNamed:@"viewSpotImage.png"] forState:UIControlStateNormal];
    [viewImageBtn addTarget:self action:@selector(viewImage:) forControlEvents:UIControlEventTouchUpInside];
//    [_imageView addSubview:viewImageBtn];
    
    _favoriteBtn = [[UIButton alloc] initWithFrame:CGRectMake(_imageView.bounds.size.width-70, _imageView.bounds.size.height-35, 30, 30)];
    [_favoriteBtn setImage:[UIImage imageNamed:@"ic_spot_favorite.png"] forState:UIControlStateNormal];
    [_favoriteBtn addTarget:self action:@selector(favorite:) forControlEvents:UIControlEventTouchUpInside];
    [_imageView addSubview:_favoriteBtn];
    
    _shareBtn = [[UIButton alloc] initWithFrame:CGRectMake(_imageView.bounds.size.width-40, _imageView.bounds.size.height-35, 30, 30)];
    [_shareBtn setImage:[UIImage imageNamed:@"ic_spot_share.png"] forState:UIControlStateNormal];
    [_imageView addSubview:_shareBtn];
    
    offsetY += _imageView.bounds.size.height + 40;
    
    UIView *spaceView = [[UIView alloc] initWithFrame:CGRectMake(130, offsetY, 1, 100)];
    spaceView.backgroundColor = APP_DIVIDE_COLOR;
    [_scrollView addSubview:spaceView];

    _ratingView = [[EDStarRating alloc] initWithFrame:CGRectMake(20, offsetY, 90, 15)];
    _ratingView.starImage = [UIImage imageNamed:@"ic_star_gray.png"];
    _ratingView.starHighlightedImage = [UIImage imageNamed:@"ic_star_yellow.png"];
    _ratingView.maxRating = 5.0;
    _ratingView.editable = NO;
    _ratingView.horizontalMargin = 3;
    _ratingView.displayMode = EDStarRatingDisplayAccurate;
    _ratingView.rating = _poi.rating;
    [_scrollView addSubview:_ratingView];

    UILabel *rankLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, offsetY, 90, 15)];
    rankLabel.textAlignment = NSTextAlignmentCenter;
    rankLabel.textColor = TEXT_COLOR_TITLE_SUBTITLE;
    if (_poi.rank) {
        rankLabel.text = [NSString stringWithFormat:@"同城排名:%d",_poi.rank];
    }
    [_scrollView addSubview:rankLabel];
    
    _priceLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, offsetY+50, 90, 25)];
    _priceLabel.textColor = APP_THEME_COLOR;
    _priceLabel.font = [UIFont boldSystemFontOfSize:20.0];
    _priceLabel.text = _poi.priceDesc;
    _priceLabel.textAlignment = NSTextAlignmentCenter;
    [_scrollView addSubview:_priceLabel];
    
    if (_poiType == kHotelPoi) {
        _bookBtn = [[UIButton alloc] initWithFrame:CGRectMake(25, offsetY+75, 70, 15)];
        _bookBtn.backgroundColor = APP_THEME_COLOR;
        _bookBtn.layer.cornerRadius = 7.5;
        [_bookBtn setTitle:@"在线预订" forState:UIControlStateNormal];
        _bookBtn.titleLabel.font = [UIFont fontWithName:@"MicrosoftYahei" size:10.0];
        [_bookBtn addTarget:self action:@selector(book:) forControlEvents:UIControlEventTouchUpInside];
        [_bookBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_scrollView addSubview:_bookBtn];
    }
    
    UIButton *addressDetailLabel =  [[UIButton alloc] initWithFrame:CGRectMake(140, offsetY, _scrollView.bounds.size.width-155, 60)];
    addressDetailLabel.titleLabel.font = [UIFont fontWithName:@"MicrosoftYaHei" size:13.0];
    [addressDetailLabel setTitleColor:TEXT_COLOR_TITLE_SUBTITLE forState:UIControlStateNormal];
    addressDetailLabel.titleLabel.numberOfLines = 4;
    [addressDetailLabel setTitle:[NSString stringWithFormat:@"     %@",_poi.address] forState:UIControlStateNormal];
    [addressDetailLabel setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    [addressDetailLabel setContentVerticalAlignment:UIControlContentVerticalAlignmentTop];
    [addressDetailLabel addTarget:self action:@selector(jumpMapView:) forControlEvents:UIControlEventTouchUpInside];
    [_scrollView addSubview:addressDetailLabel];
    
    UIImageView *addressImageView = [[UIImageView alloc] initWithFrame:CGRectMake(140, offsetY-2, 11, 16)];
    addressImageView.image = [UIImage imageNamed:@"ic_map.png"];
    [_scrollView addSubview:addressImageView];
    
    UIButton *phoneDetailBtn = [[UIButton alloc] initWithFrame:CGRectMake(140, offsetY+75, _scrollView.bounds.size.width-155, 20)];
    [phoneDetailBtn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentCenter];
    [phoneDetailBtn addTarget:self action:@selector(makePhone:) forControlEvents:UIControlEventTouchUpInside];
    [phoneDetailBtn setTitle:_poi.telephone forState:UIControlStateNormal];
    phoneDetailBtn.titleLabel.font = [UIFont fontWithName:@"MicrosoftYaHei" size:15.0];
    [phoneDetailBtn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    [phoneDetailBtn setTitleColor:TEXT_COLOR_TITLE_SUBTITLE forState:UIControlStateNormal];
    [phoneDetailBtn setImage:[UIImage imageNamed:@"ic_tel.png"] forState:UIControlStateNormal];
    [_scrollView addSubview:phoneDetailBtn];

    offsetY += 130;
    _descView = [[ResizableView alloc] initWithFrame:CGRectMake(15, offsetY, _scrollView.bounds.size.width-30, 55) andNumberOfLine:3];
    _descView.contentFont = [UIFont fontWithName:@"MicrosoftYaHei" size:12.0];
    _descView.contentColor = TEXT_COLOR_TITLE_SUBTITLE;
    _descView.content = _poi.desc;
    [_scrollView addSubview:_descView];

    if (!([_poi.desc isBlankString] || !_poi.desc)) {
        offsetY += 70;
    }
    
    UIImageView *commentBkgImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ic_comment_line.png"]];
    commentBkgImage.center = CGPointMake(_scrollView.bounds.size.width/2, offsetY+10);
    
    UILabel *commentTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 70, 14)];
    commentTitle.text = @"网友点评";
    commentTitle.textAlignment = NSTextAlignmentCenter;
    commentTitle.font = [UIFont boldSystemFontOfSize:15];
    commentTitle.textColor = APP_THEME_COLOR;
    commentTitle.center = CGPointMake(commentBkgImage.bounds.size.width/2, commentBkgImage.bounds.size.height/2);
    [commentBkgImage addSubview:commentTitle];
    [_scrollView addSubview:commentBkgImage];
    
    offsetY += 40;
    
    if (_poi.comments.count >= 1) {
        
        UIImageView *dotImageViewLeft = [[UIImageView alloc] initWithFrame:CGRectMake(10, offsetY-10, 20, 17)];
        dotImageViewLeft.image = [UIImage imageNamed:@"ic_quotation_l.png"];
        [_scrollView addSubview:dotImageViewLeft];
        
        CommentDetail *comment = [_poi.comments objectAtIndex:0];
        UILabel *commentLabel = [[UILabel alloc] initWithFrame:CGRectMake(40, offsetY, _scrollView.bounds.size.width-80, 40)];
        commentLabel.numberOfLines = 3.0;
        commentLabel.textColor = TEXT_COLOR_TITLE_SUBTITLE;
        commentLabel.font = [UIFont fontWithName:@"MicrosoftYaHei" size:12];
        commentLabel.text = comment.commentDetails;
        [_scrollView addSubview:commentLabel];
        offsetY += 40;
        UILabel *commentSubLabel = [[UILabel alloc] initWithFrame:CGRectMake(40, offsetY, _scrollView.bounds.size.width-80, 15)];
        commentSubLabel.textColor = TEXT_COLOR_TITLE_HINT;
        commentSubLabel.font = [UIFont fontWithName:@"MicrosoftYaHei" size:11];
        commentSubLabel.textAlignment = NSTextAlignmentRight;
        NSString *s = [NSString stringWithFormat:@"%@  %@", comment.nickName, comment.commentTime];
        commentSubLabel.text = s;
        [_scrollView addSubview:commentSubLabel];
        offsetY += 15;
    }
    offsetY += 10;
    if (_poi.comments.count >= 2) {
        CommentDetail *comment = [_poi.comments objectAtIndex:1];
        UILabel *commentLabel = [[UILabel alloc] initWithFrame:CGRectMake(40, offsetY, _scrollView.bounds.size.width-80, 40)];
        commentLabel.numberOfLines = 3.0;
        commentLabel.textColor = TEXT_COLOR_TITLE_SUBTITLE;
        commentLabel.font = [UIFont fontWithName:@"MicrosoftYaHei" size:12];
        commentLabel.text = comment.commentDetails;
        [_scrollView addSubview:commentLabel];
        offsetY += 40;
        UILabel *commentSubLabel = [[UILabel alloc] initWithFrame:CGRectMake(40, offsetY, _scrollView.bounds.size.width-80, 15)];
        commentSubLabel.textColor = TEXT_COLOR_TITLE_HINT;
        commentSubLabel.font = [UIFont fontWithName:@"MicrosoftYaHei" size:11];
        commentSubLabel.textAlignment = NSTextAlignmentRight;
        NSString *s = [NSString stringWithFormat:@"%@  %@", comment.nickName, comment.commentTime];
        commentSubLabel.text = s;
        [_scrollView addSubview:commentSubLabel];
        offsetY += 15;
    }
    
    offsetY += 10;

    if (_poi.comments.count > 0) {
        UIImageView *dotImageViewRight = [[UIImageView alloc] initWithFrame:CGRectMake(_scrollView.bounds.size.width-27, offsetY-20, 20, 17)];
        dotImageViewRight.image = [UIImage imageNamed:@"ic_quotation_r.png"];
        [_scrollView addSubview:dotImageViewRight];
    }
    
    UIButton *moreCommentBtn = [[UIButton alloc] initWithFrame:CGRectMake(_scrollView.bounds.size.width-80, offsetY, 80, 40)];
    [moreCommentBtn setTitle:@"更多点评>>" forState:UIControlStateNormal];
    [moreCommentBtn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    [moreCommentBtn setTitleColor:TEXT_COLOR_TITLE forState:UIControlStateNormal];
    moreCommentBtn.titleLabel.font = [UIFont fontWithName:@"MicrosoftYaHei" size:12];
    [_scrollView addSubview:moreCommentBtn];
    
    offsetY += 50;

    _scrollView.contentSize = CGSizeMake(self.bounds.size.width, offsetY);
    
}

#pragma mark - IBAction Methods

- (void)showMoreComments:(id)sender
{
    SuperWebViewController *webCtl = [[SuperWebViewController alloc] init];
    webCtl.titleStr = @"全部点评";
    webCtl.urlStr = [NSString stringWithFormat:@"%@%@", MORE_COMMENT_HTML, _poi.poiId];
    [_rootCtl.navigationController pushViewController:webCtl animated:YES];
}

- (IBAction)viewImage:(id)sender
{
    
}

- (IBAction)jumpMapView:(id)sender
{
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"地图"
                                                       delegate:self
                                              cancelButtonTitle:nil
                                         destructiveButtonTitle:nil
                                              otherButtonTitles:nil];
    NSArray *platformArray = [ConvertMethods mapPlatformInPhone];
    for (NSDictionary *dic in platformArray) {
        [sheet addButtonWithTitle:[dic objectForKey:@"platform"]];
    }
    [sheet addButtonWithTitle:@"取消"];
    sheet.cancelButtonIndex = sheet.numberOfButtons-1;
    sheet.tag = kASMap;
    [sheet showInView:self];    
}

- (IBAction)makePhone:(id)sender
{
    NSURL *phoneUrl = [NSURL URLWithString:[NSString  stringWithFormat:@"telprompt:%@", _poi.telephone]];
    if ([[UIApplication sharedApplication] canOpenURL:phoneUrl]) {
        [[UIApplication sharedApplication] openURL:phoneUrl];
    }
}

/**
 *  在线预订
 *
 *  @param sender
 */
- (IBAction)book:(id)sender
{
    
}

- (IBAction)favorite:(id)sender
{
    //先将收藏的状态改变
    _favoriteBtn.selected = !_poi.isMyFavorite;
    _favoriteBtn.userInteractionEnabled = NO;

    for (UIView* next = [self superview]; next; next = next.superview)
    {
        UIResponder* nextResponder = [next nextResponder];
        if ([nextResponder isKindOfClass:[CommonPoiDetailViewController class]])
        {
            CommonPoiDetailViewController *rootCtl;
            rootCtl = (CommonPoiDetailViewController*)nextResponder;
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
        
        if ([nextResponder isKindOfClass:[CommonPoiDetailViewController class]])
        {
            CommonPoiDetailViewController *rootCtl;
            rootCtl = (CommonPoiDetailViewController*)nextResponder;
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

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == actionSheet.cancelButtonIndex) {
        return;
    }
    NSInteger tag = actionSheet.tag;
    if (tag == kASMap) {
        [self goMap:buttonIndex];
    } else if (tag == kASShare) {
        
    }
    
}

- (void)goMap:(NSInteger)buttonIndex {
    NSArray *platformArray = [ConvertMethods mapPlatformInPhone];
    switch (buttonIndex) {
        case 0:
            switch ([[[platformArray objectAtIndex:0] objectForKey:@"type"] intValue]) {
                case kAMap:
                    [ConvertMethods jumpGaodeMapAppWithPoiName:self.poi.zhName lat:self.poi.lat lng:self.poi.lng];
                    break;
                    
                case kBaiduMap: {
                    [ConvertMethods jumpBaiduMapAppWithPoiName:self.poi.zhName lat:self.poi.lat lng:self.poi.lng];
                }
                    break;
                    
                case kAppleMap: {
                    [ConvertMethods jumpAppleMapAppWithPoiName:self.poi.zhName lat:self.poi.lat lng:self.poi.lng];
                }
                    
                default:
                    break;
            }
            break;
            
        case 1:
            switch ([[[platformArray objectAtIndex:1] objectForKey:@"type"] intValue]) {
                case kAMap:
                    [ConvertMethods jumpGaodeMapAppWithPoiName:self.poi.zhName lat:self.poi.lat lng:self.poi.lng];
                    break;
                    
                case kBaiduMap: {
                    [ConvertMethods jumpBaiduMapAppWithPoiName:self.poi.zhName lat:self.poi.lat lng:self.poi.lng];
                }
                    break;
                    
                case kAppleMap: {
                    [ConvertMethods jumpAppleMapAppWithPoiName:self.poi.zhName lat:self.poi.lat lng:self.poi.lng];
                }
                    break;
                    
                default:
                    break;
            }
            break;
            
        case 2:
            switch ([[[platformArray objectAtIndex:2] objectForKey:@"type"] intValue]) {
                case kAMap:
                    [ConvertMethods jumpGaodeMapAppWithPoiName:self.poi.zhName lat:self.poi.lat lng:self.poi.lng];
                    break;
                    
                case kBaiduMap: {
                    [ConvertMethods jumpBaiduMapAppWithPoiName:self.poi.zhName lat:self.poi.lat lng:self.poi.lng];
                }
                    break;
                    
                case kAppleMap: {
                    [ConvertMethods jumpAppleMapAppWithPoiName:self.poi.zhName lat:self.poi.lat lng:self.poi.lng];
                }                    break;
                    
                default:
                    break;
            }
            break;
            
        default:
            break;
    }
}

@end










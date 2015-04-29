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
@property (nonatomic, strong) UIButton *priceBtn;
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
        _scrollView = [[UIScrollView alloc] init];
        //                       WithFrame:CGRectMake(0, 27, self.bounds.size.width, self.bounds.size.height-35)];
        _scrollView.frame = self.bounds;
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.showsVerticalScrollIndicator = NO;
//        _scrollView.contentSize = CGSizeMake(self.bounds.size.width, 10000);
        
        [self addSubview:_scrollView];

        
//        _closeBtn = [[UIButton alloc] initWithFrame:CGRectMake(self.bounds.size.width-64, 0, 64, 40)];
//        [_closeBtn setImage:[UIImage imageNamed:@"ic_dialog_window_close.png"] forState:UIControlStateNormal];
//        _closeBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
//        _closeBtn.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 11, 5);
//        [self addSubview:_closeBtn];
        
        _imageView = [[UIImageView alloc] init];
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        _imageView.clipsToBounds = YES;
        [self addSubview:_imageView];
        
    }
    return self;
}

- (void)setPoi:(SuperPoi *)poi
{
    _poi = poi;
    [self setupSubView];
}

- (void)setupSubView
{
    CGFloat offsetY = 0;
    CGFloat w = _scrollView.bounds.size.width;
    _imageView.frame = CGRectMake(0, offsetY, _scrollView.bounds.size.width, 140);
    _imageView.backgroundColor = APP_IMAGEVIEW_COLOR;
    _imageView.userInteractionEnabled = YES;
    [_scrollView addSubview:_imageView];
    TaoziImage *image = [_poi.images firstObject];
    [_imageView sd_setImageWithURL:[NSURL URLWithString:image.imageUrl]];
    
    UIView *imageMaskView = [[UIView alloc] initWithFrame:_imageView.bounds];
    imageMaskView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.3];
    [_imageView addSubview:imageMaskView];
    
    _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 150, _imageView.bounds.size.width-20, 20)];
    _titleLabel.textColor = TEXT_COLOR_TITLE;
    _titleLabel.text = _poi.zhName;
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    _titleLabel.font = [UIFont boldSystemFontOfSize:20.];
//    [_imageView addSubview:_titleLabel];
    [_scrollView addSubview:_titleLabel];
    
    _favoriteBtn = [[UIButton alloc] initWithFrame:CGRectMake(_imageView.bounds.size.width-75, _imageView.bounds.size.height-35, 30, 30)];
    [_favoriteBtn setImage:[UIImage imageNamed:@"ic_spot_favorite.png"] forState:UIControlStateNormal];
    [_favoriteBtn setImage:[UIImage imageNamed:@"ic_spot_favorite_selected.png"] forState:UIControlStateSelected];
    if (_poi.isMyFavorite) {
        _favoriteBtn.selected = YES;
    }
    
    [_favoriteBtn addTarget:self action:@selector(favorite:) forControlEvents:UIControlEventTouchUpInside];
    [_imageView addSubview:_favoriteBtn];
    
    _shareBtn = [[UIButton alloc] initWithFrame:CGRectMake(_imageView.bounds.size.width-40, _imageView.bounds.size.height-35, 30, 30)];
    [_shareBtn setImage:[UIImage imageNamed:@"ic_spot_share.png"] forState:UIControlStateNormal];
    [_imageView addSubview:_shareBtn];
    
    offsetY += _imageView.bounds.size.height + 45;
    
//    UIView *spaceView = [[UIView alloc] initWithFrame:CGRectMake(130, offsetY, 1, 60)];
//    spaceView.backgroundColor = APP_DIVIDER_COLOR;
//    [_scrollView addSubview:spaceView];

//    _ratingView = [[EDStarRating alloc] initWithFrame:CGRectMake(20, offsetY, 90, 15)];
    _ratingView = [[EDStarRating alloc] initWithFrame:CGRectMake(0, 0, 90, 15)];
    _ratingView.center = CGPointMake(_scrollView.bounds.size.width/2, offsetY);
    _ratingView.starImage = [UIImage imageNamed:@"ic_star_gray.png"];
    _ratingView.starHighlightedImage = [UIImage imageNamed:@"ic_star_yellow.png"];
    _ratingView.maxRating = 5.0;
    _ratingView.editable = NO;
    _ratingView.horizontalMargin = 3;
    _ratingView.displayMode = EDStarRatingDisplayAccurate;
    _ratingView.rating = _poi.rating;
    [_scrollView addSubview:_ratingView];

//    UILabel *rankLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, offsetY+30, 90, 15)];
    UILabel *rankLabel = [[UILabel alloc]init];
    rankLabel.frame = CGRectMake(0, 0, 90, 15);
    rankLabel.center = CGPointMake(self.bounds.size.width/2, offsetY+30);
    rankLabel.textAlignment = NSTextAlignmentCenter;
    rankLabel.textColor = TEXT_COLOR_TITLE_SUBTITLE;
    rankLabel.font = [UIFont systemFontOfSize:12.0];
    if (_poi.rank > 0 && _poi.rank <= 500) {
        rankLabel.text = [NSString stringWithFormat:@"%@排名第%d", _poi.poiTypeName, _poi.rank];
    } else {
        rankLabel.text = [NSString stringWithFormat:@"%@排名第>500", _poi.poiTypeName];
    }
    [_scrollView addSubview:rankLabel];

    
//    ---------------更多信息---------------
    offsetY +=60;
    UIImageView *practicalInformationBkgImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ic_comment_line.png"]];
    practicalInformationBkgImage.center = CGPointMake(_scrollView.bounds.size.width/2, offsetY+10);
    UILabel * practicalLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 70, 14)];
    practicalLabel.center = CGPointMake(practicalInformationBkgImage.bounds.size.width/2, practicalInformationBkgImage.bounds.size.height/2);
    practicalLabel.text = @"实用信息";
    practicalLabel.textColor = TEXT_COLOR_TITLE_DESC;
    practicalLabel.textAlignment = NSTextAlignmentCenter;
    practicalLabel.font = [UIFont systemFontOfSize:14];
    [practicalInformationBkgImage addSubview:practicalLabel];
    [_scrollView addSubview:practicalInformationBkgImage];
    
//    -------------费   用--------------
    
//    _bookBtn = [[UIButton alloc] initWithFrame:CGRectMake(_scrollView.bounds.size.width-110, offsetY, 90, 30)];
//    _bookBtn.layer.cornerRadius = 5;
//    _bookBtn.clipsToBounds = YES;
    _bookBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    _bookBtn.layer.cornerRadius = 5;
    _bookBtn.clipsToBounds = YES;
    _bookBtn.frame = CGRectMake(w - 100, offsetY+20, 80, 30);
    [_bookBtn setContentEdgeInsets:UIEdgeInsetsMake(2, 0, 0, 0)];
    [_bookBtn setTitle:@"预订" forState:UIControlStateNormal];
    [_bookBtn setBackgroundImage:[ConvertMethods createImageWithColor:[UIColor lightGrayColor]] forState:UIControlStateDisabled];
    [_bookBtn setBackgroundImage:[ConvertMethods createImageWithColor:[UIColor redColor]] forState:UIControlStateNormal];
    _bookBtn.titleLabel.font = [UIFont boldSystemFontOfSize:14];
    [_bookBtn setTitleColor:TEXT_COLOR_TITLE_SUBTITLE forState:UIControlStateDisabled];
    _bookBtn.titleLabel.font = [UIFont systemFontOfSize:16.0];
//    [_bookBtn addTarget:self action:@selector(book:) forControlEvents:UIControlEventTouchUpInside];
    [_bookBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_scrollView addSubview:_bookBtn];
    NSString *priceDesc;
    
    if (_poi.poiType == kRestaurantPoi) {
        priceDesc = ((RestaurantPoi *)_poi).priceDesc;
    }
    if (_poi.poiType == kShoppingPoi) {
        priceDesc = ((ShoppingPoi *)_poi).priceDesc;
    }
    if ([priceDesc isBlankString] || !priceDesc) {
        offsetY += 10;
    } else {
        offsetY += 20;
        _priceBtn = [[UIButton alloc] initWithFrame:CGRectMake(55, offsetY, _scrollView.bounds.size.width-100, 30)];
        _priceBtn.titleLabel.font = [UIFont systemFontOfSize:14.0];
        NSString *priceText = [NSString stringWithFormat:@"     人均:%@ 元",priceDesc];
        [_priceBtn setTitle:priceText forState:UIControlStateNormal];
        [_priceBtn setTitleColor:TEXT_COLOR_TITLE_DESC forState:UIControlStateNormal];
        [_priceBtn setTitleColor:TEXT_COLOR_TITLE forState:UIControlStateHighlighted];
        [_priceBtn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
        [_scrollView addSubview:_priceBtn];
        offsetY += 30;
        
        UIView *spaceView = [[UIView alloc] initWithFrame:CGRectMake(65, offsetY+5, w-65, 1)];
        spaceView.backgroundColor = APP_DIVIDER_COLOR;
        [_scrollView addSubview:spaceView];
    }
    
    
//    --------------地    址----------------
    offsetY +=20;
    
    UIButton *addressDetailLabel =  [[UIButton alloc] initWithFrame:CGRectMake(55, offsetY, _scrollView.bounds.size.width-50, 30)];
    addressDetailLabel.titleLabel.font = [UIFont systemFontOfSize:14.0];
    [addressDetailLabel setTitleColor:TEXT_COLOR_TITLE_DESC forState:UIControlStateNormal];
    [addressDetailLabel setTitleColor:TEXT_COLOR_TITLE forState:UIControlStateHighlighted];
//    addressDetailLabel.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    addressDetailLabel.titleLabel.numberOfLines = 2;
    [addressDetailLabel setTitle:[NSString stringWithFormat:@"     %@",_poi.address] forState:UIControlStateNormal];
    [addressDetailLabel setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
//    [addressDetailLabel setContentVerticalAlignment:UIControlContentVerticalAlignmentTop];
    [addressDetailLabel addTarget:self action:@selector(jumpMapView:) forControlEvents:UIControlEventTouchUpInside];
    [_scrollView addSubview:addressDetailLabel];
    
    UIImageView *addressImageView = [[UIImageView alloc] initWithFrame:CGRectMake(35, offsetY, 11, 16)];
    addressImageView.image = [UIImage imageNamed:@"ic_map.png"];
    addressImageView.contentMode = UIViewContentModeScaleAspectFit;
    [_scrollView addSubview:addressImageView];
    UIView *spaceView1 = [[UIView alloc] initWithFrame:CGRectMake(65, offsetY+35, w-65, 1)];
    spaceView1.backgroundColor = APP_DIVIDER_COLOR;
    [_scrollView addSubview:spaceView1];
    
//    --------------电    话---------------
    offsetY += 60;
    UIButton *phoneDetailBtn = [[UIButton alloc] initWithFrame:CGRectMake(55, offsetY, _scrollView.bounds.size.width-100, 20)];
    [phoneDetailBtn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentCenter];
    [phoneDetailBtn addTarget:self action:@selector(makePhone:) forControlEvents:UIControlEventTouchUpInside];
    NSString *telephone;
    if (_poi.poiType == kRestaurantPoi) {
        telephone = ((RestaurantPoi *)_poi).telephone;
    }
    if (_poi.poiType == kShoppingPoi) {
        telephone = ((ShoppingPoi *)_poi).telephone;
    }
    if (_poi.poiType == kHotelPoi) {
        telephone = ((HotelPoi *)_poi).telephone;
    }
    telephone = @"     13333333测试用";
    [phoneDetailBtn setTitle:telephone forState:UIControlStateNormal];
    phoneDetailBtn.titleLabel.font = [UIFont systemFontOfSize:14.0];
    [phoneDetailBtn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    [phoneDetailBtn setTitleColor:TEXT_COLOR_TITLE_DESC forState:UIControlStateNormal];
//    [phoneDetailBtn setImage:[UIImage imageNamed:@"ic_tel.png"] forState:UIControlStateNormal];
    
    UIImageView *phoneDetailBtnView = [[UIImageView alloc] initWithFrame:CGRectMake(35, offsetY, 11, 16)];
    phoneDetailBtnView.image = [UIImage imageNamed:@"ic_tel.png"];
    phoneDetailBtnView.contentMode = UIViewContentModeScaleAspectFit;
    [_scrollView addSubview:phoneDetailBtnView];

    [_scrollView addSubview:phoneDetailBtn];
    
    
//    if (_poiType == kHotelPoi) {
//        _bookBtn = [[UIButton alloc] initWithFrame:CGRectMake(_scrollView.bounds.size.width-110, offsetY, 90, 30)];
//        _bookBtn.layer.cornerRadius = 5;
//        _bookBtn.clipsToBounds = YES;
//        [_bookBtn setContentEdgeInsets:UIEdgeInsetsMake(2, 0, 0, 0)];
//        [_bookBtn setTitle:@"在线预订" forState:UIControlStateNormal];
//        [_bookBtn setBackgroundImage:[ConvertMethods createImageWithColor:[UIColor lightGrayColor]] forState:UIControlStateDisabled];
//        [_bookBtn setBackgroundImage:[ConvertMethods createImageWithColor:APP_THEME_COLOR] forState:UIControlStateNormal];
//
//        [_bookBtn setTitleColor:TEXT_COLOR_TITLE_SUBTITLE forState:UIControlStateDisabled];
//        _bookBtn.titleLabel.font = [UIFont systemFontOfSize:14.0];
//        [_bookBtn addTarget:self action:@selector(book:) forControlEvents:UIControlEventTouchUpInside];
//        [_bookBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//        [_scrollView addSubview:_bookBtn];
//        if (!((HotelPoi *)_poi).bookUrl || [((HotelPoi *)_poi).bookUrl isBlankString]) {
//            _bookBtn.enabled = NO;
//        }
//        offsetY += 40;
//    } else {
//        offsetY += 10;
//    }

    _descView = [[ResizableView alloc] initWithFrame:CGRectMake(15, offsetY+10, _scrollView.bounds.size.width-30, 55) andNumberOfLine:3];
    _descView.contentFont = [UIFont systemFontOfSize:12.0];
    _descView.contentColor = TEXT_COLOR_TITLE_SUBTITLE;
    _descView.content = _poi.desc;
//    _descView.backgroundColor = [UIColor grayColor];
    _descView.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    [_descView setTitle:_poi.desc forState:UIControlStateNormal];
    [_scrollView addSubview:_descView];

    if (!([_poi.desc isBlankString] || !_poi.desc)) {
        offsetY += 75;
    } else {
        offsetY += 20;
    }
    
    UIImageView *commentBkgImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ic_comment_line.png"]];
    commentBkgImage.center = CGPointMake(_scrollView.bounds.size.width/2, offsetY+20);
    
    UILabel *commentTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 70, 14)];
    commentTitle.text = @"网友点评";
    commentTitle.textAlignment = NSTextAlignmentCenter;
    commentTitle.font = [UIFont systemFontOfSize:14.0];
    commentTitle.textColor = APP_THEME_COLOR;
    commentTitle.center = CGPointMake(commentBkgImage.bounds.size.width/2, commentBkgImage.bounds.size.height/2);
    [commentBkgImage addSubview:commentTitle];
    [_scrollView addSubview:commentBkgImage];
    
    offsetY += 40;
    
    if (_poi.comments.count >= 1) {
        
        UIImageView *dotImageViewLeft = [[UIImageView alloc] initWithFrame:CGRectMake(10, offsetY-10, 20, 17)];
        dotImageViewLeft.image = [UIImage imageNamed:@"ic_quotation_l.png"];
        dotImageViewLeft.contentMode = UIViewContentModeScaleAspectFit;
        [_scrollView addSubview:dotImageViewLeft];
        
        CommentDetail *comment = [_poi.comments objectAtIndex:0];
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
    if (_poi.comments.count >= 2) {
        CommentDetail *comment = [_poi.comments objectAtIndex:1];
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

    if (_poi.comments.count > 0) {
        offsetY += 10;
        UIImageView *dotImageViewRight = [[UIImageView alloc] initWithFrame:CGRectMake(_scrollView.bounds.size.width-30, offsetY-20, 20, 17)];
        dotImageViewRight.image = [UIImage imageNamed:@"ic_quotation_r.png"];
        dotImageViewRight.contentMode = UIViewContentModeScaleAspectFit;
        [_scrollView addSubview:dotImageViewRight];
    }
    
    UIButton *moreCommentBtn = [[UIButton alloc] initWithFrame:CGRectMake(_scrollView.bounds.size.width-80, offsetY, 80, 40)];
    [moreCommentBtn setTitle:@"更多点评>>" forState:UIControlStateNormal];
    [moreCommentBtn addTarget:self action:@selector(showMoreComments:) forControlEvents:UIControlEventTouchUpInside];
    [moreCommentBtn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    [moreCommentBtn setTitleColor:APP_SUB_THEME_COLOR forState:UIControlStateNormal];
    [moreCommentBtn setTitleColor:APP_SUB_THEME_COLOR_HIGHLIGHT forState:UIControlStateHighlighted];
    moreCommentBtn.titleLabel.font = [UIFont systemFontOfSize:12];
    [_scrollView addSubview:moreCommentBtn];
    
    offsetY += 50;

    _scrollView.contentSize = CGSizeMake(self.bounds.size.width, offsetY);
    
}

#pragma mark - IBAction Methods

- (void)showMoreComments:(id)sender
{
    SuperWebViewController *webCtl = [[SuperWebViewController alloc] init];
    webCtl.titleStr = @"全部点评";
    webCtl.urlStr = _poi.moreCommentsUrl;
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
    NSString *telephone;
    if (_poi.poiType == kRestaurantPoi) {
        telephone = ((RestaurantPoi *)_poi).telephone;
    }
    if (_poi.poiType == kShoppingPoi) {
        telephone = ((ShoppingPoi *)_poi).telephone;
    }
    if (_poi.poiType == kHotelPoi) {
        telephone = ((HotelPoi *)_poi).telephone;
    }
    NSURL *phoneUrl = [NSURL URLWithString:[NSString  stringWithFormat:@"telprompt:%@", telephone]];
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
    [MobClick event:@"event_go_booking_room"];
    SuperWebViewController *webCtl = [[SuperWebViewController alloc] init];
    webCtl.titleStr = @"在线预订";
    webCtl.urlStr = ((HotelPoi *)_poi).bookUrl;
    [_rootCtl.navigationController pushViewController:webCtl animated:YES];
}

- (IBAction)favorite:(id)sender
{
    if (_poiType == kRestaurantPoi) {
        [MobClick event:@"event_favorite_delicacy"];
    } else if (_poiType == kShoppingPoi) {
        [MobClick event:@"event_favorite_shopping"];
    } else if (_poiType == kHotelPoi) {
        [MobClick event:@"event_favorite_hotel"];
    }
    
    //先将收藏的状态改变
    _favoriteBtn.selected = !_poi.isMyFavorite;
    _favoriteBtn.userInteractionEnabled = NO;

    for (UIView* next = [self superview]; next; next = next.superview)
    {
        UIResponder* nextResponder = [next nextResponder];
      
        if ([nextResponder isKindOfClass:[CommonPoiDetailViewController class]]) {
            CommonPoiDetailViewController *rootCtl;
            rootCtl = (CommonPoiDetailViewController*)nextResponder;
            
            [rootCtl asyncFavoritePoiWithCompletion:^(BOOL isSuccess) {
                _favoriteBtn.userInteractionEnabled = YES;
                if (!isSuccess) {
                    _favoriteBtn.selected = !_poi.isMyFavorite;
                }
            }];
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










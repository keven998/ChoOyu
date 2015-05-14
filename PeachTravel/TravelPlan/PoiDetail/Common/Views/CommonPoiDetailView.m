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
    _imageView.frame = CGRectMake(0, offsetY, _scrollView.bounds.size.width, 314/2);
    _imageView.backgroundColor = APP_IMAGEVIEW_COLOR;
    _imageView.userInteractionEnabled = YES;
    [_scrollView addSubview:_imageView];
    TaoziImage *image = [_poi.images firstObject];
    [_imageView sd_setImageWithURL:[NSURL URLWithString:image.imageUrl]];
    
    
    
    UIView *imageMaskView = [[UIView alloc] initWithFrame:_imageView.bounds];
    imageMaskView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.3];
    [_imageView addSubview:imageMaskView];
    
    _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, (314+25)/2, _imageView.bounds.size.width-20, 20)];
    _titleLabel.textColor = TEXT_COLOR_TITLE;
    _titleLabel.text = _poi.zhName;
    
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    _titleLabel.font = [UIFont boldSystemFontOfSize:18];
    [_scrollView addSubview:_titleLabel];
    
    
    offsetY += (314+25)/2 + 14+28;
    

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
    CGFloat width = self.scrollView.bounds.size.width;
    offsetY +=14+14;
    UILabel *rankLabel = [[UILabel alloc]init];
    rankLabel.frame = CGRectMake(0, 0, 190, 15);
    rankLabel.center = CGPointMake(self.bounds.size.width/2, offsetY);
    rankLabel.textAlignment = NSTextAlignmentCenter;
    rankLabel.textColor = TEXT_COLOR_TITLE_SUBTITLE;
    rankLabel.font = [UIFont systemFontOfSize:15.0];
    if (_poi.rank > 0 && _poi.rank <= 500) {
        rankLabel.text = [NSString stringWithFormat:@"%@排名第%d", _poi.poiTypeName, _poi.rank];
    } else {
        rankLabel.text = [NSString stringWithFormat:@"%@排名第>500", _poi.poiTypeName];
    }
    [_scrollView addSubview:rankLabel];
    offsetY +=14+10;
    UIView *spaceView = [[UIView alloc] initWithFrame:CGRectMake(10, offsetY, width, 1)];
    spaceView.backgroundColor = APP_DIVIDER_COLOR;
    [_scrollView addSubview:spaceView];
    offsetY +=12;

    UILabel *practicalLabel = [[UILabel alloc]init];
    practicalLabel.frame = CGRectMake(0, 0, 150, 31);
    practicalLabel.center = CGPointMake(width/2, offsetY+15/2);
    practicalLabel.font = [UIFont boldSystemFontOfSize:18];
    practicalLabel.text = @"实用信息";
    practicalLabel.textAlignment = NSTextAlignmentCenter;
    [_scrollView addSubview:practicalLabel];
    offsetY +=23+15;
    
    
    
//    -------------费   用--------------
    if (_poiType == kHotelPoi) {

    _bookBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    _bookBtn.layer.cornerRadius = 5;
    _bookBtn.clipsToBounds = YES;
    _bookBtn.frame = CGRectMake(w - 100, offsetY, 80, 30);
    [_bookBtn setContentEdgeInsets:UIEdgeInsetsMake(2, 0, 0, 0)];
    [_bookBtn setTitle:@"预订" forState:UIControlStateNormal];
    [_bookBtn setBackgroundImage:[ConvertMethods createImageWithColor:[UIColor lightGrayColor]] forState:UIControlStateDisabled];
    [_bookBtn setBackgroundImage:[ConvertMethods createImageWithColor:[UIColor redColor]] forState:UIControlStateNormal];
    _bookBtn.titleLabel.font = [UIFont boldSystemFontOfSize:14];
    [_bookBtn setTitleColor:TEXT_COLOR_TITLE_SUBTITLE forState:UIControlStateDisabled];
    _bookBtn.titleLabel.font = [UIFont systemFontOfSize:16.0];
    [_bookBtn addTarget:self action:@selector(book:) forControlEvents:UIControlEventTouchUpInside];
    [_bookBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        if (!((HotelPoi *)_poi).bookUrl || [((HotelPoi *)_poi).bookUrl isBlankString]) {
                        _bookBtn.enabled = NO;
                    }
 
    [_scrollView addSubview:_bookBtn];
    }
    
    NSString *priceDesc;
    
    if (_poi.poiType == kRestaurantPoi) {
        priceDesc = ((RestaurantPoi *)_poi).priceDesc;
    }
    if (_poi.poiType == kShoppingPoi) {
        priceDesc = ((ShoppingPoi *)_poi).priceDesc;
    }
    if ([priceDesc isBlankString] || !priceDesc) {
        
    } else {
        _priceBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, offsetY, width, 24)];
        [_scrollView addSubview:_priceBtn];
        UILabel *priceLabel = [[UILabel alloc]initWithFrame:CGRectMake(353/2, 0, 100, 27)];
        priceLabel.text = priceDesc;
        priceLabel.font = [UIFont systemFontOfSize:14];
        priceLabel.textColor = TEXT_COLOR_TITLE_SUBTITLE;
        
        UILabel *price = [[UILabel alloc]initWithFrame:CGRectMake(35, 0, 100, 27)];
        price.text = @"费用";
        price.font = [UIFont systemFontOfSize:14];
        price.textColor = TEXT_COLOR_TITLE_SUBTITLE;
        [_priceBtn addSubview:priceLabel];
        [_priceBtn addSubview:price];
        
        UIImageView *priceImage = [[UIImageView alloc]initWithFrame:CGRectMake(10, 5, 13, 13)];
        priceImage.image = [UIImage imageNamed:@"ticket"];
        [_priceBtn addSubview:priceImage];
        
        offsetY += 24;
        
        
        UIView *spaceView2 = [[UIView alloc] initWithFrame:CGRectMake(10, offsetY, w, 1)];
        spaceView2.backgroundColor = APP_DIVIDER_COLOR;
        [_scrollView addSubview:spaceView2];
        offsetY += 1;
    }
    
    
//    --------------地    址----------------
    
    UIButton *addressDetailLabel =  [[UIButton alloc] initWithFrame:CGRectMake(0, offsetY, _scrollView.bounds.size.width, 37)];
    [_scrollView addSubview:addressDetailLabel];
    
    UIImageView *addressImageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, offsetY+12, 11, 16)];
    addressImageView.image = [UIImage imageNamed:@"map"];
    addressImageView.contentMode = UIViewContentModeScaleAspectFit;
    [_scrollView addSubview:addressImageView];
    UILabel *addressLabel = [[UILabel alloc]initWithFrame:CGRectMake(35, 6, 150, 27)];
    addressLabel.text = @"地址";
    addressLabel.font = [UIFont systemFontOfSize:14];
    [addressDetailLabel addSubview:addressLabel];
    [addressDetailLabel addTarget:self action:@selector(goMap:) forControlEvents:UIControlEventTouchUpInside];
    addressLabel.textColor = TEXT_COLOR_TITLE_SUBTITLE;
    UILabel *address = [[UILabel alloc]initWithFrame:CGRectMake(353/2, 6, 150, 27)];
    address.text = _poi.address;
    address.font = [UIFont systemFontOfSize:14];
    address.textColor = TEXT_COLOR_TITLE_SUBTITLE;
    [addressDetailLabel addSubview:address];

    offsetY +=37;
    UIView *spaceView3 = [[UIView alloc] initWithFrame:CGRectMake(10, offsetY, w, 1)];
    spaceView3.backgroundColor = APP_DIVIDER_COLOR;
    [_scrollView addSubview:spaceView3];
    offsetY +=1;
    
//    --------------电    话---------------
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
    if ([telephone isBlankString] || !telephone) {
    } else {
        _telephoneBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, offsetY, width, 37)];
        [_scrollView addSubview:_telephoneBtn];
        UILabel *telephoneNumber = [[UILabel alloc]initWithFrame:CGRectMake(353/2, 6, 100, 27)];
        telephoneNumber.text = priceDesc;
        telephoneNumber.font = [UIFont systemFontOfSize:14];
        telephoneNumber.textColor = TEXT_COLOR_TITLE_SUBTITLE;
        
        UILabel *telephoneLabel = [[UILabel alloc]initWithFrame:CGRectMake(35, 6, 100, 27)];
        telephoneLabel.text = @"电话";
        telephoneLabel.font = [UIFont systemFontOfSize:14];
        telephoneLabel.textColor = TEXT_COLOR_TITLE_SUBTITLE;
        [_telephoneBtn addSubview:telephoneLabel];
        [_telephoneBtn addSubview:telephoneNumber];
        
        UIImageView *phoneImage = [[UIImageView alloc]initWithFrame:CGRectMake(10, 12, 13, 13)];
        phoneImage.image = [UIImage imageNamed:@"phone"];
        [_telephoneBtn addSubview:phoneImage];
        
        offsetY += 37;
        
        
        UIView *spaceView2 = [[UIView alloc] initWithFrame:CGRectMake(10, offsetY, w, 1)];
        spaceView2.backgroundColor = APP_DIVIDER_COLOR;
        [_scrollView addSubview:spaceView2];
        offsetY += 1;
    }

    
    
//    if (_poiType == kHotelPoi) {
//        _bookBtn = [[UIButton alloc] initWithFrame:CGRectMake(_scrollView.bounds.size.width-110, offsetY, 90, 30)];
//        _bookBtn.layer.cornerRadius = 5;
//        _bookBtn.clipsToBounds = YES;
//        [_bookBtn setContentEdgeInsets:UIEdgeInsetsMake(2, 0, 0, 0)];
//        [_bookBtn setTitle:@"在线预订" forState:UIControlStateNormal];
//        [_bookBtn setBackgroundImage:[ConvertMethods createImageWithColor:[UIColor lightGrayColor]] forState:UIControlStateDisabled];
//        [_bookBtn setBackgroundImage:[ConvertMethods createImageWithColor:APP_THEME_COLOR] forState:UIControlStateNormal];
    
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
    
    if (!([_poi.desc isBlankString] || !_poi.desc)) {
    UILabel *desLabel = [[UILabel alloc]initWithFrame:CGRectMake(35, offsetY + 6, 100, 27)];
    desLabel.text = @"景点简介";
    desLabel.font = [UIFont systemFontOfSize:14];
    desLabel.textColor = TEXT_COLOR_TITLE_SUBTITLE;
    [_scrollView addSubview:desLabel];
    
    UIImageView *desImage = [[UIImageView alloc]initWithFrame:CGRectMake(10, offsetY + 12, 13, 13)];
    desImage.image = [UIImage imageNamed:@"spot introduction"];
    [_scrollView addSubview:desImage];
    
        _descView = [[ResizableView alloc] initWithFrame:CGRectMake(353/2, offsetY, _scrollView.bounds.size.width-353/2-10, 77) andNumberOfLine:4];
        _descView.contentFont = [UIFont systemFontOfSize:12.0];
        _descView.contentColor = TEXT_COLOR_TITLE_SUBTITLE;
        _descView.content = _poi.desc;
        _descView.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        [_descView setTitle:_poi.desc forState:UIControlStateNormal];
        [_scrollView addSubview:_descView];
        offsetY +=85;
        
        UIView *spaceView4 = [[UIView alloc] initWithFrame:CGRectMake(10, offsetY, w, 1)];
        spaceView4.backgroundColor = APP_DIVIDER_COLOR;
        [_scrollView addSubview:spaceView4];
        offsetY += 10;
        offsetY += 1;
    } else {
        offsetY +=11;
    }

    
    UILabel *commentTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 150, 31)];
    commentTitle.center = CGPointMake(width/2, offsetY+15/2);
    commentTitle.text = @"网友点评";
    commentTitle.textAlignment = NSTextAlignmentCenter;
    commentTitle.font = [UIFont boldSystemFontOfSize:18.0];
    commentTitle.textColor = TEXT_COLOR_TITLE;
    
    [_scrollView addSubview:commentTitle];
    
    UIButton *moreCommentBtn = [[UIButton alloc] initWithFrame:CGRectMake(_scrollView.bounds.size.width-80, offsetY-15, 80, 40)];
    [moreCommentBtn setTitle:@"更多点评>>" forState:UIControlStateNormal];
    [moreCommentBtn addTarget:self action:@selector(showMoreComments:) forControlEvents:UIControlEventTouchUpInside];
    [moreCommentBtn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    [moreCommentBtn setTitleColor:APP_SUB_THEME_COLOR forState:UIControlStateNormal];
    [moreCommentBtn setTitleColor:APP_SUB_THEME_COLOR_HIGHLIGHT forState:UIControlStateHighlighted];
    moreCommentBtn.titleLabel.font = [UIFont systemFontOfSize:12];
    [_scrollView addSubview:moreCommentBtn];

    
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
    
    
    offsetY += 50;

    _scrollView.contentSize = CGSizeMake(self.bounds.size.width, offsetY);
    
}

#pragma mark - IBAction Methods

- (void)showMoreComments:(id)sender
{
    SuperWebViewController *webCtl = [[SuperWebViewController alloc] init];
    webCtl.titleStr = @"全部点评";
    webCtl.urlStr = _poi.moreCommentsUrl;
    webCtl.hideToolBar = YES;
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
//    NSArray *platformArray = [ConvertMethods mapPlatformInPhone];
//    switch (buttonIndex) {
//        case 0:
//            switch ([[[platformArray objectAtIndex:0] objectForKey:@"type"] intValue]) {
//                case kAMap:
//                    [ConvertMethods jumpGaodeMapAppWithPoiName:self.poi.zhName lat:self.poi.lat lng:self.poi.lng];
//                    break;
//                    
//                case kBaiduMap: {
//                    [ConvertMethods jumpBaiduMapAppWithPoiName:self.poi.zhName lat:self.poi.lat lng:self.poi.lng];
//                }
//                    break;
//                    
//                case kAppleMap: {
                    [ConvertMethods jumpAppleMapAppWithPoiName:self.poi.zhName lat:self.poi.lat lng:self.poi.lng];
//                }
//                    
//                default:
//                    break;
//            }
//            break;
//            
//        case 1:
//            switch ([[[platformArray objectAtIndex:1] objectForKey:@"type"] intValue]) {
//                case kAMap:
//                    [ConvertMethods jumpGaodeMapAppWithPoiName:self.poi.zhName lat:self.poi.lat lng:self.poi.lng];
//                    break;
//                    
//                case kBaiduMap: {
//                    [ConvertMethods jumpBaiduMapAppWithPoiName:self.poi.zhName lat:self.poi.lat lng:self.poi.lng];
//                }
//                    break;
//                    
//                case kAppleMap: {
//                    [ConvertMethods jumpAppleMapAppWithPoiName:self.poi.zhName lat:self.poi.lat lng:self.poi.lng];
//                }
//                    break;
//                    
//                default:
//                    break;
//            }
//            break;
//            
//        case 2:
//            switch ([[[platformArray objectAtIndex:2] objectForKey:@"type"] intValue]) {
//                case kAMap:
//                    [ConvertMethods jumpGaodeMapAppWithPoiName:self.poi.zhName lat:self.poi.lat lng:self.poi.lng];
//                    break;
//                    
//                case kBaiduMap: {
//                    [ConvertMethods jumpBaiduMapAppWithPoiName:self.poi.zhName lat:self.poi.lat lng:self.poi.lng];
//                }
//                    break;
//                    
//                case kAppleMap: {
//                    [ConvertMethods jumpAppleMapAppWithPoiName:self.poi.zhName lat:self.poi.lat lng:self.poi.lng];
//                }                    break;
//                    
//                default:
//                    break;
//            }
//            break;
//            
//        default:
//            break;
//    }
}

@end










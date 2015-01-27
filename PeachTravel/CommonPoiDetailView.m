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

enum {
    kASMap = 1,
    kASShare
};

@interface CommonPoiDetailView () <UIScrollViewDelegate, UIActionSheetDelegate>

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) NSMutableArray *imageViews;
@property (nonatomic, strong) ResizableView *descView;
@property (nonatomic, strong) ResizableView *recommendDescView;
@property (nonatomic, strong) UIButton *commentBtn;
@property (nonatomic, strong) UIButton *showMoreRecommendContentBtn;
@property (nonatomic, strong) UIButton *showMoreDescContentBtn;
@property (nonatomic, strong) EDStarRating *ratingView;
@property (nonatomic, strong) UILabel *priceLabel;
@property (nonatomic, strong) UIButton *favoriteBtn;
@property (nonatomic, strong) UIButton *telephoneBtn;

@property (nonatomic, strong) UIView *panelOneView;
@property (nonatomic, strong) UIView *panelTwoView;

@end

@implementation CommonPoiDetailView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = APP_PAGE_COLOR;
        _scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.contentSize = CGSizeMake(_scrollView.bounds.size.width, _scrollView.bounds.size.height+1);
        [self addSubview:_scrollView];
        
        _closeBtn = [[UIButton alloc] initWithFrame:CGRectMake(self.bounds.size.width-40, 0, 40, 40)];
        [_closeBtn setImage:[UIImage imageNamed:@"ic_close.png"] forState:UIControlStateNormal];
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
    
    _imageView.frame = CGRectMake(10, 15, 100, 100);
    _imageView.layer.borderColor = APP_BORDER_COLOR.CGColor;
    _imageView.layer.cornerRadius = 2.0;
    _imageView.layer.borderWidth = 0.5;
    _imageView.backgroundColor = APP_IMAGEVIEW_COLOR;
    [_scrollView addSubview:_imageView];
    TaoziImage *image = [_poi.images firstObject];
    [_imageView sd_setImageWithURL:[NSURL URLWithString:image.imageUrl]];
    
    _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(_imageView.frame.origin.x+_imageView.frame.size.width+10, offsetY, self.bounds.size.width-(_imageView.frame.origin.x+_imageView.frame.size.width+20)-20, 20)];
    _titleLabel.textColor = APP_THEME_COLOR;
    _titleLabel.text = _poi.zhName;
    _titleLabel.font = [UIFont fontWithName:@"MicrosoftYaHei" size:15.0];
    [_scrollView addSubview:_titleLabel];
    
    offsetY += 25;
    
    _priceLabel = [[UILabel alloc] initWithFrame:CGRectMake(_titleLabel.frame.origin.x, offsetY, _titleLabel.frame.size.width, 15)];
    _priceLabel.textColor = TEXT_COLOR_TITLE;
    _priceLabel.font = [UIFont fontWithName:@"MicrosoftYaHei" size:13.0];
    _priceLabel.text = _poi.priceDesc;
    offsetY += 25;
    
    _ratingView = [[EDStarRating alloc] initWithFrame:CGRectMake(_titleLabel.frame.origin.x, offsetY, 60, 15)];
    _ratingView.starImage = [UIImage imageNamed:@"ic_star_gray.png"];
    _ratingView.starHighlightedImage = [UIImage imageNamed:@"rating_star.png"];
    _ratingView.maxRating = 5.0;
    _ratingView.editable = NO;
    _ratingView.horizontalMargin = 3;
    _ratingView.displayMode = EDStarRatingDisplayAccurate;
    _ratingView.rating = _poi.rating;
    [_scrollView addSubview:_ratingView];
    
    offsetY += 20;
    
    _favoriteBtn = [[UIButton alloc] initWithFrame:CGRectMake(_titleLabel.frame.origin.x, offsetY, 45, 25)];
    [_favoriteBtn addTarget:self action:@selector(favorite:) forControlEvents:UIControlEventTouchUpInside];
    [_favoriteBtn setImage:[UIImage imageNamed:@"ic_favorite.png"] forState:UIControlStateNormal];
    [_scrollView addSubview:_favoriteBtn];
    
    _telephoneBtn = [[UIButton alloc] initWithFrame:CGRectMake(_favoriteBtn.frame.size.width+_favoriteBtn.frame.origin.x, offsetY, 45, 25)];
    [_telephoneBtn addTarget:self action:@selector(makePhone:) forControlEvents:UIControlEventTouchUpInside];
    [_telephoneBtn setImage:[UIImage imageNamed:@"ic_telephone.png"] forState:UIControlStateNormal];
    [_scrollView addSubview:_telephoneBtn];
    
    _shareBtn = [[UIButton alloc] initWithFrame:CGRectMake(_telephoneBtn.frame.size.width+_telephoneBtn.frame.origin.x, offsetY, 45, 25)];      
    [_shareBtn setImage:[UIImage imageNamed:@"ic_share.png"] forState:UIControlStateNormal];
    [_scrollView addSubview:_shareBtn];
    
    offsetY += 40;
    
    UILabel *addressTitle = [[UILabel alloc] initWithFrame:CGRectMake(10, offsetY, 100, 15)];
    addressTitle.textColor = APP_THEME_COLOR;
    addressTitle.text = @"地址";
    addressTitle.font = [UIFont fontWithName:@"MicrosoftYaHei" size:13.0];
    [_scrollView addSubview:addressTitle];
    
    offsetY += 15;
    
    UIButton *addressDetailLabel = [[UIButton alloc] initWithFrame:CGRectMake(10, offsetY, self.bounds.size.width-60, 36)];
    addressDetailLabel.titleLabel.font = [UIFont fontWithName:@"MicrosoftYaHei" size:13.0];
    [addressDetailLabel setTitleColor:TEXT_COLOR_TITLE forState:UIControlStateNormal];
    addressDetailLabel.titleLabel.numberOfLines = 2.0;
    [addressDetailLabel setTitle:_poi.address forState:UIControlStateNormal];
    [addressDetailLabel addTarget:self action:@selector(jumpMapView:) forControlEvents:UIControlEventTouchUpInside];
    [_scrollView addSubview:addressDetailLabel];
    
    UIButton *mapBtn = [[UIButton alloc] initWithFrame:CGRectMake(self.bounds.size.width-50, offsetY-5, 40, 40)];
    [mapBtn addTarget:self action:@selector(jumpMapView:) forControlEvents:UIControlEventTouchUpInside];
    [mapBtn setImage:[UIImage imageNamed:@"ic_poidetail_map.png"] forState:UIControlStateNormal];
    [_scrollView addSubview:mapBtn];
    
    offsetY += 45;
    
    UIView *dotView1 = [[UIView alloc] initWithFrame:CGRectMake(10, offsetY, 6, 15)];
    dotView1.backgroundColor = APP_THEME_COLOR;
    dotView1.layer.cornerRadius = 3.0;
    [_scrollView addSubview:dotView1];
    
    UILabel *descTitleLable = [[UILabel alloc] initWithFrame:CGRectMake(20, offsetY, 100, 15)];
    descTitleLable.text = @"简介";
//    if (_poi.poiType == kShoppingPoi) {
//        descTitleLable.text = @"店铺简介";
//    }
//    if (_poi.poiType == kRestaurantPoi) {
//        descTitleLable.text = @"美食简介";
//    }

    descTitleLable.textColor = APP_THEME_COLOR;
    descTitleLable.font = [UIFont fontWithName:@"MicrosoftYaHei" size:15.0];
    [_scrollView addSubview:descTitleLable];
    
    offsetY += 20;
    
    _descView = [[ResizableView alloc] initWithFrame:CGRectMake(10, offsetY, self.bounds.size.width-20, 55) andNumberOfLine:3];
    _descView.contentFont = [UIFont fontWithName:@"MicrosoftYaHei" size:13.0];
    _descView.contentColor = TEXT_COLOR_TITLE_SUBTITLE;
    _descView.content = _poi.desc;
    [_descView addTarget:self action:@selector(showMoreContent:) forControlEvents:UIControlEventTouchUpInside];
    [_scrollView addSubview:_descView];

    _showMoreDescContentBtn = [[UIButton alloc] initWithFrame:CGRectMake(_scrollView.bounds.size.width - 25, offsetY+55, 10, 8)];
    [_showMoreDescContentBtn setImage:[UIImage imageNamed:@"cell_accessory_pink_down.png"] forState:UIControlStateNormal];
    [_showMoreDescContentBtn addTarget:self action:@selector(showMoreContent:) forControlEvents:UIControlEventTouchUpInside];
    _showMoreDescContentBtn.userInteractionEnabled = NO;
    
    if (_descView.maxNumberOfLine > 3) {
        [_scrollView addSubview:_showMoreDescContentBtn];
    }

    offsetY += 50;
    
    _panelOneView = [[UIView alloc] initWithFrame:CGRectMake(0, offsetY, self.bounds.size.width, 200)];
    _panelOneView.backgroundColor = APP_PAGE_COLOR;
    [_scrollView addSubview:_panelOneView];
    
    UIView *spaceViewOne = [[UIView alloc] initWithFrame:CGRectMake(0, 15, _panelOneView.bounds.size.width, 1)];
    spaceViewOne.backgroundColor = APP_PAGE_COLOR;
    [_panelOneView addSubview:spaceViewOne];
    
    UIView *dotView2 = [[UIView alloc] initWithFrame:CGRectMake(10, 30, 6, 15)];
    dotView2.backgroundColor = APP_THEME_COLOR;
    dotView2.layer.cornerRadius = 3.0;
    [_panelOneView addSubview:dotView2];
    UILabel *recommendTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 30, 100, 15)];
    recommendTitleLabel.text = @"网友推荐";
    recommendTitleLabel.textColor = APP_THEME_COLOR;
    recommendTitleLabel.font = [UIFont fontWithName:@"MicrosoftYaHei" size:15.0];

    [_panelOneView addSubview:recommendTitleLabel];
    
    _recommendDescView = [[ResizableView alloc] initWithFrame:CGRectMake(10, 55, self.bounds.size.width-20, 55) andNumberOfLine:3];
    _recommendDescView.content = @"吃什么好呢吃什么好呢吃什么好呢吃什么好呢，吃什么好呢吃什么好呢吃什么好呢，吃什么好呢吃什么好呢吃什么好呢吃什么好呢吃什么好呢吃什么好呢吃什么好呢，吃什么好呢吃什么好呢吃什么好呢，吃什么好呢吃什么好呢吃什么好呢";
    _recommendDescView.contentFont = [UIFont fontWithName:@"MicrosoftYaHei" size:12.0];

    _recommendDescView.contentColor = TEXT_COLOR_TITLE_SUBTITLE;
    [_recommendDescView addTarget:self action:@selector(showMoreContent:) forControlEvents:UIControlEventTouchUpInside];
    [_panelOneView addSubview:_recommendDescView];
    
    _showMoreRecommendContentBtn = [[UIButton alloc] initWithFrame:CGRectMake(_panelOneView.bounds.size.width - 25, 100, 10, 8)];
    [_showMoreRecommendContentBtn setImage:[UIImage imageNamed:@"cell_accessory_pink_down.png"] forState:UIControlStateNormal];
    [_showMoreRecommendContentBtn addTarget:self action:@selector(showMoreContent:) forControlEvents:UIControlEventTouchUpInside];
    _showMoreRecommendContentBtn.userInteractionEnabled = NO;
    if (_recommendDescView.maxNumberOfLine>3) {
        [_panelOneView addSubview:_showMoreRecommendContentBtn];
    }
    
    _panelTwoView = [[UIView alloc] initWithFrame:CGRectMake(0, 124, _panelOneView.bounds.size.width, 76)];
    _panelTwoView.backgroundColor = APP_PAGE_COLOR;
    [_panelOneView addSubview:_panelTwoView];
    
    UIView *spaceViewTwo = [[UIView alloc] initWithFrame:CGRectMake(0, 15, _panelTwoView.bounds.size.width, 1)];
    spaceViewTwo.backgroundColor = APP_PAGE_COLOR;
    [_panelTwoView addSubview:spaceViewTwo];
    UIView *dotView3 = [[UIView alloc] initWithFrame:CGRectMake(10, 30, 6, 15)];
    dotView3.backgroundColor = APP_THEME_COLOR;
    dotView3.layer.cornerRadius = 3.0;
    [_panelTwoView addSubview:dotView3];
    UILabel *commentTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 30, 100, 15)];
    commentTitleLabel.text = @"网友点评";
    commentTitleLabel.textColor = APP_THEME_COLOR;
    commentTitleLabel.font = [UIFont fontWithName:@"MicrosoftYaHei" size:15.0];
    [_panelTwoView addSubview:commentTitleLabel];

    _commentBtn = [[UIButton alloc] initWithFrame:CGRectMake(10, 50, _panelTwoView.bounds.size.width-20, 30)];
    _commentBtn.titleLabel.numberOfLines = 2;
    [_commentBtn setTitle:@"吃什么好呢吃什么好呢吃什么好呢吃什么好呢，吃什么好呢吃什么好呢吃什么好呢" forState:UIControlStateNormal];
    [_commentBtn setTitleColor:TEXT_COLOR_TITLE_SUBTITLE forState:UIControlStateNormal];
    _commentBtn.titleLabel.font = [UIFont fontWithName:@"MicrosoftYaHei" size:12.0];

    [_commentBtn addTarget:self action:@selector(showMoreComments:) forControlEvents:UIControlEventTouchUpInside];
    [_commentBtn setContentEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 30)];
    [_panelTwoView addSubview:_commentBtn];

    UIImageView *accessImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cell_accessory_gray.png"]];
    accessImageView.center = CGPointMake(_panelTwoView.bounds.size.width-20, _commentBtn.center.y);
    [_panelTwoView addSubview:accessImageView];
    
    _scrollView.contentSize = CGSizeMake(self.bounds.size.width, offsetY+250);
    
}

#pragma mark - IBAction Methods

- (void)showMoreComments:(id)sender
{
    SuperWebViewController *webCtl = [[SuperWebViewController alloc] init];
//    webCtl.titleStr = @"更多点评";
    webCtl.urlStr = [NSString stringWithFormat:@"%@%@",MORE_COMMENT_HTML,_poi.poiId];
    NSLog(@"%@", _rootCtl.navigationController);
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

- (IBAction)showMoreContent:(UIButton *)sender
{
    sender.userInteractionEnabled = NO;
    if ([sender isEqual:_descView]) {
        [_descView showMoreContent];
        [UIView animateWithDuration:0.3 animations:^{
            CGRect frame = _showMoreDescContentBtn.frame;
            frame.origin.y += _descView.resizeHeight;
            _showMoreDescContentBtn.frame = frame;
            
            frame = _descView.frame;
            frame.size.height += _descView.resizeHeight;
            _descView.frame = frame;
            
            frame = _panelOneView.frame;
            frame.origin.y += _descView.resizeHeight;
            _panelOneView.frame = frame;
            
            _showMoreDescContentBtn.transform = CGAffineTransformMakeRotation(180 *M_PI / 180.0);
        } completion:^(BOOL finished) {
            sender.userInteractionEnabled = YES;
            [_descView removeTarget:self action:@selector(showMoreContent:) forControlEvents:UIControlEventTouchUpInside];
            [_descView addTarget:self action:@selector(hideContent:) forControlEvents:UIControlEventTouchUpInside];
           
        }];
       
        CGSize size = _scrollView.contentSize;
        size.height += _descView.resizeHeight;
        [_scrollView setContentSize:size];
       
    } else {
        [_recommendDescView showMoreContent];
        [UIView animateWithDuration:0.3 animations:^{
            CGRect frame = _showMoreRecommendContentBtn.frame;
            frame.origin.y += _recommendDescView.resizeHeight;
            _showMoreRecommendContentBtn.frame = frame;
            
            frame = _descView.frame;
            frame.size.height += _recommendDescView.resizeHeight;
            _descView.frame = frame;
            
            frame = _panelTwoView.frame;
            frame.origin.y += _recommendDescView.resizeHeight;
            _panelTwoView.frame = frame;
            
            _showMoreRecommendContentBtn.transform = CGAffineTransformMakeRotation(180 *M_PI / 180.0);
        } completion:^(BOOL finished) {
            sender.userInteractionEnabled = YES;
            [_recommendDescView removeTarget:self action:@selector(showMoreContent:) forControlEvents:UIControlEventTouchUpInside];
            [_recommendDescView addTarget:self action:@selector(hideContent:) forControlEvents:UIControlEventTouchUpInside];
          
        }];
        CGSize size = _scrollView.contentSize;
        size.height += _recommendDescView.resizeHeight;
        [_scrollView setContentSize:size];
        
    }
}

- (IBAction)hideContent:(UIButton *)sender
{
    sender.userInteractionEnabled = NO;
    if ([sender isEqual:_descView]) {
        [_descView hideContent];
        [UIView animateWithDuration:0.3 animations:^{
            CGRect frame = _showMoreDescContentBtn.frame;
            frame.origin.y -= _descView.resizeHeight;
            _showMoreDescContentBtn.frame = frame;
            
            frame = _panelOneView.frame;
            frame.origin.y -= _descView.resizeHeight;
            _panelOneView.frame = frame;
            
            _showMoreDescContentBtn.transform = CGAffineTransformMakeRotation(360 *M_PI / 180.0);
        } completion:^(BOOL finished) {
            sender.userInteractionEnabled = YES;
            [_descView removeTarget:self action:@selector(hideContent:) forControlEvents:UIControlEventTouchUpInside];
            [_descView addTarget:self action:@selector(showMoreContent:) forControlEvents:UIControlEventTouchUpInside];
        }];
        CGSize size = _scrollView.contentSize;
        size.height -= _descView.resizeHeight;
        [_scrollView setContentSize:size];
       
    } else {
        [_recommendDescView hideContent];
        [UIView animateWithDuration:0.3 animations:^{
            CGRect frame = _showMoreRecommendContentBtn.frame;
            frame.origin.y -= _recommendDescView.resizeHeight;
            _showMoreRecommendContentBtn.frame = frame;
            
            frame = _panelTwoView.frame;
            frame.origin.y -= _recommendDescView.resizeHeight;
            _panelTwoView.frame = frame;
            
            _showMoreRecommendContentBtn.transform = CGAffineTransformMakeRotation(360 *M_PI / 180.0);
        } completion:^(BOOL finished) {
            sender.userInteractionEnabled = YES;
            [_recommendDescView removeTarget:self action:@selector(hideContent:) forControlEvents:UIControlEventTouchUpInside];
            [_recommendDescView addTarget:self action:@selector(showMoreContent:) forControlEvents:UIControlEventTouchUpInside];
        }];
        
        CGSize size = _scrollView.contentSize;
        size.height -= _recommendDescView.resizeHeight;
        [_scrollView setContentSize:size];

    }
}

- (IBAction)makePhone:(id)sender
{
    NSURL *phoneUrl = [NSURL URLWithString:[NSString  stringWithFormat:@"telprompt:%@", _poi.telephone]];
    if ([[UIApplication sharedApplication] canOpenURL:phoneUrl]) {
        [[UIApplication sharedApplication] openURL:phoneUrl];
    }
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










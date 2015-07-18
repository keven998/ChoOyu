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
#import "CityImageAlbum.h"

@interface CityHeaderView () <UIScrollViewDelegate, CityAlbumViewDelegate>

@property (nonatomic, strong) UIScrollView *galleryPageView; //unuse

@property (nonatomic, strong) NSMutableArray *imageViews;
@property (nonatomic, strong) UIButton *showMoreDescContentBtn;
@property (nonatomic, strong) UIButton *showMoreInfoContentBtn;



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
    CGFloat oy = 13;
    
    CityImageAlbum *albumView = [[[NSBundle mainBundle] loadNibNamed:@"CityImageAlbum"
                                                               owner:nil
                                                             options:nil] lastObject];
    albumView.delegate = self;
    CGFloat albumHeight = [CityImageAlbum heightOfCityAlbumViewWithWidth:width-36];
    [albumView setFrame:CGRectMake(18, oy, width-36, albumHeight)];
    albumView.title = _cityPoi.zhName;
    albumView.subTitle = [NSString stringWithFormat:@"~建议旅行 · %@~", _cityPoi.timeCostDesc];
    albumView.images = _cityPoi.images;
    [self addSubview:albumView];
    
    NSString *tm = [NSString stringWithFormat:@"~最佳季节：%@", _cityPoi.travelMonth];
    _travelMonth = [[UILabel alloc] initWithFrame:CGRectMake(18, CGRectGetMaxY(albumView.frame) + 20, width-36, 16)];
    _travelMonth.textColor = COLOR_TEXT_II;
    _travelMonth.userInteractionEnabled = YES;
    _travelMonth.font = [UIFont systemFontOfSize:12.0];
    _travelMonth.numberOfLines = 1;
    CGSize timeCostLabelSize = [tm boundingRectWithSize:CGSizeMake(width-116, MAXFLOAT)
                                                                  options:NSStringDrawingUsesLineFragmentOrigin
                                                               attributes:@{
                                                                            NSFontAttributeName : _travelMonth.font,
                                                                            }
                                                                  context:nil].size;
    
    if (timeCostLabelSize.height > 16) {
        NSAttributedString *more = [[NSAttributedString alloc] initWithString:@"全文" attributes:@{NSForegroundColorAttributeName : APP_THEME_COLOR, NSFontAttributeName: [UIFont systemFontOfSize:12]}];
        NSMutableAttributedString *attrstr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@... ", [tm substringToIndex:20]] attributes:nil];
        [attrstr appendAttributedString:more];
        _travelMonth.attributedText = attrstr;
    } else {
        _travelMonth.text = tm;
    }
    
    [self addSubview:_travelMonth];
    
    oy = CGRectGetMaxY(_travelMonth.frame) + 10;
    
    _cityDesc = [[UILabel alloc] initWithFrame:CGRectMake(18, oy, width-36, 40)];
    _cityDesc.textColor = COLOR_TEXT_I;
    _cityDesc.numberOfLines = 2;
    _cityDesc.userInteractionEnabled = YES;
    NSString *descStr = _cityPoi.desc;
    CGRect minRect = [descStr boundingRectWithSize:CGSizeMake(width-36, 18)
                                       options:NSStringDrawingUsesLineFragmentOrigin
                                    attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:13]}
                                       context:nil];
    CGRect maxRect = [descStr boundingRectWithSize:CGSizeMake(width-36, CGFLOAT_MAX)
                                              options:NSStringDrawingUsesLineFragmentOrigin
                                           attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:13]}
                                              context:nil];
    NSInteger totalLine = ceilf(maxRect.size.height / minRect.size.height);
    NSInteger ccount = descStr.length;
    NSInteger count = ccount * 2/totalLine;
    if (count < ccount) {
        NSString *truncateStr = [descStr substringWithRange:NSMakeRange(0, count - 3)];
        
        NSMutableParagraphStyle *ps = [[NSMutableParagraphStyle alloc] init];
        ps.lineSpacing = 4.0;
        NSDictionary *attribs = @{NSFontAttributeName: [UIFont systemFontOfSize:13], NSParagraphStyleAttributeName:ps};
        truncateStr = [NSString stringWithFormat:@"%@... ", truncateStr];
        NSMutableAttributedString *attrstr = [[NSMutableAttributedString alloc] initWithString:truncateStr attributes:attribs];
        NSAttributedString *more1 = [[NSAttributedString alloc] initWithString:@"全文" attributes:@{NSForegroundColorAttributeName : APP_THEME_COLOR, NSFontAttributeName: [UIFont systemFontOfSize:13]}];
        [attrstr appendAttributedString:more1];
        _cityDesc.attributedText = attrstr;
        [self addSubview:_cityDesc];
    } else {
        _cityDesc.text = descStr;
    }
    
    
    oy += 56;
    
    CGFloat itemSpace = 18;
    CGFloat itemSize = (width - 36 - itemSpace*3)/4.0;
    if (itemSize < 64) {
        itemSpace = 10.0;
        itemSize = (width - 36 - itemSpace*3)/4.0;
    }
    _showTipsBtn  = [[UIButton alloc] initWithFrame:CGRectMake(18, oy, itemSize, itemSize)];
    [_showTipsBtn setImage:[UIImage imageNamed:@"city_button_guide_default.png"] forState:UIControlStateNormal];
    [_showTipsBtn setImage:[UIImage imageNamed:@"city_button_guide_selected.png"] forState:UIControlStateHighlighted];
    
    [self addSubview:_showTipsBtn];
    
    _showSpotsBtn = [[UIButton alloc] initWithFrame:CGRectMake(18 + itemSpace + itemSize, oy, itemSize, itemSize)];
    [_showSpotsBtn setImage:[UIImage imageNamed:@"city_button_spot_default.png"] forState:UIControlStateNormal];
    [_showSpotsBtn setImage:[UIImage imageNamed:@"city_button_spot_selected.png"] forState:UIControlStateHighlighted];
    [self addSubview:_showSpotsBtn];
    
    _showRestaurantsBtn = [[UIButton alloc] initWithFrame:CGRectMake(18 + itemSpace * 2 + 2*itemSize, oy, itemSize, itemSize)];
    [_showRestaurantsBtn setImage:[UIImage imageNamed:@"city_button_food_default.png"] forState:UIControlStateNormal];
    [_showRestaurantsBtn setImage:[UIImage imageNamed:@"city_button_food_selected.png"] forState:UIControlStateHighlighted];
    
    [self addSubview:_showRestaurantsBtn];
    
    _showShoppingBtn = [[UIButton alloc] initWithFrame:CGRectMake(18 + itemSpace * 3 + 3*itemSize, oy, itemSize, itemSize)];
    [_showShoppingBtn setImage:[UIImage imageNamed:@"city_button_shopping_default.png"] forState:UIControlStateNormal];
    [_showShoppingBtn setImage:[UIImage imageNamed:@"city_button_shopping_selected.png"] forState:UIControlStateHighlighted];
    
    [self addSubview:_showShoppingBtn];
    
    
    oy += itemSize + 16;
    
    CGRect frame1 = self.frame;
    frame1.size.height = oy;
    frame1.size.width = width;
    self.frame = frame1;
    
}

- (void)viewImage:(NSInteger)index
{
    [MobClick event:@"event_city_photoes"];
    MWPhotoBrowser *browser = [[MWPhotoBrowser alloc] init];
    browser.titleStr = @"城市相册";
    for (UIView* next = [self superview]; next; next = next.superview)
    {
        UIResponder* nextResponder = [next nextResponder];
        
        if ([nextResponder isKindOfClass:[UIViewController class]])
        {
            UIViewController *ctl = (UIViewController*)nextResponder;
            [self loadAlbumDataWithAlbumCtl:browser];
            [browser setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];
            UINavigationController *navc = [[UINavigationController alloc] initWithRootViewController:browser];
            [ctl presentViewController:navc animated:YES completion:nil];
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
    
    NSString *requsetUrl = [NSString stringWithFormat:@"%@%@/albums", API_GET_ALBUM, _cityPoi.poiId];
    
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
    NSNumber *imageWidth = [NSNumber numberWithInt:400];
    [params setObject:imageWidth forKey:@"imgWidth"];
    
    [manager GET:requsetUrl parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"%@", responseObject);
        NSInteger code = [[responseObject objectForKey:@"code"] integerValue];
        if (code == 0) {
            NSMutableArray *tempArray = [[NSMutableArray alloc] init];
            for (id imageDic in [[responseObject objectForKey:@"result"] objectForKey:@"album"]) {
                [tempArray addObject:imageDic];
                if (tempArray.count == 99) {
                    break;
                }
            }
            albumCtl.imageList = tempArray;
            
        } else {
            
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (((CityDetailTableViewController *)ctl).isShowing) {
            [SVProgressHUD showHint:HTTP_FAILED_HINT];
        }
    }];
}


@end
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
@property (nonatomic, strong) UIButton *travelMonthBtn;



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
    [albumView setFrame:CGRectMake(15, oy, width-36, albumHeight)];
    albumView.title = _cityPoi.zhName;
    albumView.subTitle = [NSString stringWithFormat:@"~参考游玩时间 %@", _cityPoi.timeCostDesc];
    albumView.images = _cityPoi.images;

    [self addSubview:albumView];
    
    oy += (albumHeight + 20);
    
    _travelMonthBtn = [[UIButton alloc] init];
    _travelMonthBtn.titleLabel.numberOfLines = 0;
    CGSize timeCostLabelSize = [_cityPoi.travelMonth boundingRectWithSize:CGSizeMake(width-20, MAXFLOAT)
                                                                   options:NSStringDrawingUsesLineFragmentOrigin
                                                                attributes:@{
                                                                             NSFontAttributeName : [UIFont systemFontOfSize:11.0],
                                                                             }
                                                                   context:nil].size;
    CGFloat travelMotn = timeCostLabelSize.height + 4;
    _travelMonthBtn.frame = CGRectMake(18, oy, width - 36, travelMotn);
    [_travelMonthBtn setAttributedTitle:[[NSString stringWithFormat:@"最佳游玩时节: %@", _cityPoi.travelMonth] stringByAddLineSpacingAndTextColor:COLOR_TEXT_II] forState:UIControlStateNormal];
    _travelMonthBtn.titleLabel.font = [UIFont systemFontOfSize:11.0];
    _travelMonthBtn.contentVerticalAlignment = UIControlContentVerticalAlignmentTop;
    [_travelMonthBtn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    [self addSubview:_travelMonthBtn];
    
    oy += (_travelMonthBtn.frame.size.height+10);

    _cityDesc = [[UILabel alloc] initWithFrame:CGRectMake(18, oy, width-36, 40)];
    _cityDesc.textColor = COLOR_TEXT_I;
    _cityDesc.numberOfLines = 2;
    _cityDesc.userInteractionEnabled = YES;
    NSMutableParagraphStyle *ps = [[NSMutableParagraphStyle alloc] init];
    ps.lineSpacing = 3.0;
    ps.lineBreakMode = NSLineBreakByTruncatingTail;
    NSDictionary *attribs = @{NSFontAttributeName: [UIFont systemFontOfSize:13], NSParagraphStyleAttributeName:ps};
    NSAttributedString *attrstr = [[NSAttributedString alloc] initWithString:_cityPoi.desc attributes:attribs];
    _cityDesc.attributedText = attrstr;
    [self addSubview:_cityDesc];
    
    oy += 60;
    
    CGSize btnItemSize = CGSizeMake(80, 80);
    CGFloat spaceWidth = ((CGRectGetWidth(self.bounds) - 36 - btnItemSize.width*4)/3);
    _showTipsBtn  = [[UIButton alloc] initWithFrame:CGRectMake(18, oy, btnItemSize.width, btnItemSize.height)];
    [_showTipsBtn setImage:[UIImage imageNamed:@"city_button_guide_default.png"] forState:UIControlStateNormal];
    [_showTipsBtn setImage:[UIImage imageNamed:@"city_button_guide_selected.png"] forState:UIControlStateHighlighted];

    [self addSubview:_showTipsBtn];
    
    _showSpotsBtn = [[UIButton alloc] initWithFrame:CGRectMake(18 + spaceWidth + btnItemSize.width, oy, btnItemSize.width, btnItemSize.height)];
    [_showSpotsBtn setImage:[UIImage imageNamed:@"city_button_spot_default.png"] forState:UIControlStateNormal];
    [_showSpotsBtn setImage:[UIImage imageNamed:@"city_button_spot_selected.png"] forState:UIControlStateHighlighted];
    [self addSubview:_showSpotsBtn];
    
    _showRestaurantsBtn = [[UIButton alloc] initWithFrame:CGRectMake(18 + spaceWidth * 2 + 2*btnItemSize.width, oy, btnItemSize.width, btnItemSize.height)];
    [_showRestaurantsBtn setImage:[UIImage imageNamed:@"city_button_food_default.png"] forState:UIControlStateNormal];
    [_showRestaurantsBtn setImage:[UIImage imageNamed:@"city_button_food_selected.png"] forState:UIControlStateHighlighted];

    [self addSubview:_showRestaurantsBtn];
    
    _showShoppingBtn = [[UIButton alloc] initWithFrame:CGRectMake(18 + spaceWidth * 3 + 3*btnItemSize.width, oy, btnItemSize.width, btnItemSize.height)];
    [_showShoppingBtn setImage:[UIImage imageNamed:@"city_button_shopping_default.png"] forState:UIControlStateNormal];
    [_showShoppingBtn setImage:[UIImage imageNamed:@"city_button_shopping_selected.png"] forState:UIControlStateNormal];

    [self addSubview:_showShoppingBtn];
    

    oy += btnItemSize.height + 12;
    
    CGRect frame1 = self.frame;
    frame1.size.height = oy;
    frame1.size.width = width;
    self.frame = frame1;
    
}

- (void)viewImage:(NSInteger)index
{
    [MobClick event:@"event_city_photoes"];
    MWPhotoBrowser *browser = [[MWPhotoBrowser alloc] init];
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
    
    NSString *requsetUrl = [NSString stringWithFormat:@"%@%@/album", API_GET_ALBUM, _cityPoi.poiId];
    
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
                if (tempArray.count == 99) {
                    break;
                }
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

-(void)dealtap:(UITapGestureRecognizer *)tap
{
    
}

@end
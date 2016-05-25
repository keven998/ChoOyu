//
//  CityDetailViewController.m
//  PeachTravel
//
//  Created by liangpengshuai on 11/4/15.
//  Copyright © 2015 com.aizou.www. All rights reserved.
//

#import "CityDetailViewController.h"
#import "CityDetailHeaderView.h"
#import "GoodsOfCityTableViewCell.h"
#import "GoodsDetailViewController.h"
#import "AddPoiViewController.h"
#import "SuperWebViewController.h"
#import "PoisOfCityViewController.h"
#import "TravelNoteListViewController.h"
#import "PoiManager.h"
#import "GoodsManager.h"
#import "MWPhotoBrowser.h"
#import "GoodsListViewController.h"
#import "GoodsListTableViewCell.h"
#import "CityDescDetailViewController.h"
#import "TripDetailRootViewController.h"
#import "StoreManager.h"
#import "TripPlanSettingViewController.h"
#import "CityRecommendTableViewCell.h"
#import "SellerOfCityTableViewController.h"
#import "StoreDetailViewController.h"
#import "CityListViewController.h"

@interface CityDetailViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIView *moreView;

@property (nonatomic, strong)  CityDetailHeaderView *headerView;
@property (nonatomic, strong)  NSArray<StoreDetailModel *> *sellerList;
@property (nonatomic, strong)  NSArray<NSDictionary *> *descList;
@property (nonatomic, strong)  NSArray *cityList;
@property (nonatomic, strong)  NSArray<GoodsDetailModel *> *dataSource;
@property (nonatomic, strong) CityPoi *poi;
@end

@implementation CityDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    UIBarButtonItem *moreButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon_navi_white_menu"] style:UIBarButtonItemStylePlain target:self action:@selector(moreButtonAction:)];
    self.navigationItem.rightBarButtonItem = moreButton;
    
    self.navigationItem.title = _cityName;
    self.view.backgroundColor = APP_PAGE_COLOR;
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kWindowWidth, kWindowHeight)];
    [_tableView registerNib:[UINib nibWithNibName:@"GoodsListTableViewCell" bundle:nil] forCellReuseIdentifier:@"goodsListCell"];
    [_tableView registerNib:[UINib nibWithNibName:@"CityRecommendTableViewCell" bundle:nil] forCellReuseIdentifier:@"cityRecommendTableViewCell"];

    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.separatorColor = COLOR_LINE;
    _tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _tableView.bounds.size.width, 49)];
    [self.view addSubview:_tableView];
    if (_isCountry) {
        [PoiManager asyncLoadCountryInfo:_cityId completionBlock:^(BOOL isSuccess, CityPoi *cityDetail) {
            if (isSuccess) {
                _poi = cityDetail;
                _descList = _poi.remarks;
                [_tableView reloadData];
                self.navigationItem.title = _poi.zhName;
                
                _headerView = [[CityDetailHeaderView alloc] initWithFrame:CGRectMake(0, 0, kWindowWidth, 174)];
                _headerView.cityPoi = _poi;
                _tableView.tableHeaderView = _headerView;
                _headerView.containerViewController = self;
                UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewCityAlbumAction)];
                tapGesture.numberOfTapsRequired = 1;
                tapGesture.numberOfTouchesRequired = 1;
                [_headerView.headerImageView addGestureRecognizer:tapGesture];
            } else {
            }
            [GoodsManager asyncLoadGoodsOfCity:_cityId startIndex:0 count:3 completionBlock:^(BOOL isSuccess, NSArray *goodsList) {
                if (isSuccess) {
                    self.dataSource = goodsList;
                    [_tableView reloadData];
                } else {
                    self.dataSource = nil;
                }
            }];
            
        }];
        [StoreManager asyncLoadStoreListInCounrty:_cityId completionBlock:^(BOOL isSuccess, NSArray<StoreDetailModel *> *storeList) {
            if (isSuccess) {
                _sellerList = storeList;
                [_tableView reloadData];
            }
        }];
        [PoiManager asyncLoadCitiesOfCountry:_cityId completionBlcok:^(BOOL isSuccess, NSArray *poiList) {
            _cityList = poiList;
            [_tableView reloadData];
        }];

    } else {
        [PoiManager asyncLoadCityInfo:_cityId completionBlock:^(BOOL isSuccess, CityPoi *cityDetail) {
            if (isSuccess) {
                _poi = cityDetail;
                _descList = _poi.remarks;
                [_tableView reloadData];
                self.navigationItem.title = _poi.zhName;
                
                _headerView = [[CityDetailHeaderView alloc] initWithFrame:CGRectMake(0, 0, kWindowWidth, 174)];
                _headerView.cityPoi = _poi;
                _tableView.tableHeaderView = _headerView;
                _headerView.containerViewController = self;
                UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewCityAlbumAction)];
                tapGesture.numberOfTapsRequired = 1;
                tapGesture.numberOfTouchesRequired = 1;
                [_headerView.headerImageView addGestureRecognizer:tapGesture];
                
                [PoiManager asyncLoadCitiesOfCountry:_poi.countryId completionBlcok:^(BOOL isSuccess, NSArray *poiList) {
                    _cityList = poiList;
                    [_tableView reloadData];
                }];
            } else {
            }
            [GoodsManager asyncLoadGoodsOfCity:_cityId startIndex:0 count:3 completionBlock:^(BOOL isSuccess, NSArray *goodsList) {
                if (isSuccess) {
                    self.dataSource = goodsList;
                    [_tableView reloadData];
                } else {
                    self.dataSource = nil;
                }
            }];
            
        }];
        [StoreManager asyncLoadStoreListInCity:_cityId completionBlock:^(BOOL isSuccess, NSArray<StoreDetailModel *> *storeList) {
            if (isSuccess) {
                _sellerList = storeList;
                [_tableView reloadData];
            }
        }];
    }
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear: animated];
    [self dismissMoreButton];
}

- (void)setDataSource:(NSArray<GoodsDetailModel *> *)dataSource
{
    _dataSource = dataSource;
    if (!_dataSource.count) {
        UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kWindowWidth, 300)];
        self.tableView.tableFooterView = footerView;
        
        UIButton *request2Business = [[UIButton alloc] initWithFrame:footerView.bounds];
        [request2Business setImage:[UIImage imageNamed:@"icon_cityDetail_RequestBusiness"] forState:UIControlStateNormal];
        [request2Business addTarget:self action:@selector(request2Business) forControlEvents:UIControlEventTouchUpInside];
        [footerView addSubview:request2Business];
    }
}

- (void)setupToolBar
{
    UIButton *showAllGoodsButton = [[UIButton alloc] initWithFrame:CGRectMake(0, kWindowHeight-49, kWindowWidth, 49)];
    showAllGoodsButton.backgroundColor = [UIColor whiteColor];
    [showAllGoodsButton setTitle:@"查看全部玩乐" forState:UIControlStateNormal];
    [showAllGoodsButton setTitleColor:APP_THEME_COLOR forState:UIControlStateNormal];
    [showAllGoodsButton addTarget:self action:@selector(showAllGoodsAction) forControlEvents:UIControlEventTouchUpInside];
    
    UIView *spaceView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, showAllGoodsButton.bounds.size.width, 0.5)];
    spaceView.backgroundColor = COLOR_LINE;
    [showAllGoodsButton addSubview:spaceView];
    [self.view addSubview:showAllGoodsButton];
}

- (void)moreButtonAction:(UIBarButtonItem *)sender
{

    if (_moreView) {
        [_moreView removeFromSuperview];
        _moreView = nil;
    }
    CGRect frame = self.view.bounds;
    
    _moreView = [[UIView alloc] initWithFrame:CGRectMake(0, 64, frame.size.width, kWindowHeight-64)];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissMoreButton)];
    tap.numberOfTapsRequired = 1;
    tap.numberOfTouchesRequired = 1;
    [_moreView addGestureRecognizer:tap];
    
    _moreView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.7];
    
    UIView *btnBkgView = [[UIView alloc] initWithFrame:CGRectMake(0, -170, frame.size.width, 170)];
    [_moreView addSubview:btnBkgView];
    [UIView animateWithDuration:0.2 animations:^{
        btnBkgView.frame = CGRectMake(0, 0, frame.size.width, 170);
    } completion:^(BOOL finished) {
        
    }];
    
    [self.view addSubview:_moreView];
    
    NSArray *buttonArray = @[
                             @{@"picN":@"icon_cityDetail_guide",@"title":@"指南",@"selector":@"cityGuideAction"},
                             @{@"picN":@"icon_cityDetail_traffic",@"title":@"交通",@"selector":@"cityTrafficAction"},
                             @{@"picN":@"icon_cityDetail_spot",@"title":@"景点",@"selector":@"spotsOfCityAction"},
                             @{@"picN":@"icon_cityDetail_travelNote",@"title":@"游记",@"selector":@"travelNoteOfCityAction"},
                             @{@"picN":@"icon_cityDetail_restaurant",@"title":@"美食",@"selector":@"foodsOfCityAction"},
                             @{@"picN":@"icon_cityDetail_shopping",@"title":@"购物",@"selector":@"shoppingAction"},
                             ];
    
    
    CGFloat itemMargin = 5;
    CGFloat itemWidth = 60;
    CGFloat itemHeight = 70;
    CGFloat itemSpace = (frame.size.width-10-itemWidth*3)/4;
    
    for (int i=0; i<3; i++) {
        TZButton *buttonTop = [[TZButton alloc] initWithFrame:CGRectMake(itemMargin+itemSpace*(i+1)+itemWidth*i, 15, itemWidth, itemHeight)];
        buttonTop.spaceHight = 8;
        [buttonTop setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        buttonTop.titleLabel.font = [UIFont systemFontOfSize:14];
        TZButton *buttonButtom = [[TZButton alloc] initWithFrame:CGRectMake(itemMargin+itemSpace*(i+1)+itemWidth*i, 20+ itemHeight, itemWidth, itemHeight)];
        buttonButtom.spaceHight = 8;
        [buttonButtom setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        buttonButtom.titleLabel.font = [UIFont systemFontOfSize:14];
        NSString *buttomBtnSelector = [[buttonArray objectAtIndex:i+3] objectForKey:@"selector"];
        [buttonButtom addTarget:self action:NSSelectorFromString(buttomBtnSelector) forControlEvents:UIControlEventTouchUpInside];
        NSString *topBtnSelector = [[buttonArray objectAtIndex:i] objectForKey:@"selector"];
        [buttonTop addTarget:self action:NSSelectorFromString(topBtnSelector) forControlEvents:UIControlEventTouchUpInside];
        [buttonTop setImage:[UIImage imageNamed:[[buttonArray objectAtIndex:i] objectForKey:@"picN"]] forState:UIControlStateNormal];
        [buttonTop setTitle:[[buttonArray objectAtIndex:i] objectForKey:@"title"] forState:UIControlStateNormal];
        [buttonButtom setImage:[UIImage imageNamed:[[buttonArray objectAtIndex:i+3] objectForKey:@"picN"]] forState:UIControlStateNormal];
        [buttonButtom setTitle:[[buttonArray objectAtIndex:i+3] objectForKey:@"title"] forState:UIControlStateNormal];
        [btnBkgView addSubview:buttonTop];
        [btnBkgView addSubview:buttonButtom];
    }

}

- (void)dismissMoreButton
{
    if (_moreView) {
        [_moreView removeFromSuperview];
        _moreView = nil;
    }
}

- (void)cityDescAction
{
    CityDescDetailViewController *ctl = [[CityDescDetailViewController alloc] init];
    
    ctl.desc = _poi.desc;
    [self.navigationController pushViewController:ctl animated:YES];
    
}

- (void)cityGuideAction
{
    
    SuperWebViewController *funOfCityWebCtl = [[SuperWebViewController alloc] init];
    funOfCityWebCtl.urlStr = _poi.playGuide;
    funOfCityWebCtl.titleStr = @"旅游指南";;
    [self.navigationController pushViewController:funOfCityWebCtl animated:YES];
}

- (void)cityTrafficAction
{
    SuperWebViewController *funOfCityWebCtl = [[SuperWebViewController alloc] init];
    funOfCityWebCtl.urlStr = _poi.trafficInfoUrl;
    funOfCityWebCtl.titleStr = @"交通指南";
    [self.navigationController pushViewController:funOfCityWebCtl animated:YES];
}

- (void)spotsOfCityAction
{
    AddPoiViewController *addCtl = [[AddPoiViewController alloc] init];
    addCtl.cityId = _poi.poiId;
    addCtl.cityName = self.poi.zhName;
    addCtl.shouldEdit = NO;
    addCtl.poiType = kSpotPoi;
    [self.navigationController pushViewController:addCtl animated:YES];
    
}

- (void)guidesOfCityAction
{
    TripDetailRootViewController *tripDetailCtl = [[TripDetailRootViewController alloc] init];
    tripDetailCtl.canEdit = NO;;
    tripDetailCtl.cityId = _poi.poiId;
    tripDetailCtl.isCheckPlanFromCityDetail = YES;
    
    TripPlanSettingViewController *tpvc = [[TripPlanSettingViewController alloc] init];
    
    REFrostedViewController *frostedViewController = [[REFrostedViewController alloc] initWithContentViewController:tripDetailCtl menuViewController:tpvc];
    tpvc.rootViewController = tripDetailCtl;
    frostedViewController.direction = REFrostedViewControllerDirectionRight;
    frostedViewController.liveBlurBackgroundStyle = REFrostedViewControllerLiveBackgroundStyleLight;
    frostedViewController.liveBlur = YES;
    frostedViewController.limitMenuViewSize = YES;
    [self.navigationController pushViewController:frostedViewController animated:YES];
    
}

- (void)travelNoteOfCityAction
{
    TravelNoteListViewController *travelListCtl = [[TravelNoteListViewController alloc] init];
    travelListCtl.isSearch = NO;
    travelListCtl.cityId = _poi.poiId;
    travelListCtl.cityName = _poi.zhName;
    [self.navigationController pushViewController:travelListCtl animated:YES];
}

- (void)foodsOfCityAction
{
    PoisOfCityViewController *restaurantOfCityCtl = [[PoisOfCityViewController alloc] init];
    restaurantOfCityCtl.shouldEdit = NO;
    restaurantOfCityCtl.cityId = _poi.poiId;
    restaurantOfCityCtl.descDetail = _poi.diningTitles;
    restaurantOfCityCtl.zhName = _poi.zhName;
    restaurantOfCityCtl.poiType = kRestaurantPoi;
    [self.navigationController pushViewController:restaurantOfCityCtl animated:YES];
}

- (void)shoppingAction
{
    PoisOfCityViewController *shoppingOfCityCtl = [[PoisOfCityViewController alloc] init];
    shoppingOfCityCtl.shouldEdit = NO;
    shoppingOfCityCtl.descDetail = _poi.shoppingTitles;
    shoppingOfCityCtl.cityId = _poi.poiId;
    shoppingOfCityCtl.zhName = _poi.zhName;
    shoppingOfCityCtl.poiType = kShoppingPoi;
    [self.navigationController pushViewController:shoppingOfCityCtl animated:YES];
    
}

//申请成为商家
- (void)request2Business
{
    SuperWebViewController *webView = [[SuperWebViewController alloc] init];
    webView.titleStr = @"旅行派各国商户招募计划";
    webView.urlStr = @"http://h5.lvxingpai.com/xiaop.html";
    [self.navigationController pushViewController:webView animated:YES];
}

- (void)showAllGoodsAction
{
    GoodsListViewController *ctl = [[GoodsListViewController alloc] init];
    ctl.cityId = _cityId;
    if (_poi.zhName) {
        ctl.cityName = _poi.zhName;
    } else {
        ctl.cityName = _cityName;
    }
    [self.navigationController pushViewController:ctl animated:YES];
}

- (void)showAllCityAction
{
    CityListViewController *ctl = [[CityListViewController alloc] init];
    ctl.countryId = _poi.countryId;
    ctl.countryName = _poi.countryName;
    [self.navigationController pushViewController:ctl animated:YES];
}
/**
 *  查看城市图集
 */
- (void)viewCityAlbumAction
{
    MWPhotoBrowser *browser = [[MWPhotoBrowser alloc] init];
    browser.titleStr = [NSString stringWithFormat:@"%@图集", _cityName];
    [self loadAlbumDataWithAlbumCtl:browser];
    [browser setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];
    UINavigationController *navc = [[UINavigationController alloc] initWithRootViewController:browser];
    [self presentViewController:navc animated:YES completion:nil];
}
/**
 *  获取城市的图集信息
 */
- (void)loadAlbumDataWithAlbumCtl:(MWPhotoBrowser *)albumCtl
{
    NSString *requsetUrl = [NSString stringWithFormat:@"%@%@/albums", API_GET_ALBUM, _cityId];
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:@0 forKey:@"page"];
    [params setObject:@100 forKey:@"pageSize"];
    NSNumber *imageWidth = [NSNumber numberWithInt:400];
    [params setObject:imageWidth forKey:@"imgWidth"];
    
    [LXPNetworking GET:requsetUrl parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
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
        if (self.isShowing) {
            [SVProgressHUD showHint:HTTP_FAILED_HINT];
        }
    }];
}

- (void)showAllSeller
{
    SellerOfCityTableViewController *ctl = [[SellerOfCityTableViewController alloc] init];
    ctl.dataSource = _sellerList;
    [self.navigationController pushViewController:ctl animated:YES];
}

- (void)checkStoreInfo:(UIButton *)sender
{
    StoreDetailModel *store = [_sellerList objectAtIndex:sender.tag];
    StoreDetailViewController *ctl = [[StoreDetailViewController alloc] init];
    ctl.storeId = store.storeId;
    [self.navigationController pushViewController:ctl animated:YES];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return _descList.count;
    }
    if (section == 1) {
        if (_sellerList.count) {
            return 1;
        }
        return 0;
    }
    if (section == 2) {
        return _dataSource.count;
    }
    if (section == 3) {
        return _cityList.count;
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        return 50;
    }
    if (indexPath.section == 1) {
        return 100;
    }
    if (indexPath.section == 2) {
        return 108;

    }
    if (indexPath.section == 3) {
        return 200;
        
    }

    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        if (_descList.count == 0) {
            return 0.01;
        }
    }
    if (section == 1) {
        if (_sellerList.count == 0) {
            return 0.01;
        }
    }
    if (section == 2) {
        if (_dataSource.count == 0) {
            return 0.01;
        }
    }
    if (section == 3) {
        if (_cityList.count == 0) {
            return 0.01;
        }
    }
    return 40.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if (section == 0) {
        if (_descList.count == 0) {
            return 0.01;
        } else {
            return 10;
        }
    }
    if (section == 1) {
        if (_sellerList.count == 0) {
            return 0.01;
        } else {
            return 10;
        }
    }
    if (section == 2) {
        if (_dataSource.count == 0) {
            return 0.01;
        } else {
            return 10;
        }
    }
    return 10;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        if (_descList.count == 0) {
            return nil;
        }
    }
    if (section == 1) {
        if (_sellerList.count == 0) {
            return nil;
        }
    }
    if (section == 2) {
        if (_dataSource.count == 0) {
            return nil;
        }
    }
    if (section == 3) {
        if (_cityList.count == 0) {
            return nil;
        }
    }
    UIView *sectionHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 40)];
    sectionHeaderView.backgroundColor = [UIColor whiteColor];
    UIView *spaceView = [[UIView alloc] initWithFrame:CGRectMake(0, 39.5, tableView.bounds.size.width, 0.5)];
    spaceView.backgroundColor = APP_THEME_COLOR;
    [sectionHeaderView addSubview:spaceView];
    UIView *topSpaceView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 0.5)];
    topSpaceView.backgroundColor = COLOR_LINE;
    [sectionHeaderView addSubview:topSpaceView];
    
    UIButton *headerBtn = [[UIButton alloc] initWithFrame:CGRectMake(10, 0, 200, 40)];
    //    [headerBtn setImage:[UIImage imageNamed:@"icon_cityDetail_goodsSection"] forState:UIControlStateNormal];
    headerBtn.titleLabel.font = [UIFont systemFontOfSize:16.0];
    [headerBtn setTitleColor:COLOR_TEXT_I forState:UIControlStateNormal];
    headerBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    headerBtn.userInteractionEnabled = NO;
    [sectionHeaderView addSubview:headerBtn];

    if (section == 0) {
        [headerBtn setTitle:@"玩家精选" forState:UIControlStateNormal];
        
    } else if (section == 1) {
        [headerBtn setTitle:@"当地热门旅行服务商" forState:UIControlStateNormal];
        UIButton *goodsCountBtn = [[UIButton alloc] initWithFrame:CGRectMake(sectionHeaderView.bounds.size.width-80, 0, 70, 40)];
        goodsCountBtn.titleLabel.font = [UIFont systemFontOfSize:13.0];
        [goodsCountBtn setTitle:@"查看全部>" forState:UIControlStateNormal];
        [goodsCountBtn setTitleColor:COLOR_TEXT_II forState:UIControlStateNormal];
        [goodsCountBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, 5, 0, 0)];
        [goodsCountBtn setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 5)];
        goodsCountBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        [goodsCountBtn addTarget:self action:@selector(showAllSeller) forControlEvents:UIControlEventTouchUpInside];
        [sectionHeaderView addSubview:goodsCountBtn];

        
    } else if (section == 2) {
        [headerBtn setTitle:@"当地玩乐" forState:UIControlStateNormal];

        UIButton *goodsCountBtn = [[UIButton alloc] initWithFrame:CGRectMake(sectionHeaderView.bounds.size.width-80, 0, 70, 40)];
        goodsCountBtn.titleLabel.font = [UIFont systemFontOfSize:13.0];
        [goodsCountBtn setTitle:@"查看全部>" forState:UIControlStateNormal];
        [goodsCountBtn setTitleColor:COLOR_TEXT_II forState:UIControlStateNormal];
        [goodsCountBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, 5, 0, 0)];
        [goodsCountBtn setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 5)];
        goodsCountBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        [goodsCountBtn addTarget:self action:@selector(showAllGoodsAction) forControlEvents:UIControlEventTouchUpInside];
        
        [sectionHeaderView addSubview:goodsCountBtn];
        
    } else if (section == 3) {
        [headerBtn setTitle:@"热门城市" forState:UIControlStateNormal];
        UIButton *goodsCountBtn = [[UIButton alloc] initWithFrame:CGRectMake(sectionHeaderView.bounds.size.width-80, 0, 70, 40)];
        goodsCountBtn.titleLabel.font = [UIFont systemFontOfSize:13.0];
        [goodsCountBtn setTitle:@"查看全部>" forState:UIControlStateNormal];
        [goodsCountBtn setTitleColor:COLOR_TEXT_II forState:UIControlStateNormal];
        [goodsCountBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, 5, 0, 0)];
        [goodsCountBtn setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 5)];
        goodsCountBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        [goodsCountBtn addTarget:self action:@selector(showAllCityAction) forControlEvents:UIControlEventTouchUpInside];

        [sectionHeaderView addSubview:goodsCountBtn];
    }
    
    return sectionHeaderView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"descCell"];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"descCell"];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            UILabel *contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(12, 0, kWindowWidth-24, 50)];
            contentLabel.textColor = COLOR_TEXT_I;
            contentLabel.font = [UIFont systemFontOfSize:16.0];
            contentLabel.tag = 1001;
            [cell addSubview:contentLabel];
        }
        UILabel *label;
       
        for (UIView *view in cell.subviews) {
            if (view.tag == 1001) {
                label = (UILabel *)view;
                break;
            }
        }
        NSDictionary *dic = [_descList objectAtIndex:indexPath.row];
        label.text = [dic objectForKey:@"title"];

        
        return cell;
        
    } else if (indexPath.section == 1) {
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"sellerCell"];

        CGFloat itemWidth = 60;
        CGFloat space = (kWindowWidth-60*4)/5;
        for (StoreDetailModel *store in _sellerList) {
            NSInteger index = [_sellerList indexOfObject:store];
            if (index == 4) {
                break;
            }
            UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(index*itemWidth+(index+1)*space, 20, itemWidth, itemWidth)];
            button.layer.cornerRadius = 30;
            button.clipsToBounds = YES;
            [button sd_setBackgroundImageWithURL:[NSURL URLWithString:store.business.avatar] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"avatar_default"]];
            button.tag = index;
            [button addTarget:self action:@selector(checkStoreInfo:) forControlEvents:UIControlEventTouchUpInside];
            [cell addSubview:button];
        }
        return cell;
        
    } else if (indexPath.section == 2){
        GoodsListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"goodsListCell" forIndexPath:indexPath];
        cell.goodsDetail = [_dataSource objectAtIndex:indexPath.row];
        return cell;
    } else {
        CityRecommendTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cityRecommendTableViewCell" forIndexPath:indexPath];
        cell.cityPoi = [_cityList objectAtIndex:indexPath.row];
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 0) {
        NSDictionary *dic = [_descList objectAtIndex:indexPath.row];

        SuperWebViewController *ctl = [[SuperWebViewController alloc] init];
        ctl.urlStr = [dic objectForKey:@"url"];
        ctl.titleStr = [dic objectForKey:@"title"];
        [self.navigationController pushViewController:ctl animated:YES];

    } else if (indexPath.section == 2) {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        GoodsDetailViewController *ctl = [[GoodsDetailViewController alloc] init];
        ctl.hidesBottomBarWhenPushed = YES;
        ctl.goodsId = [_dataSource objectAtIndex:indexPath.row].goodsId;
        [self.navigationController pushViewController:ctl animated:YES];
        
    } else if (indexPath.section == 3) {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        CityDetailViewController *ctl = [[CityDetailViewController alloc] init];
        ctl.cityId = ((CityPoi *)[_cityList objectAtIndex:indexPath.row]).poiId;
        [self.navigationController pushViewController:ctl animated:YES];

        
    }
    
}

@end

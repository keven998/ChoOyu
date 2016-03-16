//
//  CommonPoiDetailViewController.m
//  PeachTravel
//
//  Created by liangpengshuai on 11/22/14.
//  Copyright (c) 2014 com.aizou.www. All rights reserved.
//

#import "CommonPoiDetailViewController.h"
#import "AccountManager.h"
#import "UIImage+BoxBlur.h"
#import "SpotDetailView.h"
#import "SpotPoi.h"
#import "AccountManager.h"
#import "SuperWebViewController.h"
#import "SpotDetailCell.h"

#import "CommentTableViewCell.h"
#import "UIImage+BoxBlur.h"
#import "PricePoiDetailController.h"
#import "CityDescDetailViewController.h"
#import "UIActionSheet+Blocks.h"
#import "CommonPoiDetailTableViewCell.h"

@interface CommonPoiDetailViewController () <UITableViewDataSource, UITableViewDelegate, UIActionSheetDelegate>
@property (nonatomic, strong) UIImageView *backGroundImageView;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) SpotDetailView *spotDetailView;
@property (nonatomic, strong) NSMutableArray *dataSource;


@end

@implementation CommonPoiDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UIButton *talkBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 48, 44)];
    [talkBtn setImage:[UIImage imageNamed:@"icon_share_white.png"] forState:UIControlStateNormal];
    talkBtn.imageEdgeInsets = UIEdgeInsetsMake(2, 0, 0, 0);
    [talkBtn addTarget:self action:@selector(send2Frend) forControlEvents:UIControlEventTouchUpInside];
    talkBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:talkBtn];
    
    _dataSource = [[NSMutableArray alloc] init];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (UITableView *)tableView
{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 64, self.view.bounds.size.width, self.view.bounds.size.height-64) style:UITableViewStyleGrouped];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.backgroundColor = APP_PAGE_COLOR;
        _tableView.separatorColor = COLOR_LINE;
        _tableView.tableHeaderView = self.spotDetailView;
        [self.tableView registerNib:[UINib nibWithNibName:@"CommonPoiDetailTableViewCell" bundle:nil] forCellReuseIdentifier:@"commonPoiDetailTableViewCell"];
        
        [self.tableView registerNib:[UINib nibWithNibName:@"CommentTableViewCell" bundle:nil] forCellReuseIdentifier:@"commentCell"];
    }
    return _tableView;
}

- (void)setPoi:(SuperPoi *)poi
{
    [super setPoi:poi];
    [self setupDataSource];
}

- (void)setupDataSource
{
    if (![self.poi.desc isBlankString]) {
        NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
        [dic setObject:@"简介" forKey:@"title"];
        [dic safeSetObject:self.poi.desc forKey:@"content"];
        [_dataSource addObject:dic];
    }
    if (self.poi.poiType == kSpotPoi) {
        SpotPoi *spot = (SpotPoi *)self.poi;
        if ((![spot.trafficInfo isBlankString] && spot.trafficInfo) || self.poi.address.length) {
            NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
            [dic setObject:@"交通" forKey:@"title"];
            
            NSMutableString *content = [[NSMutableString alloc] init];
            [content appendString:[NSString stringWithFormat:@"地址:  %@\n", self.poi.address]];
            
            if (![spot.trafficInfo isBlankString] && spot.trafficInfo) {
                [content appendString:[NSString stringWithFormat:@"乘车方案:  %@", spot.trafficInfo]];
            }
            [dic safeSetObject:content forKey:@"content"];
            [_dataSource addObject:dic];
        }
        if (![spot.guideInfo isBlankString] && spot.guideInfo) {
            NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
            [dic setObject:@"攻略" forKey:@"title"];
            [dic safeSetObject:spot.guideInfo forKey:@"content"];
            [_dataSource addObject:dic];
        }
        if (![spot.tipsInfo isBlankString] && spot.tipsInfo) {
            NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
            [dic setObject:@"贴士" forKey:@"title"];
            [dic safeSetObject:spot.tipsInfo forKey:@"content"];
            [_dataSource addObject:dic];
        }
    }
    if ([self.poi.comments count]) {
        [_dataSource addObject:self.poi.comments];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if ([[_dataSource objectAtIndex:section] isKindOfClass:[NSArray class]]) {
        return 10 + 40;
    }
    return 10.0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if ([[_dataSource objectAtIndex:section] isKindOfClass:[NSArray class]]) {
        UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kWindowWidth, 50)];
        
        UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 10, kWindowWidth, 40)];
        bgView.backgroundColor = [UIColor whiteColor];
        [headerView addSubview:bgView];
        
        UIView *spaceView = [[UIView alloc] initWithFrame:CGRectMake(0, 10, kWindowWidth, 0.5)];
        spaceView.backgroundColor = COLOR_LINE;
        [headerView addSubview:spaceView];
        
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(12, 10, 100, 40)];
        titleLabel.textColor = COLOR_TEXT_I;
        titleLabel.font = [UIFont systemFontOfSize:15.0];
        titleLabel.text = @"点评";
        [headerView addSubview:titleLabel];
        
        UIButton *showMoreCommentBtn = [[UIButton alloc] initWithFrame:CGRectMake(kWindowWidth-100, 10, 88, 40)];
        [showMoreCommentBtn setImage:[UIImage imageNamed:@"icon_poiDetail_moreContent"] forState:UIControlStateNormal];
        [showMoreCommentBtn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
        [showMoreCommentBtn addTarget:self action:@selector(showMoreComments) forControlEvents:UIControlEventTouchUpInside];
        [headerView addSubview:showMoreCommentBtn];
        
        UIView *spaceButtomView = [[UIView alloc] initWithFrame:CGRectMake(0, 49.5, kWindowWidth, 0.5)];
        spaceButtomView.backgroundColor = COLOR_LINE;
        [headerView addSubview:spaceButtomView];
        
        return headerView;
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return CGFLOAT_MIN;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.dataSource.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([[_dataSource objectAtIndex:section] isKindOfClass:[NSArray class]]) {
        return [[_dataSource objectAtIndex:section] count];
    }
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    id object = [_dataSource objectAtIndex:indexPath.section];
    if ([object isKindOfClass:[NSDictionary class]]) {
        return [CommonPoiDetailTableViewCell heightWithContent:[object objectForKey:@"content"]];
    } else if ([object isKindOfClass:[NSArray class]]){
        CommentDetail *comment = [object objectAtIndex:indexPath.row];
        return [CommentTableViewCell heightForCommentCellWithComment:comment.commentDetails];
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    id object = [_dataSource objectAtIndex:indexPath.section];
    if ([object isKindOfClass:[NSDictionary class]]) {
        CommonPoiDetailTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"commonPoiDetailTableViewCell" forIndexPath:indexPath];
        cell.titleLabel.text = [object objectForKey:@"title"];
        
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.lineSpacing = 5.0;
        
        NSDictionary *attribs = @{NSFontAttributeName: [UIFont systemFontOfSize:13],
                                  NSParagraphStyleAttributeName:paragraphStyle,
                                  };
        NSAttributedString *attrstr = [[NSAttributedString alloc] initWithString:[object objectForKey:@"content"] attributes:attribs];
        cell.contentLabel.attributedText = attrstr;
        
        if ([[object objectForKey:@"title"] isEqualToString:@"简介"]) {
            [cell.showMoreButton addTarget:self action:@selector(showPoidetail:) forControlEvents:UIControlEventTouchUpInside];
            cell.addressButton.hidden = YES;
            
        } else if ([[object objectForKey:@"title"] isEqualToString:@"交通"]) {
            [cell.showMoreButton addTarget:self action:@selector(trafficGuide:) forControlEvents:UIControlEventTouchUpInside];
            [cell.addressButton addTarget:self action:@selector(jumpToMapview:) forControlEvents:UIControlEventTouchUpInside];
            cell.addressButton.hidden = NO;
            
        } else if ([[object objectForKey:@"title"] isEqualToString:@"攻略"]) {
            [cell.showMoreButton addTarget:self action:@selector(travelGuide:) forControlEvents:UIControlEventTouchUpInside];
            cell.addressButton.hidden = YES;
            
        } else if ([[object objectForKey:@"title"] isEqualToString:@"贴士"]) {
            [cell.showMoreButton addTarget:self action:@selector(kengdie:) forControlEvents:UIControlEventTouchUpInside];
            cell.addressButton.hidden = YES;
        }

        return cell;
        
    } else {
        CommentDetail *comment = [object objectAtIndex:indexPath.row];
        CommentTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"commentCell" forIndexPath:indexPath];
        cell.commentDetail = comment;
        return cell;
    }
}

/**
 *  游玩指南
 *
 *  @param sender
 */
- (IBAction)travelGuide:(id)sender
{
    SuperWebViewController *webCtl = [[SuperWebViewController alloc] init];
    webCtl.titleStr = @"景点体验";
    webCtl.urlStr = ((SpotPoi *)self.poi).guideUrl;
    [self.navigationController pushViewController:webCtl animated:YES];
}

/**
 *  坑爹攻略
 *
 *  @param sender
 */
- (IBAction)kengdie:(id)sender
{
    SuperWebViewController *webCtl = [[SuperWebViewController alloc] init];
    webCtl.titleStr = @"游玩小贴士";
    webCtl.urlStr = ((SpotPoi *)self.poi).tipsUrl;
    [self.navigationController pushViewController:webCtl animated:YES];
}

/**
 *  交通指南
 *
 *  @param sender
 */
- (IBAction)trafficGuide:(id)sender
{
    SuperWebViewController *webCtl = [[SuperWebViewController alloc] init];
    webCtl.titleStr = @"景点交通";
    webCtl.urlStr = ((SpotPoi *)self.poi).trafficInfoUrl;
    [self.navigationController pushViewController:webCtl animated:YES];
}

- (void)updateView
{
    self.navigationItem.title = self.poi.zhName;
    [self.view addSubview:self.tableView];
    _spotDetailView = [[SpotDetailView alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), 0)];
    _spotDetailView.spot = self.poi;
    self.tableView.tableHeaderView = _spotDetailView;
    [_spotDetailView.poiSummary addTarget:self action:@selector(showPoiDesc) forControlEvents:UIControlEventTouchUpInside];
}

- (void)send2Frend
{
    [self shareToTalk];
}

- (void)jumpToMap
{
    [ConvertMethods jumpAppleMapAppWithPoiName:self.poi.zhName lat:self.poi.lat lng:self.poi.lng];
}

//拨打电话
- (void)makePhone
{
    if (self.poi.telephone && ![self.poi.telephone isBlankString]) {
        
        // 拨打电话
        [UIActionSheet showInView:self.view
                        withTitle:@"确认拨打电话?"
                cancelButtonTitle:@"取消"
           destructiveButtonTitle:nil
                otherButtonTitles:self.poi.tel
                         tapBlock:^(UIActionSheet *actionSheet, NSInteger buttonIndex) {
                             if (buttonIndex == 0) {
                                  NSLog(@"Chose %@", [actionSheet buttonTitleAtIndex:buttonIndex]);
                                  NSString *telStr = [NSString stringWithFormat:@"tel://%@", self.poi.tel[buttonIndex]];
                                  [[UIApplication sharedApplication] openURL:[NSURL URLWithString:telStr]];
                                 
                             }
                           
                         }];
        
    }
    
}

//子类重写
- (void)showPoiDesc
{
    CityDescDetailViewController *cddVC = [[CityDescDetailViewController alloc]init];
    cddVC.desc = self.poi.desc;
    cddVC.title = self.poi.zhName;
    [self.navigationController pushViewController:cddVC animated:YES];
}

- (void)showMoreComments
{
    SuperWebViewController *webCtl = [[SuperWebViewController alloc] init];
    webCtl.urlStr = self.poi.moreCommentsUrl;
    webCtl.titleStr = [NSString stringWithFormat:@"\"%@\" 点评", self.poi.zhName];
    [self.navigationController pushViewController:webCtl animated:YES];
}

#pragma mark - Private Methods
/**
 *  进入详细介绍的 html 界面，由子类实现
 *
 *  @param sender
 */
- (void)showPoidetail:(id)sender
{
    SuperWebViewController *webCtl = [[SuperWebViewController alloc] init];
    webCtl.titleStr = self.poi.zhName;
    
    NSLog(@"%@",self.poi.descUrl);
    
    if (self.poiType == kSpotPoi) {
        webCtl.urlStr = self.poi.descUrl;
        
    } else {
        if (self.poi.descUrl) {
            webCtl.urlStr = self.poi.descUrl;
         
        }else {
            if (![self.poi.desc isEqualToString:@""]) {
                PricePoiDetailController * pricePoi = [[PricePoiDetailController alloc] init];
                pricePoi.desc = self.poi.desc;
                pricePoi.view.backgroundColor = [UIColor whiteColor];
                [self.navigationController pushViewController:pricePoi animated:YES];
            }
            return;
        }
    }
    
    [self.navigationController pushViewController:webCtl animated:YES];
    
}

- (void)loadDataWithUrl:(NSString *)url
{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    NSNumber *imageWidth = [NSNumber numberWithInt:(kWindowWidth-22)*2];
    [params setObject:imageWidth forKey:@"imgWidth"];
    
    TZProgressHUD *hud = [[TZProgressHUD alloc] init];
    __weak typeof(self)weakSelf = self;
    [hud showHUDInViewController:weakSelf content:64];
    
    [LXPNetworking GET:url parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [hud hideTZHUD];
        NSLog(@"%@",responseObject);
        NSInteger result = [[responseObject objectForKey:@"code"] integerValue];
        if (result == 0) {
            self.poi = [PoiFactory poiWithPoiType:_poiType andJson:[responseObject objectForKey:@"result"]];
            [self updateView];
        } else {
            [self showHint:@"无法获取数据"];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [hud hideTZHUD];
        [self showHint:HTTP_FAILED_HINT];
    }];
}


/**
 *  进入地图导航
 *
 *  @param sender
 */
- (IBAction)jumpToMapview:(id)sender
{
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"其他软件导航"
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
    [sheet showInView:self.view];
}

- (void)setChatMessageModel:(TaoziChatMessageBaseViewController *)taoziMessageCtl
{
    taoziMessageCtl.messageId = self.poi.poiId;
    taoziMessageCtl.messageImage = ((TaoziImage *)[self.poi.images firstObject]).imageUrl;
    taoziMessageCtl.messageDesc = self.poi.desc;
    taoziMessageCtl.messageName = self.poi.zhName;
    taoziMessageCtl.messageRating = self.poi.rating;
    if (_poiType == kHotelPoi) {
        taoziMessageCtl.messageType = IMMessageTypeHotelMessageType;
        taoziMessageCtl.messagePrice = ((HotelPoi *)self.poi).priceDesc;
        taoziMessageCtl.messageRating = self.poi.rating;
        self.title = @"酒店详情";
        
    } else if (_poiType == kRestaurantPoi) {
        taoziMessageCtl.messageType = IMMessageTypeRestaurantMessageType;
        taoziMessageCtl.messageRating = self.poi.rating;
        taoziMessageCtl.messagePrice = ((RestaurantPoi *)self.poi).priceDesc;
        self.title = @"美食详情";
        
    } else if (_poiType == kShoppingPoi) {
        taoziMessageCtl.messageType = IMMessageTypeShoppingMessageType;
        taoziMessageCtl.messageRating = self.poi.rating;
        self.title = @"购物详情";
    }
    
    taoziMessageCtl.messageAddress = self.poi.address;
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == actionSheet.cancelButtonIndex) {
        
        return;
        
    }
    if (actionSheet.tag != kASShare) {
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
                    }
                        break;
                        
                    default:
                        break;
                }
                break;
                
            default:
                break;
        }
        
    } else {
        
        [self shareToTalk];
    }
}

@end

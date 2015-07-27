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
#import "SpecialPoiCell.h"
#import "CommentTableViewCell.h"
#import "UIImage+BoxBlur.h"
#import "PricePoiDetailController.h"
#import "CityDescDetailViewController.h"

@interface CommonPoiDetailViewController () <UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong) UIImageView *backGroundImageView;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) SpotDetailView *spotDetailView;

@end

@implementation CommonPoiDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    UIButton *talkBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 48, 44)];
    [talkBtn setImage:[UIImage imageNamed:@"navigationbar_chat_default.png"] forState:UIControlStateNormal];
    [talkBtn setImage:[UIImage imageNamed:@"navigationbar_chat_hilighted.png"] forState:UIControlStateHighlighted];
    talkBtn.imageEdgeInsets = UIEdgeInsetsMake(2, 0, 0, 0);
    [talkBtn addTarget:self action:@selector(shareToTalk) forControlEvents:UIControlEventTouchUpInside];
    talkBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:talkBtn];
    
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
        _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.backgroundColor = APP_PAGE_COLOR;
        _tableView.separatorColor = COLOR_LINE;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _tableView.tableHeaderView = self.spotDetailView;
        [self.tableView registerNib:[UINib nibWithNibName:@"SpotDetailCell" bundle:nil] forCellReuseIdentifier:@"detailCell"];
        [self.tableView registerNib:[UINib nibWithNibName:@"SpecialPoiCell" bundle:nil] forCellReuseIdentifier:@"specialCell"];
        [self.tableView registerNib:[UINib nibWithNibName:@"CommentTableViewCell" bundle:nil] forCellReuseIdentifier:@"commentCell"];
    }
    return _tableView;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    NSLog(@"%@",self.poi.style);
    return self.poi.comments.count + 3;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row < 3) {
        return 67 * SCREEN_HEIGHT/736;
    } else {
        CommentDetail *commonDetail = [self.poi.comments objectAtIndex:indexPath.row-3];
        return [CommentTableViewCell heightForCommentCellWithComment:commonDetail.commentDetails];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row < 3) {
        SpotDetailCell *cell = [tableView dequeueReusableCellWithIdentifier:@"detailCell" forIndexPath:indexPath];
        cell.accessoryType = UITableViewCellAccessoryNone;
        if (indexPath.row == 0) {
            cell.categoryLabel.text = @"地址";
            cell.infomationLabel.text = self.poi.address;
            cell.image.image = [UIImage imageNamed:@"poi_icon_add"];
        } else if(indexPath.row == 1) {
            cell.categoryLabel.text = @"费用";
            cell.infomationLabel.text = self.poi.priceDesc;
            cell.image.image = [UIImage imageNamed:@"poi_icon_ticket_default"];
        }  else {
            cell.categoryLabel.text = @"电话";
            cell.infomationLabel.text = ((SpotPoi *)self.poi).telephone;
            cell.image.image = [UIImage imageNamed:@"poi_icon_phone"];
        }
        return cell;
        
    } else {
        CommentTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"commentCell" forIndexPath:indexPath];
        cell.commentDetail = [self.poi.comments objectAtIndex:indexPath.row-3];
        return cell;
    }
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.row < 3) {
        if (indexPath.row == 0) {
            [self jumpToMap];
        } else if (indexPath.row == 1) {
            [self showPoidetail:nil];
        } else if (indexPath.row == 2) {
            [self makePhone];
        }
    }
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

- (void)jumpToMap
{
    [ConvertMethods jumpAppleMapAppWithPoiName:self.poi.zhName lat:self.poi.lat lng:self.poi.lng];
}

//拨打电话
- (void)makePhone
{
    if (self.poi.telephone && ![self.poi.telephone isBlankString]) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"确认拨打电话？" message:self.poi.telephone delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        [alertView showAlertViewWithBlock:^(NSInteger buttonIndex) {
            if (buttonIndex == 1) {
                NSString *telStr = [NSString stringWithFormat:@"tel://%@", self.poi.telephone];
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:telStr]];
            }
        }];
    }
}

//子类重写
- (void)showPoiDesc
{
    CityDescDetailViewController *cddVC = [[CityDescDetailViewController alloc]init];
    cddVC.des = self.poi.desc;
    cddVC.title = self.poi.zhName;
    [self.navigationController pushViewController:cddVC animated:YES];
}

#pragma mark - Private Methods

/**
 *  进入详细介绍的 html 界面，由子类实现
 *
 *  @param sender
 */
- (void)showPoidetail:(id)sender
{
    NSLog(@"%@",self.poi);
    
    SpotPoi * poi = (SpotPoi *)self.poi;
    
    [MobClick event:@"event_spot_information"];
    SuperWebViewController *webCtl = [[SuperWebViewController alloc] init];
    webCtl.titleStr = self.poi.zhName;
    
    NSLog(@"%@",self.poi.descUrl);
    
    if (self.poiType == kSpotPoi) {
        if (poi.bookUrl.length != 0) {
            webCtl.urlStr = poi.bookUrl;
        }
    }else{
        if (self.poi.descUrl) {
            webCtl.urlStr = self.poi.descUrl;
        }else{
            webCtl.urlStr = @"暂无此数据";
            PricePoiDetailController * pricePoi = [[PricePoiDetailController alloc] init];
            pricePoi.desc = self.poi.priceDesc;
            pricePoi.view.backgroundColor = [UIColor whiteColor];
            [self.navigationController pushViewController:pricePoi animated:YES];
            return;
        }
    }
    
    webCtl.hideToolBar = YES;
    [self.navigationController pushViewController:webCtl animated:YES];
    
}

- (UIImage *)screenShotWithView:(UIView *)view
{
    UIGraphicsBeginImageContext(view.bounds.size);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    NSData *imageData = UIImageJPEGRepresentation(image, 0.8);
    image = [UIImage imageWithData:imageData];
    return image;
}

- (void)loadDataWithUrl:(NSString *)url
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    AppUtils *utils = [[AppUtils alloc] init];
    [manager.requestSerializer setValue:utils.appVersion forHTTPHeaderField:@"Version"];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"iOS %@",utils.systemVersion] forHTTPHeaderField:@"Platform"];
    AccountManager *accountManager = [AccountManager shareAccountManager];
    if ([accountManager isLogin]) {
        [manager.requestSerializer setValue:[NSString stringWithFormat:@"%ld", (long)accountManager.account.userId] forHTTPHeaderField:@"UserId"];
    }
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    NSNumber *imageWidth = [NSNumber numberWithInt:(kWindowWidth-22)*2];
    [params setObject:imageWidth forKey:@"imgWidth"];
    
    TZProgressHUD *hud = [[TZProgressHUD alloc] init];
    __weak typeof(self)weakSelf = self;
    [hud showHUDInViewController:weakSelf content:64];
    
    [manager GET:url parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
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

@end

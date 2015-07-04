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


@interface CommonPoiDetailViewController () <UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong) SpotDetailView *spotDetailView;
@property (nonatomic, strong) UIImageView *backGroundImageView;
@property (nonatomic, strong) UITableView *tableView;
@end

@implementation CommonPoiDetailViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    UIButton *talkBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 48, 44)];
    [talkBtn setImage:[UIImage imageNamed:@"ic_home_normal"] forState:UIControlStateNormal];
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
    
    return self.poi.comments.count + 4;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row < 4) {
        return 67 * SCREEN_HEIGHT/736;
    } else {
        CommentDetail *commonDetail = [self.poi.comments objectAtIndex:indexPath.row-4];
        return [CommentTableViewCell heightForCommentCellWithComment:commonDetail.commentDetails];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row < 4) {
        SpotDetailCell *cell = [tableView dequeueReusableCellWithIdentifier:@"detailCell" forIndexPath:indexPath];
        cell.accessoryType = UITableViewCellAccessoryNone;
        if (indexPath.row == 0) {
            cell.categoryLabel.text = @"地址";
            cell.infomationLabel.text = self.poi.address;
            cell.image.image = [UIImage imageNamed:@"poi_icon_add"];
        } else if (indexPath.row == 1) {
            cell.categoryLabel.text = @"时间";
            cell.infomationLabel.text = self.poi.openTime;
            cell.image.image = [UIImage imageNamed:@"icon_arrow"];
        } else if(indexPath.row == 2) {
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
        cell.commentDetail = [self.poi.comments objectAtIndex:indexPath.row-4];
        return cell;
    }
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.row < 4) {
        if (indexPath.row == 0) {
            [self jumpToMap];
        } else if (indexPath.row == 1) {
            [self showPoidetail:nil];
        } else if (indexPath.row == 2) {
            [self showPoidetail:nil];
        } else {
            [self showPoidetail:nil];
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
}

- (void)jumpToMap
{
    [ConvertMethods jumpAppleMapAppWithPoiName:self.poi.zhName lat:self.poi.lat lng:self.poi.lng];
}

- (void)dismissCtlWithHint:(NSString *)hint {
    [SVProgressHUD showHint:hint];
    self.navigationController.navigationBar.hidden = NO;
    [UIView animateWithDuration:0.0 animations:^{
        self.view.alpha = 0;
    } completion:^(BOOL finished) {
        [self willMoveToParentViewController:nil];
        [self.navigationController popViewControllerAnimated:YES];
    }];
}

#pragma mark - Private Methods

/**
 *  进入详细介绍的 html 界面，由子类实现
 *
 *  @param sender
 */
- (void)showPoidetail:(id)sender
{
    [MobClick event:@"event_spot_information"];
    SuperWebViewController *webCtl = [[SuperWebViewController alloc] init];
    webCtl.titleStr = self.poi.zhName;
    webCtl.urlStr = self.poi.descUrl;
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

- (void) loadDataWithUrl:(NSString *)url
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
        NSInteger result = [[responseObject objectForKey:@"code"] integerValue];
        if (result == 0) {
            self.poi = [PoiFactory poiWithPoiType:_poiType andJson:[responseObject objectForKey:@"result"]];
            [self updateView];
        } else {
            [self dismissCtlWithHint:@"无法获取数据"];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [hud hideTZHUD];
        [self dismissCtlWithHint:@"呃～好像没找到网络"];
    }];
}


- (void)setChatMessageModel:(TaoziChatMessageBaseViewController *)taoziMessageCtl
{
    taoziMessageCtl.messageId = self.poi.poiId;
    taoziMessageCtl.messageImage = ((TaoziImage *)[self.poi.images firstObject]).imageUrl;
    taoziMessageCtl.messageDesc = self.poi.desc;
    taoziMessageCtl.messageName = self.poi.zhName;
    taoziMessageCtl.messageRating = self.poi.rating;
    taoziMessageCtl.chatType = IMMessageTypeHotelMessageType;
    if (_poiType == kHotelPoi) {
        taoziMessageCtl.chatType = IMMessageTypeHotelMessageType;
        taoziMessageCtl.messagePrice = ((HotelPoi *)self.poi).priceDesc;
        taoziMessageCtl.messageRating = self.poi.rating;
        self.title = @"酒店详情";
    } else if (_poiType == kRestaurantPoi) {
        taoziMessageCtl.chatType = IMMessageTypeHotelMessageType;
        taoziMessageCtl.messageRating = self.poi.rating;
        taoziMessageCtl.messagePrice = ((RestaurantPoi *)self.poi).priceDesc;
        self.title = @"美食详情";
    } else if (_poiType == kShoppingPoi) {
        taoziMessageCtl.chatType = IMMessageTypeShoppingMessageType;
        taoziMessageCtl.messageRating = self.poi.rating;
        self.title = @"购物详情";
    }
    
    taoziMessageCtl.messageAddress = self.poi.address;
}

@end

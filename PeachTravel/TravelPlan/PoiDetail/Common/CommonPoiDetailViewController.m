//
//  CommonPoiDetailViewController.m
//  PeachTravel
//
//  Created by liangpengshuai on 11/22/14.
//  Copyright (c) 2014 com.aizou.www. All rights reserved.
//

#import "CommonPoiDetailViewController.h"
#import "CommonPoiDetailView.h"
#import "AccountManager.h"
#import "UIImage+BoxBlur.h"

@interface CommonPoiDetailViewController ()
@property (nonatomic, strong) PoiSummary *commonPoi;
@property (nonatomic, strong) UIImageView *backGroundImageView;

@end

@implementation CommonPoiDetailViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    _backGroundImageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
    _backGroundImageView.image = [[self screenShotWithView:self.navigationController.view] drn_boxblurImageWithBlur:0.17];
    _backGroundImageView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.3];
    UIView *view = [[UIView alloc] initWithFrame:self.view.bounds];
    view.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
    [self.view addSubview:_backGroundImageView];
    [self.view addSubview:view];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissCtl)];
    tap.numberOfTapsRequired = 1;
    tap.numberOfTouchesRequired = 1;
    [view addGestureRecognizer:tap];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.hidden = YES;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.navigationController.navigationBar.hidden = NO;
}

- (void)updateView
{
    self.navigationItem.title = _commonPoi.zhName;
    CommonPoiDetailView *commonPoiDetailView = [[CommonPoiDetailView alloc] initWithFrame:CGRectMake(15, 30, self.view.bounds.size.width-30, self.view.bounds.size.height-50)];
    commonPoiDetailView.rootCtl = self;
    commonPoiDetailView.poiType = _poiType;
    commonPoiDetailView.poi = self.commonPoi;
    commonPoiDetailView.layer.cornerRadius = 4.0;
    [self.view addSubview:commonPoiDetailView];

    commonPoiDetailView.transform = CGAffineTransformMakeScale(0.01, 0.01);
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        commonPoiDetailView.transform = CGAffineTransformMakeScale(1, 1);

    } completion:^(BOOL finished) {
        commonPoiDetailView.transform = CGAffineTransformIdentity;
        [commonPoiDetailView.closeBtn addTarget:self action:@selector(dismissCtl) forControlEvents:UIControlEventTouchUpInside];
        [commonPoiDetailView.shareBtn addTarget:self action:@selector(chat:) forControlEvents:UIControlEventTouchUpInside];
    }];
}

- (void)dismissCtl
{
    [SVProgressHUD dismiss];
    self.navigationController.navigationBar.hidden = NO;
    [self willMoveToParentViewController:nil];
    [self.view removeFromSuperview];
    [self removeFromParentViewController];
}

- (void)dismissCtlWithHint:(NSString *)hint {
    [SVProgressHUD showHint:hint];
    self.navigationController.navigationBar.hidden = NO;
    [UIView animateWithDuration:0.0 animations:^{
        self.view.alpha = 0;
    } completion:^(BOOL finished) {
        [self willMoveToParentViewController:nil];
        [self.view removeFromSuperview];
        [self removeFromParentViewController];
    }];
}

- (void)dealloc
{
    NSLog(@"RestaurantDetialViewController dealloc");
}

#pragma mark - Private Methods

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

- (void) loadData
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    AppUtils *utils = [[AppUtils alloc] init];
    [manager.requestSerializer setValue:utils.appVersion forHTTPHeaderField:@"Version"];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"iOS %@",utils.systemVersion] forHTTPHeaderField:@"Platform"];
    AccountManager *accountManager = [AccountManager shareAccountManager];
    if ([accountManager isLogin]) {
        [manager.requestSerializer setValue:[NSString stringWithFormat:@"%@", accountManager.account.userId] forHTTPHeaderField:@"UserId"];
    }
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    NSNumber *imageWidth = [NSNumber numberWithInt:(kWindowWidth-22)*2];
    [params setObject:imageWidth forKey:@"imgWidth"];
    
    TZProgressHUD *hud = [[TZProgressHUD alloc] init];
    __weak typeof(self)weakSelf = self;
    [hud showHUDInViewController:weakSelf];
    
    NSString *typeUrl;
    if (_poiType == kRestaurantPoi) {
        typeUrl = API_GET_RESTAURANT_DETAIL;
    }
    if (_poiType == kShoppingPoi) {
        typeUrl = API_GET_SHOPPING_DETAIL;
    }
    if (_poiType == kHotelPoi) {
        typeUrl = API_GET_HOTEL_DETAIL;
    }
    
    NSString *url = [NSString stringWithFormat:@"%@%@", typeUrl, _poiId];
    
    [manager GET:url parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [hud hideTZHUD];
        NSInteger result = [[responseObject objectForKey:@"code"] integerValue];
        NSLog(@"/***获取poi详情数据****\n%@", responseObject);
        if (result == 0) {
            _commonPoi = [[PoiSummary alloc] initWithJson:[responseObject objectForKey:@"result"]];
            [self updateView];
        } else {
            [self dismissCtlWithHint:@"无法获取数据"];
        }
          
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [hud hideTZHUD];
        [self dismissCtlWithHint:@"呃～好像没找到网络"];
    }];
}

- (void) loadDataWithUrl:(NSString *)url
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    AppUtils *utils = [[AppUtils alloc] init];
    [manager.requestSerializer setValue:utils.appVersion forHTTPHeaderField:@"Version"];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"iOS %@",utils.systemVersion] forHTTPHeaderField:@"Platform"];
    AccountManager *accountManager = [AccountManager shareAccountManager];
    if ([accountManager isLogin]) {
        [manager.requestSerializer setValue:[NSString stringWithFormat:@"%@", accountManager.account.userId] forHTTPHeaderField:@"UserId"];
    }
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    NSNumber *imageWidth = [NSNumber numberWithInt:(kWindowWidth-22)*2];
    [params setObject:imageWidth forKey:@"imgWidth"];
    
    TZProgressHUD *hud = [[TZProgressHUD alloc] init];
    __weak typeof(self)weakSelf = self;
    [hud showHUDInViewController:weakSelf];
    
    [manager GET:url parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [hud hideTZHUD];
        NSInteger result = [[responseObject objectForKey:@"code"] integerValue];
        NSLog(@"/***获取poi详情数据****\n%@", responseObject);
        if (result == 0) {
            _commonPoi = [[PoiSummary alloc] initWithJson:[responseObject objectForKey:@"result"]];
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
    taoziMessageCtl.messageId = _commonPoi.poiId;
    taoziMessageCtl.messageImage = ((TaoziImage *)[_commonPoi.images firstObject]).imageUrl;
    taoziMessageCtl.messageDesc = _commonPoi.desc;
    taoziMessageCtl.messageName = _commonPoi.zhName;
    taoziMessageCtl.messagePrice = _commonPoi.priceDesc;
    taoziMessageCtl.messageRating = _commonPoi.rating;
    taoziMessageCtl.chatType = TZChatTypeFood;
    if (_poiType == kHotelPoi) {
        taoziMessageCtl.chatType = TZChatTypeHotel;
        taoziMessageCtl.messageRating = _commonPoi.rating;
        taoziMessageCtl.messagePrice = _commonPoi.priceDesc;
    } else if (_poiType == kRestaurantPoi) {
        taoziMessageCtl.chatType = TZChatTypeFood;
        taoziMessageCtl.messageRating = _commonPoi.rating;
        taoziMessageCtl.messagePrice = _commonPoi.priceDesc;
    } else if (_poiType == kShoppingPoi) {
        taoziMessageCtl.chatType = TZChatTypeShopping;
        taoziMessageCtl.messageRating = _commonPoi.rating;
    } 

    taoziMessageCtl.messageAddress = _commonPoi.address;
}

@end

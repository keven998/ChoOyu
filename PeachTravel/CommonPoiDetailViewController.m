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
@property (nonatomic, strong) PoiSummary *restaurantPoi;
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
    
    [self loadData];
}

- (void)updateView
{
    self.navigationItem.title = _restaurantPoi.zhName;
    CommonPoiDetailView *restaurantView = [[CommonPoiDetailView alloc] initWithFrame:CGRectMake(15, 20, self.view.bounds.size.width-30, self.view.bounds.size.height-40)];
    restaurantView.rootCtl = self;
    restaurantView.poi = self.restaurantPoi;
    restaurantView.layer.cornerRadius = 4.0;
    [self.view addSubview:restaurantView];

    restaurantView.alpha = 0;
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        restaurantView.alpha = 1;
    } completion:^(BOOL finished) {
        [restaurantView.closeBtn addTarget:self action:@selector(dismissCtl) forControlEvents:UIControlEventTouchUpInside];
        [restaurantView.shareBtn addTarget:self action:@selector(chat:) forControlEvents:UIControlEventTouchUpInside];

    }];
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

- (void)dismissCtl
{
    self.navigationController.navigationBar.hidden = NO;
    [UIView animateWithDuration:0.3 animations:^{
        self.view.alpha = 0;
    } completion:^(BOOL finished) {
        [self willMoveToParentViewController:nil];
        [self removeFromParentViewController];
        [self.view removeFromSuperview];
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
    [hud showHUD];
    
    NSString *url = [NSString stringWithFormat:@"%@%@", API_GET_RESTAURANT_DETAIL, _restaurantId];
    [manager GET:url parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [hud hideTZHUD];
        NSInteger result = [[responseObject objectForKey:@"code"] integerValue];
        NSLog(@"/***获取美食详情数据****\n%@", responseObject);
        if (result == 0) {
            _restaurantPoi = [[PoiSummary alloc] initWithJson:[responseObject objectForKey:@"result"]];
            _restaurantPoi.poiType  = kRestaurantPoi;
            [self updateView];
        } else {
        }
          
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [hud hideTZHUD];
        if (self.isShowing) {
            [SVProgressHUD showHint:@"呃～好像没找到网络"];
        }
    }];
}

- (void)setChatMessageModel:(TaoziChatMessageBaseViewController *)taoziMessageCtl
{
    taoziMessageCtl.messageId = _restaurantPoi.poiId;
    taoziMessageCtl.messageImage = ((TaoziImage *)[_restaurantPoi.images firstObject]).imageUrl;
    taoziMessageCtl.messageDesc = _restaurantPoi.desc;
    taoziMessageCtl.messageName = _restaurantPoi.zhName;
    taoziMessageCtl.messagePrice = _restaurantPoi.priceDesc;
    taoziMessageCtl.messageRating = _restaurantPoi.rating;
    taoziMessageCtl.chatType = TZChatTypeFood;
    taoziMessageCtl.messageAddress = _restaurantPoi.address;
}

@end

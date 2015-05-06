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
{
    UIButton *_favoriteBtn;
}
@property (nonatomic, strong) UIImageView *backGroundImageView;


@end

@implementation CommonPoiDetailViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    NSMutableArray *barItems = [[NSMutableArray alloc] init];
    
    UIButton *talkBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 48, 44)];
    [talkBtn setImage:[UIImage imageNamed:@"ic_share_to_talk.png"] forState:UIControlStateNormal];
    [talkBtn addTarget:self action:@selector(shareToTalk) forControlEvents:UIControlEventTouchUpInside];
    [barItems addObject:[[UIBarButtonItem alloc]initWithCustomView:talkBtn]];
    
    _favoriteBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 48, 44)];
    [_favoriteBtn setImage:[UIImage imageNamed:@"ic_travelnote_favorite.png"] forState:UIControlStateNormal];
    [_favoriteBtn setImage:[UIImage imageNamed:@"ic_navgation_favorite_seleted.png"] forState:UIControlStateSelected];
    [_favoriteBtn addTarget:self action:@selector(favorite) forControlEvents:UIControlEventTouchUpInside];
    [barItems addObject:[[UIBarButtonItem alloc]initWithCustomView:_favoriteBtn]];
    
    self.navigationItem.rightBarButtonItems = barItems;
    
   

}
-(void)favorite
{
    [self.delegate favorite];
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
//    self.navigationController.navigationBar.hidden = YES;
//    self.navigationController.navigationBarHidden= YES;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
//    self.navigationController.navigationBar.hidden = NO;
//    self.navigationController.navigationBarHidden = NO;
}

- (void)updateView
{
//    self.navigationItem.title = self.poi.zhName;
//    CommonPoiDetailView *commonPoiDetailView = [[CommonPoiDetailView alloc] initWithFrame:CGRectMake(15, 30, self.view.bounds.size.width-30, self.view.bounds.size.height-50)];
    CommonPoiDetailView *commonPoiDetailView = [[CommonPoiDetailView alloc] initWithFrame:self.view.bounds];
    commonPoiDetailView.contentSize = CGSizeMake(self.view.bounds.size.width, self.view.bounds.size.height+1);
    commonPoiDetailView.showsHorizontalScrollIndicator = NO;
    commonPoiDetailView.showsVerticalScrollIndicator = NO;
    commonPoiDetailView.rootCtl = self;
    commonPoiDetailView.poiType = _poiType;
    commonPoiDetailView.poi = self.poi;
    commonPoiDetailView.layer.cornerRadius = 4.0;
    [self.view addSubview:commonPoiDetailView];
    
    [self.navigationController pushViewController:self animated:YES];
//    commonPoiDetailView.transform = CGAffineTransformMakeScale(0.01, 0.01);
//    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
//        commonPoiDetailView.transform = CGAffineTransformMakeScale(1, 1);

//    } completion:^(BOOL finished) {
//        commonPoiDetailView.transform = CGAffineTransformIdentity;
//        [commonPoiDetailView.closeBtn addTarget:self action:@selector(dismissCtl) forControlEvents:UIControlEventTouchUpInside];
//        [commonPoiDetailView.shareBtn addTarget:self action:@selector(chat:) forControlEvents:UIControlEventTouchUpInside];
//    }];
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
    taoziMessageCtl.chatType = TZChatTypeFood;
    if (_poiType == kHotelPoi) {
        taoziMessageCtl.chatType = TZChatTypeHotel;
        taoziMessageCtl.messagePrice = ((HotelPoi *)self.poi).priceDesc;
        taoziMessageCtl.messageRating = self.poi.rating;
    } else if (_poiType == kRestaurantPoi) {
        taoziMessageCtl.chatType = TZChatTypeFood;
        taoziMessageCtl.messageRating = self.poi.rating;
        taoziMessageCtl.messagePrice = ((RestaurantPoi *)self.poi).priceDesc;
        
    } else if (_poiType == kShoppingPoi) {
        taoziMessageCtl.chatType = TZChatTypeShopping;
        taoziMessageCtl.messageRating = self.poi.rating;
    } 

    taoziMessageCtl.messageAddress = self.poi.address;
}

@end

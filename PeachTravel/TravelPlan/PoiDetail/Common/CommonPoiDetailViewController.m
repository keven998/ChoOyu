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
    [talkBtn setImage:[UIImage imageNamed:@"ic_home_slected"] forState:UIControlStateNormal];
    [talkBtn addTarget:self action:@selector(shareToTalk) forControlEvents:UIControlEventTouchUpInside];
    [barItems addObject:[[UIBarButtonItem alloc]initWithCustomView:talkBtn]];
    
    _favoriteBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 48, 44)];
    [_favoriteBtn setImage:[UIImage imageNamed:@"ic_travelnote_favorite.png"] forState:UIControlStateNormal];
    [_favoriteBtn setImage:[UIImage imageNamed:@"ic_navgation_favorite_seleted.png"] forState:UIControlStateSelected];
    [_favoriteBtn addTarget:self action:@selector(favorite:) forControlEvents:UIControlEventTouchUpInside];
    [barItems addObject:[[UIBarButtonItem alloc]initWithCustomView:_favoriteBtn]];
    
    self.navigationItem.rightBarButtonItems = barItems;
    
   

}
- (IBAction)favorite:(UIButton *)sender
{
    
    if (_poiType == kRestaurantPoi) {
        [MobClick event:@"event_favorite_delicacy"];
    } else if (_poiType == kShoppingPoi) {
        [MobClick event:@"event_favorite_shopping"];
    } else if (_poiType == kHotelPoi) {
        [MobClick event:@"event_favorite_hotel"];
    }

    [super asyncFavoritePoiWithCompletion:^(BOOL isSuccess) {

        if (isSuccess) {
            _favoriteBtn.selected = !_favoriteBtn.selected;
        }
    }];
    
    
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

    CommonPoiDetailView *commonPoiDetailView = [[CommonPoiDetailView alloc] initWithFrame:self.view.bounds];
    commonPoiDetailView.contentSize = CGSizeMake(self.view.bounds.size.width, self.view.bounds.size.height+1);
    commonPoiDetailView.showsHorizontalScrollIndicator = NO;
    commonPoiDetailView.showsVerticalScrollIndicator = NO;
    commonPoiDetailView.rootCtl = self;
    commonPoiDetailView.poiType = _poiType;
    commonPoiDetailView.poi = self.poi;
    commonPoiDetailView.layer.cornerRadius = 4.0;
    [self.view addSubview:commonPoiDetailView];
 
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

- (void)dealloc
{
//    NSLog(@"RestaurantDetialViewController dealloc");
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
//        NSLog(@"/***获取poi详情数据****\n%@", responseObject);
        if (result == 0) {
            self.poi = [PoiFactory poiWithPoiType:_poiType andJson:[responseObject objectForKey:@"result"]];
            [self updateView];
        } else {
            [self dismissCtlWithHint:@"无法获取数据"];
        }
        _favoriteBtn.selected=self.poi.isMyFavorite;
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [hud hideTZHUD];
        [self dismissCtlWithHint:@"呃～好像没找到网络"];
    }];
//    self.title = self.poi.zhName;
    
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
        self.title = @"酒店详情";
    } else if (_poiType == kRestaurantPoi) {
        taoziMessageCtl.chatType = TZChatTypeFood;
        taoziMessageCtl.messageRating = self.poi.rating;
        taoziMessageCtl.messagePrice = ((RestaurantPoi *)self.poi).priceDesc;
        self.title = @"没事详情";
    } else if (_poiType == kShoppingPoi) {
        taoziMessageCtl.chatType = TZChatTypeShopping;
        taoziMessageCtl.messageRating = self.poi.rating;
        self.title = @"购物详情";
    } 

    taoziMessageCtl.messageAddress = self.poi.address;
}

@end

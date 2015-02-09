//
//  ToolBoxViewController.m
//  PeachTravel
//
//  Created by liangpengshuai on 14/10/21.
//  Copyright (c) 2014年 com.aizou.www. All rights reserved.
//

#import "ToolBoxViewController.h"
#import "AccountManager.h"
#import "LoginViewController.h"
#import "ContactListViewController.h"
#import "TZCMDChatHelper.h"
#import "OperationData.h"
#import "MyGuideListTableViewController.h"
#import "FavoriteViewController.h"
#import "LocalViewController.h"
#import "CycleScrollView.h"
#import "NSTimer+Addition.h"
#import "SuperWebViewController.h"
#import "MakePlanViewController.h"
#import "ForeignViewController.h"
#import "DomesticViewController.h"

@interface ToolBoxViewController () <UIAlertViewDelegate, MHTabBarControllerDelegate, UIScrollViewDelegate, CLLocationManagerDelegate, UIActionSheetDelegate>
{
    CLLocationManager* locationManager;
    BOOL locationIsGotten;
}

@property (strong, nonatomic) CLLocation *currentLocation;

@property (nonatomic, strong) NSMutableArray *operationDataArray;
@property (nonatomic, strong) NSMutableArray *imageViews;

@property (strong, nonatomic) UILabel *weatherLabel;
@property (nonatomic, strong) CycleScrollView *galleryPageView;
@property (nonatomic, strong) UIButton *planBtn;
@property (nonatomic, strong) UIButton *aroundBtn;
@property (nonatomic, strong) UIView *contentFrame;

@end

@implementation ToolBoxViewController

#pragma mark - LifeCycle

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"home_navigation_title.png"]];
    self.view.backgroundColor = APP_PAGE_COLOR;
    
    UIBarButtonItem * makePlanBtn = [[UIBarButtonItem alloc]initWithTitle:nil style:UIBarButtonItemStyleBordered target:self action:@selector(showActionHint)];
    makePlanBtn.image = [UIImage imageNamed:@"ic_new_plan.png"];
    makePlanBtn.tintColor = [UIColor whiteColor];
    self.navigationItem.rightBarButtonItem = makePlanBtn;

    [self setupView];
    self.automaticallyAdjustsScrollViewInsets = NO;
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate= self;
    if (IS_IOS8) {
        [locationManager requestWhenInUseAuthorization];
    }
    [locationManager startUpdatingLocation];
}

- (void) setupView {
    CGFloat w = CGRectGetWidth(self.view.bounds);
    CGFloat h = CGRectGetHeight(self.view.bounds);
    
    CGFloat ratioY = h/480;
    CGFloat ratioX = w/320;
    
    CGFloat height = 135 * ratioY;
    
    _galleryPageView = [[CycleScrollView alloc]initWithFrame:CGRectMake(0, 64, w, height) animationDuration:5];
    _galleryPageView.backgroundColor = [APP_THEME_COLOR colorWithAlphaComponent:0.2];
    _galleryPageView.clipsToBounds = YES;
    [self.view addSubview:_galleryPageView];
    
    _contentFrame = [[UIView alloc] initWithFrame:CGRectMake(0.0, _galleryPageView.frame.size.height+64, w, h - (_galleryPageView.frame.size.height+64))];
    _contentFrame.backgroundColor = [UIColor whiteColor];
    _contentFrame.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:_contentFrame];
    
    //    _weatherFrame = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, _galleryPageView.frame.origin.y+_galleryPageView.frame.size.height-40, w, 40.0)];
    //    _weatherFrame.image = [UIImage imageNamed:@"weatherbackground.png"];
    //    _weatherFrame.contentMode = UIViewContentModeScaleToFill;
    //    _weatherFrame.clipsToBounds = YES;
    //    _weatherFrame.autoresizesSubviews = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
    
    CGFloat offsetY = 10.0 * ratioY;
    
    _weatherLabel = [[UILabel alloc] initWithFrame:CGRectMake(18.0, offsetY, w - 28, 15*ratioY)];
    _weatherLabel.textAlignment = NSTextAlignmentRight;
    _weatherLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    _weatherLabel.textColor = UIColorFromRGB(0x7a7a7a);
    _weatherLabel.font = [UIFont fontWithName:@"MicrosoftYaHei" size:(9*ratioY)];
    
    _weatherLabel.numberOfLines = 2;
    [_contentFrame addSubview:_weatherLabel];
    
    
    offsetY += _weatherLabel.frame.size.height + 10*ratioY + 50*(ratioY-1);
    
    UIImageView *bkgView = [[UIImageView alloc] initWithFrame:CGRectMake((w-260*ratioX)/2, offsetY, 260*ratioX, 145*ratioX)];
    bkgView.image = [UIImage imageNamed:@"bkg-linked_dots.png"];

    [_contentFrame addSubview:bkgView];
    
    _planBtn = [[UIButton alloc] initWithFrame:CGRectMake(20.0*ratioX+10*(ratioX-1), offsetY, 115*ratioX, 200*ratioY)];
    
    UILabel *myGuideTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0, 0, _planBtn.bounds.size.width - 20.0, 22*ratioY)];
    myGuideTitleLabel.font = [UIFont boldSystemFontOfSize:18*ratioX];
    myGuideTitleLabel.textColor = APP_THEME_COLOR;
    myGuideTitleLabel.textAlignment = NSTextAlignmentCenter;
    [_planBtn addSubview:myGuideTitleLabel];
    
    UILabel *guideSubTitle = [[UILabel alloc] initWithFrame:CGRectMake(20, 25*ratioY, _planBtn.bounds.size.width + 48.0, 60*ratioY)];
    guideSubTitle.font = [UIFont fontWithName:@"MicrosoftYaHei" size:12*ratioX];
    guideSubTitle.numberOfLines = 3;
    guideSubTitle.textColor = TEXT_COLOR_TITLE_PH;
    guideSubTitle.textAlignment = NSTextAlignmentCenter;
    [_planBtn addSubview:guideSubTitle];
    
    UIButton *guideSimButton = [[UIButton alloc] initWithFrame:CGRectMake(12.5, (guideSubTitle.frame.size.height+guideSubTitle.frame.origin.y) + 5*ratioY, 90*ratioX, 90*ratioX)];
    guideSimButton.clipsToBounds = YES;
    guideSimButton.titleLabel.numberOfLines = 2;
    [guideSimButton setTitle:@"我的\n旅程" forState:UIControlStateNormal];
    [guideSimButton setTitleColor:APP_SUB_THEME_COLOR forState:UIControlStateNormal];
    guideSimButton.titleLabel.font = [UIFont fontWithName:@"MicrosoftYaHei" size:17*ratioX];
    [guideSimButton setBackgroundImage:[UIImage imageNamed:@"ic_home_btn_cycle.png"] forState:UIControlStateNormal];
    [_planBtn addSubview:guideSimButton];
    
    myGuideTitleLabel.text = @"旅程助手";
    
    CGFloat title_w = [myGuideTitleLabel.text sizeWithAttributes:@{NSFontAttributeName : [UIFont boldSystemFontOfSize:18*ratioX]}].width;
    
    UIImageView *titleImage = [[UIImageView alloc] initWithFrame:CGRectMake((_planBtn.bounds.size.width-title_w-30)/2, (22*ratioY-11)/2, title_w+30, 11)];
    titleImage.image = [UIImage imageNamed:@"deco-dots.png"];
    [_planBtn addSubview:titleImage];

    
    NSString *str = @"最贴心的旅程助手\n旅行可以\n更安心、简单";
    NSMutableAttributedString *desc = [[NSMutableAttributedString alloc] initWithString:str];
    [desc addAttribute:NSForegroundColorAttributeName value:TEXT_COLOR_TITLE_PH  range:NSMakeRange(0, [str length])];
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.lineSpacing = 4.0;
    [desc addAttribute:NSParagraphStyleAttributeName value:style range:NSMakeRange(0, str.length)];
    [guideSubTitle setAttributedText:desc];

    [guideSimButton addTarget:self action:@selector(myTravelNote:) forControlEvents:UIControlEventTouchUpInside];
    [_contentFrame addSubview:_planBtn];
    
    _aroundBtn = [[UIButton alloc] initWithFrame:CGRectMake(w-115*ratioX-20*ratioX-10*(ratioX-1), offsetY, 115*ratioX, 200*ratioY)];
    
    UILabel *nearByTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0, 0.0, _aroundBtn.bounds.size.width - 20.0, 22*ratioY)];
    nearByTitleLabel.font = [UIFont boldSystemFontOfSize:18*ratioX];
    nearByTitleLabel.textColor = APP_THEME_COLOR;
    nearByTitleLabel.textAlignment = NSTextAlignmentCenter;

    [_aroundBtn addSubview:nearByTitleLabel];
    
    UILabel *nearBySubTitle = [[UILabel alloc] initWithFrame:CGRectMake(22, 25*ratioY, _aroundBtn.bounds.size.width - 20.0, 60*ratioY)];
    nearBySubTitle.font = [UIFont fontWithName:@"MicrosoftYaHei" size:12*ratioX];
    nearBySubTitle.numberOfLines = 3;
    nearBySubTitle.textColor = TEXT_COLOR_TITLE_PH;
    nearBySubTitle.textAlignment = NSTextAlignmentCenter;
    [_aroundBtn addSubview:nearBySubTitle];
    
    UIButton *nearBySimButton = [[UIButton alloc] initWithFrame:CGRectMake(12.5, (guideSubTitle.frame.size.height+guideSubTitle.frame.origin.y) + 5*ratioY, 90*ratioX, 90*ratioX)];
    [nearBySimButton setTitleColor:APP_SUB_THEME_COLOR forState:UIControlStateNormal];
    [nearBySimButton setBackgroundImage:[UIImage imageNamed:@"ic_home_btn_cycle.png"] forState:UIControlStateNormal];
    [nearBySimButton setTitle:@"发现\n身边" forState:UIControlStateNormal];
    nearBySimButton.titleLabel.numberOfLines = 2;
    nearBySimButton.titleLabel.font = [UIFont fontWithName:@"MicrosoftYaHei" size:17*ratioX];
    nearBySimButton.clipsToBounds = YES;
    [_aroundBtn addSubview:nearBySimButton];
    
    nearByTitleLabel.text = @"身边发现";
    str = @"旅途有发现\n发现途中的灵感\n发现当下的乐趣";
    desc = [[NSMutableAttributedString alloc] initWithString:str];
    [desc addAttribute:NSForegroundColorAttributeName value:TEXT_COLOR_TITLE_PH  range:NSMakeRange(0, [str length])];
    style = [[NSMutableParagraphStyle alloc] init];
    style.lineSpacing = 4.0;
    [desc addAttribute:NSParagraphStyleAttributeName value:style range:NSMakeRange(0, str.length)];
    [nearBySubTitle setAttributedText:desc];
    [nearBySimButton addTarget:self action:@selector(nearBy:) forControlEvents:UIControlEventTouchUpInside];
    
    CGFloat title_w2 = [nearByTitleLabel.text sizeWithAttributes:@{NSFontAttributeName : [UIFont boldSystemFontOfSize:18*ratioX]}].width;
    
    UIImageView *titleImage2 = [[UIImageView alloc] initWithFrame:CGRectMake((_aroundBtn.bounds.size.width-title_w2-30)/2, (22*ratioY-11)/2, title_w2+30, 11)];
    titleImage2.image = [UIImage imageNamed:@"deco-dots.png"];
    [_aroundBtn addSubview:titleImage2];
    [_contentFrame addSubview:_aroundBtn];

    
    offsetY = 210.0;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if ([self rdv_tabBarController].tabBarHidden) {
        [[self rdv_tabBarController] setTabBarHidden:NO];
    }
    if (!_operationDataArray || _operationDataArray.count == 0) {
        [self loadRecommendData];
    } else {
        if (_operationDataArray && _operationDataArray.count > 1) {
            [_galleryPageView.scrollView setContentOffset:CGPointZero];
        }
        [_galleryPageView.animationTimer resumeTimerAfterTimeInterval:2];
    }
    [self.navigationController.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setBarTintColor:APP_THEME_COLOR];
    self.navigationController.navigationBar.translucent = YES;
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if (self.navigationController.viewControllers.count == 2) {
        [[self rdv_tabBarController] setTabBarHidden:YES];
    }
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"navi_bkg.png"] forBarMetrics:UIBarMetricsDefault];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
}

- (void)dealloc
{
    [_galleryPageView stopTimer];
    _galleryPageView = nil;
    locationManager.delegate = nil;
    locationManager = nil;
}

- (void) setUpGallaryView
{
    NSInteger count = [_operationDataArray count];
    NSMutableArray *images = [[NSMutableArray alloc] init];
    for (NSUInteger i = 0; i < count; i++)
    {
        [images addObject:[NSNull null]];
    }
    
    _imageViews = images;
    __weak typeof(ToolBoxViewController *)weakSelf = self;
    
    _galleryPageView.fetchContentViewAtIndex = ^UIView *(NSInteger pageIndex){
        return (UIView *)[weakSelf loadScrollViewWithPage:pageIndex];
    };
    
    _galleryPageView.totalPagesCount = ^NSInteger(void){
        return weakSelf.operationDataArray.count;
    };
    
    _galleryPageView.TapActionBlock = ^(NSInteger pageIndex){
        NSLog(@"点击了第%ld个", (long)(long)pageIndex);
        OperationData *data = [weakSelf.operationDataArray objectAtIndex:pageIndex];
        SuperWebViewController *webCtl = [[SuperWebViewController alloc] init];
        webCtl.titleStr = data.title;
        webCtl.urlStr = data.linkUrl;
        [weakSelf.navigationController pushViewController:webCtl animated:YES];

    };
    
//    if (!self.weatherInfo) {
//        [_weatherFrame removeFromSuperview];
//    } else {
//        [_weatherFrame removeFromSuperview];
//        [self.view addSubview:_weatherFrame];
//    }
}

- (UIImageView *)loadScrollViewWithPage:(NSUInteger)page {
    if (page >= _operationDataArray.count ) {
        return nil;
    }
    
    UIImageView *img = [_imageViews objectAtIndex:page];
    if ((NSNull *)img == [NSNull null]) {
        img = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0.0, CGRectGetWidth(self.galleryPageView.frame), CGRectGetHeight(self.galleryPageView.frame))];
        img.contentMode = UIViewContentModeScaleAspectFill;
        img.clipsToBounds = YES;
        img.userInteractionEnabled = YES;
        [_imageViews replaceObjectAtIndex:page withObject:img];
    }
    
    if (img.superview == nil) {
        CGRect frame = img.frame;
        frame.origin.x = CGRectGetWidth(frame) * page;
        img.frame = frame;
        NSString *imageStr = ((OperationData *)[_operationDataArray objectAtIndex:page]).imageUrl;
        [img sd_setImageWithURL:[NSURL URLWithString:imageStr] placeholderImage:[UIImage imageNamed:@"spot_detail_default.png"]];
    }
    return img;
}



- (void)setWeatherInfo:(WeatherInfo *)weatherInfo
{
    _weatherInfo = weatherInfo;
    if(_weatherInfo) {
        [self getReverseGeocode];
    }
}

/**
 *  获取运营位推荐
 */
- (void)loadRecommendData
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    AppUtils *utils = [[AppUtils alloc] init];
    [manager.requestSerializer setValue:utils.appVersion forHTTPHeaderField:@"Version"];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"iOS %@",utils.systemVersion] forHTTPHeaderField:@"Platform"];
    
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [manager.requestSerializer setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    NSNumber *imageWidth = [NSNumber numberWithInt:(kWindowWidth-22)*2];
    [params setObject:imageWidth forKey:@"imgWidth"];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    //获取首页数据
    [manager GET:API_GET_COLUMNS parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"%@", responseObject);
        NSInteger code = [[responseObject objectForKey:@"code"] integerValue];
        if (code == 0) {
            if (!_operationDataArray) {
                _operationDataArray = [[NSMutableArray alloc] init];
            }
            for (id operationDic in [responseObject objectForKey:@"result"]) {
                OperationData *operation = [[OperationData alloc] initWithJson:operationDic];
                [_operationDataArray addObject:operation];
            }

            [self setUpGallaryView];
        } else {
            
        }
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    }];

}

#pragma mark - YWeatherInfoDelegate
- (void)gotWeatherInfo:(WeatherInfo *)weatherInfo
{
    NSLog(@"/*****接收到天气数据******/\n");
    self.weatherInfo = weatherInfo;
}

- (void)updateWeatherLabelWithCityName:(NSString *)city
{
    NSString *currentDate = [ConvertMethods getCurrentDataWithFormat:@"yyyy-MM-dd"];
    NSString *tempCityName = city? city:@"当前位置";
    //将城市名字包含“市辖区”字眼的去掉
    NSString *cityName = [tempCityName stringByReplacingOccurrencesOfString:@"市辖区" withString:@""];
    NSString *s = [NSString stringWithFormat:@"%@  %@ %@",currentDate, cityName, [yahooWeatherCode objectAtIndex:_weatherInfo.mCurrentCode]];
//    _weatherLabel.text = s;
    NSMutableAttributedString *desc = [[NSMutableAttributedString alloc] initWithString:s];
    [desc addAttribute:NSForegroundColorAttributeName value:TEXT_COLOR_TITLE_PH  range:NSMakeRange(0, [s length])];
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.lineSpacing = 2.5;
    style.alignment = NSTextAlignmentRight;
    [desc addAttribute:NSParagraphStyleAttributeName value:style range:NSMakeRange(0, s.length)];
    [_weatherLabel setAttributedText:desc];
    
    CGFloat offsetX = [s sizeWithAttributes:@{NSFontAttributeName : [UIFont fontWithName:@"MicrosoftYaHei" size:9*(kWindowHeight/480)]}].width;

    UIImageView *weatherImageview = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetWidth(_weatherLabel.bounds) - offsetX - 20, 2, kWindowHeight/480*10, 10*kWindowHeight/480)];
    weatherImageview.image = [UIImage imageNamed:[yahooWeatherImageName objectAtIndex:_weatherInfo.mCurrentCode]];

    [_weatherLabel addSubview:weatherImageview];
}

#pragma mark - IBAction Methods


- (IBAction)nearBy:(UIButton *)sender {    
    LocalViewController *lvc = [[LocalViewController alloc] init];
    [self.navigationController pushViewController:lvc animated:YES];
}

- (IBAction)myTravelNote:(UIButton *)sender {
    AccountManager *accountManager = [AccountManager shareAccountManager];
    if (!accountManager.isLogin) {
        [self performSelector:@selector(goLogin:) withObject:nil afterDelay:0.3];
        [SVProgressHUD showErrorWithStatus:@"请先登录"];
    } else {
        MyGuideListTableViewController *myGuidesCtl = [[MyGuideListTableViewController alloc] init];
        [self.navigationController pushViewController:myGuidesCtl animated:YES];
    }
}

- (IBAction)goLogin:(id)sender
{
    LoginViewController *loginCtl = [[LoginViewController alloc] init];
    UINavigationController *nctl = [[UINavigationController alloc] initWithRootViewController:loginCtl];
    loginCtl.isPushed = NO;
    [nctl.navigationBar setBackgroundImage:[UIImage imageNamed:@"navi_bkg.png"] forBarMetrics:UIBarMetricsDefault];
    nctl.navigationBar.translucent = YES;
    [self.navigationController presentViewController:nctl animated:YES completion:nil];
}

- (IBAction) showActionHint {
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:nil
                                                       delegate:self
                                              cancelButtonTitle:@"取消"
                                         destructiveButtonTitle:nil
                                              otherButtonTitles:@"新建旅程", nil];
    [sheet showInView:self.view];
}

#pragma mark - UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        [actionSheet resignFirstResponder];
        [self makePlan];
    }
}

- (void)makePlan
{
    Destinations *destinations = [[Destinations alloc] init];
    MakePlanViewController *makePlanCtl = [[MakePlanViewController alloc] init];
    ForeignViewController *foreignCtl = [[ForeignViewController alloc] init];
    DomesticViewController *domestic = [[DomesticViewController alloc] init];
    domestic.destinations = destinations;
    foreignCtl.destinations = destinations;
    makePlanCtl.destinations = destinations;
    makePlanCtl.viewControllers = @[domestic, foreignCtl];
    domestic.makePlanCtl = makePlanCtl;
    foreignCtl.makePlanCtl = makePlanCtl;
    makePlanCtl.animationOptions = UIViewAnimationOptionTransitionNone;
    makePlanCtl.duration = 0;
    makePlanCtl.segmentedTitles = @[@"国内", @"国外"];
    makePlanCtl.selectedColor = APP_THEME_COLOR;
    makePlanCtl.segmentedTitleFont = [UIFont fontWithName:@"MicrosoftYahei" size:18.0];
    makePlanCtl.normalColor= [UIColor grayColor];

    [self.navigationController pushViewController:makePlanCtl animated:YES];
}

#pragma mark - private

/**
 *  是否有未读的消息，包括未读的聊天消息和好友请求消息
 *
 *  @return
 */
- (BOOL)isUnReadMsg
{
    NSArray *conversations = [[[EaseMob sharedInstance] chatManager] conversations];
    for (EMConversation *conversation in conversations) {
        if (conversation.unreadMessagesCount > 0) {
            return YES;
        }
    }
    AccountManager *accountManager = [AccountManager shareAccountManager];
    if (accountManager.numberOfUnReadFrendRequest > 0) {
        return YES;
    }
    return NO;
}

#pragma mark - MKMapViewDelegate

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    [locationManager stopUpdatingLocation];
    if (!locationIsGotten) {
        locationIsGotten = YES;
        CLLocation *location = [locations firstObject];
        NSLog(@"oh my god我被定位到了：%f, %f", location.coordinate.latitude, location.coordinate.longitude);
        _location = location;
        [self updateWeatherWithLocation:location];
    }
}

- (void)updateWeatherWithLocation:(CLLocation *)location
{
    YWeatherUtils* yweatherUtils = [YWeatherUtils getInstance];
    [yweatherUtils setMAfterRecieveDataDelegate: self];
    [yweatherUtils queryYahooWeather:location.coordinate.latitude andLng:location.coordinate.longitude apiKey:@""];
}


- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error
{
      
    [locationManager stopUpdatingLocation];
    NSString *errorString;
    NSLog(@"Error: %@",[error localizedDescription]);
    switch([error code]) {
        case kCLErrorDenied:
            //Access denied by user
            errorString = @"去设置里把定位服务打开呗~";
            //Do something...
            break;
        case kCLErrorLocationUnknown:
            //Probably temporary...
            errorString = @"定位失败了，待会再试试吧";
            //Do something else...
            break;
        default:
            errorString = @"定位失败了，待会再试试吧";
            break;
    }
    NSLog(@"%@", errorString);
}



- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    switch (status) {
        case kCLAuthorizationStatusNotDetermined:
            [locationManager stopUpdatingLocation];
            break;
        case kCLAuthorizationStatusAuthorizedAlways:
            [locationManager startUpdatingLocation];
            
            break;
        case kCLAuthorizationStatusAuthorizedWhenInUse:
            [locationManager startUpdatingLocation];
            
        default:
            break;
    }
}

- (void)getReverseGeocode
{
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    
    CLLocationCoordinate2D myCoOrdinate;
    
    myCoOrdinate.latitude = _location.coordinate.latitude;
    myCoOrdinate.longitude = _location.coordinate.longitude;
    
    CLLocation *location = [[CLLocation alloc] initWithLatitude:myCoOrdinate.latitude longitude:myCoOrdinate.longitude];
    [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
        if (error)
        {
            NSLog(@"failed with error: %@", error);
            return;
        }
        if(placemarks.count > 0)
        {
            CLPlacemark *clPlaceMark = [placemarks firstObject];
            NSString *city = [clPlaceMark.addressDictionary objectForKey:@"City"];
            [self updateWeatherLabelWithCityName:city];
        }
    }];
}





@end

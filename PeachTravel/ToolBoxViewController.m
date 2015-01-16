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
#import "ChatListViewController.h"
#import "TZCMDChatHelper.h"
#import "IMRootViewController.h"
#import "OperationData.h"
#import "MyGuideListTableViewController.h"
#import "FavoriteViewController.h"
#import "LocalViewController.h"
#import "CycleScrollView.h"
#import "NSTimer+Addition.h"
#import "TZButton.h"
#import "SuperWebViewController.h"

//两次提示的默认间隔
static const CGFloat kDefaultPlaySoundInterval = 3.0;

@interface ToolBoxViewController () <UIAlertViewDelegate, IChatManagerDelegate, MHTabBarControllerDelegate, UIScrollViewDelegate, CLLocationManagerDelegate>
{
    CLLocationManager* locationManager;
    BOOL locationIsGotten;
}

@property (strong, nonatomic) CLLocation *currentLocation;

@property (strong, nonatomic) NSDate *lastPlaySoundDate;
@property (nonatomic, strong) NSMutableArray *operationDataArray;
@property (nonatomic, strong) NSMutableArray *imageViews;

@property (strong, nonatomic) UILabel *weatherLabel;
@property (nonatomic, strong) CycleScrollView *galleryPageView;
@property (nonatomic, strong) TZButton *planBtn;
@property (nonatomic, strong) TZButton *aroundBtn;

@property (strong, nonatomic) UIButton *IMBtn;

/**
 *  未读消息的 label
 */
@property (strong, nonatomic) UILabel *unReadMsgLabel;

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
    
    self.view.backgroundColor = APP_PAGE_COLOR;
    self.navigationItem.title = @"桃子旅行";

    [self setupView];
    self.automaticallyAdjustsScrollViewInsets = NO;
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate= self;
    if (IS_IOS8) {
        [locationManager requestWhenInUseAuthorization];
    }
    [locationManager startUpdatingLocation];

    //获取未读消息数，此时并没有把self注册为SDK的delegate，读取出的未读数是上次退出程序时的
    [self didUnreadMessagesCountChanged];

    [self registerNotifications];
    [self setupUnreadMessageCount];
}

- (void) setupView {
    CGFloat w = CGRectGetWidth(self.view.bounds);
    CGFloat h = CGRectGetHeight(self.view.bounds);
    
    CGFloat offsetY = 74.0;
    
    _galleryPageView = [[CycleScrollView alloc]initWithFrame:CGRectMake(10, offsetY, w - 20, 170.0) animationDuration:5];
    _galleryPageView.backgroundColor = [APP_THEME_COLOR colorWithAlphaComponent:0.2];
    _galleryPageView.layer.cornerRadius = 5.0;
    _galleryPageView.clipsToBounds = YES;
    [self.view addSubview:_galleryPageView];
    
    offsetY += CGRectGetHeight(_galleryPageView.frame);
    
    _contentFrame = [[UIView alloc] initWithFrame:CGRectMake(0.0, offsetY, w, h - offsetY)];
    _contentFrame.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:_contentFrame];
    
    //    _weatherFrame = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, _galleryPageView.frame.origin.y+_galleryPageView.frame.size.height-40, w, 40.0)];
    //    _weatherFrame.image = [UIImage imageNamed:@"weatherbackground.png"];
    //    _weatherFrame.contentMode = UIViewContentModeScaleToFill;
    //    _weatherFrame.clipsToBounds = YES;
    //    _weatherFrame.autoresizesSubviews = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
    
    offsetY = 20.0;
    
    UIView *lv = [[UIView alloc] initWithFrame:CGRectMake(12.0, offsetY, 5.0, 14.0)];
    lv.backgroundColor = APP_THEME_COLOR;
    lv.layer.cornerRadius = 1.5;
    [_contentFrame addSubview:lv];
    
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(21.0, offsetY-1, w, 16.0)];
    title.font = [UIFont systemFontOfSize:16.0];
    title.textColor = APP_THEME_COLOR;
    title.textAlignment = NSTextAlignmentLeft;
    title.text = @"桃子旅行助手";
    title.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [_contentFrame addSubview:title];
    
    _weatherLabel = [[UILabel alloc] initWithFrame:CGRectMake(18.0, offsetY-6, w - 28, 24)];
    _weatherLabel.textAlignment = NSTextAlignmentRight;
    _weatherLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    _weatherLabel.textColor = UIColorFromRGB(0x7a7a7a);
    _weatherLabel.font = [UIFont systemFontOfSize:9.0];
    _weatherLabel.numberOfLines = 2;
    [_contentFrame addSubview:_weatherLabel];
    
    offsetY += 16 + 10;
    
    CGFloat cw = (w - 30)/2;
    
    _planBtn = [[TZButton alloc] initWithFrame:CGRectMake(10.0, offsetY, cw, cw)];
    _planBtn.title.text = @"行程助手";
    _planBtn.simButton.text = @"我的行程";
    NSString *str = @"最贴心的旅行计划助手\n专为美眉们打造\n";
    NSMutableAttributedString *desc = [[NSMutableAttributedString alloc] initWithString:str];
    [desc addAttribute:NSForegroundColorAttributeName value:TEXT_COLOR_TITLE_PH  range:NSMakeRange(0, [str length])];
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.lineSpacing = 4.0;
    [desc addAttribute:NSParagraphStyleAttributeName value:style range:NSMakeRange(0, str.length)];
    [_planBtn.subTitle setAttributedText:desc];
    [_planBtn addTarget:self action:@selector(myTravelNote:) forControlEvents:UIControlEventTouchUpInside];
    [_contentFrame addSubview:_planBtn];
    
    _aroundBtn = [[TZButton alloc] initWithFrame:CGRectMake(cw + 20, offsetY, cw, cw)];
    _aroundBtn.title.text = @"身边发现";
    _aroundBtn.simButton.text = @"去发现";
    str = @"旅行有发现\n发现途中的灵感\n发现当下的乐趣";
    desc = [[NSMutableAttributedString alloc] initWithString:str];
    [desc addAttribute:NSForegroundColorAttributeName value:TEXT_COLOR_TITLE_PH  range:NSMakeRange(0, [str length])];
    style = [[NSMutableParagraphStyle alloc] init];
    style.lineSpacing = 3.0;
    [desc addAttribute:NSParagraphStyleAttributeName value:style range:NSMakeRange(0, str.length)];
    [_aroundBtn.subTitle setAttributedText:desc];
    [_aroundBtn addTarget:self action:@selector(nearBy:) forControlEvents:UIControlEventTouchUpInside];
    [_contentFrame addSubview:_aroundBtn];

    
    offsetY = 210.0;
    
    _IMBtn = [[UIButton alloc] initWithFrame:CGRectMake(11, _contentFrame.frame.size.height-20-57-50, w-22, 57.0)];
    [_IMBtn setImage:[UIImage imageNamed:@"ic_im_background.png"] forState:UIControlStateNormal];
    [_IMBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    _IMBtn.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [_IMBtn addTarget:self action:@selector(jumpIM:) forControlEvents:UIControlEventTouchUpInside];
    [_contentFrame addSubview:_IMBtn];
    
    UIImageView *imTextImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ic_im_text.png"]];
    imTextImageView.center = CGPointMake(_IMBtn.bounds.size.width/2, _IMBtn.bounds.size.height/2);
    [_IMBtn addSubview:imTextImageView];
    
    UIImageView *accessImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ic_im_arrow.png"]];
    accessImageView.center = CGPointMake(_IMBtn.bounds.size.width-30,  _IMBtn.bounds.size.height/2);
    [_IMBtn addSubview:accessImageView];
    
    _unReadMsgLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 20, 10, 10)];
    [_unReadMsgLabel setCenter:CGPointMake(_IMBtn.center.x + 15, 10)];
    _unReadMsgLabel.layer.cornerRadius = 5.0;
    _unReadMsgLabel.clipsToBounds = YES;
    _unReadMsgLabel.backgroundColor = APP_THEME_COLOR;
    _unReadMsgLabel.hidden = YES;
    [_IMBtn addSubview:_unReadMsgLabel];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if ([self rdv_tabBarController].tabBarHidden) {
        [[self rdv_tabBarController] setTabBarHidden:NO];
    }
    [self updateUnReadMsgStatus];
    if (!_operationDataArray || _operationDataArray.count == 0) {
        [self loadRecommendData];
    } else {
        if (_operationDataArray && _operationDataArray.count > 1) {
            [_galleryPageView.scrollView setContentOffset:CGPointZero];
        }
        [_galleryPageView.animationTimer resumeTimerAfterTimeInterval:2];
    }
    NSLog(@"tool viewWillAppear");
    
    

}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if (self.navigationController.viewControllers.count == 2) {
        [[self rdv_tabBarController] setTabBarHidden:YES];
    }
}

- (void)dealloc
{
    NSLog(@"***********最重要的页面销毁掉了*************");
    [_galleryPageView stopTimer];
    _galleryPageView = nil;
    [self unregisterNotifications];
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

/**
 *  更新未读消息的状态
 */
- (void)updateUnReadMsgStatus
{
    if ([self isUnReadMsg]) {
        _unReadMsgLabel.hidden = NO;
    } else {
        _unReadMsgLabel.hidden = YES;
    }
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
    NSString *s = [NSString stringWithFormat:@"%@  %@\n%@",currentDate, cityName, [yahooWeatherCode objectAtIndex:_weatherInfo.mCurrentCode]];
//    _weatherLabel.text = s;
    NSMutableAttributedString *desc = [[NSMutableAttributedString alloc] initWithString:s];
    [desc addAttribute:NSForegroundColorAttributeName value:TEXT_COLOR_TITLE_PH  range:NSMakeRange(0, [s length])];
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.lineSpacing = 2.5;
    style.alignment = NSTextAlignmentRight;
    [desc addAttribute:NSParagraphStyleAttributeName value:style range:NSMakeRange(0, s.length)];
    [_weatherLabel setAttributedText:desc];
    
    CGFloat offsetX = [[yahooWeatherCode objectAtIndex:_weatherInfo.mCurrentCode] sizeWithAttributes:@{NSFontAttributeName : [UIFont systemFontOfSize:9]}].width;
    UIImageView *weatherImageview = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetWidth(_weatherLabel.bounds) - offsetX - 13, 14, 9, 10.5)];
    weatherImageview.image = [UIImage imageNamed:[yahooWeatherImageName objectAtIndex:_weatherInfo.mCurrentCode]];
    weatherImageview.backgroundColor = [UIColor grayColor];
    [_weatherLabel addSubview:weatherImageview];
}

#pragma mark - IBAction Methods

//进入聊天功能
- (IBAction)jumpIM:(UIButton *)sender {
    AccountManager *accountManager = [AccountManager shareAccountManager];
    if ([accountManager isLogin]) {
        ContactListViewController *contactListCtl = [[ContactListViewController alloc] init];
        contactListCtl.title = @"桃友";
        if ([accountManager numberOfUnReadFrendRequest]) {
            contactListCtl.notify = YES;
        } else {
            contactListCtl.notify = NO;
        }
        
        ChatListViewController *chatListCtl = [[ChatListViewController alloc] init];
        chatListCtl.title = @"Talk";
        chatListCtl.notify = NO;
        
        NSArray *viewControllers = [NSArray arrayWithObjects:chatListCtl,contactListCtl, nil];
        IMRootViewController *IMRootCtl = [[IMRootViewController alloc] init];
        IMRootCtl.delegate = self;
        IMRootCtl.viewControllers = viewControllers;
        [self.navigationController pushViewController:IMRootCtl animated:YES];

    } else {
        [SVProgressHUD showErrorWithStatus:@"请先登录"];
        [self performSelector:@selector(goLogin:) withObject:nil afterDelay:0.8];
    }
}

- (IBAction)nearBy:(UIButton *)sender {    
    LocalViewController *lvc = [[LocalViewController alloc] init];
    [self.navigationController pushViewController:lvc animated:YES];
}

- (IBAction)myFavorite:(id)sender {
    AccountManager *accountManager = [AccountManager shareAccountManager];
    if (!accountManager.isLogin) {
        [self performSelector:@selector(goLogin:) withObject:nil afterDelay:0.3];
        [SVProgressHUD showErrorWithStatus:@"请先登录"];
    } else {
        FavoriteViewController *fvc = [[FavoriteViewController alloc] init];
        [self.navigationController pushViewController:fvc animated:YES];
    }
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
    [self.navigationController presentViewController:nctl animated:YES completion:nil];
}

#pragma mark - private

-(void)registerNotifications
{
    [self unregisterNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateUnReadMsgStatus) name:receiveFrendRequestNoti object:nil];
    [[EaseMob sharedInstance].chatManager addDelegate:self delegateQueue:nil];
}

-(void)unregisterNotifications
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[EaseMob sharedInstance].chatManager removeDelegate:self];
}

// 统计未读消息数
-(void)setupUnreadMessageCount
{
    NSArray *conversations = [[[EaseMob sharedInstance] chatManager] conversations];
    NSInteger unreadCount = 0;
    for (EMConversation *conversation in conversations) {
        unreadCount += conversation.unreadMessagesCount;
    }
    UIApplication *application = [UIApplication sharedApplication];
    [application setApplicationIconBadgeNumber:unreadCount];
}

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

#pragma mark - IChatManagerDelegate 消息变化

- (void)networkChanged:(EMConnectionState)connectionState
{
    NSLog(@"网络状态发生变化");
}

- (void)didUpdateConversationList:(NSArray *)conversationList
{
    NSLog(@"聊天的内容发生变化");
}

// 未读消息数量变化回调
-(void)didUnreadMessagesCountChanged
{
    [self setupUnreadMessageCount];
}

- (void)didFinishedReceiveOfflineMessages:(NSArray *)offlineMessages{
    [self setupUnreadMessageCount];
}

- (void)didFinishedReceiveOfflineCmdMessages:(NSArray *)offlineCmdMessages
{
    for (EMMessage *cmdMessage in offlineCmdMessages) {
        [TZCMDChatHelper distributeCMDMsg:cmdMessage];
    }
    NSLog(@"我收到了很多透传消息");
}

// 收到消息回调
-(void)didReceiveMessage:(EMMessage *)message
{
    NSLog(@"收到消息，消息为%@", message);
    _unReadMsgLabel.hidden = NO;
    
    BOOL needShowNotification = message.isGroup ? [self needShowNotification:message.conversationChatter] : YES;
    if (needShowNotification) {
#if !TARGET_IPHONE_SIMULATOR
        [self playSoundAndVibration];
        
        BOOL isAppActivity = [[UIApplication sharedApplication] applicationState] == UIApplicationStateActive;
        if (!isAppActivity) {
            [self showNotificationWithMessage:message];
        }
#endif
    }
}

/**
 *  接收到透传消息的回调，当程序 activity 的时候
 *
 *  @param cmdMessage
 */
- (void)didReceiveCmdMessage:(EMMessage *)cmdMessage
{
    [TZCMDChatHelper distributeCMDMsg:cmdMessage];
    NSLog(@"接收到透传消息:  %@",cmdMessage);
}

/**
 *  是否需要显示推送通知
 *
 *  @param fromChatter
 *
 *  @return
 */
- (BOOL)needShowNotification:(NSString *)fromChatter
{
    BOOL ret = YES;
    NSArray *igGroupIds = [[EaseMob sharedInstance].chatManager ignoredGroupIds];
    for (NSString *str in igGroupIds) {
        if ([str isEqualToString:fromChatter]) {
            ret = NO;
            break;
        }
    }
    
    if (ret) {
        EMPushNotificationOptions *options = [[EaseMob sharedInstance].chatManager pushNotificationOptions];
        
        do {
            if (options.noDisturbing) {
                NSDate *now = [NSDate date];
                NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitHour | NSCalendarUnitMinute fromDate:now];
                NSInteger hour = [components hour];
                //        NSInteger minute= [components minute];
                
                NSUInteger startH = options.noDisturbingStartH;
                NSUInteger endH = options.noDisturbingEndH;
                if (startH>endH) {
                    endH += 24;
                }
                
                if (hour>=startH && hour<=endH) {
                    ret = NO;
                    break;
                }
            }
        } while (0);
    }
    
    return ret;
}

- (void)playSoundAndVibration{
    //如果距离上次响铃和震动时间太短, 则跳过响铃
    NSLog(@"%@, %@", [NSDate date], self.lastPlaySoundDate);
    
    NSTimeInterval timeInterval = [[NSDate date]
                                   timeIntervalSinceDate:self.lastPlaySoundDate];
    if (timeInterval < kDefaultPlaySoundInterval) {
        return;
    }
    //保存最后一次响铃时间
    self.lastPlaySoundDate = [NSDate date];
    
    // 收到消息时，播放音频
    [[EaseMob sharedInstance].deviceManager asyncPlayNewMessageSound];
    // 收到消息时，震动
    [[EaseMob sharedInstance].deviceManager asyncPlayVibration];
}

- (void)showNotificationWithMessage:(EMMessage *)message
{
    EMPushNotificationOptions *options = [[EaseMob sharedInstance].chatManager pushNotificationOptions];
    //发送本地推送
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    notification.fireDate = [NSDate date]; //触发通知的时间
    
    if (options.displayStyle == ePushNotificationDisplayStyle_messageSummary) {
        id<IEMMessageBody> messageBody = [message.messageBodies firstObject];
        NSString *messageStr = nil;
        switch (messageBody.messageBodyType) {
            case eMessageBodyType_Text:
            {
                messageStr = ((EMTextMessageBody *)messageBody).text;
            }
                break;
            case eMessageBodyType_Image:
            {
                messageStr = @"[图片]";
            }
                break;
            case eMessageBodyType_Location:
            {
                messageStr = @"[位置]";
            }
                break;
            case eMessageBodyType_Voice:
            {
                messageStr = @"[音频]";
            }
                break;
            case eMessageBodyType_Video:{
                messageStr = @"[视频]";
            }
                break;
            default:
                break;
        }
        
        NSString *title = message.from;
        if (message.isGroup) {
            NSArray *groupArray = [[EaseMob sharedInstance].chatManager groupList];
            for (EMGroup *group in groupArray) {
                if ([group.groupId isEqualToString:message.conversationChatter]) {
                    title = [NSString stringWithFormat:@"%@(%@)", message.groupSenderName, group.groupSubject];
                    break;
                }
            }
        }
        
        notification.alertBody = [NSString stringWithFormat:@"%@:%@", title, messageStr];
    }
    else{
        notification.alertBody = @"您有一条新消息";
    }
    
    notification.alertAction = @"打开";
    notification.timeZone = [NSTimeZone defaultTimeZone];
    //发送通知
    [[UIApplication sharedApplication] scheduleLocalNotification:notification];
    //    UIApplication *application = [UIApplication sharedApplication];
    //    application.applicationIconBadgeNumber += 1;
}

#pragma mark - IChatManagerDelegate 登陆回调（主要用于监听自动登录是否成功）

- (void)didLoginWithInfo:(NSDictionary *)loginInfo error:(EMError *)error
{
    if (error) {
        NSLog(@"自动登录失败");
    } else {
        NSLog(@"自动登录成功");
    }
}

#pragma mark - IChatManagerDelegate 好友变化

- (void)didReceiveBuddyRequest:(NSString *)username
                       message:(NSString *)message
{
#if !TARGET_IPHONE_SIMULATOR
    [self playSoundAndVibration];
    
    BOOL isAppActivity = [[UIApplication sharedApplication] applicationState] == UIApplicationStateActive;
    if (!isAppActivity) {
        //发送本地推送
        UILocalNotification *notification = [[UILocalNotification alloc] init];
        notification.fireDate = [NSDate date]; //触发通知的时间
        notification.alertBody = [NSString stringWithFormat:@"%@ %@", username, @"添加你为桃友"];
        notification.alertAction = @"打开";
        notification.timeZone = [NSTimeZone defaultTimeZone];
    }
#endif
    
}

- (void)didUpdateBuddyList:(NSArray *)buddyList
            changedBuddies:(NSArray *)changedBuddies
                     isAdd:(BOOL)isAdd
{
    NSLog(@"buddyList:%@/n changeedBuddies:%@", buddyList, changedBuddies);
}

- (void)didRemovedByBuddy:(NSString *)username
{
    NSLog(@"didRemovedByBuddy我要删除会话");
    [[EaseMob sharedInstance].chatManager removeConversationByChatter:username deleteMessages:YES];
}

- (void)didAcceptedByBuddy:(NSString *)username
{
}

- (void)didRejectedByBuddy:(NSString *)username
{
    NSLog(@"%@", [NSString stringWithFormat:@"你被'%@'无耻的拒绝了", username]);
}

- (void)didAcceptBuddySucceed:(NSString *)username{
}

#pragma mark - IChatManagerDelegate 群组变化

- (void)didReceiveGroupInvitationFrom:(NSString *)groupId
                              inviter:(NSString *)username
                              message:(NSString *)message
{
    NSLog(@"didReceiveGroupInvitationFrom");
    [self playSoundAndVibration];
}

- (void)groupDidUpdateInfo:(EMGroup *)group error:(EMError *)error
{
    NSLog(@"groupDidUpdateInfo");
    AccountManager *accountManager = [AccountManager shareAccountManager];
    [accountManager updateGroup:group.groupId withGroupOwner:group.owner groupSubject:group.groupSubject groupInfo:group.groupDescription];
}

- (void)didAcceptInvitationFromGroup:(EMGroup *)group
                               error:(EMError *)error
{
    NSLog(@"didAcceptInvitationFromGroup");
    
}

- (void)didUpdateGroupList:(NSArray *)allGroups error:(EMError *)error
{
    NSLog(@"didUpdateGroupList");
}

//接收到入群申请
- (void)didReceiveApplyToJoinGroup:(NSString *)groupId
                         groupname:(NSString *)groupname
                     applyUsername:(NSString *)username
                            reason:(NSString *)reason
                             error:(EMError *)error
{
    if (!error) {
#if !TARGET_IPHONE_SIMULATOR
        NSLog(@"didReceiveGroupInvitationFrom");
        [self playSoundAndVibration];
#endif
        
    }
}

/*!
 @method
 @brief 离开一个群组后的回调
 @param group  所要离开的群组对象
 @param reason 离开的原因
 @param error  错误信息
 @discussion
 离开的原因包含主动退出, 被别人请出, 和销毁群组三种情况
 */

- (void)group:(EMGroup *)group didLeave:(EMGroupLeaveReason)reason error:(EMError *)error
{
    NSLog(@"%@", group);
}

- (void)didReceiveGroupRejectFrom:(NSString *)groupId
                          invitee:(NSString *)username
                           reason:(NSString *)reason
{
    NSLog(@"%@", [NSString stringWithFormat:@"你被'%@'无耻的拒绝了", username]);
}


- (void)didReceiveAcceptApplyToJoinGroup:(NSString *)groupId
                               groupname:(NSString *)groupname
{
    NSString *message = [NSString stringWithFormat:@"同意加入群组\'%@\'", groupname];
    [self showHint:message];
}

#pragma mark - IChatManagerDelegate 登录状态变化

- (void)didLoginFromOtherDevice
{
    __weak typeof (ToolBoxViewController *)weakSelf = self;
    [[EaseMob sharedInstance].chatManager asyncLogoffWithCompletion:^(NSDictionary *info, EMError *error) {
        AccountManager *accountManager = [AccountManager shareAccountManager];
        [accountManager asyncLogout:^(BOOL isSuccess) {
            if (isSuccess) {
            } else {
                [weakSelf showHint:@"退出失败"];
            }
        }];

        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示"
                                                            message:@"你的账号已在其他地方登录"
                                                           delegate:self
                                                  cancelButtonTitle:@"确定"
                                                  otherButtonTitles:nil,
                                  nil];
        alertView.tag = 100;
        [alertView show];
    } onQueue:nil];
}

- (void)didRemovedFromServer {
    [[EaseMob sharedInstance].chatManager asyncLogoffWithCompletion:^(NSDictionary *info, EMError *error) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示"
                                                            message:@"你的账号已被从服务器端移除"
                                                           delegate:self
                                                  cancelButtonTitle:@"确定"
                                                  otherButtonTitles:nil,
                                  nil];
        alertView.tag = 101;
        [alertView show];
    } onQueue:nil];
}

- (void)didConnectionStateChanged:(EMConnectionState)connectionState
{
    
}

#pragma mark -

- (void)willAutoReconnect{
    NSLog(@"正在重连中");
}

- (void)didAutoReconnectFinishedWithError:(NSError *)error{
    if (error) {
        NSLog(@"重连失败，稍候将继续重连");
    }else{
        NSLog(@"重连成功");
    }
}




@end

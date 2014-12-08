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

//两次提示的默认间隔
static const CGFloat kDefaultPlaySoundInterval = 3.0;

@interface ToolBoxViewController () <UIAlertViewDelegate, IChatManagerDelegate, MHTabBarControllerDelegate, UIScrollViewDelegate, CLLocationManagerDelegate>
{
    CLLocationManager* locationManager;
    BOOL locationIsGotten;
}

@property (strong, nonatomic) CLLocation *currentLocation;

@property (strong, nonatomic) NSDate *lastPlaySoundDate;
@property (nonatomic, strong) NSArray *operationDataArray;
@property (nonatomic, strong) NSMutableArray *imageViews;

@property (strong, nonatomic) UILabel *weatherLabel;
@property (nonatomic, strong) UIScrollView *galleryPageView;
@property (nonatomic, strong) UIButton *planBtn;
@property (nonatomic, strong) UIButton *favoriteBtn;
@property (nonatomic, strong) UIButton *aroundBtn;
@property (strong, nonatomic) UIButton *IMBtn;

@property (nonatomic, strong) UIImageView *contentFrame;
@property (nonatomic, strong) UIView *weatherFrame;

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
    
    [self setupView];
    
    self.navigationItem.title = @"桃子旅行";
    
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate= self;
    if (IS_IOS8) {
        [locationManager requestAlwaysAuthorization];
    } else {
        [locationManager startUpdatingLocation];
    }

    //获取未读消息数，此时并没有把self注册为SDK的delegate，读取出的未读数是上次退出程序时的
    [self didUnreadMessagesCountChanged];

    [self registerNotifications];
    [self setupUnreadMessageCount];
}

- (void) setupView {
    CGFloat w = CGRectGetWidth(self.view.bounds);
    CGFloat h = CGRectGetHeight(self.view.bounds) - 64.0 - 49.0;
    
    CGFloat offsetY = 64.0;
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    _galleryPageView = [[UIScrollView alloc] initWithFrame:CGRectMake(0.0, offsetY, w, 176.0)];
    _galleryPageView.pagingEnabled = YES;
    _galleryPageView.showsHorizontalScrollIndicator = NO;
    _galleryPageView.showsVerticalScrollIndicator = NO;
    _galleryPageView.delegate = self;
    _galleryPageView.autoresizesSubviews = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:_galleryPageView];
    
    _weatherFrame = [[UIView alloc] initWithFrame:CGRectMake(0.0, offsetY, w, 24.0)];
    _weatherFrame.autoresizesSubviews = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
    _weatherFrame.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.33];
//    [self.view addSubview:_weatherFrame];
    
    _weatherLabel = [[UILabel alloc] initWithFrame:CGRectMake(19.0, 0.0, w - 38.0, 24.0)];
    _weatherLabel.textAlignment = NSTextAlignmentLeft;
    _weatherLabel.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    _weatherLabel.textColor = [UIColor whiteColor];
    _weatherLabel.font = [UIFont systemFontOfSize:13.0];
    [_weatherFrame addSubview:_weatherLabel];
    
    _IMBtn = [[UIButton alloc] initWithFrame:CGRectMake(0.0, h, w, 64.0)];
    _IMBtn.backgroundColor = [UIColor greenColor];
    [_IMBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    _IMBtn.titleLabel.font = [UIFont boldSystemFontOfSize:17.0];
    _IMBtn.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    [_IMBtn setTitle:@"桃·Talk" forState:UIControlStateNormal];
    [_IMBtn addTarget:self action:@selector(jumpIM:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_IMBtn];
    
    offsetY += CGRectGetHeight(_galleryPageView.frame);
    
    _contentFrame = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, offsetY, w, h - offsetY)];
    _contentFrame.contentMode = UIViewContentModeScaleAspectFill;
    _contentFrame.userInteractionEnabled = YES;
    _contentFrame.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:_contentFrame];
    
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 20.0, w, 21.0)];
    title.font = [UIFont systemFontOfSize:17.0];
    title.textColor = TEXT_COLOR_TITLE;
    title.textAlignment = NSTextAlignmentCenter;
    title.text = @"\"旅行助手\"";
    title.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleWidth;
    [_contentFrame addSubview:title];
    
    _favoriteBtn = [[UIButton alloc] initWithFrame:CGRectMake(0.0, 0.0, 76.0, 96.0)];
    _favoriteBtn.titleLabel.font = [UIFont systemFontOfSize:14.0];
    [_favoriteBtn setTitleColor:TEXT_COLOR_TITLE_SUBTITLE forState:UIControlStateNormal];
    [_favoriteBtn setTitleColor:TEXT_COLOR_TITLE forState:UIControlStateHighlighted];
    _favoriteBtn.center = CGPointMake(CGRectGetWidth(_contentFrame.bounds)/2.0, CGRectGetHeight(_contentFrame.bounds)/2.0);
    [_favoriteBtn setImage:[UIImage imageNamed:@"ic_notify_flag.png"] forState:UIControlStateNormal];
    [_favoriteBtn setTitle:@"收藏夹" forState:UIControlStateNormal];
    _favoriteBtn.titleEdgeInsets = UIEdgeInsetsMake(20.0, -20.0, -20.0, 20.0);
    _favoriteBtn.imageEdgeInsets = UIEdgeInsetsMake(-20.0, 20.0, 20.0, -20.0);
    [_favoriteBtn addTarget:self action:@selector(myFavorite:) forControlEvents:UIControlEventTouchUpInside];
    [_contentFrame addSubview:_favoriteBtn];
    
    _planBtn = [[UIButton alloc] initWithFrame:CGRectMake(0.0, 0.0, 76.0, 96.0)];
    _planBtn.titleLabel.font = [UIFont systemFontOfSize:14.0];
    [_planBtn setTitleColor:TEXT_COLOR_TITLE_SUBTITLE forState:UIControlStateNormal];
    [_planBtn setTitleColor:TEXT_COLOR_TITLE forState:UIControlStateHighlighted];
    _planBtn.center = CGPointMake(CGRectGetWidth(_contentFrame.bounds)/2.0 - 76.0, CGRectGetHeight(_contentFrame.bounds)/2.0);
    [_planBtn setImage:[UIImage imageNamed:@"ic_notify_flag.png"] forState:UIControlStateNormal];
    [_planBtn setTitle:@"我的攻略" forState:UIControlStateNormal];
    _planBtn.titleEdgeInsets = UIEdgeInsetsMake(20.0, -20.0, -20.0, 20.0);
    _planBtn.imageEdgeInsets = UIEdgeInsetsMake(-20.0, 20.0, 20.0, -20.0);
    [_planBtn addTarget:self action:@selector(myTravelNote:) forControlEvents:UIControlEventTouchUpInside];
    [_contentFrame addSubview:_planBtn];
    
    _aroundBtn = [[UIButton alloc] initWithFrame:CGRectMake(0.0, 0.0, 76.0, 96.0)];
    _aroundBtn.titleLabel.font = [UIFont systemFontOfSize:14.0];
    [_aroundBtn setTitleColor:TEXT_COLOR_TITLE_SUBTITLE forState:UIControlStateNormal];
    [_aroundBtn setTitleColor:TEXT_COLOR_TITLE forState:UIControlStateHighlighted];
    _aroundBtn.center = CGPointMake(CGRectGetWidth(_contentFrame.bounds)/2.0 + 76.0, CGRectGetHeight(_contentFrame.bounds)/2.0);
    [_aroundBtn setImage:[UIImage imageNamed:@"ic_notify_flag.png"] forState:UIControlStateNormal];
    [_aroundBtn setTitle:@"我身边" forState:UIControlStateNormal];
    _aroundBtn.titleEdgeInsets = UIEdgeInsetsMake(20.0, -20.0, -20.0, 20.0);
    _aroundBtn.imageEdgeInsets = UIEdgeInsetsMake(-20.0, 20.0, 20.0, -20.0);
    [_aroundBtn addTarget:self action:@selector(nearBy:) forControlEvents:UIControlEventTouchUpInside];
    [_contentFrame addSubview:_aroundBtn];

#warning 测试数据
    _operationDataArray = [[NSArray alloc] init];
    OperationData *testData = [[OperationData alloc] init];
    testData.imageUrl = @"http://lvxingpai-img-store.qiniudn.com/assets/images/orig.3419768e362f13d103ce61664610738c.jpg";
    OperationData *testData1 = [[OperationData alloc] init];
    testData1.imageUrl = @"http://lvxingpai-img-store.qiniudn.com/assets/images/612e622e2604f4f0c59cdfa75b422805.jpg";
    OperationData *testData2 = [[OperationData alloc] init];
    testData2.imageUrl = @"http://lvxingpai-img-store.qiniudn.com/assets/images/orig.3419768e362f13d103ce61664610738c.jpg";
    _operationDataArray = @[testData, testData1,testData2];
    [self setupSubView];
}

- (void)viewWillLayoutSubviews {

}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)dealloc
{
    [self unregisterNotifications];
}

- (void) setupSubView
{
    int count = [_operationDataArray count];
    _galleryPageView.contentSize = CGSizeMake(CGRectGetWidth(_galleryPageView.bounds) * count, 0);
    NSMutableArray *images = [[NSMutableArray alloc] init];
    for (NSUInteger i = 0; i < count; i++)
    {
        [images addObject:[NSNull null]];
    }
    _imageViews = images;
    [self loadScrollViewWithPage:0];
    if (count > 1) {
        [self loadScrollViewWithPage:1];
    }
    if (!self.weatherInfo) {
        [_weatherFrame removeFromSuperview];
    } else {
        [_weatherFrame removeFromSuperview];
        [self.view addSubview:_weatherFrame];
    }
    
}

- (void)loadScrollViewWithPage:(NSUInteger)page {
    if (page >= _operationDataArray.count) {
        return;
    }

    UIImageView *img = [_imageViews objectAtIndex:page];
    if ((NSNull *)img == [NSNull null]) {
        img = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0.0, CGRectGetWidth(_galleryPageView.bounds), CGRectGetHeight(_galleryPageView.bounds))];
        img.contentMode = UIViewContentModeScaleAspectFill;
        img.clipsToBounds = YES;
        img.userInteractionEnabled = YES;
        [_imageViews replaceObjectAtIndex:page withObject:img];
        img.tag = page;
        UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewImage:)];
        [img addGestureRecognizer:tap];
    }
    
    if (img.superview == nil) {
        CGRect frame = img.frame;
        frame.origin.x = CGRectGetWidth(frame) * page;
        img.frame = frame;
        [_galleryPageView insertSubview:img atIndex:0];
        OperationData *opreateData = [_operationDataArray objectAtIndex:page];
        NSString *url = opreateData.imageUrl;
        [img sd_setImageWithURL:[NSURL URLWithString:url] placeholderImage:[UIImage imageNamed:@"spot_detail_default.png"]];
    }
}

- (void)setWeatherInfo:(WeatherInfo *)weatherInfo
{
    _weatherInfo = weatherInfo;
    if(_weatherInfo) {
        [self getReverseGeocode];
    }
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

#pragma mark - YWeatherInfoDelegate
- (void)gotWeatherInfo:(WeatherInfo *)weatherInfo
{
    NSLog(@"/*****接收到天气数据******/\n");
    self.weatherInfo = weatherInfo;
    
}

- (void)updateWeatherLabelWithCityName:(NSString *)city
{
    NSString *currentDate = [ConvertMethods getCurrentDataWithFormat:@"yyyy-MM-dd"];
    NSLog(@"%@", _location.description);
    NSString *cityName = city? city:@"当前位置";
    NSString *s = [NSString stringWithFormat:@"  %@  %@  %@",currentDate, cityName, [yahooWeatherCode objectAtIndex:_weatherInfo.mCurrentCode]];
//    [_weatherBtn setTitle:s forState:UIControlStateNormal];
    _weatherLabel.text = s;
    [_weatherFrame removeFromSuperview];
    [self.view addSubview:_weatherFrame];
//    [UIView animateWithDuration:0.3 animations:^{
//        _weatherBtn.alpha = 0.5;
//    } completion:^(BOOL finished) {
//        
//    }];
}

#pragma mark - IBAction Methods

- (IBAction)viewImage:(id)sender
{
    
}

//进入聊天功能
- (IBAction)jumpIM:(UIButton *)sender {
    AccountManager *accountManager = [AccountManager shareAccountManager];
    if ([accountManager isLogin]) {

        ContactListViewController *contactListCtl = [[ContactListViewController alloc] init];
        contactListCtl.title = @"好友";
        if ([accountManager numberOfUnReadFrendRequest]) {
            contactListCtl.notify = YES;
        } else {
            contactListCtl.notify = NO;
        }
        
        ChatListViewController *chatListCtl = [[ChatListViewController alloc] init];
        chatListCtl.title = @"消息";
        chatListCtl.notify = NO;
        
        NSArray *viewControllers = [NSArray arrayWithObjects:chatListCtl,contactListCtl, nil];
        IMRootViewController *IMRootCtl = [[IMRootViewController alloc] init];
        IMRootCtl.delegate = self;
        IMRootCtl.viewControllers = viewControllers;
        IMRootCtl.hidesBottomBarWhenPushed = YES;
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
    FavoriteViewController *fvc = [[FavoriteViewController alloc] init];
    [self.navigationController pushViewController:fvc animated:YES];
}

- (IBAction)myTravelNote:(UIButton *)sender {
    
    MyGuideListTableViewController *myGuidesCtl = [[MyGuideListTableViewController alloc] init];
    AccountManager *accountManager = [AccountManager shareAccountManager];
    if (!accountManager.isLogin) {
        [self performSelector:@selector(goLogin:) withObject:nil afterDelay:0.3];
        [SVProgressHUD showErrorWithStatus:@"请先登录"];
    } else {
        myGuidesCtl.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:myGuidesCtl animated:YES];
    }
}

- (IBAction)goLogin:(id)sender
{
    LoginViewController *loginCtl = [[LoginViewController alloc] init];
    UINavigationController *nctl = [[UINavigationController alloc] initWithRootViewController:loginCtl];
    loginCtl.hidesBottomBarWhenPushed = YES;
    loginCtl.isPushed = NO;
    [self.navigationController presentViewController:nctl animated:YES completion:nil];
}

#pragma mark - private

-(void)registerNotifications
{
    [self unregisterNotifications];
    [[EaseMob sharedInstance].chatManager addDelegate:self delegateQueue:nil];
}

-(void)unregisterNotifications
{
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

#pragma mark - IChatManagerDelegate 消息变化

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

- (BOOL)needShowNotification:(NSString *)fromChatter
{
    BOOL ret = YES;
    NSArray *igGroupIds = [[EaseMob sharedInstance].chatManager ignoredGroupList];
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

// 收到消息回调
-(void)didReceiveMessage:(EMMessage *)message
{
    NSLog(@"收到消息，消息为%@", message);
    id<IEMMessageBody> messageBody = [message.messageBodies firstObject];
    if (messageBody.messageBodyType == eMessageBodyType_Command) {
        [TZCMDChatHelper distributeCMDMsg:message];
        UIAlertView *a = [[UIAlertView alloc] initWithTitle:@"接收到透传消息" message:nil delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:nil, nil];
        [a show];
        
    }
    BOOL needShowNotification = message.isGroup ? [self needShowNotification:message.conversation.chatter] : YES;
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
                if ([group.groupId isEqualToString:message.conversation.chatter]) {
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
        AccountManager *accountManager = [AccountManager shareAccountManager];
        [[EaseMob sharedInstance].chatManager asyncLoginWithUsername:accountManager.account.easemobUser
                                                            password:accountManager.account.easemobPwd
                                                          completion:
         ^(NSDictionary *loginInfo, EMError *error) {
             if (error) {
                 NSLog(@"登录失败：%@", error);
             } else {
                 NSLog(@"登录成功");
             }
         } onQueue:nil];
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
        notification.alertBody = [NSString stringWithFormat:@"%@ %@", username, @"添加你为好友"];
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
    NSString *message = [NSString stringWithFormat:@"你被'%@'无耻的拒绝了", username];
    NSLog(@"%@", message);
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

    if (!error) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"groupDidUpdateInfo" object:nil];
    }
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

- (void)didReceiveGroupRejectFrom:(NSString *)groupId
                          invitee:(NSString *)username
                           reason:(NSString *)reason
{
    NSString *message = [NSString stringWithFormat:@"你被'%@'无耻的拒绝了", username];
    NSLog(@"%@", message);
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
    [[EaseMob sharedInstance].chatManager asyncLogoffWithCompletion:^(NSDictionary *info, EMError *error) {
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
    [self hideHud];
    [self showHudInView:self.view hint:@"正在重连中..."];
}

- (void)didAutoReconnectFinishedWithError:(NSError *)error{
    [self hideHud];
    if (error) {
        [self showHint:@"重连失败，稍候将继续重连"];
    }else{
        [self showHint:@"重连成功！"];
    }
}

#pragma scrolldelegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (scrollView == _galleryPageView) {
        CGFloat pageWidth = CGRectGetWidth(self.galleryPageView.frame);
        NSUInteger page = floor((self.galleryPageView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
        [self loadScrollViewWithPage:page - 1];
        [self loadScrollViewWithPage:page];
        [self loadScrollViewWithPage:page + 1];
    }
}




@end

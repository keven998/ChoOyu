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

//两次提示的默认间隔
static const CGFloat kDefaultPlaySoundInterval = 3.0;

@interface ToolBoxViewController () <UIAlertViewDelegate, IChatManagerDelegate, MHTabBarControllerDelegate, UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet UIButton *weatherBtn;
@property (strong, nonatomic)NSDate *lastPlaySoundDate;
@property (weak, nonatomic) IBOutlet UIButton *IMBtn;
@property (weak, nonatomic) IBOutlet UIScrollView *galleryPageView;
@property (nonatomic, strong) NSArray *operationDataArray;
@property (nonatomic, strong) NSMutableArray *imageViews;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *weatherBtnConstraints;

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

    //获取未读消息数，此时并没有把self注册为SDK的delegate，读取出的未读数是上次退出程序时的
    [self didUnreadMessagesCountChanged];

    [self registerNotifications];
    [self setupUnreadMessageCount];
    
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

- (void)dealloc
{
    [self unregisterNotifications];
}

- (void) setupSubView
{
    _galleryPageView.pagingEnabled = YES;
    _galleryPageView.showsHorizontalScrollIndicator = NO;
    _galleryPageView.showsVerticalScrollIndicator = NO;
    _galleryPageView.delegate = self;
    _galleryPageView.bounces = YES;
    
    NSLog(@"%@", NSStringFromCGRect(_galleryPageView.frame));

    int count = [_operationDataArray count];
    _galleryPageView.contentSize = CGSizeMake(kWindowWidth * count, CGRectGetHeight(_galleryPageView.frame));
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
        self.weatherBtn.alpha = 0;
    } else {
        self.weatherBtn.alpha = 0.5;
    }
    
}

- (void)loadScrollViewWithPage:(NSUInteger)page {
    if (page >= _operationDataArray.count) {
        return;
    }

    UIImageView *img = [_imageViews objectAtIndex:page];
    if ((NSNull *)img == [NSNull null]) {
        img = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0.0, self.view.bounds.size.width, 176)];
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
        [self.galleryPageView insertSubview:img atIndex:0];
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

- (void)getReverseGeocode
{
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];

    CLLocationCoordinate2D myCoOrdinate;
    
    myCoOrdinate.latitude = _location.coordinate.latitude;
    myCoOrdinate.longitude = _location.coordinate.longitude;
    
    CLLocation *location = [[CLLocation alloc] initWithLatitude:myCoOrdinate.latitude longitude:myCoOrdinate.longitude];
    [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error)
     {
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

- (void)updateWeatherLabelWithCityName:(NSString *)city
{
    NSString *currentDate = [ConvertMethods getCurrentDataWithFormat:@"yyyy-MM-dd"];
    NSLog(@"%@", _location.description);
    NSString *cityName = city? city:@"当前位置";
    NSString *sss = [yahooWeatherCode objectAtIndex:_weatherInfo.mCurrentCode];
    NSString *s = [NSString stringWithFormat:@"%@  %@  %@",currentDate, cityName, [yahooWeatherCode objectAtIndex:_weatherInfo.mCurrentCode]];
    [_weatherBtn setTitle:s forState:UIControlStateNormal];
    [UIView animateWithDuration:0.3 animations:^{
        _weatherBtn.alpha = 0.5;
    } completion:^(BOOL finished) {
    }];
    


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
        contactListCtl.notify = YES;
        
        ChatListViewController *chatListCtl = [[ChatListViewController alloc] init];
        chatListCtl.title = @"消息";
        chatListCtl.notify = YES;
        
        NSArray *viewControllers = [NSArray arrayWithObjects:chatListCtl,contactListCtl, nil];
        
//        MHTabBarController *tabBarController = [[MHTabBarController alloc] init];
//        tabBarController.delegate = self;
//        tabBarController.viewControllers = viewControllers;
//        tabBarController.hidesBottomBarWhenPushed = YES;
//        [self.navigationController pushViewController:tabBarController animated:YES];
        
        
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
}

- (IBAction)myTravelNote:(UIButton *)sender {
}

- (IBAction)goLogin:(id)sender
{
    LoginViewController *loginCtl = [[LoginViewController alloc] init];
    [self.navigationController pushViewController:loginCtl animated:YES];
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
        NSString *hintText = @"你的账号登录失败，正在重试中... \n点击 '登出' 按钮跳转到登录页面 \n点击 '继续等待' 按钮等待重连成功";
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示"
                                                            message:hintText
                                                           delegate:self
                                                  cancelButtonTitle:@"继续等待"
                                                  otherButtonTitles:@"登出",
                                  nil];
        alertView.tag = 99;
        [alertView show];
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

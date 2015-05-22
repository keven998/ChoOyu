/************************************************************
  *  * EaseMob CONFIDENTIAL 
  * __________________ 
  * Copyright (C) 2013-2014 EaseMob Technologies. All rights reserved. 
  *  
  * NOTICE: All information contained herein is, and remains 
  * the property of EaseMob Technologies.
  * Dissemination of this information or reproduction of this material 
  * is strictly forbidden unless prior written permission is obtained
  * from EaseMob Technologies.
  */

#import "ChatViewController.h"

#import <MediaPlayer/MediaPlayer.h>
#import <MobileCoreServices/MobileCoreServices.h>

#import "DXChatBarMoreView.h"
#import "DXRecordView.h"
#import "DXFaceView.h"
#import "HPGrowingTextView.h"
#import "EMChatViewCell.h"
#import "TipsChatTableViewCell.h"
#import "EMChatTimeCell.h"
#import "ChatSendHelper.h"
#import "MessageReadManager.h"
#import "LocationViewController.h"
#import "UIViewController+HUD.h"
#import "NSDate+Category.h"
#import "DXMessageToolBar.h"
#import "DXChatBarMoreView.h"
#import "CallViewController.h"
#import "ZYQAssetPickerController.h"
#import "ChatGroupSettingViewController.h"
#import "ChatSettingViewController.h"
#import "AccountManager.h"
#import "Group.h"
#import "ContactDetailViewController.h"
#import "SearchUserInfoViewController.h"
#import "CreateConversationViewController.h"
#import "SpotDetailViewController.h"
#import "MyGuideListTableViewController.h"
#import "FavoriteViewController.h"
#import "CityDetailTableViewController.h"
#import "SearchDestinationViewController.h"
#import "TravelNoteListViewController.h"
#import "TravelNoteDetailViewController.h"
#import "CommonPoiDetailViewController.h"
#import "RestaurantDetailViewController.h"
#import "HotelDetailViewController.h"
#import "ShoppingDetailViewController.h"
#import "TZSideViewController.h"
#import "REFrostedViewController.h"
#import "TripPlanSettingViewController.h"

#import "TripDetailRootViewController.h"
#import "PeachTravel-swift.h"

#define KPageCount 20

@interface ChatViewController ()<UITableViewDataSource, UITableViewDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, IChatManagerDelegate, DXChatBarMoreViewDelegate, DXMessageToolBarDelegate, LocationViewDelegate, IDeviceManagerDelegate, ZYQAssetPickerControllerDelegate, ChatConversationDelegate>
{
    UIMenuController *_menuController;
    UIMenuItem *_copyMenuItem;
    UIMenuItem *_deleteMenuItem;
    NSIndexPath *_longPressIndexPath;
    
    NSInteger _recordingCount;
    
    dispatch_queue_t _messageQueue;
    dispatch_queue_t loadChatPeopleQueue;
    BOOL _isScrollToBottom;
}

@property (nonatomic) IMChatType chatType;
@property (nonatomic) NSInteger chatter;

@property (strong, nonatomic) NSMutableArray *dataSource;//tableView数据源
@property (strong, nonatomic) IMGroupModel *group;   //保存群组的人员信息

@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) DXMessageToolBar *chatToolBar;

@property (nonatomic, strong) UIView *headerView;
@property (nonatomic, strong) UIActivityIndicatorView *headerLoading;

@property (strong, nonatomic) UIImagePickerController *imagePicker;

@property (strong, nonatomic) MessageReadManager *messageReadManager;//message阅读的管理者
@property (nonatomic, strong) ChatConversation *conversation;
@property (strong, nonatomic) NSDate *chatTagDate;

@property (nonatomic) BOOL isScrollToBottom;
@property (nonatomic) BOOL isPlayingAudio;
@property (nonatomic, strong) AccountManager *accountManager;

@property (nonatomic, assign) BOOL didEndScroll;

@end

@implementation ChatViewController

- (instancetype)initWithConversation:(ChatConversation *)conversation
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        _isPlayingAudio = NO;
        _chatter = conversation.chatterId;
        _chatType = conversation.chatType;
        _conversation = conversation;
        _didEndScroll = YES;
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = APP_PAGE_COLOR;
    _conversation.isCurrentConversation = YES;
    _conversation.delegate = self;
    [_conversation resetConvsersationUnreadMessageCount];
    [_conversation getDefaultChatMessageInConversation:20];
    
    for (BaseMessage *message in _conversation.chatMessageList) {
        [self.dataSource addObject:[[MessageModel alloc] initWithBaseMessage:(message)]];
    }

    [[[EaseMob sharedInstance] deviceManager] addDelegate:self onQueue:nil];
    [[EaseMob sharedInstance].chatManager removeDelegate:self];
    //注册为SDK的ChatManager的delegate
    [[EaseMob sharedInstance].chatManager addDelegate:self delegateQueue:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removeAllMessages:) name:@"RemoveAllMessages" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(exitGroup) name:@"ExitGroup" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackground) name:@"applicationDidEnterBackground" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateChatView:) name:updateChateViewNoti object:nil];

    _messageQueue = dispatch_queue_create("easemob.com", NULL);

    self.automaticallyAdjustsScrollViewInsets = NO;

    [self.view addSubview:self.tableView];
    [self.view addSubview:self.chatToolBar];
    
    self.tableView.tableHeaderView = self.headerView;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(keyBoardHidden)];
    [self.view addGestureRecognizer:tap];
    _isScrollToBottom = YES;
    
    [self setupBarButtonItem];
}

- (UIView *)headerView {
    if (!_headerView) {
        _headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.tableView.bounds), 44.0)];
        _headerView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        
        UIActivityIndicatorView *indicatroView = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 32.0, 32.0)];
        [indicatroView setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
        [indicatroView setCenter:CGPointMake(CGRectGetWidth(self.tableView.bounds)/2.0, 44.0/2.0)];
        [_headerView addSubview:indicatroView];
        _headerLoading = indicatroView;
    }
    return _headerView;
}

- (void)setupBarButtonItem
{
    UINavigationBar *bar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 64)];
    UINavigationItem *navTitle = [[UINavigationItem alloc] initWithTitle:self.chatterNickName];

    if (_chatType == IMChatTypeIMChatGroupType) {
        UIButton *menu = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 44)];
        [menu setImage:[UIImage imageNamed:@"ic_menu_navigationbar.png"] forState:UIControlStateNormal];
        [menu addTarget:self action:@selector(showMenu) forControlEvents:UIControlEventTouchUpInside];
        [menu setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
        navTitle.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:menu];
    }
    
    UIButton *back = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 44)];
    [back setImage:[UIImage imageNamed:@"ic_navigation_back.png"] forState:UIControlStateNormal];
    [back addTarget:self action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];
    [back setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    navTitle.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:back];

    [bar pushNavigationItem:navTitle animated:YES];
    [self.view addSubview:bar];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [MobClick beginLogPageView:@"page_talking"];
    [_chatToolBar registerNoti];
    if (_isScrollToBottom) {
        [self scrollViewToBottom:YES];
    }
    else{
        _isScrollToBottom = YES;
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:@"page_talking"];
    [_chatToolBar unRegisterNoti];
    // 设置当前conversation的所有message为已读
    _conversation.unReadMessageCount = 0;
}

- (void)dealloc
{
    _tableView.delegate = nil;
    _tableView.dataSource = nil;
    _tableView = nil;
    
    _chatToolBar.delegate = nil;
    _chatToolBar = nil;
    
    [[EaseMob sharedInstance].chatManager stopPlayingAudio];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - IBAction Methods

- (void)showMenu
{
    [self.view endEditing:YES];
    [self.frostedViewController.view endEditing:YES];
    
    [self.frostedViewController presentMenuViewController];
}

/**
 * 实现父类的后退按钮
 */
- (void)goBack
{
    [self.frostedViewController dismissViewControllerAnimated:YES completion:nil];
    [self.frostedViewController.navigationController popToRootViewControllerAnimated:YES];
}

/**
 *  点击聊天的头像进入联系人信息
 *
 *  @param sender
 */
- (void)showUserInfoWithModel:(MessageModel *)model
{
    if (model.isSender) {
        return;
    }
    
//    Contact *contact = [self.accountManager TZContactByEasemobUser:model.username];
//    if (!contact) {
//        for (Contact *tempContact in self.peopleInGroup) {
//            if ([tempContact.easemobUser isEqualToString:model.username]) {
//                [self  showUserInfoWithContactInfo:tempContact];
//                return;
//            }
//        }
//        if (!contact) {
//             __weak typeof(ChatViewController *)weakSelf = self;
//            TZProgressHUD *hud = [[TZProgressHUD alloc] init];
//            [hud showHUDInViewController:weakSelf];
//            [self asyncLoadGroupFromEasemobServerWithCompletion:^(BOOL isSuccess) {
//                [hud hideTZHUD];
//                if (isSuccess) {
//                    for (Contact *tempContact in self.peopleInGroup) {
//                        if ([tempContact.easemobUser isEqualToString:model.username]) {
//                            [self  showUserInfoWithContactInfo:tempContact];
//                            break;
//                        }
//                    }
//                }
//            }];
//        }
//    } else {
//        [self  showUserInfoWithContactInfo:contact];
//    }
}

- (void)showUserInfoWithContactInfo:(Contact *)contact
{
//    if ([self.accountManager isMyFrend:contact.userId]) {
//        ContactDetailViewController *contactDetailCtl = [[ContactDetailViewController alloc] init];
//        contactDetailCtl.contact = contact;
//        if (_isChatGroup) {
//            contactDetailCtl.goBackToChatViewWhenClickTalk = NO;
//        } else {
//            contactDetailCtl.goBackToChatViewWhenClickTalk = YES;
//        }
//        [self.navigationController pushViewController:contactDetailCtl animated:YES];
//        
//    } else {
//        SearchUserInfoViewController *searchUserInfoCtl = [[SearchUserInfoViewController alloc] init];
//        searchUserInfoCtl.userInfo = @{@"userId":contact.userId,
//                                       @"avatar":contact.avatar,
//                                       @"nickName":contact.nickName,
//                                       @"signature":contact.signature,
//                                       @"easemobUser":contact.easemobUser
//                                       };
//        [self.navigationController pushViewController:searchUserInfoCtl animated:YES];
//    }
}

#pragma mark - private Methods

- (NSArray *)loadContactsFromDB
{
    NSMutableArray *contacts = [[NSMutableArray alloc] init];
//    _group = [self.accountManager groupWithGroupId:_chatter];
//    if (_group) {
//        for (id item in _group.numbers) {
//            [contacts addObject:item];
//        }
//    }
    return contacts;
}

/**
 *  在别的页面发送消息，本页面需要将发送的消息插入到 datasource 里
 *
 *  @param noti 包含新消息内容的 noti
 */
- (void)updateChatView:(NSNotification *)noti
{
    BaseMessage *message = [noti.userInfo objectForKey:@"message"];
    //如果是发送的消息是属于当前页面的
    if (message.chatterId == _chatter) {
        [self addChatMessage2DataSource:[noti.userInfo objectForKey:@"message"]];
    }
}

- (void)loadContactsFromTZServerWithGroup:(EMGroup *)emgroup withCompletion:(void(^)(BOOL))completion
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    AppUtils *utils = [[AppUtils alloc] init];
    [manager.requestSerializer setValue:utils.appVersion forHTTPHeaderField:@"Version"];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"iOS %@",utils.systemVersion] forHTTPHeaderField:@"Platform"];
    
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [manager.requestSerializer setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:emgroup.occupants forKey:@"easemob"];
    //获取用户信息列表
    [manager POST:API_GET_USERINFO_WITHEASEMOB parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSInteger code = [[responseObject objectForKey:@"code"] integerValue];
        if (code == 0) {
            completion(YES);
        } else {
            completion(NO);
            [self showHint:@"请求也是失败了"];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        completion(NO);
        [self showHint:@"呃～好像没找到网络"];
    }];
}

#pragma mark - getter

- (AccountManager *)accountManager
{
    if (!_accountManager) {
        _accountManager = [AccountManager shareAccountManager];
        
    }
    return _accountManager;
}

- (NSMutableArray *)dataSource
{
    if (_dataSource == nil) {
        _dataSource = [NSMutableArray array];
    }
    
    return _dataSource;
}

- (UITableView *)tableView
{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 44, CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds) - self.chatToolBar.frame.size.height - 44) style:UITableViewStylePlain];
        _tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.backgroundColor = APP_PAGE_COLOR;
        _tableView.tableFooterView = [[UIView alloc] init];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        
        UILongPressGestureRecognizer *lpgr = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
        lpgr.minimumPressDuration = .5;
        [_tableView addGestureRecognizer:lpgr];
    }
    
    return _tableView;
}

- (DXMessageToolBar *)chatToolBar
{
    if (!_chatToolBar) {
        _chatToolBar = [[DXMessageToolBar alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - [DXMessageToolBar defaultHeight], self.view.frame.size.width, [DXMessageToolBar defaultHeight])];
        _chatToolBar.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
        _chatToolBar.backgroundColor = APP_PAGE_COLOR;
        _chatToolBar.delegate = self;
        _chatToolBar.rootCtl = self;
    }
    
    return _chatToolBar;
}

- (UIImagePickerController *)imagePicker
{
    if (!_imagePicker) {
        _imagePicker = [[UIImagePickerController alloc] init];
        _imagePicker.delegate = self;
    }
    
    return _imagePicker;
}

- (MessageReadManager *)messageReadManager
{
    if (!_messageReadManager) {
        _messageReadManager = [MessageReadManager defaultManager];
    }
    
    return _messageReadManager;
}

- (NSDate *)chatTagDate
{
    if (!_chatTagDate) {
        _chatTagDate = [NSDate dateWithTimeIntervalInMilliSecondSince1970:0];
    }
    
    return _chatTagDate;
}

#pragma mark - Private Methods

- (void)updateChattingPeople
{
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row < [self.dataSource count]) {
        id obj = [self.dataSource objectAtIndex:indexPath.row];
        if ([obj isKindOfClass:[NSString class]]) {
            EMChatTimeCell *timeCell = (EMChatTimeCell *)[tableView dequeueReusableCellWithIdentifier:@"MessageCellTime"];
            if (timeCell == nil) {
                timeCell = [[EMChatTimeCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"MessageCellTime"];
                timeCell.backgroundColor = [UIColor clearColor];
                timeCell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
            timeCell.time = (NSString *)obj;
            return timeCell;
            
        } else if ([obj isKindOfClass:[MessageModel class]]) {
            MessageModel *model = (MessageModel *)obj;
            if (model.type == IMMessageTypeTipsMessageType) {
                TipsChatTableViewCell *tipsCell = (TipsChatTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"MessageCellTips"];
                if (tipsCell == nil) {
                    tipsCell = [[TipsChatTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"MessageCellTips"];
                    tipsCell.backgroundColor = [UIColor clearColor];
                    tipsCell.selectionStyle = UITableViewCellSelectionStyleNone;
                }
                tipsCell.textLabel.text = @"测试 TIPS 消息";
                return tipsCell;
                
            }  else{
                if (model.isChatGroup) {
                } else {
                    model.nickName = _chatterNickName;
                    if (model.isSender) {
                        model.headImageURL = [NSURL URLWithString:self.accountManager.account.avatarSmall];
                    } else {
                        model.headImageURL = [NSURL URLWithString:_chatterAvatar];
                    }
                }
                NSString *cellIdentifier = [EMChatViewCell cellIdentifierForMessageModel:model];
                EMChatViewCell *cell = (EMChatViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
                if (cell == nil) {
                    cell = [[EMChatViewCell alloc] initWithMessageModel:model reuseIdentifier:cellIdentifier];
                    cell.backgroundColor = [UIColor clearColor];
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                }
                cell.messageModel = model;
                
                return cell;
            }
        }
    }
    return nil;
}

#pragma mark - Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSObject *obj = [self.dataSource objectAtIndex:indexPath.row];
    if ([obj isKindOfClass:[NSString class]]) {
        return 40;
    } else {
        return [EMChatViewCell tableView:tableView heightForRowAtIndexPath:indexPath withObject:(MessageModel *)obj];
    }
}

#pragma mark - scrollView delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (_didEndScroll) {
        if (scrollView.contentOffset.y < 40) {
            _didEndScroll = NO;
            [self loadMoreMessages];
        }
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
   _didEndScroll = YES;
}

#pragma mark - GestureRecognizer

// 点击背景隐藏
- (void)keyBoardHidden
{
    [self.chatToolBar endEditing:YES];
}

- (void)handleLongPress:(UILongPressGestureRecognizer *)recognizer
{
	if (recognizer.state == UIGestureRecognizerStateBegan && [self.dataSource count] > 0) {
        CGPoint location = [recognizer locationInView:self.tableView];
        NSIndexPath * indexPath = [self.tableView indexPathForRowAtPoint:location];
        id object = [self.dataSource objectAtIndex:indexPath.row];
        if ([object isKindOfClass:[MessageModel class]]) {
            if (((MessageModel *)object).type == IMMessageTypeTipsMessageType) {
                return;
            }
            EMChatViewCell *cell = (EMChatViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];
            [cell becomeFirstResponder];
            _longPressIndexPath = indexPath;
            [self showMenuViewController:cell.bubbleView andIndexPath:indexPath messageType:cell.messageModel.type];
        }
    }
}

#pragma mark - UIResponder actions

- (void)routerEventWithName:(NSString *)eventName userInfo:(NSDictionary *)userInfo
{
    MessageModel *model = [userInfo objectForKey:KMESSAGEKEY];
    if ([eventName isEqualToString:kRouterEventTextURLTapEventName]) {
        [self chatTextCellUrlPressed:[userInfo objectForKey:@"url"]];
        
    } else if ([eventName isEqualToString:kRouterEventAudioBubbleTapEventName]) {
        [self chatAudioCellBubblePressed:model];
        
    } else if ([eventName isEqualToString:kRouterEventImageBubbleTapEventName]){
        [self chatImageCellBubblePressed:model andImageView:[userInfo objectForKey:@"imageView"]];
        
    } else if ([eventName isEqualToString:kRouterEventLocationBubbleTapEventName]){
        [self chatLocationCellBubblePressed:model];
        
    } else if ([eventName isEqualToString:kRouterEventTaoziBubbleTapEventName]) {
        [self chatTaoziBubblePressed:model];
        
    } else if([eventName isEqualToString:kResendButtonTapEventName]){
        EMChatViewCell *resendCell = [userInfo objectForKey:kShouldResendCell];
        MessageModel *messageModel = resendCell.messageModel;
        messageModel.status = eMessageDeliveryState_Delivering;
        NSIndexPath *indexPath = [self.tableView indexPathForCell:resendCell];
        [self.tableView beginUpdates];
        [self.tableView reloadRowsAtIndexPaths:@[indexPath]
                              withRowAnimation:UITableViewRowAnimationNone];
        [self.tableView endUpdates];
        id <IChatManager> chatManager = [[EaseMob sharedInstance] chatManager];
        [chatManager asyncResendMessage:messageModel.message progress:nil];

    } else if ([eventName isEqualToString:kRouterEventChatHeadImageTapEventName]) {   //点击头像
        [self showUserInfoWithModel:model];
    }
}

/**
 *  链接被点击
 *
 *  @param url
 */
- (void)chatTextCellUrlPressed:(NSURL *)url
{
    if (url) {
        [[UIApplication sharedApplication] openURL:url];
    }
}

/**
 *  语音的bubble被点击
 *
 *  @param model
 */
- (void)chatAudioCellBubblePressed:(MessageModel *)model
{
    if (!model.isSender) {
        id <IEMFileMessageBody> body = [model.message.messageBodies firstObject];
        EMAttachmentDownloadStatus downloadStatus = [body attachmentDownloadStatus];
        if (downloadStatus == EMAttachmentDownloading) {
            [self showHint:@"正在下载语音，稍后点击"];
            return;
        }
        else if (downloadStatus == EMAttachmentDownloadFailure)
        {
            [self showHint:@"正在下载语音，稍后点击"];
            [[EaseMob sharedInstance].chatManager asyncFetchMessage:model.message progress:nil];
            
            return;
        }
    }
    
    // 播放音频
    if (model.type == eMessageBodyType_Voice) {
        __weak ChatViewController *weakSelf = self;
        BOOL isPrepare = [self.messageReadManager prepareMessageAudioModel:model updateViewCompletion:^(MessageModel *prevAudioModel, MessageModel *currentAudioModel) {
            if (prevAudioModel || currentAudioModel) {
                [weakSelf.tableView reloadData];
            }
        }];
        
        if (isPrepare) {
            _isPlayingAudio = YES;
            __weak ChatViewController *weakSelf = self;
            [[[EaseMob sharedInstance] deviceManager] enableProximitySensor];
            [[EaseMob sharedInstance].chatManager asyncPlayAudio:model.chatVoice completion:^(EMError *error) {
                [weakSelf.messageReadManager stopMessageAudioModel];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakSelf.tableView reloadData];
                    
                    weakSelf.isPlayingAudio = NO;
                });
            } onQueue:nil];
        }
        else{
            _isPlayingAudio = NO;
        }
    }
}

// 位置的bubble被点击
- (void)chatLocationCellBubblePressed:(MessageModel *)model
{
    _isScrollToBottom = NO;
    LocationViewController *locationController = [[LocationViewController alloc] initWithLocation:CLLocationCoordinate2DMake(model.latitude, model.longitude)];
    [self.navigationController pushViewController:locationController animated:YES];
}

/**
 *  自定义旅行派消息的气泡被点击
 *
 *  @param model 回传的 气泡所属的 model
 */
- (void)chatTaoziBubblePressed:(MessageModel *)model
{
    _isScrollToBottom = NO;
    [self keyBoardHidden];
    switch (model.type) {
        case IMMessageTypeSpotMessageType: {
            SpotDetailViewController *spotDetailCtl = [[SpotDetailViewController alloc] init];
            spotDetailCtl.title = model.poiModel.poiName;
            spotDetailCtl.spotId = model.poiModel.poiId;
            [self.navigationController pushViewController:spotDetailCtl animated:YES];
        }
            break;
             
        case IMMessageTypeRestaurantMessageType: {
            CommonPoiDetailViewController *restaurantDetailCtl = [[RestaurantDetailViewController alloc] init];
            restaurantDetailCtl.title = model.poiModel.poiName;
            restaurantDetailCtl.poiId = model.poiModel.poiId;
            [self.navigationController pushViewController:restaurantDetailCtl animated:YES];
        }
            break;
            
        case IMMessageTypeShoppingMessageType: {
            CommonPoiDetailViewController *shoppingCtl = [[ShoppingDetailViewController alloc] init];
            shoppingCtl.title = model.poiModel.poiName;
            shoppingCtl.poiId = model.poiModel.poiId;
            [self.navigationController pushViewController:shoppingCtl animated:YES];
            NSLog(@"asda");
        }
            break;
            
        case IMMessageTypeHotelMessageType: {
            CommonPoiDetailViewController *hotelCtl = [[HotelDetailViewController alloc] init];
            hotelCtl.title = model.poiModel.poiName;
            hotelCtl.poiId = model.poiModel.poiId;
            [self.navigationController pushViewController:hotelCtl animated:YES];
        }
            break;
            
        case IMMessageTypeTravelNoteMessageType: {
            TravelNoteDetailViewController *travelNoteCtl = [[TravelNoteDetailViewController alloc] init];
            TravelNote *travelNote = [[TravelNote alloc] init];
            
            travelNote.title = model.poiModel.poiName;
            travelNote.summary = model.poiModel.desc;
            
            TaoziImage *image = [[TaoziImage alloc] init];
            
            image.imageUrl = model.poiModel.image;
            travelNote.images = @[image];
            
            travelNote.detailUrl = model.poiModel.detailUrl;
            travelNote.travelNoteId = model.poiModel.poiId;
            travelNoteCtl.titleStr = @"游记详情";
            travelNoteCtl.travelNote = travelNote;
            [self.navigationController pushViewController:travelNoteCtl animated:YES];
        }
            break;
            
        case IMMessageTypeGuideMessageType: {
            TripDetailRootViewController *tripDetailCtl = [[TripDetailRootViewController alloc] init];
            tripDetailCtl.tripId = model.poiModel.poiId;
            tripDetailCtl.isMakeNewTrip = NO;
            if (model.isSender) {
                tripDetailCtl.canEdit = YES;
            } else {
                tripDetailCtl.canEdit = NO;
            }
            
            TripPlanSettingViewController *tpvc = [[TripPlanSettingViewController alloc] init];
            
            REFrostedViewController *frostedViewController = [[REFrostedViewController alloc] initWithContentViewController:tripDetailCtl menuViewController:tpvc];
            frostedViewController.direction = REFrostedViewControllerDirectionRight;
            frostedViewController.liveBlurBackgroundStyle = REFrostedViewControllerLiveBackgroundStyleLight;
            frostedViewController.liveBlur = YES;
            frostedViewController.limitMenuViewSize = YES;
            frostedViewController.resumeNavigationBar = NO;
            [self.navigationController pushViewController:frostedViewController animated:YES];
        }
            break;
        
        case IMMessageTypeCityPoiMessageType: {
            _isScrollToBottom = NO;
            CityDetailTableViewController *cityCtl = [[CityDetailTableViewController alloc] init];
            cityCtl.title = model.poiModel.poiName;
            cityCtl.cityId = model.poiModel.poiId;
            [self.navigationController pushViewController:cityCtl animated:YES];
        }
            break;
            
        default:
            break;
    }
}

// 图片的bubble被点击
- (void)chatImageCellBubblePressed:(MessageModel *)model andImageView:(UIImageView *)imageView
{
    [self keyBoardHidden];
    __weak ChatViewController *weakSelf = self;
    
    if (model.type == IMMessageTypeImageMessageType) {
        NSString *imageUrl = ((ImageMessage *)model.baseMessage).localPath;
        [weakSelf.messageReadManager showBrowserWithImages:@[[NSURL URLWithString:imageUrl]] andImageView:imageView];
    }
}


#pragma mark - EMChatBarMoreViewDelegate

/**
 *  发送我的攻略
 *
 *  @param moreView
 */
- (void)moreViewMyStrategyAction:(DXChatBarMoreView *)moreView
{
    [MobClick event:@"event_share_plan_extra"];
    MyGuideListTableViewController *myGuideListTableCtl = [[MyGuideListTableViewController alloc] init];
    myGuideListTableCtl.chatterId = _chatter;
    myGuideListTableCtl.selectToSend = YES;
    myGuideListTableCtl.chatType = _chatType;
    UINavigationController *ctl = [[UINavigationController alloc] initWithRootViewController:myGuideListTableCtl];
    [self presentViewController:ctl animated:YES completion:^ {
//        [self keyBoardHidden];
    }];
}

/**
 *  发送我的收藏夹里的内容
 *
 *  @param moreView
 */
- (void)moreViewMyFavoriteAction:(DXChatBarMoreView *)moreView
{
    [MobClick event:@"event_share_favorite_extra"];

    FavoriteViewController *favoriteCtl = [[FavoriteViewController alloc] init];
    favoriteCtl.chatType = _chatType;
    favoriteCtl.chatterId = _chatter;
    favoriteCtl.selectToSend = YES;
    UINavigationController *ctl = [[UINavigationController alloc] initWithRootViewController:favoriteCtl];
    [self presentViewController:ctl animated:YES completion:^ {
//        [self keyBoardHidden];
    }];
}

/**
 *  发送目的地
 *
 *  @param moreView 
 */
- (void)moreViewDestinationAction:(DXChatBarMoreView *)moreView
{
    [MobClick event:@"event_share_search_extra"];

//    SearchDestinationViewController *searchCtl = [[SearchDestinationViewController alloc] init];
//    searchCtl.isCanSend = YES;
//    searchCtl.titleStr = @"发送地点";
//    searchCtl.chatter = _chatter;
//    searchCtl.isChatGroup = _isChatGroup;
//    [self.navigationController pushViewController:searchCtl animated:YES];

    SearchDestinationViewController *searchCtl = [[SearchDestinationViewController alloc] init];
    searchCtl.isCanSend = YES;
    searchCtl.chatterId = _chatter;
    searchCtl.chatType = _chatType;
    UINavigationController *tznavc = [[UINavigationController alloc] initWithRootViewController:searchCtl];
    [self presentViewController:tznavc animated:YES completion:^ {
//        [self keyBoardHidden];
    }];
}

/**
 *  发送游记
 *
 *  @param moreView
 */
- (void)moreViewTravelNoteAction:(DXChatBarMoreView *)moreView
{
    [MobClick event:@"event_share_travel_notes_extra"];

    TravelNoteListViewController *travelNoteCtl = [[TravelNoteListViewController alloc] init];
    travelNoteCtl.isSearch = YES;
    travelNoteCtl.chatterId = _chatter;
    travelNoteCtl.chatType = _chatType;
    UINavigationController *tznavc = [[UINavigationController alloc] initWithRootViewController:travelNoteCtl];
    [self presentViewController:tznavc animated:YES completion:^ {
//        [self keyBoardHidden];
    }];
}

- (void)moreViewPhotoAction:(DXChatBarMoreView *)moreView
{
    // 隐藏键盘
//    [self keyBoardHidden];
    
    // 弹出照片选择
    ZYQAssetPickerController *picker = [[ZYQAssetPickerController alloc] init];
    picker.maximumNumberOfSelection = 10;
    picker.assetsFilter = [ALAssetsFilter allPhotos];
    picker.showEmptyGroups=NO;
    picker.myDelegate = self;
    picker.selectionFilter = [NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
        if ([[(ALAsset*)evaluatedObject valueForProperty:ALAssetPropertyType] isEqual:ALAssetTypeVideo]) {
            NSTimeInterval duration = [[(ALAsset*)evaluatedObject valueForProperty:ALAssetPropertyDuration] doubleValue];
            return duration >= 5;
        } else {
            return YES;
        }
    }];
    
    [self presentViewController:picker animated:YES completion:NULL];
}

- (void)moreViewTakePicAction:(DXChatBarMoreView *)moreView
{
//    [self keyBoardHidden];
    
#if TARGET_IPHONE_SIMULATOR
    [self showHint:@"模拟器不支持拍照"];
#elif TARGET_OS_IPHONE
    self.imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    self.imagePicker.mediaTypes = @[(NSString *)kUTTypeImage];
    [self presentViewController:self.imagePicker animated:YES completion:NULL];
#endif
}

- (void)moreViewLocationAction:(DXChatBarMoreView *)moreView
{
    // 隐藏键盘
//    [self keyBoardHidden];
    
    LocationViewController *locationController = [[LocationViewController alloc] init];
    locationController.delegate = self;
    [self presentViewController:[[UINavigationController alloc] initWithRootViewController:locationController] animated:YES completion:nil];
}

#pragma mark - LocationViewDelegate

- (void)sendLocationLatitude:(double)latitude longitude:(double)longitude andAddress:(NSString *)address
{
    [self sendLocationLatitude:latitude longitude:longitude andAddress:address];
}

#pragma mark - DXMessageToolBarDelegate
- (void)inputTextViewWillBeginEditing:(HPGrowingTextView *)messageInputTextView{
    [_menuController setMenuItems:nil];
}

- (void)didChangeFrameToHeight:(CGFloat)toHeight
{
    [UIView animateWithDuration:0.25 animations:^{
        CGRect rect = self.tableView.frame;
        rect.origin.y = 65;
        rect.size.height = self.view.frame.size.height - toHeight - 65;
        self.tableView.frame = rect;
    }];
    [self scrollViewToBottom:YES];
}

- (void)didSendText:(NSString *)text
{
    if (text && text.length > 0) {
        [self sendTextMessage:text];
    }
}

/**
 *  按下录音按钮开始录音
 */
- (void)didStartRecordingVoiceAction:(UIView *)recordView
{
    DXRecordView *tmpView = (DXRecordView *)recordView;
    tmpView.center = self.view.center;
    [self.view addSubview:tmpView];
    [self.view bringSubviewToFront:recordView];
}

/**
 *  手指向上滑动取消录音
 */
- (void)didCancelRecordingVoiceAction:(UIView *)recordView
{
    [[EaseMob sharedInstance].chatManager asyncCancelRecordingAudioWithCompletion:nil onQueue:nil];
}

/**
 *  松开手指完成录音
 */
- (void)didFinishRecoingVoiceAction:(UIView *)recordView
{
    [self sendAudioMessage:@""];
}

#pragma mark - ZYQAssetPickerController Delegate
/**
 *  从相册里获取图片
 *
 *  @param picker
 *  @param assets
 */
- (void)assetPickerController:(ZYQAssetPickerController *)picker didFinishPickingAssets:(NSArray *)assets
{
    [picker dismissViewControllerAnimated:YES completion:nil];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        for (int i=0; i<assets.count; i++) {
            ALAsset *asset=assets[i];
            UIImage *tempImg=[UIImage imageWithCGImage:asset.defaultRepresentation.fullScreenImage];
            [self sendImageMessage:tempImg];
        }
    });
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *orgImage = info[UIImagePickerControllerOriginalImage];
    [picker dismissViewControllerAnimated:YES completion:nil];
    [self sendImageMessage:orgImage];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self.imagePicker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - MenuItem actions

- (void)copyMenuAction:(id)sender
{
    // todo by du. 复制
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    if (_longPressIndexPath.row > 0) {
        MessageModel *model = [self.dataSource objectAtIndex:_longPressIndexPath.row];
        pasteboard.string = model.content;
    }
    
    _longPressIndexPath = nil;
}

- (void)deleteMenuAction:(id)sender
{
//    if (_longPressIndexPath && _longPressIndexPath.row > 0) {
//        MessageModel *model = [self.dataSource objectAtIndex:_longPressIndexPath.row];
//        NSMutableArray *messages = [NSMutableArray arrayWithObjects:model, nil];
//        [_conversation removeMessage:model.message];
//        NSMutableArray *indexPaths = [NSMutableArray arrayWithObjects:_longPressIndexPath, nil];;
//        if (_longPressIndexPath.row - 1 >= 0) {
//            id nextMessage = nil;
//            id prevMessage = [self.dataSource objectAtIndex:(_longPressIndexPath.row - 1)];
//            if (_longPressIndexPath.row + 1 < [self.dataSource count]) {
//                nextMessage = [self.dataSource objectAtIndex:(_longPressIndexPath.row + 1)];
//            }
//            if ((!nextMessage || [nextMessage isKindOfClass:[NSString class]]) && [prevMessage isKindOfClass:[NSString class]]) {
//                [messages addObject:prevMessage];
//                [indexPaths addObject:[NSIndexPath indexPathForRow:(_longPressIndexPath.row - 1) inSection:0]];
//            }
//        }
//        [self.dataSource removeObjectsInArray:messages];
//        [self.tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
//    }
//    
//    _longPressIndexPath = nil;
}

#pragma mark - private

- (BOOL)canRecord
{
    __block BOOL bCanRecord = YES;
    if ([[[UIDevice currentDevice] systemVersion] compare:@"7.0"] != NSOrderedAscending)
    {
        dispatch_semaphore_t sema = dispatch_semaphore_create(0);
        AVAudioSession *audioSession = [AVAudioSession sharedInstance];
        if ([audioSession respondsToSelector:@selector(requestRecordPermission:)]) {
            [audioSession performSelector:@selector(requestRecordPermission:) withObject:^(BOOL granted) {
                if (granted) {
                    bCanRecord = YES;
                } else {
                    bCanRecord = NO;
                }
            }];
        }
        
        dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
    }
    
    return bCanRecord;
}

- (void)stopAudioPlaying
{
    //停止音频播放及播放动画
    [[EaseMob sharedInstance].chatManager stopPlayingAudio];
    MessageModel *playingModel = [self.messageReadManager stopMessageAudioModel];
    
    NSIndexPath *indexPath = nil;
    if (playingModel) {
        indexPath = [NSIndexPath indexPathForRow:[self.dataSource indexOfObject:playingModel] inSection:0];
    }
    
    if (indexPath) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView beginUpdates];
            [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
            [self.tableView endUpdates];
        });
    }
}

- (void)loadMoreMessages
{
}


- (void)addChatMessage2DataSource:(BaseMessage *) message
{
    if (!message) {
        return;
    }
    NSDate *createDate = [NSDate dateWithTimeIntervalInMilliSecondSince1970:(NSTimeInterval)message.createTime];
    NSTimeInterval tempDate = [createDate timeIntervalSinceDate:self.chatTagDate];
    if (tempDate > 60 || tempDate < -60 || (self.chatTagDate == nil)) {
        [self.dataSource addObject:[createDate formattedTime]];
        self.chatTagDate = createDate;
        [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:self.dataSource.count-1 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
    }
    
    MessageModel *model = [[MessageModel alloc] initWithBaseMessage:message];
    [self.dataSource addObject:model];
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.dataSource.count-1 inSection:0];
    [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];

}

- (void)scrollViewToBottom:(BOOL)animated
{
    if (self.tableView.contentSize.height > self.tableView.frame.size.height)
    {
        CGPoint offset = CGPointMake(0, self.tableView.contentSize.height - self.tableView.frame.size.height);
        [self.tableView setContentOffset:offset animated:animated];
    }
}

/*
- (void)showRoomContact:(id)sender
{
    [self.view endEditing:YES];
    [self keyBoardHidden];
    if (_isChatGroup) {
        EMGroup *chatGroup = nil;
        NSArray *groupArray = [[EaseMob sharedInstance].chatManager groupList];
        for (EMGroup *group in groupArray) {
            if ([group.groupId isEqualToString:_chatter]) {
                chatGroup = group;
                break;
            }
        }
        if (chatGroup == nil) {
            chatGroup = [EMGroup groupWithId:_chatter];
        }
        ChatGroupSettingViewController *chatSettingCtl = [[ChatGroupSettingViewController alloc] init];
        chatSettingCtl.group = chatGroup;
//        TZSideViewController *sideCtl = [[TZSideViewController alloc] initWithDetailViewFrame:CGRectMake(50, 20, 270, 460)];
//        sideCtl.detailViewController = chatSettingCtl;
//        [sideCtl showSideDetailView];
    } else {
//        ChatSettingViewController *chatSettingCtl = [[ChatSettingViewController alloc] init];
//        chatSettingCtl.chatter = _conversation.chatter;
//        [self.navigationController pushViewController:chatSettingCtl animated:YES];
    }
}
 */

- (void)removeAllMessages:(id)sender
{
//    if (_dataSource.count == 0) {
//        return;
//    }
//    
//    if ([sender isKindOfClass:[NSNotification class]]) {
//        NSString *chatter = (NSString *)[(NSNotification *)sender object];
//        if (_isChatGroup && [chatter isEqualToString:_conversation.chatter]) {
//            [_conversation removeAllMessages];
//            [_dataSource removeAllObjects];
//            [_tableView reloadData];
//        } else if (!_isChatGroup && [chatter isEqualToString:_conversation.chatter]) {
//            [_conversation removeAllMessages];
//            [_dataSource removeAllObjects];
//            [_tableView reloadData];
//        }
//    }
}

- (void)showMenuViewController:(UIView *)showInView andIndexPath:(NSIndexPath *)indexPath messageType:(IMMessageType)messageType
{
    if (_menuController == nil) {
        _menuController = [UIMenuController sharedMenuController];
    }
    if (_copyMenuItem == nil) {
        _copyMenuItem = [[UIMenuItem alloc] initWithTitle:@"复制" action:@selector(copyMenuAction:)];
    }
    if (_deleteMenuItem == nil) {
        _deleteMenuItem = [[UIMenuItem alloc] initWithTitle:@"删除" action:@selector(deleteMenuAction:)];
    }
    
    if (messageType == IMMessageTypeTextMessageType) {
        [_menuController setMenuItems:@[_copyMenuItem, _deleteMenuItem]];
    }
    else{
        [_menuController setMenuItems:@[_deleteMenuItem]];
    }
    
    [_menuController setTargetRect:showInView.frame inView:showInView.superview];
    [_menuController setMenuVisible:YES animated:YES];
}

- (void)exitGroup
{
    [self.navigationController popToViewController:self animated:NO];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)applicationDidEnterBackground
{
    [_chatToolBar cancelTouchRecord];
    
    // 设置当前conversation的所有message为已读
    _conversation.unReadMessageCount = 0;
}

- (void)sendTextMessage:(NSString *)messageStr
{
    IMClientManager *imClientManager = [IMClientManager shareInstance];
    
    BaseMessage *message = [imClientManager.messageSendManager sendTextMessage:messageStr receiver:_conversation.chatterId chatType:_conversation.chatType conversationId:_conversation.conversationId];
    [self addChatMessage2DataSource:message];
}

- (void)sendLocation:(long)lat lng:(long) lng  address:(NSString *)address{
    IMClientManager *imClientManager = [IMClientManager shareInstance];
    LocationModel *model = [[LocationModel alloc] init];
    model.longitude = 116.24;
    model.latitude = 39.28;
    model.address = @"北京";
    
    BaseMessage *message = [imClientManager.messageSendManager sendLocationMessage:model receiver:_conversation.chatterId chatType:_conversation.chatType conversationId:_conversation.conversationId];
    [self addChatMessage2DataSource:message];
}

- (void)sendAudioMessage:(NSString *)audioPath
{
    IMClientManager *imClientManager = [IMClientManager shareInstance];
    BaseMessage *audioMessage = [imClientManager.messageSendManager sendAudioMessageWithWavFormat:_conversation.chatterId conversationId:_conversation.conversationId wavAudioPath:audioPath chatType:_conversation.chatType progress:^(float progress) {
        
    }];

    [self addChatMessage2DataSource:audioMessage];
}

- (void)sendImageMessage:(UIImage *)image
{
    IMClientManager *imClientManager = [IMClientManager shareInstance];
    
    BaseMessage *imageMessage = [imClientManager.messageSendManager sendImageMessage:_conversation.chatterId conversationId:_conversation.conversationId image:image chatType:_conversation.chatType progress:^(float progressValue) {
        
    }];
    [self addChatMessage2DataSource:imageMessage];

}


#pragma mark - MessageManagerDelegate
- (void)receiverMessage:(BaseMessage* __nonnull)message
{
    [self addChatMessage2DataSource:message];
}

- (void)didSendMessage:(BaseMessage * __nonnull)message
{
    for (int i = 0; i < self.dataSource.count; i++) {
        MessageModel *msg = self.dataSource[i];
        if ([msg isKindOfClass:[MessageModel class]]) {
            if ([msg.baseMessage isKindOfClass:[BaseMessage class]]) {
                if (message.localId == msg.baseMessage.localId) {
                    msg.status = message.status;
                    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
                    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
                    if ([cell isKindOfClass:[EMChatViewCell class]]) {
                        ((EMChatViewCell *)cell).messageModel = msg;
                    }
                }
            }
        }
    }
}

#pragma mark - EMDeviceManagerProximitySensorDelegate

- (void)proximitySensorChanged:(BOOL)isCloseToUser{
    //如果此时手机靠近面部放在耳朵旁，那么声音将通过听筒输出，并将屏幕变暗（省电啊）
    if (isCloseToUser)//黑屏
    {
        // 使用耳机播放
        [[EaseMob sharedInstance].deviceManager switchAudioOutputDevice:eAudioOutputDevice_earphone];
    } else {
        // 使用扬声器播放
        [[EaseMob sharedInstance].deviceManager switchAudioOutputDevice:eAudioOutputDevice_speaker];
        if (!_isPlayingAudio) {
            [[[EaseMob sharedInstance] deviceManager] disableProximitySensor];
        }
    }
}

@end

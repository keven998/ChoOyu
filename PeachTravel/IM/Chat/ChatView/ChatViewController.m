//
//  ChatViewController.m
//  PeachTravel
//
//  Created by liangpengshuai on 5/25/15.
//  Copyright (c) 2015 com.aizou.www. All rights reserved.
//

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
#import "MessageReadManager.h"
#import "LocationViewController.h"
#import "UIViewController+HUD.h"
#import "NSDate+Category.h"
#import "DXMessageToolBar.h"
#import "CallViewController.h"
#import "ZYQAssetPickerController.h"
#import "ChatGroupSettingViewController.h"
#import "ChatSettingViewController.h"
#import "AccountManager.h"
#import "SearchUserInfoViewController.h"
#import "CreateConversationViewController.h"
#import "SpotDetailViewController.h"
#import "PlansListTableViewController.h"
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
#import "ChatQuestionTableViewCell.h"
#import "SuperWebViewController.h"
#import "OtherUserInfoViewController.h"
#import "ConvertToCommonEmoticonsHelper.h"

#import "TripDetailRootViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "PeachTravel-swift.h"

#import "MJRefresh.h"
#import "RefreshHeader.h"

#define KPageCount 20

@interface ChatViewController ()<UITableViewDataSource, UITableViewDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, DXChatBarMoreViewDelegate, DXMessageToolBarDelegate, LocationViewDelegate, ZYQAssetPickerControllerDelegate, ChatConversationDelegate, ChatManagerAudioPlayDelegate, ChatQuestionTableViewCellDelegate>
{
    UIMenuController *_menuController;
    UIMenuItem *_copyMenuItem;
    UIMenuItem *_deleteMenuItem;
    NSIndexPath *_longPressIndexPath;
    
    NSInteger _recordingCount;
    
    BOOL _isScrollToBottom;
    
}

@property (nonatomic) IMChatType chatType;
@property (nonatomic) NSInteger chatter;

@property (strong, nonatomic) NSMutableArray *dataSource;//tableView数据源
@property (strong, nonatomic) NSArray *groupNumbers;   //保存群组的人员信息

@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) DXMessageToolBar *chatToolBar;

@property (nonatomic, strong) UIActivityIndicatorView *headerLoading;

@property (strong, nonatomic) UIImagePickerController *imagePicker;

@property (strong, nonatomic) MessageReadManager *messageReadManager;//message阅读的管理者
@property (nonatomic, strong) ChatConversation *conversation;
@property (strong, nonatomic) NSDate *chatTagDate;

@property (nonatomic) BOOL isScrollToBottom;
@property (nonatomic) BOOL isPlayingAudio;
@property (nonatomic, strong) AccountManager *accountManager;

@property (nonatomic) BOOL loadMessageOver;

@property (nonatomic) BOOL isLoadingContactsInGroup;

@end

@implementation ChatViewController

#pragma mark - life cycle

- (instancetype)initWithConversation:(ChatConversation *)conversation
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        _isPlayingAudio = NO;
        _chatter = conversation.chatterId;
        _chatType = conversation.chatType;
        _conversation = conversation;
        _loadMessageOver = NO;
        _isLoadingContactsInGroup = false;
    }
    
    return self;
}

- (instancetype)initWithChatter:(NSInteger)chatter chatType:(IMChatType)chatType
{
    IMClientManager *imclientManager = [IMClientManager shareInstance];
    ChatConversation *conversation= [imclientManager.conversationManager getConversationWithChatterId:chatter chatType:chatType];
    return [[ChatViewController alloc] initWithConversation:conversation];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.automaticallyAdjustsScrollViewInsets = NO;
    self.navigationItem.title = _chatterName;
    self.view.backgroundColor = APP_PAGE_COLOR;
    
    // 聊天类型为讨论组
    if (_chatType == IMChatTypeIMChatDiscussionGroupType) {
        _groupNumbers = [[IMDiscussionGroupManager shareInstance] getFullDiscussionGroupInfoFromDBWithGroupId: _conversation.chatterId].members;
        if (!_groupNumbers || _groupNumbers.count == 0) {
            [self getMembersInGroupFromServer];
        } else {
            [self fillGroupMemberInfo];
        }
    }
    
    _conversation.isCurrentConversation = YES;
    _conversation.delegate = self;
    [_conversation getDefaultChatMessageInConversation:15];
    [self sortDataSource];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removeAllMessages:) name:@"RemoveAllMessages" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(exitGroup) name:@"ExitGroup" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackground) name:@"applicationDidEnterBackground" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateChatView:) name:updateChateViewNoti object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateChatTitle:) name:updateChateGroupTitleNoti object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardHidden) name:UIKeyboardWillHideNotification object:nil];
    
    [self.view addSubview:self.tableView];
    [self.view addSubview:self.chatToolBar];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(keyBoardHidden)];
    [self.view addGestureRecognizer:tap];
    _isScrollToBottom = YES;
    
    [self setupBarButtonItem];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [MobClick beginLogPageView:@"page_lxp_chatting"];
    [_chatToolBar registerNoti];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stopPlayAudio) name:UIApplicationWillResignActiveNotification object:nil];
    if (_isScrollToBottom) {
        [self scrollViewToBottom:YES];
    }
    else{
        _isScrollToBottom = YES;
    }
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.dataSource.count-1 inSection:0];
    [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:@"page_lxp_chatting"];
    [_chatToolBar unRegisterNoti];
    // 设置当前conversation的所有message为已读
    _conversation.unReadMessageCount = 0;
    
    [[ChatManagerAudio shareInstance] stopPlayAudio];
}

- (void)dealloc
{
    _tableView.delegate = nil;
    _tableView.dataSource = nil;
    _tableView = nil;
    
    _chatToolBar.delegate = nil;
    _chatToolBar = nil;
    _conversation.isCurrentConversation = NO;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - setter & getter

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
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds) - [DXMessageToolBar defaultHeight] - 64)];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.backgroundColor = APP_PAGE_COLOR;
        _tableView.tableFooterView = [[UIView alloc] init];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        UILongPressGestureRecognizer *lpgr = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
        lpgr.minimumPressDuration = .5;
        [_tableView addGestureRecognizer:lpgr];
        MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadMoreMessages)];
        
        // 隐藏时间
        header.lastUpdatedTimeLabel.hidden = YES;
        // 隐藏状态
        header.stateLabel.hidden = YES;
        // 设置header
        self.tableView.header = header;
    }
    
    return _tableView;
}

- (DXMessageToolBar *)chatToolBar
{
    if (!_chatToolBar) {
        
        _chatToolBar = [[DXMessageToolBar alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - [DXMessageToolBar defaultHeight] - 64, self.view.frame.size.width, [DXMessageToolBar defaultHeight])];
        _chatToolBar.backgroundColor = [UIColor whiteColor];
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

#pragma mark - privateMethods

- (void)stopPlayAudio
{
    [[ChatManagerAudio shareInstance] stopPlayAudio];
}

/**
 *  从服务器上加载群组成员信息
 */
- (void)getMembersInGroupFromServer
{
    if (_isLoadingContactsInGroup) {
        return;
    }
    _isLoadingContactsInGroup = YES;
    IMDiscussionGroupManager *groupManager = [IMDiscussionGroupManager shareInstance];
    [groupManager asyncGetDiscussionGroupInfoFromServer:_conversation.chatterId completion:^(BOOL isSuccess, NSInteger errorCode, IMDiscussionGroup * group) {
        _isLoadingContactsInGroup = NO;
        if (isSuccess) {
            [groupManager asyncGetMembersInDiscussionGroupInfoFromServer:group completion:^(BOOL isSuccess, NSInteger errorCode, IMDiscussionGroup * fullgroup) {
                if (isSuccess) {
                     _groupNumbers = [[IMDiscussionGroupManager shareInstance] getFullDiscussionGroupInfoFromDBWithGroupId: _conversation.chatterId].members;
                    [self fillGroupMemberInfo];
                    [self.tableView reloadData];
                } else {
                }
            }];
        }
    }];
}

/**
 *  填充群组成员的信息，如备注等
 */
- (void)fillGroupMemberInfo
{
    AccountManager *accountManager = [AccountManager shareAccountManager];
    FrendManager *frendManager = [IMClientManager shareInstance].frendManager;
    for (FrendModel *model in _groupNumbers) {
        if ([accountManager frendIsMyContact:model.userId]) {
            FrendModel *frend = [frendManager getFrendInfoFromDBWithUserId:model.userId];
            model.memo = frend.memo;
        }
    }
}

// 将日期和聊天数据存放在dataSource
- (void)sortDataSource
{
    [self.dataSource removeAllObjects];
    for (BaseMessage *message in _conversation.chatMessageList) {
        NSDate *createDate = [NSDate dateWithTimeIntervalInMilliSecondSince1970:(NSTimeInterval)message.createTime*1000];
        NSTimeInterval tempDate = [createDate timeIntervalSinceDate:self.chatTagDate];
        if (tempDate > 60 || tempDate < -60 || (self.chatTagDate == nil)) {
            [self.dataSource addObject:[createDate formattedTime]];
            self.chatTagDate = createDate;
        }
        
        message.chatType = _chatType;
        MessageModel *model = [[MessageModel alloc] initWithBaseMessage:(message)];
        [self fillMessageModel:model];
        [self.dataSource addObject: model];
    }
}

- (void)setupBarButtonItem
{
    UIButton *menu = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 44)];
    [menu setImage:[UIImage imageNamed:@"common_icon_navigaiton_menu"] forState:UIControlStateNormal];
    [menu addTarget:self action:@selector(showMenu) forControlEvents:UIControlEventTouchUpInside];
    [menu setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:menu];
    
    UIButton *back = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 44)];
    [back setImage:[UIImage imageNamed:@"common_icon_navigaiton_back"] forState:UIControlStateNormal];
    [back setImage:[UIImage imageNamed:@"common_icon_navigaiton_back_highlight"] forState:UIControlStateHighlighted];
    [back addTarget:self action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];
    [back setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:back];
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
        [self addChatMessage2Buttom:[noti.userInfo objectForKey:@"message"]];
    }
}

/**
 *  获取所有的聊天图片
 *
 *  @return
 */
- (NSArray *)getAllImagePathListWithImageList:(NSArray *)imageMessages
{
    NSMutableArray *retMessages = [[NSMutableArray alloc] init];
    for (ImageMessage *message in imageMessages) {
        if (message.sendType == IMMessageSendTypeMessageSendSomeoneElse) {
            NSString *imageUrl = message.fullUrl;
            if (imageUrl) {
                [retMessages addObject:imageUrl];
            }
            
        } else {
            [retMessages addObject:message.localPath];
        }
    }
    return retMessages;
}

/**
 *  发送文本消息
 *
 *  @param messageStr
 */
- (void)sendTextMessage:(NSString *)messageStr
{
    IMClientManager *imClientManager = [IMClientManager shareInstance];
    NSString *willSendText = [ConvertToCommonEmoticonsHelper convertToCommonEmoticons:messageStr];
    BaseMessage *message = [imClientManager.messageSendManager sendTextMessage:willSendText receiver:_conversation.chatterId chatType:_conversation.chatType conversationId:_conversation.conversationId completionBlock:^(BOOL isSuccess, NSString * __nullable error) {
        if (!isSuccess) {
            if (error) {
                TipsMessage *message = [[TipsMessage alloc] initWithContent:error tipsType:TipsMessageTypeCommon_Tips];
                message.chatterId = _conversation.chatterId;
                message.createTime = [[NSDate date] timeIntervalSince1970];
                [_conversation addReceiveMessage:message];
                [_conversation insertMessage2DB: message]; 
            }
        }
    }];
    
    [self addChatMessage2Buttom:message];
}

/**
 *  发送位置消息
 *
 *  @param model
 *  @param locImage
 */
- (void)sendLocation:(LocationModel *)model Image:(UIImage *)locImage {
    IMClientManager *imClientManager = [IMClientManager shareInstance];
    
    BaseMessage *message = [imClientManager.messageSendManager sendLocationMessage:model receiver:_conversation.chatterId  mapImage:locImage chatType:_conversation.chatType conversationId:_conversation.conversationId];
    
    [self addChatMessage2Buttom:message];
}

/**
 *  发送语音消息
 *
 *  @param audioPath
 */
- (void)sendAudioMessage:(NSString *)audioPath
{
    IMClientManager *imClientManager = [IMClientManager shareInstance];
    BaseMessage *audioMessage = [imClientManager.messageSendManager sendAudioMessageWithWavFormat:_conversation.chatterId conversationId:_conversation.conversationId wavAudioPath:audioPath chatType:_conversation.chatType progress:^(float progress) {
        
    }];
    
    [self addChatMessage2Buttom:audioMessage];
}

/**
 *  发送图片消息
 *
 *  @param imageData
 */
- (void)sendImageMessage:(NSData *)imageData
{
    IMClientManager *imClientManager = [IMClientManager shareInstance];
    BaseMessage *imageMessage = [imClientManager.messageSendManager sendImageMessage:_conversation.chatterId conversationId:_conversation.conversationId imageData:imageData chatType:_conversation.chatType progress:^(float progressValue) {
        NSLog(@"发送了: %lf", progressValue);
    }];
    [self addChatMessage2Buttom:imageMessage];
    
}

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

/**
 *  上拉加载更多聊天记录
 */
- (void)loadMoreMessages
{
    // 马上进入刷新状态
    [_tableView.header beginRefreshing];
    
    ChatViewController *weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        NSArray *moreMessages = [weakSelf.conversation getMoreChatMessageInConversation:10];
        if ([moreMessages count] > 0) {
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self addChatMessageList2Top:moreMessages];
                // 拿到当前的下拉刷新控件，结束刷新状态
                [self.tableView.header endRefreshing];
            });
        } else {
            _loadMessageOver = YES;
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                // 拿到当前的下拉刷新控件，结束刷新状态
                [self.tableView.header endRefreshing];
                self.tableView.header.state = MJRefreshStateNoMoreData;
            });
        }
    });
    
}

/**
 *  添加一条新发送的消息到底部
 *
 *  @param message
 */
- (void)addChatMessage2Buttom:(BaseMessage *) message
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
    message.chatType = _chatType;
    MessageModel *model = [[MessageModel alloc] initWithBaseMessage:message];
    [self fillMessageModel:model];
    [self.dataSource addObject:model];
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.dataSource.count-1 inSection:0];
    [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
}

- (void)addChatMessageList2Top:(NSArray *)messageList
{
    NSMutableArray *indexPath2Insert = [[NSMutableArray alloc] init];
    int i = 0;
    for (NSInteger j=messageList.count-1; j>0; j--) {
        BaseMessage *message = messageList[j];
        NSDate *createDate = [NSDate dateWithTimeIntervalInMilliSecondSince1970:(NSTimeInterval)message.createTime];
        NSTimeInterval tempDate = [createDate timeIntervalSinceDate:self.chatTagDate];
        if (tempDate > 60 || tempDate < -60 || (self.chatTagDate == nil)) {
            [self.dataSource insertObject:[createDate formattedTime] atIndex:0];
            self.chatTagDate = createDate;
            NSIndexPath *path = [NSIndexPath indexPathForRow:i inSection:0];
            
            [indexPath2Insert addObject:path];
            i++;
        }
        message.chatType = _chatType;
        MessageModel *model = [[MessageModel alloc] initWithBaseMessage:message];
        [self fillMessageModel:model];
        [self.dataSource insertObject:model atIndex:0];
        NSIndexPath *path = [NSIndexPath indexPathForRow:i inSection:0];
        [indexPath2Insert addObject:path];
        i++;
    }
    // 刷新表格
    [self.tableView reloadData];
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
    
}

- (void)fillMessageModel:(MessageModel *)message
{
    if (message.isSender) {
        message.nickName = self.accountManager.account.nickName;
        message.headImageURL = [NSURL URLWithString: self.accountManager.account.avatarSmall];
        
    } else {
        if (_chatType == IMChatTypeIMChatSingleType) {
            message.nickName = _conversation.chatterName;
            message.headImageURL = [NSURL URLWithString:_conversation.chatterAvatar];
            
        } else {
            BOOL find = NO;
            for (FrendModel *model in _groupNumbers) {
                if (model.userId == message.senderId) {
                    if ([model.memo isBlankString]) {
                        message.nickName = model.nickName;
                    } else {
                        message.nickName = model.memo;
                    }
                    if ([model.avatarSmall isBlankString]) {
                        message.headImageURL = [NSURL URLWithString:model.avatar];
                    } else {
                        message.headImageURL = [NSURL URLWithString:model.avatarSmall];
                    }
                    find = YES;
                    break;
                }
            }
            if (!find) {
                [self getMembersInGroupFromServer];
            }
        }
    }
}

- (void)scrollViewToBottom:(BOOL)animated
{
    if (self.tableView.contentSize.height > self.tableView.frame.size.height)
    {
        CGPoint offset = CGPointMake(0, self.tableView.contentSize.height - self.tableView.frame.size.height);
        [self.tableView setContentOffset:offset animated:animated];
    }
}

- (void)removeAllMessages:(id)sender
{
    if (_dataSource.count == 0) {
        return;
    }
    
    [_dataSource removeAllObjects];
    [_conversation deleteAllMessage];
    [_tableView reloadData];
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
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)applicationDidEnterBackground
{
    [_chatToolBar cancelTouchRecord];
    
    // 设置当前conversation的所有message为已读
    _conversation.unReadMessageCount = 0;
}

#pragma mark - IBAction Methods

- (void)showMenu
{
    [MobClick event:@"navigation_item_chat_setting"];
    [self keyBoardHidden];
    [self.view endEditing:YES];
    [self.frostedViewController.view endEditing:YES];
    
    [self.frostedViewController presentMenuViewController];
}

/**
 * 实现父类的后退按钮
 */
- (void)goBack
{
    if (self.backBlock) {
        self.backBlock();
    } else {
        if (self.frostedViewController.navigationController.viewControllers.count > 1) {
            [self.frostedViewController.navigationController popToRootViewControllerAnimated:YES];
            
        } else {
            [self.frostedViewController dismissViewControllerAnimated:YES completion:nil];
        }
    }
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
    OtherUserInfoViewController *OtherUser = [[OtherUserInfoViewController alloc]init];
    OtherUser.userId = model.senderId;
    [self.frostedViewController.navigationController pushViewController:OtherUser animated:YES];
}

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
            if (((MessageModel *)object).type == IMMessageTypeQuestionMessageType) {
                ChatQuestionTableViewCell *cell = (ChatQuestionTableViewCell *)[_tableView cellForRowAtIndexPath:indexPath];
                CGPoint point = [recognizer locationInView:cell.tableView];
                NSIndexPath *questionTableIndexPath = [cell.tableView indexPathForRowAtPoint:point];
                QuestionModel *model = ((QuestionMessage *)((MessageModel *)object).baseMessage).questionList[questionTableIndexPath.row];
                [self showQuestionWithLongPressPoint:model];
                return;
            }
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

- (void)showQuestionWithLongPressPoint:(QuestionModel *)questionModel
{
    SuperWebViewController *ctl = [[SuperWebViewController alloc] init];
    ctl.urlStr = questionModel.url;
    ctl.titleStr = questionModel.title;
    [self.navigationController pushViewController:ctl animated:YES];
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
    ChatManagerAudio *audioManager = [ChatManagerAudio shareInstance];
    audioManager.chatManagerAudioPlayDelegate = self;
    model.isPlayed = YES;
    ((AudioMessage *)model.baseMessage).audioStatus = IMAudioStatusReaded;
    if (!model.isPlaying) {
        [audioManager playAudio:model.localPath messageLocalId:model.baseMessage.localId];
        model.isPlaying = true;
    } else {
        [audioManager stopPlayAudio];
        model.isPlaying = false;
    }
    [self.tableView reloadData];
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
            [self.frostedViewController.navigationController pushViewController:spotDetailCtl animated:YES];
        }
            break;
            
        case IMMessageTypeRestaurantMessageType: {
            CommonPoiDetailViewController *restaurantDetailCtl = [[RestaurantDetailViewController alloc] init];
            restaurantDetailCtl.title = model.poiModel.poiName;
            restaurantDetailCtl.poiId = model.poiModel.poiId;
            [self.frostedViewController.navigationController pushViewController:restaurantDetailCtl animated:YES];
        }
            break;
            
        case IMMessageTypeShoppingMessageType: {
            CommonPoiDetailViewController *shoppingCtl = [[ShoppingDetailViewController alloc] init];
            shoppingCtl.title = model.poiModel.poiName;
            shoppingCtl.poiId = model.poiModel.poiId;
            [self.frostedViewController.navigationController pushViewController:shoppingCtl animated:YES];
        }
            break;
            
        case IMMessageTypeHotelMessageType: {
            CommonPoiDetailViewController *hotelCtl = [[HotelDetailViewController alloc] init];
            hotelCtl.title = model.poiModel.poiName;
            hotelCtl.poiId = model.poiModel.poiId;
            [self.frostedViewController.navigationController pushViewController:hotelCtl animated:YES];
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
            travelNoteCtl.titleStr = model.poiModel.poiName;
            travelNoteCtl.travelNote = travelNote;
            [self.frostedViewController.navigationController pushViewController:travelNoteCtl animated:YES];
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
                tripDetailCtl.userId = model.senderId;
            }
            
            TripPlanSettingViewController *tpvc = [[TripPlanSettingViewController alloc] init];
            
            REFrostedViewController *frostedViewController = [[REFrostedViewController alloc] initWithContentViewController:[[UINavigationController alloc] initWithRootViewController:tripDetailCtl] menuViewController:tpvc];
            frostedViewController.direction = REFrostedViewControllerDirectionRight;
            frostedViewController.liveBlurBackgroundStyle = REFrostedViewControllerLiveBackgroundStyleLight;
            frostedViewController.liveBlur = YES;
            frostedViewController.limitMenuViewSize = YES;
            frostedViewController.resumeNavigationBar = NO;
            [self.frostedViewController.navigationController pushViewController:frostedViewController animated:YES];
        }
            break;
            
        case IMMessageTypeCityPoiMessageType: {
            _isScrollToBottom = NO;
            CityDetailTableViewController *cityCtl = [[CityDetailTableViewController alloc] init];
            cityCtl.title = model.poiModel.poiName;
            cityCtl.cityId = model.poiModel.poiId;
            [self.frostedViewController.navigationController pushViewController:cityCtl animated:YES];
        }
            break;
            
        case IMMessageTypeHtml5MessageType: {
            SuperWebViewController *ctl = [[SuperWebViewController alloc] init];
            ctl.titleStr = ((HtmlMessage *)model.baseMessage).title;
            ctl.urlStr = ((HtmlMessage *)model.baseMessage).url;
            [self.frostedViewController.navigationController pushViewController:ctl animated:YES];
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
        NSArray *imageMessages = [self.conversation getAllImageMessageInConversation];
        NSArray *imageList = [self getAllImagePathListWithImageList:imageMessages];
        
        NSUInteger index = 0;
        for (ImageMessage *message in imageMessages) {
            if (message.localId == model.baseMessage.localId) {
                break;
            }
            index++;
        }
        [weakSelf.messageReadManager showBrowserWithImages:imageList andImageView:imageView andCurrentPhotoIndex:index];
    }
}

#pragma mark - UIResponder actions

- (void)routerEventWithName:(NSString *)eventName userInfo:(NSDictionary *)userInfo
{
    MessageModel *model = [userInfo objectForKey:KMESSAGEKEY];
    if ([eventName isEqualToString:kRouterEventTextURLTapEventName]) {
        [self chatTextCellUrlPressed:[userInfo objectForKey:@"url"]];
        
    } else if ([eventName isEqualToString:kRouterEventAudioBubbleTapEventName]) {
        [self handleNotification:YES];
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
        messageModel.status = IMMessageStatusIMMessageSending;
        NSIndexPath *indexPath = [self.tableView indexPathForCell:resendCell];
        [self.tableView beginUpdates];
        [self.tableView reloadRowsAtIndexPaths:@[indexPath]
                              withRowAnimation:UITableViewRowAnimationNone];
        [self.tableView endUpdates];
        IMClientManager *imClientManager = [IMClientManager shareInstance];
        [imClientManager.messageSendManager resendMessage:messageModel.baseMessage receiver:_conversation.chatterId chatType:_conversation.chatType conversationId:_conversation.conversationId];
        
    } else if ([eventName isEqualToString:kRouterEventChatHeadImageTapEventName]) {   //点击头像
        [self showUserInfoWithModel:model];
    }
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
    NSLog(@"%@",self.dataSource);
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
                tipsCell.content = model.content;
                return tipsCell;
                
            } else if (model.type == IMMessageTypeQuestionMessageType) {
                ChatQuestionTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"questionCell"];
                if (!cell) {
                    cell = [[ChatQuestionTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"questionCell"];
                    cell.delegate = self;
                }
                cell.messageModel = model;
                return cell;
                
            } else{
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
    } else if ([obj isKindOfClass:[MessageModel class]]) {
        if (((MessageModel *)obj).type == IMMessageTypeQuestionMessageType) {
            return [ChatQuestionTableViewCell heightForBubbleWithObject:(MessageModel *)obj];
        } else {
            return [EMChatViewCell tableView:tableView heightForRowAtIndexPath:indexPath withObject:(MessageModel *)obj];
        }
    }
    return 0;
}

#pragma mark - scrollView delegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self keyBoardHidden];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView.contentOffset.y < 40 && !_loadMessageOver && _dataSource.count >= 10) {
        if (![_tableView.header isRefreshing]) {
            [_tableView.header beginRefreshing];
        }
    }
}

#pragma mark - ChatQuestionTableViewCellDelegate

- (void)chatQuestionTableCellDidSelectedWithQuestionModel:(QuestionModel *)questionModel
{
    SuperWebViewController *ctl = [[SuperWebViewController alloc] init];
    ctl.urlStr = questionModel.url;
    ctl.titleStr = questionModel.title;
    [self.navigationController pushViewController:ctl animated:YES];
}


#pragma mark - EMChatBarMoreViewDelegate

/**
 *  发送我的攻略
 *
 *  @param moreView
 */
- (void)moreViewMyStrategyAction:(DXChatBarMoreView *)moreView
{
    [MobClick event:@"chat_item_lxpplan"];

    PlansListTableViewController *myGuideListTableCtl = [[PlansListTableViewController alloc] initWithUserId:self.accountManager.account.userId];
    myGuideListTableCtl.chatterId = _chatter;
    myGuideListTableCtl.selectToSend = YES;
    myGuideListTableCtl.chatType = _chatType;
    myGuideListTableCtl.userName = _accountManager.account.nickName;
    UINavigationController *ctl = [[UINavigationController alloc] initWithRootViewController:myGuideListTableCtl];
    [self presentViewController:ctl animated:YES completion:^ {
    }];
}

/**
 *  发送我的收藏夹里的内容
 *
 *  @param moreView
 */
- (void)moreViewMyFavoriteAction:(DXChatBarMoreView *)moreView
{
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
    [MobClick event:@"chat_item_lxpsearch"];

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
    
    NSString * mediaType = AVMediaTypeVideo;
    AVAuthorizationStatus  authorizationStatus = [AVCaptureDevice authorizationStatusForMediaType:mediaType];
    if (authorizationStatus == AVAuthorizationStatusRestricted|| authorizationStatus == AVAuthorizationStatusDenied) {
        [self showHint:@"您没有开启摄像头权限!"];
    }else{
        [self presentViewController:self.imagePicker animated:YES completion:nil];
    }
#endif
}

- (void)moreViewLocationAction:(DXChatBarMoreView *)moreView
{
    // 隐藏键盘
    [MobClick event:@"chat_item_lxplocation"];

    LocationViewController *locationController = [[LocationViewController alloc] init];
    locationController.delegate = self;
    [self presentViewController:[[UINavigationController alloc] initWithRootViewController:locationController] animated:YES completion:nil];
}

#pragma mark - LocationViewDelegate

- (void)sendLocation:(LocationModel *)locModel locImage:(UIImage *)locImage
{
    [self sendLocation:locModel Image:locImage];
}

#pragma mark - DXMessageToolBarDelegate

- (void)inputTextViewWillBeginEditing:(HPGrowingTextView *)messageInputTextView{
    [_menuController setMenuItems:nil];
}

- (void)didChangeFrameToHeight:(CGFloat)toHeight
{
    [UIView animateWithDuration:0.25 animations:^{
        CGRect rect = self.tableView.frame;
        rect.size.height = kWindowHeight - toHeight - 64;
        self.tableView.frame = rect;
    }];
    [self scrollViewToBottom:NO];
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
}

/**
 *  松开手指完成录音
 */
- (void)didFinishRecoingVoiceAction:(NSString *)audioPath
{
    [self sendAudioMessage:audioPath];
}

#pragma mark - ZYQAssetPickerControllerDelegate

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
            
            NSLog(@"开始获取图片信息");
            UIImage *tempImg = [UIImage imageWithCGImage:asset.defaultRepresentation.fullScreenImage];
            NSData *imageData = UIImageJPEGRepresentation(tempImg, 1);
            NSLog(@"结束获取图片信息");

            dispatch_async(dispatch_get_main_queue(), ^{
                
                [self sendImageMessage:imageData];
                
            });
            [NSThread sleepForTimeInterval:0.3];
            
        }
    });
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSLog(@"imagePickerController: %@", info);
    UIImage *orgImage = info[UIImagePickerControllerOriginalImage];
    [picker dismissViewControllerAnimated:YES completion:nil];
    NSData *imageData = UIImageJPEGRepresentation(orgImage, 0.3);
    [self sendImageMessage:imageData];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self.imagePicker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - MenuItem actions

- (void)copyMenuAction:(id)sender
{
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    if (_longPressIndexPath.row > 0) {
        MessageModel *model = [self.dataSource objectAtIndex:_longPressIndexPath.row];
        pasteboard.string = model.content;
    }
    _longPressIndexPath = nil;
}

- (void)deleteMenuAction:(id)sender
{
    if (_longPressIndexPath && _longPressIndexPath.row > 0) {
        MessageModel *model = [self.dataSource objectAtIndex:_longPressIndexPath.row];
        NSMutableArray *messages = [NSMutableArray arrayWithObjects:model, nil];
        [_conversation deleteMessageWithLocalId:model.baseMessage.localId];
        NSMutableArray *indexPaths = [NSMutableArray arrayWithObjects:_longPressIndexPath, nil];
        NSLog(@"%@", _longPressIndexPath);
        
        if (_longPressIndexPath.row - 1 >= 0) {
            id nextMessage = nil;
            id prevMessage = [self.dataSource objectAtIndex:(_longPressIndexPath.row - 1)];
            if (_longPressIndexPath.row + 1 < [self.dataSource count]) {
                nextMessage = [self.dataSource objectAtIndex:(_longPressIndexPath.row + 1)];
            }
            if ((!nextMessage || [nextMessage isKindOfClass:[NSString class]]) && [prevMessage isKindOfClass:[NSString class]]) {
                [messages addObject:prevMessage];
                [indexPaths addObject:[NSIndexPath indexPathForRow:(_longPressIndexPath.row - 1) inSection:0]];
            }
        }
        [self.dataSource removeObjectsInArray:messages];
        [self.tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    
    _longPressIndexPath = nil;
}

#pragma mark - MessageManagerDelegate

- (void)receiverMessage:(BaseMessage* __nonnull)message
{
    [self addChatMessage2Buttom:message];
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

#pragma mark - ChatManagerAudioDelegate

- (void)playAudioEnded:(NSInteger)messageId
{
    for (int i = 0; i < self.dataSource.count; i++) {
        MessageModel *msg = self.dataSource[i];
        if ([msg isKindOfClass:[MessageModel class]]) {
            if ([msg.baseMessage isKindOfClass:[BaseMessage class]]) {
                if (messageId == msg.baseMessage.localId) {
                    msg.isPlaying = NO;
                    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
                    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
                    if ([cell isKindOfClass:[EMChatViewCell class]]) {
                        ((EMChatViewCell *)cell).messageModel = msg;
                    }
                }
            }
        }
    }
    [self handleNotification:NO];
}

#pragma mark - 监听听筒or扬声器

- (void) handleNotification:(BOOL)state
{
    //建议在播放之前设置yes，播放结束设置NO，这个功能是开启红外感应
    [[UIDevice currentDevice] setProximityMonitoringEnabled:state];
    
    if(state)//添加监听
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(sensorStateChange:) name:@"UIDeviceProximityStateDidChangeNotification"
                                                   object:nil];
    else//移除监听
        [[NSNotificationCenter defaultCenter] removeObserver:self name:@"UIDeviceProximityStateDidChangeNotification" object:nil];
}

//处理监听触发事件
-(void)sensorStateChange:(NSNotificationCenter *)notification;
{
    //如果此时手机靠近面部放在耳朵旁，那么声音将通过听筒输出，并将屏幕变暗（省电啊）
    if ([[UIDevice currentDevice] proximityState] == YES) {
        NSLog(@"Device is close to user");
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
        
    } else {
        NSLog(@"Device is not close to user");
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
    }
}

- (void)updateChatTitle:(NSNotification *)Noti
{
    self.navigationItem.title = Noti.object;
    
}

@end

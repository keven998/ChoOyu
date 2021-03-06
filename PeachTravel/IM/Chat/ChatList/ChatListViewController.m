//
//  ChatListViewController
//  PeachTravel
//
//  Created by liangpengshuai on 5/25/15.
//  Copyright (c) 2015 com.aizou.www. All rights reserved.
//

#import "ChatListViewController.h"
#import "ChatListCell.h"
#import "NSDate+Category.h"
#import "ChatViewController.h"
#import "ConvertToCommonEmoticonsHelper.h"
#import "AccountManager.h"
#import "CreateConversationViewController.h"
#import "ContactListViewController.h"
#import "AddContactTableViewController.h"
#import "REFrostedViewController.h"
#import "ChatGroupSettingViewController.h"
#import "ChatSettingViewController.h"
#import "PeachTravel-swift.h"

@interface ChatListViewController ()<UITableViewDelegate, UITableViewDataSource, CreateConversationDelegate, ChatConversationManagerDelegate, FriendRequestManagerDelegate>

@property (strong, nonatomic) UITableView           *tableView;
@property (nonatomic, strong) AccountManager        *accountManager;
@property (nonatomic, strong) CreateConversationViewController *createConversationCtl;
@property (strong, nonatomic) NSMutableArray *dataSource;

@property (nonatomic, strong) UIView *emptyView;

@property (nonatomic, strong) IMClientManager *imClientManager;

@property (nonatomic, strong) UILabel *frendRequestUnreadCountLabel;

/**
 *  是否有未读的消息，如果有出现小红点
 */
@property (nonatomic) BOOL *isShowNotify;

@end

@implementation ChatListViewController

#pragma mark - life cycle

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
    [self.view addSubview:self.tableView];
    // 初始化对话管理对象
    self.imClientManager.conversationManager.delegate = self;
    _dataSource = [[self.imClientManager.conversationManager getConversationList] mutableCopy];
    
    UIButton *addBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    [addBtn setImage:[UIImage imageNamed:@"ic_navigationbar_menu_add.png"] forState:UIControlStateNormal];
    [addBtn addTarget:self action:@selector(addAction:) forControlEvents:UIControlEventTouchUpInside];
    addBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:addBtn];
    
    UIButton *contactListBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    [contactListBtn setImage:[UIImage imageNamed:@"ic_navigationbar_menu_friendlist.png"] forState:UIControlStateNormal];
    [contactListBtn addTarget:self action:@selector(showContactList:) forControlEvents:UIControlEventTouchUpInside];
    contactListBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    _frendRequestUnreadCountLabel = [[UILabel alloc] initWithFrame:CGRectMake(12, 7, 8, 8)];
    _frendRequestUnreadCountLabel.backgroundColor = [UIColor redColor];
    _frendRequestUnreadCountLabel.layer.cornerRadius = 4;
    _frendRequestUnreadCountLabel.clipsToBounds = YES;
    [contactListBtn addSubview:_frendRequestUnreadCountLabel];
    [[IMClientManager shareInstance].frendRequestManager addFrendRequestDelegate:self];
    
    // 在这里判断是否已经查看过好友请求数
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    NSString *key = [NSString stringWithFormat:@"%@_%ld", kShouldShowUnreadFrendRequestNoti, [AccountManager shareAccountManager].account.userId];
    BOOL isShowUnreadCount = [defaults boolForKey:key];
    if (isShowUnreadCount&&[IMClientManager shareInstance].frendRequestManager.unReadFrendRequestCount > 0) {
        _frendRequestUnreadCountLabel.hidden = NO;
    } else {
        _frendRequestUnreadCountLabel.hidden = YES;
    }
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:contactListBtn];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userDidLogin) name:userDidLoginNoti object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(networkChanged:) name:networkConnectionStatusChangeNoti object:nil];
    
    
    if (self.accountManager.isLogin) {
        self.IMState = IM_RECEIVING;
        [self.imClientManager.messageReceiveManager asyncACKMessageWithReceivedMessages:nil completion:^(BOOL isSuccess) {
            self.IMState = IM_RECEIVED;
        }];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [MobClick beginLogPageView:@"page_home_talk_lists"];
    [self refreshDataSource];
    [_delegate unreadMessageCountHasChange];
      
    [self updateIMStatusWithNetworkStatus:self.imClientManager.netWorkReachability.hostReachability.currentReachabilityStatus];
    
    // 隐藏小红点
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    NSString *key = [NSString stringWithFormat:@"%@_%ld", kShouldShowUnreadFrendRequestNoti, [AccountManager shareAccountManager].account.userId];

    BOOL isShowUnreadCount = [defaults boolForKey:key];
    if (isShowUnreadCount&&[IMClientManager shareInstance].frendRequestManager.unReadFrendRequestCount > 0) {
        _frendRequestUnreadCountLabel.hidden = NO;
    } else {
        _frendRequestUnreadCountLabel.hidden = YES;
    }
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:@"page_home_talk_lists"];
}

- (void)dealloc
{
    _createConversationCtl.delegate = nil;
    _createConversationCtl = nil;
    [[IMClientManager shareInstance].frendRequestManager removeFrendRequestDelegate:self];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - getter & setter

- (AccountManager *)accountManager
{
    if (!_accountManager) {
        _accountManager = [AccountManager shareAccountManager];
    }
    return _accountManager;
}

- (IMClientManager *)imClientManager
{
    if (!_imClientManager) {
        _imClientManager = [IMClientManager shareInstance];
    }
    return _imClientManager;
}

- (UITableView *)tableView
{
    if (_tableView == nil) {
        _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        _tableView.backgroundColor = APP_PAGE_COLOR;
        _tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [_tableView registerClass:[ChatListCell class] forCellReuseIdentifier:@"chatListCell" ];
    }
    return _tableView;
}

- (void)setIMState:(IM_CONNECT_STATE)IMState
{
    _IMState = IMState;
    [self updateNavigationTitleViewStatus];
}

#pragma mark - private methods

- (void)userDidLogin
{
    // 设置会话管理者的代理
    self.imClientManager.conversationManager.delegate = self;
    [self.imClientManager.conversationManager updateConversationListFromDB];
    _dataSource = [[self.imClientManager.conversationManager getConversationList] mutableCopy];
    [self.tableView reloadData];
}

// 监听网络状态改变的通知
- (void)networkChanged:(NSNotification *)noti
{
    NSDictionary *userInfo = noti.userInfo;
    NetworkStatus status = [[userInfo objectForKey:@"status"] integerValue];
    [self updateIMStatusWithNetworkStatus: status];
}

- (void)updateIMStatusWithNetworkStatus:(NetworkStatus) status
{
    if (status == NotReachable) {
        [self setIMState:IM_DISCONNECTED];
        
    } else if (_IMState != IM_RECEIVING){
        [self setIMState:IM_CONNECTED];
    }
}

- (void)refreshDataSource
{
    _dataSource = [[self.imClientManager.conversationManager getConversationList] mutableCopy];
    [self.tableView reloadData];
    for (ChatConversation *tzConversation in _dataSource) {
        if ([tzConversation.chatterName isBlankString]) {
            [self.imClientManager.conversationManager asyncChatterUserInfoInConversationFromServer:tzConversation completion:^(ChatConversation * conversation) {
                NSInteger index = [_dataSource indexOfObject:tzConversation];
                [self.dataSource replaceObjectAtIndex:index withObject:conversation];
                [self.tableView reloadData];
            }];
        }
        if ([tzConversation.chatterAvatar isBlankString]) {
            
            
        }
    }
}


/**
 *  通过连接状态更新navi的状态
 */
- (void)updateNavigationTitleViewStatus
{
    UIView *titleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 150, 44)];
    UIActivityIndicatorView *activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    activityView.center = CGPointMake(35, 22);
    [titleView addSubview:activityView];
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(55, 0, 105, 44)];
    titleLabel.textColor = COLOR_TEXT_I;
    titleLabel.font = [UIFont boldSystemFontOfSize:17.0];
    [activityView startAnimating];
    [titleView addSubview:titleLabel];
    
    switch (_IMState) {
        case IM_CONNECTING: {
            self.navigationItem.titleView = titleView;
            titleLabel.text = @"连接中...";
            NSLog(@"连接中");
        }
            break;
            
        case IM_DISCONNECTED: {
            UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(55, 0, 105, 44)];
            titleLabel.textColor = COLOR_TEXT_I;
            titleLabel.textAlignment = NSTextAlignmentCenter;
            titleLabel.font = [UIFont boldSystemFontOfSize:17.0];
            titleLabel.text = @"消息(未连接)";
            self.navigationItem.titleView = titleLabel;
            NSLog(@"未连接");
        }
            break;
            
        case IM_RECEIVING: {
            self.navigationItem.titleView = titleView;
            titleLabel.text = @"收取中...";
            NSLog(@"收取中");
            self.navigationItem.titleView = titleView;
        }
            break;
            
        case IM_RECEIVED: {
            UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 105, 44)];
            titleLabel.textColor = COLOR_TEXT_I;
            titleLabel.textAlignment = NSTextAlignmentCenter;
            titleLabel.font = [UIFont boldSystemFontOfSize:17.0];
            titleLabel.text = @"消息";
            self.navigationItem.titleView = titleLabel;
            NSLog(@"IM_RECEIVED");
        }
            break;
            
        case IM_CONNECTED: {
            UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 105, 44)];
            titleLabel.textColor = COLOR_TEXT_I;
            titleLabel.textAlignment = NSTextAlignmentCenter;
            titleLabel.font = [UIFont boldSystemFontOfSize:17.0];
            titleLabel.text = @"消息";
            self.navigationItem.titleView = titleLabel;
            NSLog(@"IM_CONNECTED");
        }
            break;
            
        default: {
            UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 105, 44)];
            titleLabel.textColor = COLOR_TEXT_I;
            titleLabel.textAlignment = NSTextAlignmentCenter;
            titleLabel.font = [UIFont boldSystemFontOfSize:17.0];
            titleLabel.text = @"消息";
            self.navigationItem.titleView = titleLabel;
        }
            break;
    }
    
}

- (IBAction)addConversation:(id)sender
{
    _createConversationCtl = [[CreateConversationViewController alloc] init];
    _createConversationCtl.delegate = self;
    TZNavigationViewController *nCtl = [[TZNavigationViewController alloc] initWithRootViewController:_createConversationCtl];
    [self presentViewController:nCtl animated:YES completion:nil];
}

- (void) setupListView {
    if (self.emptyView != nil) {
        [self.emptyView removeFromSuperview];
        self.emptyView = nil;
    }
    if ([self.tableView superview] == nil) {
        [self.view addSubview:self.tableView];
    }
}

/**
 *  得到最后消息时间
 *
 *  @param conversation
 *
 *  @return
 */
- (NSString *)lastMessageTimeByConversation:(ChatConversation *)conversation
{
    NSString *ret = [NSDate formattedTimeFromTimeInterval:conversation.lastUpdateTime];
    return ret;
}

/**
 * 得到最后消息文字或者类型
 *
 *  @param conversation
 *
 *  @return
 */
- (NSString *)subTitleMessageByConversation:(ChatConversation *)conversation
{
    NSString *ret = @"";
    BaseMessage *lastMessage = [conversation lastLocalMessage];
    if (lastMessage) {
        if (conversation.chatType == IMChatTypeIMChatGroupType) {
            NSString *nickName = lastMessage.senderName;
            switch (lastMessage.messageType) {
                case IMMessageTypeImageMessageType: {
                    ret = [NSString stringWithFormat:@"%@:[图片]", nickName];
                }
                    break;
                    
                case IMMessageTypeTextMessageType: {
                    
                    // 表情映射。
                    NSString *didReceiveText = [ConvertToCommonEmoticonsHelper
                                                convertToSystemEmoticons:lastMessage.message];
                    ret = [NSString stringWithFormat:@"%@: %@",nickName, didReceiveText];
                }
                    break;
                    
                case IMMessageTypeGuideMessageType:
                    ret = [NSString stringWithFormat:@"%@:[链接] %@", nickName, ((IMGuideMessage *)lastMessage).guideName];
                    
                    break;
                case IMMessageTypeTravelNoteMessageType:
                    ret = [NSString stringWithFormat:@"%@:[链接] %@", nickName, ((IMTravelNoteMessage *)lastMessage).name];
                    
                    break;
                case IMMessageTypeSpotMessageType:
                    ret = [NSString stringWithFormat:@"%@:[链接] %@", nickName, ((IMSpotMessage *)lastMessage).spotName];
                    
                    break;
                case IMMessageTypeCityPoiMessageType:
                    ret = [NSString stringWithFormat:@"%@:[链接] %@", nickName, ((IMCityMessage *)lastMessage).poiName];
                    
                    break;
                case IMMessageTypeRestaurantMessageType:
                    ret = [NSString stringWithFormat:@"%@:[链接] %@", nickName, ((IMRestaurantMessage *)lastMessage).poiName];
                    
                    break;
                case IMMessageTypeHotelMessageType:
                    ret = [NSString stringWithFormat:@"%@:[链接] %@", nickName, ((IMHotelMessage *)lastMessage).poiName];
                    break;
                case IMMessageTypeShoppingMessageType: {
                    ret = [NSString stringWithFormat:@"%@:[链接] %@", nickName, ((IMShoppingMessage *)lastMessage).poiName];
                }
                    break;
                    
                    
                case IMMessageTypeAudioMessageType:{
                    ret = [NSString stringWithFormat:@"%@:[语音]", nickName];
                    
                }
                    break;
                    
                case IMMessageTypeLocationMessageType: {
                    ret = [NSString stringWithFormat:@"%@:[位置]", nickName];
                    
                }
                    break;
                    
                case IMMessageTypeQuestionMessageType: {
                    ret = [NSString stringWithFormat:@"%@:[问问消息]", nickName];
                    
                }
                    break;
                    
                case IMMessageTypeHtml5MessageType: {
                    ret = [NSString stringWithFormat:@"%@:[链接]", nickName];
                    
                }
                    break;
                    
                case IMMessageTypeTipsMessageType: {
                    ret = ((TipsMessage *) lastMessage).tipsContent;
                    
                }
                    break;
                    
                default: {
                    ret = [NSString stringWithFormat:@"%@:升级新版本才可以查看这条神秘消息哦", nickName];
                    
                } break;
            }
            
        } else {
            
            switch (lastMessage.messageType) {
                case IMMessageTypeImageMessageType: {
                    ret = [NSString stringWithFormat:@"[图片]"];
                }
                    break;
                    
                case IMMessageTypeTextMessageType: {
                    
                    // 表情映射。
                    NSString *didReceiveText = [ConvertToCommonEmoticonsHelper
                                                convertToSystemEmoticons:lastMessage.message];
                    ret = [NSString stringWithFormat:@"%@", didReceiveText];
                }
                    break;
                    
                case IMMessageTypeGuideMessageType:
                    ret = [NSString stringWithFormat:@"[链接] %@", ((IMGuideMessage *)lastMessage).guideName];
                    break;
                    
                case IMMessageTypeTravelNoteMessageType:
                    ret = [NSString stringWithFormat:@"[链接] %@", ((IMTravelNoteMessage *)lastMessage).name];
                    break;
                    
                case IMMessageTypeSpotMessageType:
                    ret = [NSString stringWithFormat:@"[链接] %@", ((IMSpotMessage *)lastMessage).spotName];
                    break;
                    
                case IMMessageTypeCityPoiMessageType:
                    ret = [NSString stringWithFormat:@"[链接] %@", ((IMCityMessage *)lastMessage).poiName];
                    break;
                    
                case IMMessageTypeRestaurantMessageType:
                    ret = [NSString stringWithFormat:@"[链接] %@", ((IMRestaurantMessage *)lastMessage).poiName];
                    break;
                    
                case IMMessageTypeHotelMessageType:
                    ret = [NSString stringWithFormat:@"[链接] %@", ((IMHotelMessage *)lastMessage).poiName];
                    break;
                    
                case IMMessageTypeShoppingMessageType:
                    ret = [NSString stringWithFormat:@"[链接] %@", ((IMShoppingMessage *)lastMessage).poiName];
                    break;
                    
                case IMMessageTypeHtml5MessageType:
                    ret = [NSString stringWithFormat:@"[链接]"];
                    break;
                    
                case IMMessageTypeAudioMessageType:
                    ret = [NSString stringWithFormat:@"[语音]"];
                    break;
                    
                case IMMessageTypeLocationMessageType:
                    ret = [NSString stringWithFormat:@"[位置]"];
                    break;
                    
                case IMMessageTypeQuestionMessageType:
                    ret = [NSString stringWithFormat:@"[问问消息]"];
                    break;
                    
                case IMMessageTypeTipsMessageType:
                    ret = ((TipsMessage *) lastMessage).tipsContent;
                    break;
                    
                    
                default: {
                    ret = [NSString stringWithFormat:@"升级新版本才可以查看这条神秘消息哦"];
                    
                } break;
            }
            
        }
    }
    return ret;
}

//通过 uiview 获取 uiviewcontroller
- (UIViewController *)findViewController:(UIView *)sourceView
{
    id target=sourceView;
    while (target) {
        target = ((UIResponder *)target).nextResponder;
        if ([target isKindOfClass:[UIViewController class]]) {
            break;
        }
    }
    return target;
}

- (void)pushChatViewControllerWithConversation: (ChatConversation *)conversation
{
    ChatViewController *chatController = [[ChatViewController alloc] initWithConversation:conversation];
    chatController.chatterName = conversation.chatterName;
    UIViewController *menuViewController = nil;
    if (conversation.chatType == IMChatTypeIMChatGroupType || conversation.chatType == IMChatTypeIMChatDiscussionGroupType) {
        menuViewController = [[ChatGroupSettingViewController alloc] init];
        ((ChatGroupSettingViewController *)menuViewController).groupId = conversation.chatterId;
        ((ChatGroupSettingViewController *)menuViewController).conversation = conversation;
        
    } else {
        menuViewController = [[ChatSettingViewController alloc] init];
        ((ChatSettingViewController *)menuViewController).currentConversation= conversation;
        ((ChatSettingViewController *)menuViewController).chatterId = conversation.chatterId;
    }
    
    REFrostedViewController *frostedViewController = [[REFrostedViewController alloc] initWithContentViewController:chatController menuViewController:menuViewController];
    if (conversation.chatType == IMChatTypeIMChatGroupType || conversation.chatType == IMChatTypeIMChatDiscussionGroupType) {
        ((ChatGroupSettingViewController *)menuViewController).containerCtl = frostedViewController;
    } else {
        ((ChatSettingViewController *)menuViewController).containerCtl = frostedViewController;
    }
    frostedViewController.hidesBottomBarWhenPushed = YES;
    frostedViewController.direction = REFrostedViewControllerDirectionRight;
    frostedViewController.liveBlurBackgroundStyle = REFrostedViewControllerLiveBackgroundStyleLight;
    frostedViewController.liveBlur = YES;
    frostedViewController.limitMenuViewSize = YES;
    self.navigationController.interactivePopGestureRecognizer.delaysTouchesBegan = NO;
    [self.navigationController pushViewController:frostedViewController animated:YES];
}


#pragma mark - IBAction

- (IBAction)showContactList:(id)sender
{
    ContactListViewController *contactListCtl = [[ContactListViewController alloc] init];
    [MobClick endEvent:@"navigation_item_my_friends"];
    TZNavigationViewController *nCtl = [[TZNavigationViewController alloc] initWithRootViewController:contactListCtl];
    [self presentViewController:nCtl animated:YES completion:nil];
}

- (IBAction)addUserContact:(id)sender
{
    AddContactTableViewController *addContactCtl = [[AddContactTableViewController alloc] init];
    TZNavigationViewController *nCtl = [[TZNavigationViewController alloc] initWithRootViewController:addContactCtl];
    [self presentViewController:nCtl animated:YES completion:nil];
}

- (IBAction)addAction:(UIButton *)sender
{
    [MobClick endEvent:@"navigation_item_talks_menu"];
    
    PXAlertView *alertView = [PXAlertView showAlertWithTitle:nil
                                                     message:nil
                                                 cancelTitle:@"取消"
                                                 otherTitles:@[ @"新建聊天(群)", @"添加朋友"]
                                                  completion:^(BOOL cancelled, NSInteger buttonIndex) {
                                                      if (buttonIndex == 1) {
                                                          [self addConversation:nil];
                                                      } else if (buttonIndex == 2) {
                                                          [self addUserContact:nil];
                                                      }
                                                  }];
    
    
    [alertView setTitleFont:[UIFont systemFontOfSize:16]];
    [alertView useCustomStyle];
    
    [alertView setBackgroundColor:[UIColor whiteColor]];
    
    
    // 设置其他按钮的颜色
    UIColor * otherNormal = TEXT_COLOR_TITLE;
    UIColor * otherSeleced = APP_THEME_COLOR;
    [alertView setAllButtonsTextColor:otherNormal andHighLightedColor:otherSeleced];
    
    // 设置取消按钮的颜色
    UIColor *cancelNormal = TEXT_COLOR_TITLE;
    UIColor *cancelSelected = TEXT_COLOR_TITLE;
    [alertView setCancelButtonTextColor:cancelNormal andHighLightedColor:cancelSelected];
    
    // 设置取消按钮的下划线
    [alertView setCancelUnderlineWithColor:COLOR_LINE];
}

#pragma mark - TableViewDelegate & TableViewDatasource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identify = @"chatListCell";
    ChatListCell *cell = [tableView dequeueReusableCellWithIdentifier:identify forIndexPath:indexPath];
    
    ChatConversation *tzConversation = [self.dataSource objectAtIndex:indexPath.row];
    
    if (tzConversation.chatType == IMChatTypeIMChatSingleType) {
        if ([tzConversation.chatterName isBlankString]) {
            if (tzConversation.chatterId == WenwenUserId) {
                cell.name = @"旅行问问";
            } else if (tzConversation.chatterId == PaipaiUserId) {
                cell.name = @"旅行派";
            } else {
                cell.name = [NSString stringWithFormat:@"%ld", (long)tzConversation.chatterId];
            }
        } else {
            cell.name = tzConversation.chatterName;
        }
        if (tzConversation.chatterId == WenwenUserId) {
            cell.imageView.image = [UIImage imageNamed:@"lvxingwenwen.png"];
            cell.imageView.layer.cornerRadius = 9;
        } else if (tzConversation.chatterId == PaipaiUserId) {
            cell.imageView.image = [UIImage imageNamed:@"lvxingpaipai.png"];
            cell.imageView.layer.cornerRadius = 9;

        } else {
            [cell.imageView sd_setImageWithURL:[NSURL URLWithString:tzConversation.chatterAvatar] placeholderImage:[UIImage imageNamed:@"avatar_default"]];
            cell.imageView.layer.cornerRadius = 28;
        }
    } else {
        cell.imageView.layer.cornerRadius = 28;
        cell.imageView.image = [UIImage imageNamed:@"icon_chat_group.png"];
        if (tzConversation.chatterName && ![tzConversation.chatterName isBlankString]) {
            cell.name = tzConversation.chatterName;
        } else {
            cell.name = [NSString stringWithFormat:@"%ld", tzConversation.chatterId];
        }
    }
    
    BaseMessage *message = tzConversation.lastLocalMessage;
    
    BOOL isSender = message.sendType == IMMessageSendTypeMessageSendMine ? YES : NO;
    
    if (isSender) {
        if (message.status == IMMessageStatusIMMessageSending) {
            cell.sendStatus = MSGSending;
        }
        if (message.status == IMMessageStatusIMMessageFailed) {
            cell.sendStatus = MSGSendFaild;
        }
        if (message.status == IMMessageStatusIMMessageSuccessful) {
            cell.sendStatus = MSGSended;
        }
    } else {
        cell.sendStatus = MSGSended;
    }
    cell.detailMsg = [self subTitleMessageByConversation:tzConversation];
    cell.time = [self lastMessageTimeByConversation:tzConversation];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.unreadCount = tzConversation.unReadMessageCount;
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return  self.dataSource.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 76;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    ChatConversation *tzConversation = [self.dataSource objectAtIndex:indexPath.row];
    [self pushChatViewControllerWithConversation:tzConversation];
    tzConversation.unReadMessageCount = 0;
    [tzConversation resetConvsersationUnreadMessageCount];
    [_delegate unreadMessageCountHasChange];
    
    if (tzConversation.chatterId == WenwenUserId) {
        [MobClick event:@"cell_item_wenwen"];
    }
    if (tzConversation.chatterId == PaipaiUserId) {
        [MobClick event:@"cell_item_paipai"];
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    ChatConversation *conversation = [self.dataSource objectAtIndex:indexPath.row];
    if (conversation.chatterId != WenwenUserId && conversation.chatterId != PaipaiUserId) {
        return YES;
    } else {
        return NO;
    }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        ChatConversation *conversation = [self.dataSource objectAtIndex:indexPath.row];
        if (conversation.chatterId != WenwenUserId && conversation.chatterId != PaipaiUserId) {
            [self.imClientManager.conversationManager removeConversationWithChatterId: conversation.chatterId deleteMessage:NO];
        }
    }
}

#pragma mark - ChatConversationManagerDelegate

- (void)conversationsHaveAdded:(NSArray * __nonnull)conversationList
{
    [_delegate unreadMessageCountHasChange];
    [self refreshDataSource];
}

- (void)conversationsHaveRemoved:(NSArray * __nonnull)conversationList
{
    for (ChatConversation *addedConversation in conversationList) {
        for (ChatConversation *conversation in _dataSource) {
            if (addedConversation.chatterId == conversation.chatterId) {
                NSInteger row = [_dataSource indexOfObject:conversation];
                [_dataSource removeObject:conversation];
                [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForItem:row inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
                [_delegate unreadMessageCountHasChange];
                break;
            }
        }
    }
}

- (void)conversationStatusHasChanged:(ChatConversation * __nonnull)conversation
{
    [_delegate unreadMessageCountHasChange];
    [self refreshDataSource];
}

#pragma mark - FriendRequestManagerDelegate

- (void)friendRequestNumberNeedUpdate
{
    if ([IMClientManager shareInstance].frendRequestManager.unReadFrendRequestCount > 0) {
        _frendRequestUnreadCountLabel.hidden = NO;
    } else {
        _frendRequestUnreadCountLabel.hidden = YES;
    }
}

#pragma mark - CreateConversationDelegate

- (void)createConversationSuccessWithChatter:(NSInteger)chatterId chatType:(IMChatType)chatType chatTitle:(NSString *)chatTitle
{
    [_createConversationCtl dismissViewControllerAnimated:YES completion:^{
        ChatConversation *conversation = [self.imClientManager.conversationManager getConversationWithChatterId:chatterId chatType:chatType];
        [self pushChatViewControllerWithConversation:conversation];
    }];
}

@end



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
#import "RealtimeSearchUtil.h"
#import "ChatViewController.h"
#import "ConvertToCommonEmoticonsHelper.h"
#import "AccountManager.h"
#import "CreateConversationViewController.h"
#import "ContactListViewController.h"
#import "AddContactTableViewController.h"
#import "PXAlertView+Customization.h"
#import "REFrostedViewController.h"
#import "ChatGroupSettingViewController.h"
#import "ChatSettingViewController.h"
#import "PeachTravel-swift.h"

@interface ChatListViewController ()<UITableViewDelegate, UITableViewDataSource, IChatManagerDelegate, CreateConversationDelegate, ChatConversationManagerDelegate>

@property (strong, nonatomic) UITableView           *tableView;
@property (nonatomic, strong) AccountManager        *accountManager;
@property (nonatomic, strong) CreateConversationViewController *createConversationCtl;
@property (strong, nonatomic) NSMutableArray *dataSource;

@property (nonatomic, strong) UIView *emptyView;

@property (nonatomic, strong) IMClientManager *imClientManager;

/**
 *  是否有未读的消息，如果有出现小红点
 */
@property (nonatomic) BOOL *isShowNotify;

@end

@implementation ChatListViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)loadView
{
    [super loadView];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.tableView];
    self.imClientManager.conversationManager.delegate = self;
    _dataSource = [[self.imClientManager.conversationManager getConversationList] mutableCopy];
    
    UIButton *addBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    [addBtn setImage:[UIImage imageNamed:@"add_contact.png"] forState:UIControlStateNormal];
    [addBtn addTarget:self action:@selector(addAction:) forControlEvents:UIControlEventTouchUpInside];
    addBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:addBtn];
    
    UIButton *contactListBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    [contactListBtn setImage:[UIImage imageNamed:@"ic_contacts_normal.png"] forState:UIControlStateNormal];
    [contactListBtn addTarget:self action:@selector(showContactList:) forControlEvents:UIControlEventTouchUpInside];
    contactListBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:contactListBtn];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userDidLogin) name:userDidLoginNoti object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(networkChanged:) name:networkConnectionStatusChangeNoti object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(paipaiSayHello2User) name:userDidLoginNoti object:nil];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [MobClick beginLogPageView:@"page_talk_lists"];
    [self refreshDataSource];
    [self updateNavigationTitleViewStatus];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:@"page_talk_lists"];
}

- (void)dealloc {
    _createConversationCtl.delegate = nil;
    _createConversationCtl = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)userDidLogin
{
    [self.imClientManager.conversationManager updateConversationListFromDB];
    _dataSource = [[self.imClientManager.conversationManager getConversationList] mutableCopy];
    [self.tableView reloadData];
}

- (void)networkChanged:(NSNotification *)noti
{
    NSDictionary *userInfo = noti.userInfo;
    NetworkStatus status = [[userInfo objectForKey:@"status"] integerValue];
    if (status == NotReachable) {
        [self setIMState:IM_DISCONNECTED];
    } else {
        [self setIMState:IM_CONNECTED];
    }
}

- (void)refreshDataSource
{
    _dataSource = [[self.imClientManager.conversationManager getConversationList] mutableCopy];
    [self.tableView reloadData];
    [_delegate unreadMessageCountHasChange:self.imClientManager.conversationManager.totalMessageUnreadCount];
    
}

/**
 *  登录成功后服务号向大家打招呼
 */
- (void)paipaiSayHello2User
{
    EMConversation *conversation = [[EaseMob sharedInstance].chatManager conversationForChatter:@"gcounhhq0ckfjwotgp02c39vq40ewhxt" isGroup:NO];
    [self insertPaipaiHelloMsgToEasemobDB:conversation];
}

- (void)insertPaipaiHelloMsgToEasemobDB:(EMConversation *)conversation
{
    if (conversation.latestMessage) {
        return;
    }
    id  chatManager = [[EaseMob sharedInstance] chatManager];
    NSDictionary *loginInfo = [chatManager loginInfo];
    NSString *account = [loginInfo objectForKey:kSDKUsername];
    EMChatText *chatText = [[EMChatText alloc] initWithText:@"欢迎使用旅行派"];
    EMTextMessageBody *textBody = [[EMTextMessageBody alloc] initWithChatObject:chatText];
    EMMessage *message = [[EMMessage alloc] initWithReceiver:conversation.chatter bodies:@[textBody]];

    [message setIsGroup:NO];
    [message setIsReadAcked:NO];
    [message setTo:account];
    [message setFrom:conversation.chatter];
    [message setIsGroup:NO];
    message.conversationChatter = conversation.chatter;
    
    NSTimeInterval interval = [[NSDate date] timeIntervalSince1970];
    NSString *messageID = [NSString stringWithFormat:@"%.0f", interval];
    [message setMessageId:messageID];
    
    [chatManager importMessage:message
                   append2Chat:YES];
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

- (IBAction)addAction:(UIButton *)sender
{
    PXAlertView *alertView = [PXAlertView showAlertWithTitle:nil
                                    message:nil
                                cancelTitle:@"取消"
                                otherTitles:@[ @"新建聊天", @"添加好友"]
                                 completion:^(BOOL cancelled, NSInteger buttonIndex) {
                                     if (buttonIndex == 1) {
                                         [self addConversation:nil];
                                         [MobClick event:@"event_create_new_talk"];
                                     } else if (buttonIndex == 2) {
                                         [self addUserContact:nil];
                                         [MobClick event:@"event_add_new_friend"];
                                     }
                                 }];
    [alertView setTitleFont:[UIFont systemFontOfSize:16]];
    [alertView useDefaultIOS7Style];
}

- (UITableView *)tableView
{
    if (_tableView == nil) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0.0, self.view.frame.size.width, self.view.frame.size.height) style:UITableViewStylePlain];
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


#pragma mark - IBAction

- (IBAction)showContactList:(id)sender
{
    ContactListViewController *contactListCtl = [[ContactListViewController alloc] init];
    
    TZNavigationViewController *nCtl = [[TZNavigationViewController alloc] initWithRootViewController:contactListCtl];
    [self presentViewController:nCtl animated:YES completion:nil];
}

- (IBAction)addUserContact:(id)sender
{
    AddContactTableViewController *addContactCtl = [[AddContactTableViewController alloc] init];
    TZNavigationViewController *nCtl = [[TZNavigationViewController alloc] initWithRootViewController:addContactCtl];
    [self presentViewController:nCtl animated:YES completion:nil];
}


#pragma mark - private

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
    titleLabel.textColor = [UIColor blackColor];
    titleLabel.font = [UIFont boldSystemFontOfSize:17.0];
    [activityView startAnimating];
    [titleView addSubview:titleLabel];
    
    switch (_IMState) {
        case IM_CONNECTING: {
            self.navigationItem.titleView = titleView;
            titleLabel.text = @"旅行圈(连接中...)";
            NSLog(@"连接中");
        }
            break;
            
        case IM_DISCONNECTED: {
            UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(55, 0, 105, 44)];
            titleLabel.textColor = [UIColor redColor];
            titleLabel.textAlignment = NSTextAlignmentCenter;
            titleLabel.font = [UIFont boldSystemFontOfSize:17.0];
            titleLabel.text = @"旅行圈(未连接)";
            self.navigationItem.titleView = titleLabel;
            NSLog(@"未连接");
        }
            break;
            
        case IM_RECEIVING: {
            self.navigationItem.titleView = titleView;
            titleLabel.text = @"旅行圈(收取中...)";
            NSLog(@"收取中");
            self.navigationItem.titleView = titleView;
        }
            break;
            
        case IM_RECEIVED: {
            UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 105, 44)];
            titleLabel.textColor = [UIColor blackColor];
            titleLabel.textAlignment = NSTextAlignmentCenter;
            titleLabel.font = [UIFont boldSystemFontOfSize:17.0];
            titleLabel.text = @"旅行圈";
            self.navigationItem.titleView = titleLabel;
            NSLog(@"IM_RECEIVED");
        }
            break;
            
        case IM_CONNECTED: {
            UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 105, 44)];
            titleLabel.textColor = [UIColor blackColor];
            titleLabel.textAlignment = NSTextAlignmentCenter;
            titleLabel.font = [UIFont boldSystemFontOfSize:17.0];
            titleLabel.text = @"旅行圈";
            self.navigationItem.titleView = titleLabel;
            NSLog(@"IM_CONNECTED");
        }
            break;
            
        default: {
            UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 105, 44)];
            titleLabel.textColor = [UIColor blackColor];
            titleLabel.textAlignment = NSTextAlignmentCenter;
            titleLabel.font = [UIFont boldSystemFontOfSize:17.0];
            titleLabel.text = @"旅行圈";
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
-(NSString *)lastMessageTimeByConversation:(ChatConversation *)conversation
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
-(NSString *)subTitleMessageByConversation:(ChatConversation *)conversation
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
                    ret = [NSString stringWithFormat:@"%@:[链接] %@", nickName, ((IMGuideMessage *)lastMessage).guideId];

                    break;
                case IMMessageTypeTravelNoteMessageType:
                    ret = [NSString stringWithFormat:@"%@:[链接] %@", nickName, ((IMTravelNoteMessage *)lastMessage).travelNoteId];

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
                    ret = [NSString stringWithFormat:@"[链接] %@", ((IMGuideMessage *)lastMessage).guideId];
                    
                    break;
                case IMMessageTypeTravelNoteMessageType:
                    ret = [NSString stringWithFormat:@"[链接] %@", ((IMTravelNoteMessage *)lastMessage).travelNoteId];
                    
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
                case IMMessageTypeShoppingMessageType: {
                    ret = [NSString stringWithFormat:@"[链接] %@", ((IMShoppingMessage *)lastMessage).poiName];
                }
                    break;

                    
                    
                case IMMessageTypeAudioMessageType:{
                    ret = [NSString stringWithFormat:@"[语音]"];
                    
                }
                    break;
                    
                case IMMessageTypeLocationMessageType: {
                    ret = [NSString stringWithFormat:@"[位置]"];
                    
                }
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

    UIViewController *menuViewController = nil;
    if (conversation.chatType == IMChatTypeIMChatGroupType) {
        menuViewController = [[ChatGroupSettingViewController alloc] init];
        EMGroup *chatGroup;
        ((ChatGroupSettingViewController *)menuViewController).group = chatGroup;
    } else {
        menuViewController = [[ChatSettingViewController alloc] init];
        ((ChatSettingViewController *)menuViewController).chatterId = conversation.chatterId;
    }
    
    REFrostedViewController *frostedViewController = [[REFrostedViewController alloc] initWithContentViewController:chatController menuViewController:menuViewController];
    frostedViewController.hidesBottomBarWhenPushed = YES;
    frostedViewController.direction = REFrostedViewControllerDirectionRight;
    frostedViewController.liveBlurBackgroundStyle = REFrostedViewControllerLiveBackgroundStyleLight;
    frostedViewController.liveBlur = YES;
    frostedViewController.limitMenuViewSize = YES;
    frostedViewController.resumeNavigationBar = NO;
    self.navigationController.interactivePopGestureRecognizer.delaysTouchesBegan = NO;
    [self.navigationController pushViewController:frostedViewController animated:YES];
    frostedViewController.navigationItem.title = conversation.chatterName;
}

#pragma mark - TableViewDelegate & TableViewDatasource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *identify = @"chatListCell";
    ChatListCell *cell = [tableView dequeueReusableCellWithIdentifier:identify forIndexPath:indexPath];

    ChatConversation *tzConversation = [self.dataSource objectAtIndex:indexPath.row];

    if (tzConversation.chatType == IMChatTypeIMChatSingleType) {
        cell.name = tzConversation.chatterName;
        [cell.imageView sd_setImageWithURL:[NSURL URLWithString:tzConversation.chatterAvatar] placeholderImage:[UIImage imageNamed:@"avatar_placeholder.png"]];
    } else{
        cell.imageView.image = [UIImage imageNamed:@"avatar_placeholder.png"];
        cell.name = tzConversation.chatterName;
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
    cell.unreadCount = tzConversation.unReadMessageCount;
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return  self.dataSource.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return [ChatListCell tableView:tableView heightForRowAtIndexPath:indexPath];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    ChatConversation *tzConversation = [self.dataSource objectAtIndex:indexPath.row];
    [self pushChatViewControllerWithConversation:tzConversation];
    tzConversation.unReadMessageCount = 0;

}

-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        ChatConversation *conversation = [self.dataSource objectAtIndex:indexPath.row];
        [self.imClientManager.conversationManager removeConversationWithChatterId: conversation.chatterId];
        [MobClick event:@"event_delete_talk_item"];
    }
}

#pragma mark - ChatConversationManagerDelegate
- (void)conversationsHaveAdded:(NSArray * __nonnull)conversationList
{
    NSLog(@"ChatConversationManagerDelegate - conversationListNeedUpdate");
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
                break;
            }
        }
    }
}

- (void)conversationStatusHasChanged:(ChatConversation * __nonnull)conversation
{
    [self refreshDataSource];
}

#pragma mark - CreateConversationDelegate

- (void)createConversationSuccessWithChatter:(NSInteger)chatterId chatType:(IMChatType)chatType chatTitle:(NSString *)chatTitle
{
    [_createConversationCtl dismissViewControllerAnimated:YES completion:^{
        ChatConversation *conversation = [self.imClientManager.conversationManager getConversationWithChatterId:chatterId];
        [self pushChatViewControllerWithConversation:conversation];
    }];
}

@end



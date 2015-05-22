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
#import "ChatListViewController.h"
#import "ChatListCell.h"
#import "NSDate+Category.h"
#import "RealtimeSearchUtil.h"
#import "ChatViewController.h"
#import "EMSearchDisplayController.h"
#import "ConvertToCommonEmoticonsHelper.h"
#import "AccountManager.h"
#import "CreateConversationViewController.h"
#import "TZConversation.h"
#import "ContactListViewController.h"
#import "AddContactTableViewController.h"
#import "PXAlertView+Customization.h"
#import "REFrostedViewController.h"
#import "ChatGroupSettingViewController.h"
#import "ChatSettingViewController.h"

@interface ChatListViewController ()<UITableViewDelegate, UITableViewDataSource, IChatManagerDelegate, CreateConversationDelegate>

@property (strong, nonatomic) NSMutableArray        *chattingPeople;       //保存正在聊天的联系人的旅行派信息，显示界面的时候需要用到
@property (strong, nonatomic) UITableView           *tableView;
@property (nonatomic, strong) AccountManager        *accountManager;
@property (nonatomic, strong) CreateConversationViewController *createConversationCtl;
@property (strong, nonatomic) EMSearchDisplayController *searchController;

@property (nonatomic, strong) UIView *emptyView;

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
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [MobClick beginLogPageView:@"page_talk_lists"];
    [self refreshDataSource];
    [self registerNotifications];
    [self updateNavigationTitleViewStatus];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:@"page_talk_lists"];
}

- (void)dealloc{
    [self unregisterNotifications];
    _createConversationCtl.delegate = nil;
    _createConversationCtl = nil;
    _searchController.delegate = nil;
    _searchController = nil;
}

#pragma mark - getter & setter

- (AccountManager *)accountManager
{
    if (!_accountManager) {
        _accountManager = [AccountManager shareAccountManager];
    }
    return _accountManager;
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

- (int)numberOfUnReadChatMsg
{
    if (!_chattingPeople) {
        [self loadChattingPeople];
    }
    int ret = 0;
    for (TZConversation *tzConversation in _chattingPeople) {
        ret += tzConversation.conversation.unreadMessagesCount;
    }
    return ret;
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
//    contactListCtl.hidesBottomBarWhenPushed = YES;
//    [self.navigationController pushViewController:contactListCtl animated:YES];
    
    TZNavigationViewController *nCtl = [[TZNavigationViewController alloc] initWithRootViewController:contactListCtl];
    [self presentViewController:nCtl animated:YES completion:nil];
}

- (IBAction)addUserContact:(id)sender
{
    AddContactTableViewController *addContactCtl = [[AddContactTableViewController alloc] init];
    TZNavigationViewController *nCtl = [[TZNavigationViewController alloc] initWithRootViewController:addContactCtl];
    [self presentViewController:nCtl animated:YES completion:nil];
    
//    addContactCtl.hidesBottomBarWhenPushed = YES;
//    [self.navigationController pushViewController:addContactCtl animated:YES];
}


#pragma mark - private

/**
 *  得到聊天历史列表的好友的信息
 */
- (void)loadChattingPeople
{
    NSLog(@"开始加载正在聊天的人");
    NSMutableArray *dataSource = [self loadConversations];
    if (!_chattingPeople) {
        _chattingPeople = [[NSMutableArray alloc] init];
    } else {
        [_chattingPeople removeAllObjects];
    }
    for (EMConversation *conversation in dataSource) {
        if (!conversation.chatter) {
            [[EaseMob sharedInstance].chatManager removeConversationByChatter:conversation.chatter deleteMessages:YES
                                                                  append2Chat:YES];
        }
        if (!conversation.isGroup) {
            if ([self.accountManager TZContactByEasemobUser:conversation.chatter]) {
                TZConversation *tzConversation = [[TZConversation alloc] init];
                tzConversation.chatterNickName = [self.accountManager TZContactByEasemobUser:conversation.chatter].nickName;
                tzConversation.chatterAvatar = [self.accountManager TZContactByEasemobUser:conversation.chatter].avatarSmall;
                tzConversation.conversation = conversation;
                [_chattingPeople addObject:tzConversation];
            } else {
//                [[EaseMob sharedInstance].chatManager removeConversationByChatter:conversation.chatter deleteMessages:NO
//                                                                      append2Chat:YES];

            }
            
        } else {
            NSArray *groupArray = [[EaseMob sharedInstance].chatManager groupList];
            for (EMGroup *group in groupArray) {
                NSLog(@"%@", group.groupSubject);
            }
            
            TZConversation *tzConversation = [[TZConversation alloc] init];
            tzConversation.conversation = conversation;
            [_chattingPeople addObject:tzConversation];

            for (EMGroup *group in groupArray) {
                if ([group.groupId isEqualToString:conversation.chatter]) {
                    if (group.groupSubject) {
                        tzConversation.chatterNickName = group.groupSubject;
                    }
                    break;
                }
            }
            if (!tzConversation.chatterNickName) {
                Group *group = [self.accountManager groupWithGroupId:tzConversation.conversation.chatter];
                tzConversation.chatterNickName = group.groupSubject;
            }
        }
    }
    if (_chattingPeople.count > 0) {
        [self setupListView];
    }
    NSLog(@"结束加载正在聊天的人");

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

- (NSMutableArray *)loadConversations
{
    NSLog(@"loadDataSource start");
    NSMutableArray *ret = nil;
    NSArray *conversations = [[EaseMob sharedInstance].chatManager conversations];
    NSArray* sorte = [conversations sortedArrayUsingComparator:
           ^(EMConversation *obj1, EMConversation* obj2){
               EMMessage *message1 = [obj1 latestMessage];
               EMMessage *message2 = [obj2 latestMessage];
               if(message1.timestamp > message2.timestamp) {
                   return(NSComparisonResult)NSOrderedAscending;
               }else {
                   return(NSComparisonResult)NSOrderedDescending;
               }
           }];
    ret = [[NSMutableArray alloc] initWithArray:sorte];
    NSLog(@"loadDataSource end");
    return ret;
}

/**
 *  得到最后消息时间
 *
 *  @param conversation
 *
 *  @return
 */
-(NSString *)lastMessageTimeByConversation:(EMConversation *)conversation
{
    NSString *ret = @"";
    EMMessage *lastMessage = [conversation latestMessage];
    if (lastMessage) {
        ret = [NSDate formattedTimeFromTimeInterval:lastMessage.timestamp];
    }
    
    return ret;
}

// 得到未读消息条数
- (NSInteger)unreadMessageCountByConversation:(EMConversation *)conversation
{
    NSInteger ret = 0;
    ret = conversation.unreadMessagesCount;
    return  ret;
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
    return NO;
}

/**
 * 得到最后消息文字或者类型
 *
 *  @param conversation
 *
 *  @return
 */
-(NSString *)subTitleMessageByConversation:(EMConversation *)conversation
{
    NSString *ret = @"";
    EMMessage *lastMessage = [conversation latestMessage];
    if (lastMessage) {
        if (conversation.isGroup) {
            NSString *nickName = [[lastMessage.ext objectForKey:@"fromUser"] objectForKey:@"nickName"];
            id<IEMMessageBody> messageBody = lastMessage.messageBodies.lastObject;
            switch (messageBody.messageBodyType) {
                case eMessageBodyType_Image:{
                    ret = [NSString stringWithFormat:@"%@:[图片]", nickName];
                }
                    break;
                    
                case eMessageBodyType_Text:{
                    
                    switch ([[lastMessage.ext objectForKey:@"tzType"] integerValue]) {
                        case TZChatNormalText: {
                            // 表情映射。
                            NSString *didReceiveText = [ConvertToCommonEmoticonsHelper
                                                        convertToSystemEmoticons:((EMTextMessageBody *)messageBody).text];
                            ret = [NSString stringWithFormat:@"%@: %@",nickName, didReceiveText];
                        }
                            break;
                            
                        case TZChatTypeStrategy: case TZChatTypeTravelNote: case TZChatTypeSpot: case TZChatTypeCity: case TZChatTypeFood: case TZChatTypeHotel: case TZChatTypeShopping:{

                            ret = [NSString stringWithFormat:@"%@:[链接]%@", nickName, [[lastMessage.ext objectForKey:@"content"] objectForKey:@"name"]];
                        }
                            break;
                            
                        case TZTipsMsg: {
                            ret = [lastMessage.ext objectForKey:@"content"];
                        }
                            break;
                            
                        default: {
                            ret = [NSString stringWithFormat:@"升级新版本才可以查看这条神秘消息哦"];
                        }
                            break;
                    }

                }
                    break;
                    
                case eMessageBodyType_Voice:{
                    ret = [NSString stringWithFormat:@"%@:[语音]", nickName];

                }
                    break;
                    
                case eMessageBodyType_Location: {
                    ret = [NSString stringWithFormat:@"%@:升级新版本才可以查看这条神秘消息哦", nickName];

                }
                    break;
                    
                case eMessageBodyType_Video: {
                    ret = [NSString stringWithFormat:@"%@:升级新版本才可以查看这条神秘消息哦", nickName];

                }
                    break;
                    
                default: {
                    ret = [NSString stringWithFormat:@"%@:升级新版本才可以查看这条神秘消息哦", nickName];

                } break;
            }

        } else {
            
            id<IEMMessageBody> messageBody = lastMessage.messageBodies.lastObject;
            switch (messageBody.messageBodyType) {
                    
                case eMessageBodyType_Image:{
                    ret = @"[图片]";
                }
                    break;
                    
                case eMessageBodyType_Text:{
                    
                    switch ([[lastMessage.ext objectForKey:@"tzType"] integerValue]) {
                        case TZChatNormalText: {
                            // 表情映射。
                            NSString *didReceiveText = [ConvertToCommonEmoticonsHelper
                                                        convertToSystemEmoticons:((EMTextMessageBody *)messageBody).text];
                            ret = didReceiveText;
                            
                        }
                            break;
                            
                        case TZChatTypeStrategy: case TZChatTypeTravelNote: case TZChatTypeSpot: case TZChatTypeCity: case TZChatTypeFood: case TZChatTypeHotel: case TZChatTypeShopping:{
                            
                            ret = [NSString stringWithFormat:@"[链接]%@",[[lastMessage.ext objectForKey:@"content"] objectForKey:@"name"]];
                            
                        }
                            break;

                        case TZTipsMsg: {
                            ret = [lastMessage.ext objectForKey:@"content"];
                        }
                            break;
                            
                        default: {
                            ret = [NSString stringWithFormat:@"升级新版本才可以查看这条神秘消息哦"];
                        }
                            break;
                    }
                    
                }
                    break;
                    
                case eMessageBodyType_Voice:{
                    ret = @"[声音]";
                } break;
                case eMessageBodyType_Location: {
                    ret = @"[位置]";
                } break;
                case eMessageBodyType_Video: {
                    ret = @"[视频]";
                } break;
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

- (void)pushChatViewControllerWithChatter:(NSString *)chatter isGroup:(BOOL)isGroup chatTitle:(NSString *)chatTitle
{

    ChatViewController *chatController;
    chatController = [[ChatViewController alloc] initWithChatter:chatter isGroup:isGroup];
    chatController.chatterNickName = chatTitle;
    chatController.title = chatTitle;
    
    UIViewController *menuViewController = nil;
    if (isGroup) {
        menuViewController = [[ChatGroupSettingViewController alloc] init];
        EMGroup *chatGroup = [EMGroup groupWithId:chatter];
        ((ChatGroupSettingViewController *)menuViewController).group = chatGroup;
    } else {
//        menuViewController = [[ChatSettingViewController alloc] init];
//        ((ChatSettingViewController *)menuViewController).chatter = chatter;
    }
    
    REFrostedViewController *frostedViewController = [[REFrostedViewController alloc] initWithContentViewController:chatController menuViewController:menuViewController];
    frostedViewController.hidesBottomBarWhenPushed = YES;
    frostedViewController.direction = REFrostedViewControllerDirectionRight;
    frostedViewController.liveBlurBackgroundStyle = REFrostedViewControllerLiveBackgroundStyleLight;
    frostedViewController.liveBlur = YES;
    frostedViewController.limitMenuViewSize = YES;
    frostedViewController.resumeNavigationBar = NO;
    self.navigationController.interactivePopGestureRecognizer.delaysTouchesBegan=NO;
    [self.navigationController pushViewController:frostedViewController animated:YES];
}

#pragma mark - TableViewDelegate & TableViewDatasource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *identify = @"chatListCell";
    ChatListCell *cell = [tableView dequeueReusableCellWithIdentifier:identify forIndexPath:indexPath];

    TZConversation *tzConversation = [self.chattingPeople objectAtIndex:indexPath.row];
    
    if (!tzConversation.conversation.isGroup) {
        cell.name = tzConversation.chatterNickName;
        [cell.imageView sd_setImageWithURL:[NSURL URLWithString:tzConversation.chatterAvatar] placeholderImage:[UIImage imageNamed:@"avatar_placeholder.png"]];
    } else{
        cell.name = tzConversation.chatterNickName;
    }
    
    EMMessage *message = tzConversation.conversation.latestMessage;
    NSDictionary *userInfo = [[EaseMob sharedInstance].chatManager loginInfo];
    NSString *login = [userInfo objectForKey:kSDKUsername];
    BOOL isSender = [login isEqualToString:message.from] ? YES : NO;
    
    if (isSender) {
        if (message.deliveryState == eMessageDeliveryState_Delivering) {
            cell.sendStatus = MSGSending;
        }
        if (message.deliveryState == eMessageDeliveryState_Failure) {
            cell.sendStatus = MSGSendFaild;
        }
        if (message.deliveryState == eMessageDeliveryState_Delivered) {
            cell.sendStatus = MSGSended;
        }
    } else {
        cell.sendStatus = MSGSended;
    }
    cell.detailMsg = [self subTitleMessageByConversation:tzConversation.conversation];
    cell.time = [self lastMessageTimeByConversation:tzConversation.conversation];
    cell.unreadCount = [self unreadMessageCountByConversation:tzConversation.conversation];
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return  self.chattingPeople.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return [ChatListCell tableView:tableView heightForRowAtIndexPath:indexPath];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    TZConversation *tzConversation = [self.chattingPeople objectAtIndex:indexPath.row];
    NSString *title;
    if (tzConversation.conversation.isGroup) {
        title = tzConversation.chatterNickName;
    } else {
        title = tzConversation.chatterNickName;
    }
    
    NSString *chatter = tzConversation.conversation.chatter;
    [self pushChatViewControllerWithChatter:chatter isGroup:tzConversation.conversation.isGroup chatTitle:title];
    [tzConversation.conversation markAllMessagesAsRead:YES];

}

-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        TZConversation *tzConveration = [self.chattingPeople objectAtIndex:indexPath.row];
        [[EaseMob sharedInstance].chatManager removeConversationByChatter:tzConveration.conversation.chatter deleteMessages:YES
                                                              append2Chat:YES];
        [self.chattingPeople removeObjectAtIndex:indexPath.row];
        [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        [MobClick event:@"event_delete_talk_item"];
    }
}

#pragma mark - IChatMangerDelegate

-(void)didUnreadMessagesCountChanged
{
    [self refreshDataSource];
}

- (void)didUpdateGroupList:(NSArray *)allGroups error:(EMError *)error
{
    NSArray *groupArray = [[EaseMob sharedInstance].chatManager groupList];
    NSLog(@"%@",groupArray);
    
    NSMutableArray *dataSource = [self loadConversations];

    for (EMConversation *conversation in dataSource) {
        if (conversation.isGroup) {
            BOOL find = NO;
            for (EMGroup *group in groupArray) {
                if ([group.groupId isEqualToString:conversation.chatter]) {
                    find = YES;
                    break;
                }
            }
            if (!find) {
                [[EaseMob sharedInstance].chatManager removeConversationByChatter:conversation.chatter deleteMessages:YES
                                                                      append2Chat:YES];
            }
        }
    }
        
    NSLog(@"allgroups:%@", allGroups);
    [self refreshDataSource];
}

- (void)didSendMessage:(EMMessage *)message error:(EMError *)error;
{
    for (int i = 0; i < self.chattingPeople.count; i++) {
        TZConversation *tzConversation = [self.chattingPeople objectAtIndex:i];
        if ([tzConversation.conversation.latestMessage.messageId isEqualToString:message.messageId]) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:i inSection:0];
            [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
        }
    }
}


#pragma mark - registerNotifications
-(void)registerNotifications{
    [self unregisterNotifications];
    [[EaseMob sharedInstance].chatManager addDelegate:self delegateQueue:nil];
}

-(void)unregisterNotifications{
    [[EaseMob sharedInstance].chatManager removeDelegate:self];
}

#pragma mark - public

-(void)refreshDataSource
{
    NSLog(@"%@",[NSThread currentThread]);
    NSLog(@"开始刷新聊天DataSource");
    [self loadChattingPeople];
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"结束刷新聊天DataSource");
        [self.tableView reloadData];
    });
}

- (void)networkChanged:(EMConnectionState)connectionState
{
    if (connectionState == eEMConnectionDisconnected) {
    }
    else{
    }
}

- (void)willReceiveOfflineMessages{
    NSLog(@"开始接收离线消息");
}

- (void)didFinishedReceiveOfflineMessages:(NSArray *)offlineMessages{
    NSLog(@"离线消息接收成功");
    [self refreshDataSource];
}

#pragma mark - CreateConversationDelegate

- (void)createConversationSuccessWithChatter:(NSString *)chatter isGroup:(BOOL)isGroup chatTitle:(NSString *)chatTitle
{
    [_createConversationCtl dismissViewControllerAnimated:YES completion:^{
        [self pushChatViewControllerWithChatter:chatter isGroup:isGroup chatTitle:chatTitle];
    }];
}

@end



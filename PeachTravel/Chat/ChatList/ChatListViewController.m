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
#import "SRRefreshView.h"
#import "ChatListCell.h"
#import "NSDate+Category.h"
#import "RealtimeSearchUtil.h"
#import "ChatViewController.h"
#import "EMSearchDisplayController.h"
#import "ConvertToCommonEmoticonsHelper.h"
#import "AccountManager.h"
#import "CreateConversationViewController.h"

@interface ChatListViewController ()<UITableViewDelegate,UITableViewDataSource, SRRefreshDelegate, IChatManagerDelegate>

@property (strong, nonatomic) NSMutableArray        *dataSource;
@property (strong, nonatomic) NSMutableArray        *chattingPeople;       //保存正在聊天的联系人的桃子信息，显示界面的时候需要用到
@property (strong, nonatomic) UITableView           *tableView;
@property (nonatomic, strong) SRRefreshView         *slimeView;
@property (nonatomic, strong) UIView                *networkStateView;
@property (nonatomic, strong) AccountManager *accountManager;

@property (strong, nonatomic) EMSearchDisplayController *searchController;

@end

@implementation ChatListViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _dataSource = [NSMutableArray array];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)]) {
        [self setEdgesForExtendedLayout:UIRectEdgeNone];
    }
    
    self.view.backgroundColor = APP_PAGE_COLOR;
    _dataSource = [self loadDataSource];
    [self loadChattingPeople];
//    [self.view addSubview:self.tableView];
//    [self.tableView addSubview:self.slimeView];
    [self networkStateView];
    [self searchController];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self refreshDataSource];
    [self registerNotifications];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self unregisterNotifications];
}

#pragma mark - getter

- (AccountManager *)accountManager
{
    if (!_accountManager) {
        _accountManager = [AccountManager shareAccountManager];
    }
    return _accountManager;
}

- (SRRefreshView *)slimeView
{
    if (!_slimeView) {
        _slimeView = [[SRRefreshView alloc] init];
        _slimeView.delegate = self;
        _slimeView.upInset = 0;
        _slimeView.slimeMissWhenGoingBack = YES;
        _slimeView.slime.bodyColor = [UIColor grayColor];
        _slimeView.slime.skinColor = [UIColor grayColor];
        _slimeView.slime.lineWith = 1;
        _slimeView.slime.shadowBlur = 4;
        _slimeView.slime.shadowColor = [UIColor grayColor];
        _slimeView.backgroundColor = [UIColor whiteColor];
    }
    
    return _slimeView;
}

- (UITableView *)tableView
{
    if (_tableView == nil) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kWindowWidth, self.view.frame.size.height - 64) style:UITableViewStylePlain];
        _tableView.backgroundColor = APP_PAGE_COLOR;
        _tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.tableFooterView = [[UIView alloc] init];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [_tableView registerClass:[ChatListCell class] forCellReuseIdentifier:@"chatListCell"];
    }
    
    return _tableView;
}

- (UIView *)networkStateView
{
    if (_networkStateView == nil) {
        _networkStateView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 44)];
        _networkStateView.backgroundColor = [UIColor colorWithRed:255 / 255.0 green:199 / 255.0 blue:199 / 255.0 alpha:0.5];
        
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, (_networkStateView.frame.size.height - 20) / 2, 20, 20)];
        imageView.image = [UIImage imageNamed:@"messageSendFail"];
        [_networkStateView addSubview:imageView];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(imageView.frame) + 5, 0, _networkStateView.frame.size.width - (CGRectGetMaxX(imageView.frame) + 15), _networkStateView.frame.size.height)];
        label.font = [UIFont systemFontOfSize:15.0];
        label.textColor = [UIColor grayColor];
        label.backgroundColor = [UIColor clearColor];
        label.text = @"当前网络连接失败";
        [_networkStateView addSubview:label];
    }
    
    return _networkStateView;
}

#pragma mark - private

- (void)loadChattingPeople
{
    if (!_chattingPeople) {
        _chattingPeople = [[NSMutableArray alloc] init];
    } else {
        [_chattingPeople removeAllObjects];
    }
    for (EMConversation *conversation in self.dataSource) {
        if (!conversation.isGroup) {
            if ([self.accountManager TZContactByEasemobUser:conversation.chatter]) {
                [_chattingPeople addObject:[self.accountManager TZContactByEasemobUser:conversation.chatter]];
            } else {
                [[EaseMob sharedInstance].chatManager removeConversationByChatter:conversation.chatter deleteMessages:NO];
            }
        } else {
            [_chattingPeople addObject:conversation.chatter];
        }
    }
    //重新加载 datasource
    if (_chattingPeople.count <= 0) {
        [self setupEmptyView];
    } else {
//        self.dataSource = [self loadDataSource];
        [self setupListView];
    }
}

- (void) setupEmptyView {
    CGFloat width = self.view.frame.size.width;
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ic_notify_flag.png"]];
    imageView.contentMode = UIViewContentModeScaleToFill;
    imageView.center = CGPointMake(width/2.0, 100.0);
    [self.view addSubview:imageView];
    
    UILabel *desc = [[UILabel alloc] initWithFrame:CGRectMake(0, 100.0+imageView.frame.size.height/2.0, width, 64.0)];
    desc.textColor = UIColorFromRGB(0x666666);
    desc.font = [UIFont systemFontOfSize:15.0];
    desc.numberOfLines = 2;
    desc.textAlignment = NSTextAlignmentCenter;
    desc.text = @"想去哪儿旅行\n约蜜蜜们来八一八吧";
    [self.view addSubview:desc];
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(0.0, 0.0, 108.0, 34.0);
    btn.backgroundColor = [UIColor redColor];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btn setTitle:@"去聊聊" forState:UIControlStateNormal];
    btn.titleLabel.font = [UIFont systemFontOfSize:14.0];
    btn.center = CGPointMake(width/2.0, desc.frame.origin.y + 64.0 + 40.0);
    [btn addTarget:self action:@selector(addConversation:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
}

- (IBAction)addConversation:(id)sender
{
    CreateConversationViewController *createCoversationCtl = [[CreateConversationViewController alloc] init];
    [self.navigationController pushViewController:createCoversationCtl animated:YES];
}

- (void) setupListView {
    [self.view addSubview:self.tableView];
    [self.tableView addSubview:self.slimeView];
}

- (NSMutableArray *)loadDataSource
{
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
    return ret;
}

// 得到最后消息时间
-(NSString *)lastMessageTimeByConversation:(EMConversation *)conversation
{
    NSString *ret = @"";
    EMMessage *lastMessage = [conversation latestMessage];;
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

// 得到最后消息文字或者类型
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
                            
                        case TZChatTypeStrategy: {
                            
                        }
                            break;
                            
                        case TZChatTypeTravelNote: {
                            
                        }
                            break;
                            
                        case TZChatTypeSpot: {
                            
                        }
                            break;
                            
                        case TZChatTypeCity: {
                            
                        }
                            break;
                            
                        case TZChatTypeFood: TZChatTypeHotel: TZChatTypeShopping: {
                            
                        }
                            break;
                            
                        case TZTipsMsg: {
                            ret = [lastMessage.ext objectForKey:@"content"];
                        }
                            
                        default:
                            break;
                    }

                }
                    break;
                    
                case eMessageBodyType_Voice:{
                    ret = [NSString stringWithFormat:@"%@:[声音]", nickName];

                }
                    break;
                    
                case eMessageBodyType_Location: {
                    ret = [NSString stringWithFormat:@"%@:[位置]", nickName];

                }
                    break;
                    
                case eMessageBodyType_Video: {
                    ret = [NSString stringWithFormat:@"%@:[视频]", nickName];

                }
                    break;
                    
                default: {
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
                            
                        case TZChatTypeStrategy: {
                            
                        }
                            break;
                            
                        case TZChatTypeTravelNote: {
                            
                        }
                            break;
                            
                        case TZChatTypeSpot: {
                            
                        }
                            break;
                            
                        case TZChatTypeCity: {
                            
                        }
                            break;
                            
                        case TZChatTypeFood: {
                            
                        }
                            break;
                            
                        case TZTipsMsg: {
                            ret = [lastMessage.ext objectForKey:@"content"];
                        }
                            
                        default:
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

#pragma mark - TableViewDelegate & TableViewDatasource

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *identify = @"chatListCell";
    ChatListCell *cell = [tableView dequeueReusableCellWithIdentifier:identify];
    
    if (!cell) {
        cell = [[ChatListCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identify];
    }
    EMConversation *conversation = [self.dataSource objectAtIndex:indexPath.row];
    id chatPeople = [self.chattingPeople objectAtIndex:indexPath.row];
    if (!conversation.isGroup) {
        cell.name = ((Contact *)chatPeople).nickName;
        [cell.imageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@", ((Contact *)chatPeople).avatar]] placeholderImage:[UIImage imageNamed:@"chatListCellHead.png"]];
    } else{
        NSArray *groupArray = [[EaseMob sharedInstance].chatManager groupList];
        for (EMGroup *group in groupArray) {
            if ([group.groupId isEqualToString:conversation.chatter]) {
                cell.name = group.groupSubject;
                break;
            }
        }
        [cell.imageView setImage:[UIImage imageNamed:@"groupPrivateHeader"]];
    }
    cell.detailMsg = [self subTitleMessageByConversation:conversation];
    cell.time = [self lastMessageTimeByConversation:conversation];
    cell.unreadCount = [self unreadMessageCountByConversation:conversation];
    return cell;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return  self.dataSource.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return [ChatListCell tableView:tableView heightForRowAtIndexPath:indexPath];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    EMConversation *conversation = [self.dataSource objectAtIndex:indexPath.row];
    ChatViewController *chatController;
    NSString *title;
    if (conversation.isGroup) {
        NSArray *groupArray = [[EaseMob sharedInstance].chatManager groupList];
        for (EMGroup *group in groupArray) {
            if ([group.groupId isEqualToString:conversation.chatter]) {
                title = group.groupSubject;
                break;
            }
        }
    } else {
        title = ((Contact*)[self.chattingPeople objectAtIndex:indexPath.row]).nickName;
    }
    
    NSString *chatter = conversation.chatter;
    chatController = [[ChatViewController alloc] initWithChatter:chatter isGroup:conversation.isGroup];
    chatController.title = title;
    [conversation markMessagesAsRead:YES];
    [self.navigationController pushViewController:chatController animated:YES];
}

-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        EMConversation *converation = [self.dataSource objectAtIndex:indexPath.row];
        [[EaseMob sharedInstance].chatManager removeConversationByChatter:converation.chatter deleteMessages:YES];
        [self.dataSource removeObjectAtIndex:indexPath.row];
        [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}

#pragma mark - scrollView delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [_slimeView scrollViewDidScroll];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [_slimeView scrollViewDidEndDraging];
}

#pragma mark - slimeRefresh delegate
//刷新消息列表
- (void)slimeRefreshStartRefresh:(SRRefreshView *)refreshView
{
    [self refreshDataSource];
    [_slimeView endRefresh];
}

#pragma mark - IChatMangerDelegate

-(void)didUnreadMessagesCountChanged
{
    [self refreshDataSource];
}

- (void)didUpdateGroupList:(NSArray *)allGroups error:(EMError *)error
{
    [self refreshDataSource];
}

#pragma mark - registerNotifications
-(void)registerNotifications{
    [self unregisterNotifications];
    [[EaseMob sharedInstance].chatManager addDelegate:self delegateQueue:nil];
}

-(void)unregisterNotifications{
    [[EaseMob sharedInstance].chatManager removeDelegate:self];
}

- (void)dealloc{
    [self unregisterNotifications];
}

#pragma mark - public

-(void)refreshDataSource
{
    self.dataSource = [self loadDataSource];
    [self loadChattingPeople];
    [_tableView reloadData];
    [self hideHud];
}

- (void)networkChanged:(EMConnectionState)connectionState
{
    if (connectionState == eEMConnectionDisconnected) {
        _tableView.tableHeaderView = _networkStateView;
    }
    else{
        _tableView.tableHeaderView = nil;
    }
}

- (void)willReceiveOfflineMessages{
    NSLog(@"开始接收离线消息");
}

- (void)didFinishedReceiveOfflineMessages:(NSArray *)offlineMessages{
    NSLog(@"离线消息接收成功");
    [self refreshDataSource];
}

@end



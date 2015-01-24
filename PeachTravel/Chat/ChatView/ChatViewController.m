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

#import "SRRefreshView.h"
#import "DXChatBarMoreView.h"
#import "DXRecordView.h"
#import "DXFaceView.h"
#import "HPGrowingTextView.h"
#import "EMChatViewCell.h"
#import "TipsChatTableViewCell.h"
#import "EMChatTimeCell.h"
#import "ChatSendHelper.h"
#import "MessageReadManager.h"
#import "MessageModelManager.h"
#import "LocationViewController.h"
#import "UIViewController+HUD.h"
#import "NSDate+Category.h"
#import "DXMessageToolBar.h"
#import "DXChatBarMoreView.h"
#import "CallViewController.h"
#import "ZYQAssetPickerController.h"
#import "ChatGroupSettingViewController.h"
#import "ChatSettingViewController.h"
#import "ChatScrollView.h"
#import "AccountManager.h"
#import "Group.h"
#import "ContactDetailViewController.h"
#import "SearchUserInfoViewController.h"
#import "CreateConversationViewController.h"
#import "SpotDetailViewController.h"
#import "CommonPoiDetailViewController.h"
#import "MyGuideListTableViewController.h"
#import "FavoriteViewController.h"
#import "CityDetailTableViewController.h"
#import "SearchDestinationViewController.h"
#import "TravelNoteListViewController.h"
#import "TravelNoteDetailViewController.h"
#import "CommonPoiDetailViewController.h"
#import "CommonPoiDetailViewController.h"
#import "IMRootViewController.h"
#import "TripDetailRootViewController.h"

#define KPageCount 20

@interface ChatViewController ()<UITableViewDataSource, UITableViewDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, SRRefreshDelegate, IChatManagerDelegate, DXChatBarMoreViewDelegate, DXMessageToolBarDelegate, LocationViewDelegate, IDeviceManagerDelegate, ZYQAssetPickerControllerDelegate>
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

@property (nonatomic) BOOL isChatGroup;
@property (strong, nonatomic) NSString *chatter;
@property (strong, nonatomic) ChatScrollView *chatScrollView;

@property (strong, nonatomic) NSMutableArray *dataSource;//tableView数据源
@property (strong, nonatomic) NSArray *peopleInGroup;   //保存群组的人员信息
@property (strong, nonatomic) NSMutableArray *chattingPeople;

@property (strong, nonatomic) NSMutableArray *numberBtns;   //群组的时候存放群组头像的 btn
@property (strong, nonatomic) NSMutableArray *numberDeleteBtns; //群组的时候存放群组头像上的删除按钮的 btn

@property (strong, nonatomic) Group *group;     //当前聊天的群组信息，是自己维护的群组，存到是桃子用户的信息。
@property (strong, nonatomic) SRRefreshView *slimeView;
@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) DXMessageToolBar *chatToolBar;

@property (strong, nonatomic) UIImagePickerController *imagePicker;

@property (strong, nonatomic) MessageReadManager *messageReadManager;//message阅读的管理者
@property (strong, nonatomic) EMConversation *conversation;//会话管理者
@property (strong, nonatomic) NSDate *chatTagDate;

@property (nonatomic) BOOL isScrollToBottom;
@property (nonatomic) BOOL isPlayingAudio;
@property (nonatomic, strong) AccountManager *accountManager;

/**
 *  如果是群组的话标题用的三个 view，因为要相应点击点击查看群成员事件
 */
@property (nonatomic, strong) UIButton *titleBtn;
@property (nonatomic, strong) UIView *titleView;
@property (nonatomic, strong) UIImageView *titleIndicator;


@end

@implementation ChatViewController

- (instancetype)initWithChatter:(NSString *)chatter isGroup:(BOOL)isGroup
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        _isPlayingAudio = NO;
        _chatter = chatter;
        _isChatGroup = isGroup;
        
        //根据接收者的username获取当前会话的管理者
        _conversation = [[EaseMob sharedInstance].chatManager conversationForChatter:chatter isGroup:_isChatGroup];
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = APP_PAGE_COLOR;
    
    [[[EaseMob sharedInstance] deviceManager] addDelegate:self onQueue:nil];
    [[EaseMob sharedInstance].chatManager removeDelegate:self];
    //注册为SDK的ChatManager的delegate
    [[EaseMob sharedInstance].chatManager addDelegate:self delegateQueue:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removeAllMessages:) name:@"RemoveAllMessages" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(exitGroup) name:@"ExitGroup" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackground) name:@"applicationDidEnterBackground" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateChatView:) name:updateChateViewNoti object:nil];

    _messageQueue = dispatch_queue_create("easemob.com", NULL);
    loadChatPeopleQueue = dispatch_queue_create("loadChattingPeople", NULL);
    self.automaticallyAdjustsScrollViewInsets = NO;

    if (_isChatGroup) {
        self.peopleInGroup = [self loadContactsFromDB];
    }

    [self setupBarButtonItem];
    [self.view addSubview:self.tableView];
    [self.tableView addSubview:self.slimeView];
    [self.view addSubview:self.chatToolBar];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(keyBoardHidden)];
    [self.view addGestureRecognizer:tap];
    //通过会话管理者获取已收发消息
    [self loadMoreMessages];
    _isScrollToBottom = YES;

}

- (void)setupBarButtonItem
{
    UIBarButtonItem *registerBtn = [[UIBarButtonItem alloc]initWithTitle:nil style:UIBarButtonItemStyleBordered target:self action:@selector(showRoomContact:)];
    [registerBtn setImage:[UIImage imageNamed:@"ic_more.png"]];
    self.navigationItem.rightBarButtonItem = registerBtn;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    NSLog(@"viewWillAppear");
    [_chatToolBar registerNoti];
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
            chatGroup = [[EMGroup alloc] initWithGroupId:_chatter];
        }
        
        self.navigationItem.titleView = self.titleView;
        [_titleBtn setTitle:chatGroup.groupSubject forState:UIControlStateNormal];
    }
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
    [_chatToolBar unRegisterNoti];
    // 设置当前conversation的所有message为已读
    [_conversation markAllMessagesAsRead:YES];
    
}

- (void)dealloc
{
    _tableView.delegate = nil;
    _tableView.dataSource = nil;
    _tableView = nil;
    
    _slimeView.delegate = nil;
    _slimeView = nil;
    
    _chatToolBar.delegate = nil;
    _chatToolBar = nil;
    
    [[EaseMob sharedInstance].chatManager stopPlayingAudio];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[EaseMob sharedInstance].chatManager removeDelegate:self];
    [[[EaseMob sharedInstance] deviceManager] removeDelegate:self];
    
    EMMessage *message = [_conversation latestMessage];
    if (message == nil) {
        [[EaseMob sharedInstance].chatManager removeConversationByChatter:_conversation.chatter deleteMessages:YES];
    }
}

#pragma mark - IBAction Methods

/**
 * 实现父类的后退按钮
 */
- (void)goBack
{
//    [self.navigationController popToRootViewControllerAnimated:YES];
    NSArray *ctls = self.navigationController.viewControllers;
    UIViewController *ctl = [ctls objectAtIndex:1];
    if ([ctl isKindOfClass:[IMRootViewController class]]) {
        [((IMRootViewController *)ctl) setSelectedIndex:0 animated:YES];
        [self.navigationController popToViewController:ctl animated:YES];
        return;
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

/**
 *  显示群组联系人列表
 *
 *  @param sender
 */
- (IBAction)showGroupList:(id)sender
{
    [self keyBoardHidden];
    [_titleBtn removeTarget:self action:@selector(showGroupList:) forControlEvents:UIControlEventTouchUpInside];
    [_titleBtn addTarget:self action:@selector(hideGroupList) forControlEvents:UIControlEventTouchUpInside];
    if (self.peopleInGroup.count > 0) {
        self.chatScrollView.dataSource = [self createChatScrollViewDataSource];
        if ([self.accountManager.account.easemobUser isEqualToString:self.group.owner]) {
            self.chatScrollView.shouldshowDeleteBtn = YES;
            
        } else {
            self.chatScrollView.shouldshowDeleteBtn = NO;
        }
    }
    [self asyncLoadGroupFromEasemobServerWithCompletion:^(BOOL isSuccess) {
        if (isSuccess) {
            self.chatScrollView.dataSource = [self createChatScrollViewDataSource];
            if ([self.accountManager.account.easemobUser isEqualToString:self.group.owner]) {
                self.chatScrollView.shouldshowDeleteBtn = YES;
            } else {
                self.chatScrollView.shouldshowDeleteBtn = NO;
            }
        }
    }];
    self.chatScrollView.addBtn.hidden = NO;
    [UIView animateWithDuration:0.4 animations:^{
        CGRect rect = CGRectMake(0, 64, self.view.frame.size.width, 150);
        self.chatScrollView.frame = rect;
        _titleIndicator.transform = CGAffineTransformMakeRotation(180 *M_PI / 180.0);
    } completion:^(BOOL finished) {
    }];

}

/**
 *  隐藏群组的联系人列表
 */
- (void)hideGroupList
{
    [_titleBtn removeTarget:self action:@selector(hideGroupList) forControlEvents:UIControlEventTouchUpInside];
    [_titleBtn addTarget:self action:@selector(showGroupList:) forControlEvents:UIControlEventTouchUpInside];
    [UIView animateWithDuration:0.4 animations:^{
        CGRect rect = CGRectMake(0, -150, self.view.frame.size.width, 150);
        self.chatScrollView.frame = rect;
        _titleIndicator.transform = CGAffineTransformMakeRotation(360 *M_PI / 180.0);
    } completion:^(BOOL finished) {
    }];
}

//增加群组成员
- (IBAction)addGroupNumber:(id)sender
{
    CreateConversationViewController *createConversationCtl = [[CreateConversationViewController alloc] init];
    createConversationCtl.group = self.group;
    [self hideGroupList];
    UINavigationController *nCtl = [[UINavigationController alloc] initWithRootViewController:createConversationCtl];
    [self presentViewController:nCtl animated:YES completion:nil];
}

- (IBAction)beginDelete:(id)sender
{
    for (UIButton *btn in self.numberDeleteBtns) {
        btn.hidden = NO;
    }
    self.chatScrollView.addBtn.hidden = YES;
    self.chatScrollView.deleteBtn.hidden = YES;
}

/**
 *  点击群组联系人列表的头像进入联系人信息
 *
 *  @param sender 
 */
- (IBAction)showUserInfo:(UIButton *)sender
{
    Contact *selectPerson = self.peopleInGroup[sender.tag];
    [self  showUserInfoWithContactInfo:selectPerson];

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
    
    Contact *contact = [self.accountManager TZContactByEasemobUser:model.username];
    
    if (!model.isChatGroup) {
        return;
    }
    
    if (!contact) {
        for (Contact *tempContact in self.peopleInGroup) {
            if ([tempContact.easemobUser isEqualToString:model.username]) {
                [self  showUserInfoWithContactInfo:tempContact];
                return;
            }
        }
        if (!contact) {
             __weak typeof(ChatViewController *)weakSelf = self;
            TZProgressHUD *hud = [[TZProgressHUD alloc] init];
            [hud showHUDInViewController:weakSelf];
            [self asyncLoadGroupFromEasemobServerWithCompletion:^(BOOL isSuccess) {
                [hud hideTZHUD];
                if (isSuccess) {
                    for (Contact *tempContact in self.peopleInGroup) {
                        if ([tempContact.easemobUser isEqualToString:model.username]) {
                            [self  showUserInfoWithContactInfo:tempContact];
                            break;
                        }
                    }
                }
            }];
        }
    } else {
        [self  showUserInfoWithContactInfo:contact];
    }
}

- (void)showUserInfoWithContactInfo:(Contact *)contact
{
    if ([self.accountManager isMyFrend:contact.userId]) {
        ContactDetailViewController *contactDetailCtl = [[ContactDetailViewController alloc] init];
        contactDetailCtl.contact = contact;
        if (_isChatGroup) {
            contactDetailCtl.goBackToChatViewWhenClickTalk = NO;
        } else {
            contactDetailCtl.goBackToChatViewWhenClickTalk = YES;
        }
        [self.navigationController pushViewController:contactDetailCtl animated:YES];
        
    } else {
        SearchUserInfoViewController *searchUserInfoCtl = [[SearchUserInfoViewController alloc] init];
        searchUserInfoCtl.userInfo = @{@"userId":contact.userId,
                                       @"avatar":contact.avatar,
                                       @"nickName":contact.nickName,
                                       @"signature":contact.signature,
                                       @"easemobUser":contact.easemobUser
                                       };
        [self.navigationController pushViewController:searchUserInfoCtl animated:YES];
    }
}

/**
 *  删除群组里的用户
 *
 *  @param sender
 */
- (IBAction)deleteNumber:(UIButton *)sender
{
    Contact *selectPerson = self.peopleInGroup[sender.tag];

    NSArray *occupants = @[selectPerson.easemobUser];
     __weak typeof(ChatViewController *)weakSelf = self;
    TZProgressHUD *hud = [[TZProgressHUD alloc] init];
    [hud showHUDInViewController:weakSelf];

    [[EaseMob sharedInstance].chatManager asyncRemoveOccupants:occupants fromGroup:self.group.groupId completion:^(EMGroup *group, EMError *error) {
        [hud hideTZHUD];
        if (!error) {
            [self.accountManager removeNumberToGroup:self.group.groupId numbers:[NSSet setWithObject:selectPerson]];
            self.peopleInGroup = [self loadContactsFromDB];
            self.chatScrollView.dataSource = [self createChatScrollViewDataSource];
            for (UIButton *btn in self.numberDeleteBtns) {
                btn.hidden = NO;
            }
            AccountManager *accountManager = [AccountManager shareAccountManager];
            NSString *messageStr = [NSString stringWithFormat:@"%@把%@移除了群组",accountManager.account.nickName, selectPerson.nickName];
            
            NSDictionary *messageDic = @{@"tzType":[NSNumber numberWithInt:TZTipsMsg], @"content":messageStr};
            
            EMMessage *message = [ChatSendHelper sendTaoziMessageWithString:messageStr andExtMessage:messageDic toUsername:self.group.groupId isChatGroup:YES requireEncryption:NO];
            [self addChatDataToMessage:message];
        }
        else{
        }
    } onQueue:nil];
}

#pragma mark - private Methods

- (NSArray *)loadContactsFromDB
{
    NSMutableArray *contacts = [[NSMutableArray alloc] init];
    _group = [self.accountManager groupWithGroupId:_chatter];
    if (_group) {
        for (id item in _group.numbers) {
            [contacts addObject:item];
        }
    }
    return contacts;
}

/**
 *  在别的页面发送消息，本页面需要将发送的消息插入到 datasource 里
 *
 *  @param noti 包含新消息内容的 noti
 */
- (void)updateChatView:(NSNotification *)noti
{
    EMMessage *message = [noti.userInfo objectForKey:@"message"];
    //如果是发送的消息是属于当前页面的
    if ([message.conversationChatter isEqualToString:_chatter]) {
        [self addChatDataToMessage:[noti.userInfo objectForKey:@"message"]];
    }
}

/**
 *  异步从环信服务器上取群组的信息
 */
- (void)asyncLoadGroupFromEasemobServerWithCompletion:(void(^)(BOOL isSuccess))completion
{
    [[EaseMob sharedInstance].chatManager asyncFetchGroupInfo:_chatter completion:^(EMGroup *group, EMError *error){
        if (!error) {
            [self loadContactsFromTZServerWithGroup:group withCompletion:completion];
        }
    } onQueue:nil];
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
            [self updateGroupInDB:[responseObject objectForKey:@"result"] andEMGroup:emgroup];
            completion(YES);
        } else {
            completion(NO);
//            [SVProgressHUD showErrorWithStatus:@"网络加载失败"];
            [self showHint:@"请求也是失败了"];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        completion(NO);
        [self showHint:@"呃～好像没找到网络"];
    }];

}

- (void)updateGroupInDB:(id)numbersDic andEMGroup:(EMGroup *)emGroup
{
    AccountManager *accountManager = [AccountManager shareAccountManager];
    self.group = [accountManager updateGroup:emGroup.groupId withGroupOwner:emGroup.owner groupSubject:emGroup.groupSubject groupInfo:emGroup.groupDescription numbers:numbersDic];
    
    self.peopleInGroup = [self loadContactsFromDB];
    
    NSMutableArray *datas = [[NSMutableArray alloc] init];
    for (Contact *contact in self.peopleInGroup) {
        [datas addObject:contact.avatar];
    }
}

/**
 *  如果是群组的话，点击展开按钮，返回所有的联系人信息
 *
 *  @return 所有的聊天人的信息
 */
- (NSArray *)createChatScrollViewDataSource
{
    [self.numberBtns removeAllObjects];
    [self.numberDeleteBtns removeAllObjects];
    NSMutableArray *titles = [[NSMutableArray alloc] init];
    NSMutableArray *retArray = [[NSMutableArray alloc] init];
    for (int i = 0; i < self.peopleInGroup.count; i++) {
        if (self.accountManager.account.userId.integerValue != ((Contact *)self.peopleInGroup[i]).userId.integerValue) {
            UIButton *item = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
            item.layer.cornerRadius = 20;
            item.tag = i;
            [item sd_setBackgroundImageWithURL:[NSURL URLWithString:((Contact *)self.peopleInGroup[i]).avatar] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"chatListCellHead"]];
            item.clipsToBounds = YES;
            [item addTarget:self action:@selector(showUserInfo:) forControlEvents:UIControlEventTouchUpInside];
            
            UIButton *deleteBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
            [deleteBtn setImage:[UIImage imageNamed:@"ic_remove_select_one.png"] forState:UIControlStateNormal];
            [deleteBtn setImageEdgeInsets:UIEdgeInsetsMake(28, 28, 0, 0)];
            deleteBtn.tag = i;
            [deleteBtn addTarget:self action:@selector(deleteNumber:) forControlEvents:UIControlEventTouchUpInside];
            deleteBtn.hidden = YES;
            [retArray addObject:item];
            [self.numberBtns addObject:item];
            [self.numberDeleteBtns addObject:deleteBtn];
            [titles addObject:((Contact *)self.peopleInGroup[i]).nickName];
        }
    }
    self.chatScrollView.titles = titles;
    self.chatScrollView.deleteBtns = self.numberDeleteBtns;
    return retArray;
}

- (NSURL *)convert2Mp4:(NSURL *)movUrl {
    NSURL *mp4Url = nil;
    AVURLAsset *avAsset = [AVURLAsset URLAssetWithURL:movUrl options:nil];
    NSArray *compatiblePresets = [AVAssetExportSession exportPresetsCompatibleWithAsset:avAsset];
    
    if ([compatiblePresets containsObject:AVAssetExportPresetHighestQuality]) {
        AVAssetExportSession *exportSession = [[AVAssetExportSession alloc]initWithAsset:avAsset
                                                                              presetName:AVAssetExportPresetHighestQuality];
        mp4Url = [movUrl copy];
        mp4Url = [mp4Url URLByDeletingPathExtension];
        mp4Url = [mp4Url URLByAppendingPathExtension:@"mp4"];
        exportSession.outputURL = mp4Url;
        exportSession.shouldOptimizeForNetworkUse = YES;
        exportSession.outputFileType = AVFileTypeMPEG4;
        dispatch_semaphore_t wait = dispatch_semaphore_create(0l);
        [exportSession exportAsynchronouslyWithCompletionHandler:^{
            switch ([exportSession status]) {
                case AVAssetExportSessionStatusFailed: {
                    NSLog(@"failed, error:%@.", exportSession.error);
                } break;
                case AVAssetExportSessionStatusCancelled: {
                    NSLog(@"cancelled.");
                } break;
                case AVAssetExportSessionStatusCompleted: {
                    NSLog(@"completed.");
                } break;
                default: {
                    NSLog(@"others.");
                } break;
            }
            dispatch_semaphore_signal(wait);
        }];
        long timeout = dispatch_semaphore_wait(wait, DISPATCH_TIME_FOREVER);
        if (timeout) {
            NSLog(@"timeout.");
        }
        if (wait) {
            //dispatch_release(wait);
            wait = nil;
        }
    }
    
    return mp4Url;
}

#pragma mark - getter

- (AccountManager *)accountManager
{
    if (!_accountManager) {
        _accountManager = [AccountManager shareAccountManager];
        
    }
    return _accountManager;
}

- (NSMutableArray *)numberDeleteBtns
{
    if(!_numberDeleteBtns) {
        _numberDeleteBtns = [[NSMutableArray alloc] init];
    }
    return _numberDeleteBtns;
}

- (NSMutableArray *)numberBtns
{
    if (!_numberBtns) {
        _numberBtns = [[NSMutableArray alloc] init];
    }
    return _numberBtns;
}

- (UIView *)titleView
{
    if (!_titleView) {
        _titleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kWindowWidth - 120, 44)];
        _titleBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, _titleView.frame.size.width, 30)];
        _titleBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
        _titleBtn.contentVerticalAlignment = UIControlContentVerticalAlignmentBottom;
        [_titleBtn addTarget:self action:@selector(showGroupList:) forControlEvents:UIControlEventTouchUpInside];
        _titleIndicator = [[UIImageView alloc] initWithFrame:CGRectMake( _titleView.frame.size.width/2-5, 35, 10, 6)];
        [_titleIndicator setImage:[UIImage imageNamed:@"ic_group_expand.png"]];
        [_titleBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        _titleBtn.titleLabel.font = [UIFont boldSystemFontOfSize:16.0];
        [_titleView addSubview:_titleBtn];
        [_titleView addSubview:_titleIndicator];
    }
    return _titleView;
}

- (ChatScrollView *)chatScrollView
{
    if (!_chatScrollView) {
        _chatScrollView = [[ChatScrollView alloc] initWithFrame:CGRectMake(0, 64-150, self.view.frame.size.width, 150)];
        [self.view addSubview:_chatScrollView];
        [_chatScrollView.dismissBtn addTarget:self action:@selector(hideGroupList) forControlEvents:UIControlEventTouchUpInside];
        [_chatScrollView.addBtn addTarget:self action:@selector(addGroupNumber:) forControlEvents:UIControlEventTouchUpInside];
        [_chatScrollView.deleteBtn addTarget:self action:@selector(beginDelete:) forControlEvents:UIControlEventTouchUpInside];

    }
    return _chatScrollView;
}

- (NSMutableArray *)dataSource
{
    if (_dataSource == nil) {
        _dataSource = [NSMutableArray array];
    }
    
    return _dataSource;
}

- (NSMutableArray *)chattingPeople
{
    if (!_chattingPeople) {
        _chattingPeople = [[NSMutableArray alloc] init];
    }
    return _chattingPeople;
}

- (SRRefreshView *)slimeView
{
    if (_slimeView == nil) {
        _slimeView = [[SRRefreshView alloc] init];
        _slimeView.delegate = self;
        _slimeView.upInset = 0;
        _slimeView.slimeMissWhenGoingBack = YES;
        _slimeView.slime.bodyColor = APP_THEME_COLOR;
        _slimeView.slime.skinColor = [UIColor clearColor];
        _slimeView.slime.lineWith = 0.7;
        _slimeView.slime.shadowBlur = 0;
        _slimeView.slime.shadowColor = [UIColor clearColor];
    }
    
    return _slimeView;
}

- (UITableView *)tableView
{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 64, self.view.frame.size.width, self.view.frame.size.height - self.chatToolBar.frame.size.height - 64) style:UITableViewStylePlain];
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
        _chatToolBar.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin;
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
            if ([[model.taoziMessage objectForKey:@"tzType"] integerValue] == TZTipsMsg) {
                TipsChatTableViewCell *tipsCell = (TipsChatTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"MessageCellTips"];
                if (tipsCell == nil) {
                    tipsCell = [[TipsChatTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"MessageCellTips"];
                    tipsCell.backgroundColor = [UIColor clearColor];
                    tipsCell.selectionStyle = UITableViewCellSelectionStyleNone;
                }
                tipsCell.textLabel.text = [model.taoziMessage objectForKey:@"content"];
                return tipsCell;
                
            }  else{
                if (model.isChatGroup) {
                    [self checkOutModel:model];
                } else {
                    model.nickName = _chatterNickName;
                    if (model.isSender) {
                        model.headImageURL = [NSURL URLWithString:self.accountManager.account.avatar];
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
    }
    else{
        if ([[((MessageModel *)obj).taoziMessage objectForKey:@"tzType"] integerValue] == TZTipsMsg) {
            return 40;
        } else {
            return [EMChatViewCell tableView:tableView heightForRowAtIndexPath:indexPath withObject:(MessageModel *)obj];
        }
    }
}

#pragma mark - scrollView delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (_chatScrollView && !_chatScrollView.hidden) {
        [self hideGroupList];
    }
    if (_slimeView) {
        [_slimeView scrollViewDidScroll];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    
    if (_chatScrollView && !_chatScrollView.hidden) {
        [self hideGroupList];
    }
    if (_slimeView) {
        [_slimeView scrollViewDidEndDraging];
    }
}

#pragma mark - slimeRefresh delegate
//加载更多
- (void)slimeRefreshStartRefresh:(SRRefreshView *)refreshView
{
    [self loadMoreMessages];
    [_slimeView endRefresh];
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
        
    } else if ([eventName isEqualToString:kRouterEventTaoziCityBubbleTapEventName]) {
        [self chatTaoziCityBubblePressed:model];

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
        
    } else if([eventName isEqualToString:kRouterEventChatCellVideoTapEventName]) {
        [self chatVideoCellPressed:model];
    
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

- (void)chatVideoCellPressed:(MessageModel *)model{
    __weak ChatViewController *weakSelf = self;
    id <IChatManager> chatManager = [[EaseMob sharedInstance] chatManager];
    [weakSelf showHudInView:weakSelf.view hint:@"正在获取视频..."];
    [chatManager asyncFetchMessage:model.message progress:nil completion:^(EMMessage *aMessage, EMError *error) {
        [weakSelf hideHud];
        if (!error) {
            NSString *localPath = aMessage == nil ? model.localPath : [[aMessage.messageBodies firstObject] localPath];
            if (localPath && localPath.length > 0) {
                [weakSelf playVideoWithVideoPath:localPath];
            }
        }else{
            [weakSelf showHint:@"视频获取失败!"];
        }
    } onQueue:nil];
}

/**
 *  自定义桃子消息的气泡被点击
 *
 *  @param model 回传的 气泡所属的 model
 */
- (void)chatTaoziBubblePressed:(MessageModel *)model
{
    _isScrollToBottom = NO;
    switch ([[model.taoziMessage objectForKey:@"tzType"] integerValue]) {
        case TZChatTypeSpot: {
            SpotDetailViewController *spotDetailCtl = [[SpotDetailViewController alloc] init];
            spotDetailCtl.title = [[model.taoziMessage objectForKey:@"content"] objectForKey:@"name"];
            spotDetailCtl.spotId = [[model.taoziMessage objectForKey:@"content"] objectForKey:@"id"];
            [self.navigationController pushViewController:spotDetailCtl animated:YES];
        }
            break;
            
        case TZChatTypeFood: {
            CommonPoiDetailViewController *restaurantDetailCtl = [[CommonPoiDetailViewController alloc] init];
            restaurantDetailCtl.poiId = [[model.taoziMessage objectForKey:@"content"] objectForKey:@"id"];
            restaurantDetailCtl.poiType = kRestaurantPoi;
            restaurantDetailCtl.title = [[model.taoziMessage objectForKey:@"content"] objectForKey:@"name"];
            [self addChildViewController:restaurantDetailCtl];
            [self.view addSubview:restaurantDetailCtl.view];
        }
            break;
            
        case TZChatTypeShopping: {
            CommonPoiDetailViewController *shoppingCtl = [[CommonPoiDetailViewController alloc] init];
            shoppingCtl.title = [[model.taoziMessage objectForKey:@"content"] objectForKey:@"name"];
            shoppingCtl.poiId = [[model.taoziMessage objectForKey:@"content"] objectForKey:@"id"];
            shoppingCtl.poiType = kShoppingPoi;
            [self addChildViewController:shoppingCtl];
            [self.view addSubview:shoppingCtl.view];
        }
            break;
            
        case TZChatTypeHotel: {
            CommonPoiDetailViewController *hotelCtl = [[CommonPoiDetailViewController alloc] init];
            hotelCtl.title = [[model.taoziMessage objectForKey:@"content"] objectForKey:@"name"];
            hotelCtl.poiId = [[model.taoziMessage objectForKey:@"content"] objectForKey:@"id"];
            hotelCtl.poiType = kHotelPoi;
            [self addChildViewController:hotelCtl];
            [self.view addSubview:hotelCtl.view];
        }
            break;
            
        case TZChatTypeTravelNote: {
            TravelNoteDetailViewController *travelNoteCtl = [[TravelNoteDetailViewController alloc] init];
            travelNoteCtl.travelNoteTitle = [[model.taoziMessage objectForKey:@"content"] objectForKey:@"name"];
            travelNoteCtl.desc = [[model.taoziMessage objectForKey:@"content"] objectForKey:@"desc"];
            travelNoteCtl.travelNoteCover = [[model.taoziMessage objectForKey:@"content"] objectForKey:@"image"];
            travelNoteCtl.travelNoteId = [[model.taoziMessage objectForKey:@"content"] objectForKey:@"id"];
            travelNoteCtl.titleStr = @"游记详情";
            

            [self.navigationController pushViewController:travelNoteCtl animated:YES];
        }
            break;
            
        case TZChatTypeStrategy: {
            TripDetailRootViewController *tripDetailCtl = [[TripDetailRootViewController alloc] init];
            tripDetailCtl.tripId = [[model.taoziMessage objectForKey:@"content"] objectForKey:@"id"];
            tripDetailCtl.isMakeNewTrip = NO;
            if (model.isSender) {
                tripDetailCtl.canEdit = YES;
            } else {
                tripDetailCtl.canEdit = NO;
            }
            
            [self.navigationController pushViewController:tripDetailCtl animated:YES];
        }
            break;
            
        default:
            break;
    }
}

/**
 *  桃子城市气泡被点击
 *
 *  @param playVideoWithVideoPath
 *  @param videoPath
 */
- (void)chatTaoziCityBubblePressed:(MessageModel *)model
{
    _isScrollToBottom = NO;
    CityDetailTableViewController *cityCtl = [[CityDetailTableViewController alloc] init];
    cityCtl.title = [[model.taoziMessage objectForKey:@"content"] objectForKey:@"name"];
    cityCtl.cityId = [[model.taoziMessage objectForKey:@"content"] objectForKey:@"id"];
    [self.navigationController pushViewController:cityCtl animated:YES];
}

- (void)playVideoWithVideoPath:(NSString *)videoPath
{
    _isScrollToBottom = NO;
    NSURL *videoURL = [NSURL fileURLWithPath:videoPath];
    MPMoviePlayerViewController *moviePlayerController = [[MPMoviePlayerViewController alloc] initWithContentURL:videoURL];
    [moviePlayerController.moviePlayer prepareToPlay];
    moviePlayerController.moviePlayer.movieSourceType = MPMovieSourceTypeFile;
    [self presentMoviePlayerViewControllerAnimated:moviePlayerController];
}

// 图片的bubble被点击
- (void)chatImageCellBubblePressed:(MessageModel *)model andImageView:(UIImageView *)imageView
{
    [self keyBoardHidden];
    __weak ChatViewController *weakSelf = self;
    id <IChatManager> chatManager = [[EaseMob sharedInstance] chatManager];
    if ([model.messageBody messageBodyType] == eMessageBodyType_Image) {
        EMImageMessageBody *imageBody = (EMImageMessageBody *)model.messageBody;
        if (imageBody.thumbnailDownloadStatus == EMAttachmentDownloadSuccessed) {
            [weakSelf showHudInView:weakSelf.view hint:@"正在获取大图..."];
            [chatManager asyncFetchMessage:model.message progress:nil completion:^(EMMessage *aMessage, EMError *error) {
                [weakSelf hideHud];
                if (!error) {
                    NSString *localPath = aMessage == nil ? model.localPath : [[aMessage.messageBodies firstObject] localPath];
                    if (localPath && localPath.length > 0) {
                        NSURL *url = [NSURL fileURLWithPath:localPath];
                        weakSelf.isScrollToBottom = NO;
                        [weakSelf.messageReadManager showBrowserWithImages:@[url] andImageView:imageView];
                        return ;
                    }
                }
                [weakSelf showHint:@"再点一下试试呗~"];
            } onQueue:nil];
        }else{
            //获取缩略图
            [chatManager asyncFetchMessageThumbnail:model.message progress:nil completion:^(EMMessage *aMessage, EMError *error) {
                if (!error) {
                    [weakSelf reloadTableViewDataWithMessage:model.message];
                }else{
                    [weakSelf showHint:@"网络出了点小问题"];
                }
                
            } onQueue:nil];
        }
    }else if ([model.messageBody messageBodyType] == eMessageBodyType_Video) {
        //获取缩略图
        EMVideoMessageBody *videoBody = (EMVideoMessageBody *)model.messageBody;
        if (videoBody.thumbnailDownloadStatus != EMAttachmentDownloadSuccessed) {
            [chatManager asyncFetchMessageThumbnail:model.message progress:nil completion:^(EMMessage *aMessage, EMError *error) {
                if (!error) {
                    [weakSelf reloadTableViewDataWithMessage:model.message];
                }else{
                    [weakSelf showHint:@"缩略图获取失败!"];
                }
            } onQueue:nil];
        }
    }
}

#pragma mark - IChatManagerDelegate

- (void)didSendMessage:(EMMessage *)message error:(EMError *)error;
{
    NSLog(@"发送结果：%@", error);
    [self reloadTableViewDataWithMessage:message];
}

- (void)reloadTableViewDataWithMessage:(EMMessage *)message{
    __weak ChatViewController *weakSelf = self;
    dispatch_async(_messageQueue, ^{
        if ([weakSelf.conversation.chatter isEqualToString:message.conversationChatter])
        {
            for (int i = 0; i < weakSelf.dataSource.count; i ++) {
                id object = [weakSelf.dataSource objectAtIndex:i];
                if ([object isKindOfClass:[MessageModel class]]) {
                    EMMessage *currMsg = [weakSelf.dataSource objectAtIndex:i];
                    if ([message.messageId isEqualToString:currMsg.messageId]) {
                        MessageModel *cellModel = [MessageModelManager modelWithMessage:message];
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [weakSelf.tableView beginUpdates];
                            [weakSelf.dataSource replaceObjectAtIndex:i withObject:cellModel];
                            [weakSelf.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:i inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
                            [weakSelf.tableView endUpdates];
                            
                        });
                        
                        break;
                    }
                }
            }
        }
    });
}

- (void)didMessageAttachmentsStatusChanged:(EMMessage *)message error:(EMError *)error{
    if (!error) {
        id<IEMFileMessageBody>fileBody = (id<IEMFileMessageBody>)[message.messageBodies firstObject];
        if ([fileBody messageBodyType] == eMessageBodyType_Image) {
            EMImageMessageBody *imageBody = (EMImageMessageBody *)fileBody;
            if ([imageBody thumbnailDownloadStatus] == EMAttachmentDownloadSuccessed)
            {
                [self reloadTableViewDataWithMessage:message];
            }
        }else if([fileBody messageBodyType] == eMessageBodyType_Video){
            EMVideoMessageBody *videoBody = (EMVideoMessageBody *)fileBody;
            if ([videoBody thumbnailDownloadStatus] == EMAttachmentDownloadSuccessed)
            {
                [self reloadTableViewDataWithMessage:message];
            }
        }else if([fileBody messageBodyType] == eMessageBodyType_Voice){
            if ([fileBody attachmentDownloadStatus] == EMAttachmentDownloadSuccessed)
            {
                [self reloadTableViewDataWithMessage:message];
            }
        }
        
    }else{
        
    }
}

- (void)didFetchingMessageAttachments:(EMMessage *)message progress:(float)progress{
    NSLog(@"didFetchingMessageAttachment: %f", progress);
}

-(void)didReceiveMessage:(EMMessage *)message
{
    if ([_conversation.chatter isEqualToString:message.conversationChatter]) {
        [self addChatDataToMessage:message];
    }
}

- (void)group:(EMGroup *)group didLeave:(EMGroupLeaveReason)reason error:(EMError *)error
{
    if (_isChatGroup && [group.groupId isEqualToString:_chatter]) {
        [self.navigationController popToViewController:self animated:NO];
        [self.navigationController popViewControllerAnimated:NO];
    }
}

- (void)didInterruptionRecordAudio
{
    [_chatToolBar cancelTouchRecord];
    
    // 设置当前conversation的所有message为已读
    [_conversation markAllMessagesAsRead:YES];
    
    [self stopAudioPlaying];
}

#pragma mark - EMChatBarMoreViewDelegate

/**
 *  发送我的攻略
 *
 *  @param moreView
 */
- (void)moreViewMyStrategyAction:(DXChatBarMoreView *)moreView
{
    [self keyBoardHidden];
    MyGuideListTableViewController *myGuideListTableCtl = [[MyGuideListTableViewController alloc] init];
    myGuideListTableCtl.chatter = _chatter;
    myGuideListTableCtl.selectToSend = YES;
    myGuideListTableCtl.isChatGroup = _isChatGroup;
    [self.navigationController pushViewController:myGuideListTableCtl animated:YES];
}

/**
 *  发送我的收藏夹里的内容
 *
 *  @param moreView
 */
- (void)moreViewMyFavoriteAction:(DXChatBarMoreView *)moreView
{
    [self keyBoardHidden];
    FavoriteViewController *favoriteCtl = [[FavoriteViewController alloc] init];
    favoriteCtl.isChatGroup = _isChatGroup;
    favoriteCtl.chatter = _chatter;
    favoriteCtl.selectToSend = YES;
    [self.navigationController pushViewController:favoriteCtl animated:YES];

}

/**
 *  发送目的地
 *
 *  @param moreView 
 */
- (void)moreViewDestinationAction:(DXChatBarMoreView *)moreView
{
    [self keyBoardHidden];
    SearchDestinationViewController *searchCtl = [[SearchDestinationViewController alloc] init];
    searchCtl.chatter = _chatter;
    searchCtl.isChatGroup = _isChatGroup;
    [self.navigationController pushViewController:searchCtl animated:YES];

}

/**
 *  发送我的攻略
 *
 *  @param moreView
 */
- (void)moreViewTravelNoteAction:(DXChatBarMoreView *)moreView
{
    [self keyBoardHidden];
    TravelNoteListViewController *travelNoteCtl = [[TravelNoteListViewController alloc] init];
    travelNoteCtl.isSearch = YES;
    travelNoteCtl.chatter = _chatter;
    travelNoteCtl.isChatGroup = _isChatGroup;
    [self.navigationController pushViewController:travelNoteCtl animated:YES];
}

- (void)moreViewPhotoAction:(DXChatBarMoreView *)moreView
{
    // 隐藏键盘
    [self keyBoardHidden];
    
    // 弹出照片选择
    ZYQAssetPickerController *picker = [[ZYQAssetPickerController alloc] init];
    picker.maximumNumberOfSelection = 10;
    picker.assetsFilter = [ALAssetsFilter allPhotos];
    picker.showEmptyGroups=NO;
    picker.delegate=self;
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
    [self keyBoardHidden];
    
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
    [self keyBoardHidden];
    
    LocationViewController *locationController = [[LocationViewController alloc] initWithNibName:nil bundle:nil];
    locationController.delegate = self;
    [self.navigationController pushViewController:locationController animated:YES];
}

/*****暂时屏蔽掉录制视频和发送及时语音的功能*****/
/*
- (void)moreViewVideoAction:(DXChatBarMoreView *)moreView{
    [self keyBoardHidden];
    
#if TARGET_IPHONE_SIMULATOR
    [self showHint:@"模拟器不支持录像"];
#elif TARGET_OS_IPHONE
    self.imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    self.imagePicker.mediaTypes = @[(NSString *)kUTTypeMovie];
    [self presentViewController:self.imagePicker animated:YES completion:NULL];
#endif
}
- (void)moreViewAudioCallAction:(DXChatBarMoreView *)moreView
{
    CallViewController *callController = [CallViewController shareController];
    [callController setupCallOutWithChatter:_chatter];
    [self presentViewController:callController animated:YES completion:nil];
}
*/

#pragma mark - LocationViewDelegate

- (void)sendLocationLatitude:(double)latitude longitude:(double)longitude andAddress:(NSString *)address
{
    EMMessage *locationMessage = [ChatSendHelper sendLocationLatitude:latitude longitude:longitude address:address toUsername:_conversation.chatter isChatGroup:_isChatGroup requireEncryption:NO];
    [self addChatDataToMessage:locationMessage];
}

#pragma mark - DXMessageToolBarDelegate
- (void)inputTextViewWillBeginEditing:(HPGrowingTextView *)messageInputTextView{
    [_menuController setMenuItems:nil];
}

- (void)didChangeFrameToHeight:(CGFloat)toHeight
{
    [UIView animateWithDuration:0.25 animations:^{
        CGRect rect = self.tableView.frame;
        rect.origin.y = 64;
        rect.size.height = self.view.frame.size.height - toHeight - 64;
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
    
    NSError *error = nil;
    [[EaseMob sharedInstance].chatManager startRecordingAudioWithError:&error];
    if (error) {
        NSLog(@"开始录音失败");
    }
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
    [[EaseMob sharedInstance].chatManager
     asyncStopRecordingAudioWithCompletion:^(EMChatVoice *aChatVoice, NSError *error){
         if (!error) {
             [self sendAudioMessage:aChatVoice];
         }else{
             if (error.code == EMErrorAudioRecordNotStarted) {
                 [self showHint:error.domain yOffset:-40];
             } else {
                 [self showHint:error.domain];
             }
         }
         
     } onQueue:nil];
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
        NSMutableArray *images = [[NSMutableArray alloc] init];
        for (int i=0; i<assets.count; i++) {
            ALAsset *asset=assets[i];
            UIImage *tempImg=[UIImage imageWithCGImage:asset.defaultRepresentation.fullScreenImage];
            [images addObject:tempImg];
        }
        [self sendImageMessages:images];
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
    if (_longPressIndexPath && _longPressIndexPath.row > 0) {
        MessageModel *model = [self.dataSource objectAtIndex:_longPressIndexPath.row];
        NSMutableArray *messages = [NSMutableArray arrayWithObjects:model, nil];
        [_conversation removeMessage:model.message];
        NSMutableArray *indexPaths = [NSMutableArray arrayWithObjects:_longPressIndexPath, nil];;
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
        [self.tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
    }
    
    _longPressIndexPath = nil;
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
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        NSLog(@"******开始加载聊天记录0");
        NSInteger currentCount = [weakSelf.dataSource count];
        EMMessage *latestMessage = [weakSelf.conversation latestMessage];
        NSTimeInterval beforeTime = 0;
        if (latestMessage) {
            beforeTime = latestMessage.timestamp + 1;
        }else{
            beforeTime = [[NSDate date] timeIntervalSince1970] * 1000 + 1;
        }
        
        NSArray *chats = [weakSelf.conversation loadNumbersOfMessages:(currentCount + KPageCount) before:beforeTime];
        NSLog(@"******开始加载聊天记录1");

        if ([chats count] > currentCount) {
            weakSelf.dataSource.array = [weakSelf sortChatSource:chats];
            dispatch_async(dispatch_get_main_queue(), ^{
                NSLog(@"******结束加载聊天记录");

                [weakSelf.tableView reloadData];
                [weakSelf.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[weakSelf.dataSource count] - currentCount - 1 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
            });
        } else {
            NSLog(@"******不需要加载聊天记录");
        }
    });
}

- (NSArray *)sortChatSource:(NSArray *)array
{
    NSMutableArray *resultArray = [[NSMutableArray alloc] init];
    if (array && [array count] > 0) {
        
        for (EMMessage *message in array) {
            MessageModel *model = [MessageModelManager modelWithMessage:message];
            
            //如果消息是透传消息，直接忽略掉
            if (model.type != eMessageBodyType_Command) {
                NSDate *createDate = [NSDate dateWithTimeIntervalInMilliSecondSince1970:(NSTimeInterval)message.timestamp];
                NSTimeInterval tempDate = [createDate timeIntervalSinceDate:self.chatTagDate];
                if (tempDate > 60 || tempDate < -60 || (self.chatTagDate == nil)) {
                    [resultArray addObject:[createDate formattedTime]];
                    self.chatTagDate = createDate;
                }
                [self updateModelData:model];
                
                if (model) {
                    [resultArray addObject:model];
                }

            }
        }
    }
    return resultArray;
}

/**
 *  更新信息的发送者的 nickName 和头像链接
 *  具体逻辑有点复杂，现在写下来以后别忘记，因为每次进入聊天界面都会维护一个包含在此界面聊天的，所有联系人最新信息。这个方法就是如何保证最新
 *  1.当发现信息比 chattingPeople 里所有的信息都新时，直接替换掉 2，如果chattingPeople 里的信息是最新的，则将messageModel的信息更新
 *  3.如果在 chattingPeople数组里没有发现messageModel则直接加入。。
 *  @param messageModel 需要更新的信息
 */
- (void)updateModelData:(MessageModel *)messageModel
{
    for (MessageModel *model in self.chattingPeople) {
        if ([model.username isEqualToString: messageModel.username]) {
            if (messageModel.timestamp > model.timestamp) {
                [self.chattingPeople removeObject:model];
                [self.chattingPeople addObject:messageModel];
            } else {
                messageModel.nickName = model.nickName;
                messageModel.headImageURL = model.headImageURL;
            }
            return;
        }
    }
    [self.chattingPeople addObject:messageModel];
}


/**
 *  检查messageModel包含的用户信息是不是最新的
 *
 *  @param messageModel 将要被检查的消息
 */
- (void)checkOutModel:(MessageModel *)messageModel
{
    dispatch_async(loadChatPeopleQueue, ^{
        for (MessageModel *model in self.chattingPeople) {
            if ([model.username isEqualToString:messageModel.username] && (![model.nickName isEqualToString:messageModel.nickName] || ![model.headImageURL isEqual:messageModel.headImageURL])) {
                messageModel.headImageURL = model.headImageURL;
                messageModel.nickName = model.nickName;
            }
        }
    });
     
}

- (NSMutableArray *)addChatToMessage:(EMMessage *)message
{
    NSMutableArray *ret = [[NSMutableArray alloc] init];
    NSDate *createDate = [NSDate dateWithTimeIntervalInMilliSecondSince1970:(NSTimeInterval)message.timestamp];
    NSTimeInterval tempDate = [createDate timeIntervalSinceDate:self.chatTagDate];
    if (tempDate > 60 || tempDate < -60 || (self.chatTagDate == nil)) {
        [ret addObject:[createDate formattedTime]];
        self.chatTagDate = createDate;
    }
    
    MessageModel *model = [MessageModelManager modelWithMessage:message];
    if (model) {
        [ret addObject:model];
    }
    
    return ret;
}

- (void)addChatDataToMessage:(EMMessage *)message
{
    __weak ChatViewController *weakSelf = self;
    dispatch_async(_messageQueue, ^{
        NSArray *messages = [weakSelf addChatToMessage:message];
        NSMutableArray *indexPaths = [[NSMutableArray alloc] init];
        
        for (int i = 0; i < messages.count; i++) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:weakSelf.dataSource.count+i inSection:0];
            [indexPaths addObject:indexPath];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.dataSource addObjectsFromArray:messages];
            [weakSelf.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
            [weakSelf.tableView scrollToRowAtIndexPath:[indexPaths lastObject] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
        });
    });

}

- (void)scrollViewToBottom:(BOOL)animated
{
    if (self.tableView.contentSize.height > self.tableView.frame.size.height)
    {
        CGPoint offset = CGPointMake(0, self.tableView.contentSize.height - self.tableView.frame.size.height);
        [self.tableView setContentOffset:offset animated:animated];
    }
}

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
            chatGroup = [[EMGroup alloc] initWithGroupId:_chatter];
        }
        ChatGroupSettingViewController *chatSettingCtl = [[ChatGroupSettingViewController alloc] init];
        chatSettingCtl.group = chatGroup;
        [self.navigationController pushViewController:chatSettingCtl animated:YES];
        
    } else {
        ChatSettingViewController *chatSettingCtl = [[ChatSettingViewController alloc] init];
        chatSettingCtl.chatter = _conversation.chatter;
        [self.navigationController pushViewController:chatSettingCtl animated:YES];
    }
}

- (void)removeAllMessages:(id)sender
{
    if (_dataSource.count == 0) {
        return;
    }
    
    if ([sender isKindOfClass:[NSNotification class]]) {
        NSString *chatter = (NSString *)[(NSNotification *)sender object];
        if (_isChatGroup && [chatter isEqualToString:_conversation.chatter]) {
            [_conversation removeAllMessages];
            [_dataSource removeAllObjects];
            [_tableView reloadData];
        } else if (!_isChatGroup && [chatter isEqualToString:_conversation.chatter]) {
            [_conversation removeAllMessages];
            [_dataSource removeAllObjects];
            [_tableView reloadData];
        }
    }
}

- (void)showMenuViewController:(UIView *)showInView andIndexPath:(NSIndexPath *)indexPath messageType:(MessageBodyType)messageType
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
    
    if (messageType == eMessageBodyType_Text) {
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
    [_conversation markAllMessagesAsRead:YES];
}

#pragma mark - send message

- (void)sendTextMessage:(NSString *)textMessage
{
    EMMessage *tempMessage = [ChatSendHelper sendTextMessageWithString:textMessage toUsername:_conversation.chatter isChatGroup:_isChatGroup requireEncryption:NO];
    [self addChatDataToMessage:tempMessage];
}

- (void)sendImageMessages:(NSArray *)imageMessages
{
    for (UIImage *imageMsg in imageMessages) {
        EMMessage *tempMessage = [ChatSendHelper sendImageMessageWithImage:imageMsg toUsername:_conversation.chatter isChatGroup:_isChatGroup requireEncryption:NO];
        [self addChatDataToMessage:tempMessage];
    }
}

- (void)sendImageMessage:(UIImage *)imageMessage
{
    EMMessage *tempMessage = [ChatSendHelper sendImageMessageWithImage:imageMessage toUsername:_conversation.chatter isChatGroup:_isChatGroup requireEncryption:NO];
    [self addChatDataToMessage:tempMessage];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self keyBoardHidden];
}

- (void)sendTaoziMessage:(NSDictionary *)taoziMsg
{
    EMMessage *tempMessage = [ChatSendHelper sendTaoziMessageWithString:@"" andExtMessage:taoziMsg toUsername:_conversation.chatter isChatGroup:_isChatGroup requireEncryption:NO];
    [self addChatDataToMessage:tempMessage];
}


-(void)sendAudioMessage:(EMChatVoice *)voice
{
    EMMessage *tempMessage = [ChatSendHelper sendVoice:voice toUsername:_conversation.chatter isChatGroup:_isChatGroup requireEncryption:NO];
    [self addChatDataToMessage:tempMessage];
}

/*****暂时屏蔽掉发送视频功能*******/
/*
-(void)sendVideoMessage:(EMChatVideo *)video
{
    EMMessage *tempMessage = [ChatSendHelper sendVideo:video toUsername:_conversation.chatter isChatGroup:_isChatGroup requireEncryption:NO];
    [self addChatDataToMessage:tempMessage];
}
 */

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

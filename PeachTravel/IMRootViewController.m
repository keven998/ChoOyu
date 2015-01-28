//
//  IMRootViewController.m
//  PeachTravel
//
//  Created by liangpengshuai on 11/18/14.
//  Copyright (c) 2014 com.aizou.www. All rights reserved.
//

#import "IMRootViewController.h"
#import "AddContactTableViewController.h"
#import "CreateConversationViewController.h"
#import "RNGridMenu.h"
#import "ChatListViewController.h"
#import "ContactListViewController.h"
#import "AccountManager.h"

@interface IMRootViewController () <RNGridMenuDelegate, CreateConversationDelegate>

@property (nonatomic, strong) NSArray *addItems;

@property (nonatomic, strong) CreateConversationViewController *createCoversationCtl;

@property (nonatomic, strong) RNGridMenu *av;

@property (nonatomic, strong) UILabel *unReadChatMsgLabel;
@property (nonatomic, strong) UILabel *unReadFrendRequestLabel;

@end

@implementation IMRootViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationController.navigationBar setBarTintColor:[UIColor whiteColor]];
    [self.navigationController.navigationBar setTintColor:APP_THEME_COLOR];

    self.navigationItem.title = @"桃•Talk";
    NSLog(@"%@", self.navigationController);
    UIBarButtonItem * makePlanBtn = [[UIBarButtonItem alloc]initWithTitle:nil style:UIBarButtonItemStyleBordered target:self action:@selector(addAction:)];
    [makePlanBtn setImage:[UIImage imageNamed:@"ic_menu_add.png"]];
    self.navigationItem.rightBarButtonItem = makePlanBtn;

    self.view.backgroundColor = APP_PAGE_COLOR;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(goBack) name:userDidLogoutNoti object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateFrendRequestStatus) name:frendRequestListNeedUpdateNoti object:nil];
    
    _unReadChatMsgLabel = [[UILabel alloc] initWithFrame:CGRectMake(40, 0, 15, 15)];
    _unReadChatMsgLabel.backgroundColor = [UIColor redColor];
    _unReadChatMsgLabel.layer.cornerRadius = 7.5;
    _unReadChatMsgLabel.textAlignment = NSTextAlignmentCenter;
    _unReadChatMsgLabel.font = [UIFont boldSystemFontOfSize:12.0];
    _unReadChatMsgLabel.textColor = [UIColor whiteColor];
    _unReadChatMsgLabel.clipsToBounds = YES;
    UIButton *chatBtn = [self.segmentedBtns firstObject];
    [chatBtn addSubview:_unReadChatMsgLabel];
    
    _unReadFrendRequestLabel = [[UILabel alloc] initWithFrame:CGRectMake(40, 0, 15, 15)];
    _unReadFrendRequestLabel.backgroundColor = [UIColor redColor];
    _unReadFrendRequestLabel.layer.cornerRadius = 7.5;
    _unReadFrendRequestLabel.clipsToBounds = YES;
    _unReadFrendRequestLabel.textAlignment = NSTextAlignmentCenter;
    _unReadFrendRequestLabel.font = [UIFont boldSystemFontOfSize:12.0];
    _unReadFrendRequestLabel.textColor = [UIColor whiteColor];
    UIButton *contactBtn = [self.segmentedBtns lastObject];
    [contactBtn addSubview:_unReadFrendRequestLabel];

    id chatListCtl = [self.viewControllers firstObject];
    if ([chatListCtl isKindOfClass:[ChatListViewController class]]) {
        self.numberOfUnReadChatMsg = ((ChatListViewController *)chatListCtl).numberOfUnReadChatMsg;
    }
    [self updateFrendRequestStatus];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)goBack
{
    [self.navigationController popViewControllerAnimated:NO];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (int)totalUnReadMsg
{
    AccountManager *accountManager = [AccountManager shareAccountManager];
    id chatListCtl = [self.viewControllers firstObject];
    int unreadChatMsg = 0;
    if ([chatListCtl isKindOfClass:[ChatListViewController class]]) {
        unreadChatMsg = ((ChatListViewController *)chatListCtl).numberOfUnReadChatMsg;
    }
    self.numberOfUnReadChatMsg = unreadChatMsg;
    return ((int)accountManager.numberOfUnReadFrendRequest + unreadChatMsg);
}

- (void)setNumberOfUnReadChatMsg:(int)numberOfUnReadChatMsg
{
    _numberOfUnReadChatMsg = numberOfUnReadChatMsg;

    if (_numberOfUnReadChatMsg > 0) {
        _unReadChatMsgLabel.hidden = NO;
        _unReadChatMsgLabel.text = [NSString stringWithFormat:@"%d", _numberOfUnReadChatMsg];
    } else {
        _unReadChatMsgLabel.hidden = YES;
    }
}

- (void)setIMState:(IM_CONNECT_STATE)IMState
{
    _IMState = IMState;
    switch (_IMState) {
        case IM_CONNECTING: {
            self.navigationItem.title = @"连接中";
        }
            break;
            
        case IM_DISCONNECTED: {
            self.navigationItem.title = @"未连接";
        }
            break;
            
        case IM_RECEIVING: {
            self.navigationItem.title = @"收取中";
        }
            break;
            
        case IM_RECEIVED: {
            self.navigationItem.title = @"桃•Talk";
        }
            break;
            
        case IM_CONNECTED: {
            self.navigationItem.title = @"桃•Talk";
        }
            
        default:
            break;
    }
}

//收到好友请求
- (void)updateFrendRequestStatus
{
    AccountManager *accountManager = [AccountManager shareAccountManager];
    int numberOfUnReadFrendRequestMsg = (int)accountManager.numberOfUnReadFrendRequest;
    
    id contactListCtl = [self.viewControllers lastObject];
    if ([contactListCtl isKindOfClass:[ContactListViewController class]]) {
        ((ContactListViewController*)contactListCtl).numberOfUnreadFrendRequest = numberOfUnReadFrendRequestMsg;
        if (numberOfUnReadFrendRequestMsg > 0) {
            _unReadFrendRequestLabel.hidden = NO;
            _unReadFrendRequestLabel.text = [NSString stringWithFormat:@"%d", numberOfUnReadFrendRequestMsg];
        } else {
            _unReadFrendRequestLabel.hidden = YES;
        }
    }
}

- (IBAction)addUserContact:(id)sender
{
    AddContactTableViewController *addContactCtl = [[AddContactTableViewController alloc] init];
    [self.navigationController pushViewController:addContactCtl animated:YES];
}

- (IBAction)addConversation:(id)sender
{
    _createCoversationCtl = [[CreateConversationViewController alloc] init];
    _createCoversationCtl.delegate = self;
    UINavigationController *nCtl = [[UINavigationController alloc] initWithRootViewController:_createCoversationCtl];
    [self presentViewController:nCtl animated:YES completion:nil];
}

- (IBAction)addAction:(UIButton *)sender
{
    NSInteger numberOfOptions = 2;
    NSArray *items = @[
                       [[RNGridMenuItem alloc] initWithImage:[UIImage imageNamed:@"ic_new_talk"] title:@"Talk"],
                       [[RNGridMenuItem alloc] initWithImage:[UIImage imageNamed:@"ic_add_friend"] title:@"加桃友"]
                       ];
    
    _av = [[RNGridMenu alloc] initWithItems:[items subarrayWithRange:NSMakeRange(0, numberOfOptions)]];
    _av.delegate = self;
    [_av showInViewController:self.navigationController center:CGPointMake(self.navigationController.view.bounds.size.width/2.f, self.navigationController.view.bounds.size.height/2.f)];
}

#pragma mark - RNGridMenuDelegate

- (void)gridMenu:(RNGridMenu *)gridMenu willDismissWithSelectedItem:(RNGridMenuItem *)item atIndex:(NSInteger)itemIndex {
    if (itemIndex == 0) {
        [self addConversation:nil];
    } else {
        [self addUserContact:nil];
    }
    _av = nil;
}

- (void)gridMenuWillDismiss:(RNGridMenu *)gridMenu
{
    _av = nil;
}

#pragma mark - CreateConversationDelegate

- (void)createConversationSuccessWithChatter:(NSString *)chatter isGroup:(BOOL)isGroup chatTitle:(NSString *)chatTitle
{
    [_createCoversationCtl dismissViewControllerAnimated:YES completion:^{
        ChatViewController *chatCtl = [[ChatViewController alloc] initWithChatter:chatter isGroup:isGroup];
        chatCtl.title = chatTitle;
        [self.navigationController pushViewController:chatCtl animated:YES];
    }];
}


@end

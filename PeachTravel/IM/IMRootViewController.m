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
#import "JDStatusBarNotification.h"

@interface IMRootViewController () <RNGridMenuDelegate, CreateConversationDelegate, UIActionSheetDelegate>

@property (nonatomic, strong) NSArray *addItems;

@property (nonatomic, strong) CreateConversationViewController *createCoversationCtl;

@property (nonatomic, strong) RNGridMenu *av;

@property (nonatomic, strong) UILabel *unReadChatMsgLabel;
@property (nonatomic, strong) UILabel *unReadFrendRequestLabel;
@property (nonatomic) BOOL isShowing;

@end

@implementation IMRootViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"navi_bkg.png"] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.translucent = YES;

    UIButton *button =  [UIButton buttonWithType:UIButtonTypeCustom];
    [button setImage:[UIImage imageNamed:@"ic_navigation_back.png"] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(goBack)forControlEvents:UIControlEventTouchUpInside];
    [button setFrame:CGRectMake(0, 0, 48, 30)];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button setTitleColor:TEXT_COLOR_TITLE forState:UIControlStateHighlighted];
    button.titleLabel.font = [UIFont fontWithName:@"MicrosoftYaHei" size:17.0];
    button.titleEdgeInsets = UIEdgeInsetsMake(2, 1, 0, 0);
    button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithCustomView:button];
    self.navigationItem.leftBarButtonItem = barButton;

    UIButton *addBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    [addBtn setImage:[UIImage imageNamed:@"ic_menu_add.png"] forState:UIControlStateNormal];
    [addBtn addTarget:self action:@selector(addAction:) forControlEvents:UIControlEventTouchUpInside];
    addBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:addBtn];

    self.view.backgroundColor = APP_PAGE_COLOR;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(goBack) name:userDidLogoutNoti object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateFrendRequestStatus) name:frendRequestListNeedUpdateNoti object:nil];
    
    _unReadChatMsgLabel = [[UILabel alloc] initWithFrame:CGRectMake(40, 0, 18, 18)];
    _unReadChatMsgLabel.backgroundColor = [UIColor redColor];
    _unReadChatMsgLabel.layer.cornerRadius = 9;
    _unReadChatMsgLabel.textAlignment = NSTextAlignmentCenter;
    _unReadChatMsgLabel.font = [UIFont boldSystemFontOfSize:12.0];
    _unReadChatMsgLabel.textColor = [UIColor whiteColor];
    _unReadChatMsgLabel.clipsToBounds = YES;
    UIButton *chatBtn = [self.segmentedBtns firstObject];
    [chatBtn addSubview:_unReadChatMsgLabel];
    
    _unReadFrendRequestLabel = [[UILabel alloc] initWithFrame:CGRectMake(40, 0, 18, 18)];
    _unReadFrendRequestLabel.backgroundColor = [UIColor redColor];
    _unReadFrendRequestLabel.layer.cornerRadius = 9;
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
    
    _isShowing = YES;
    switch (_IMState) {
        case IM_CONNECTING: {
            NSLog(@"连接中");
            [JDStatusBarNotification showWithStatus:@"连接中"];
        }
            break;
            
        case IM_DISCONNECTED: {
            NSLog(@"未连接");
            [JDStatusBarNotification showWithStatus:@"未连接" styleName:JDStatusBarStyleError];
        }
            break;
            
        case IM_RECEIVING: {
            NSLog(@"收取中");
            [JDStatusBarNotification showWithStatus:@"收取中"];
        }
            break;
            
        case IM_RECEIVED: {
            NSLog(@"IM_RECEIVED");
            self.navigationItem.title = @"Talk";
            [JDStatusBarNotification dismissAfter:0.3];
            
        }
            break;
            
        case IM_CONNECTED: {
            NSLog(@"IM_CONNECTED");
            
            [JDStatusBarNotification dismiss];

        }
            
        default:
            [JDStatusBarNotification dismiss];
            break;
    }

}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [JDStatusBarNotification dismiss];
    _isShowing = NO;
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
        if (_numberOfUnReadChatMsg > 9) {
            _unReadChatMsgLabel.font = [UIFont boldSystemFontOfSize:10.0];
        }
        if (_numberOfUnReadChatMsg > 99) {
            _unReadFrendRequestLabel.font = [UIFont systemFontOfSize:5.0];
        }
        else {
            _unReadFrendRequestLabel.font = [UIFont boldSystemFontOfSize:12.0];
        }
    } else {
        _unReadChatMsgLabel.hidden = YES;
    }
}

- (void)setIMState:(IM_CONNECT_STATE)IMState
{
    _IMState = IMState;
    if (!_isShowing) {
        return;
    }
    JDStatusBarStyle *style = [[JDStatusBarStyle alloc] init];
    style.barColor = [[UIColor whiteColor] colorWithAlphaComponent:0.9];
    switch (_IMState) {
        case IM_CONNECTING: {
            NSLog(@"连接中");
            [JDStatusBarNotification showWithStatus:@"连接中"];
        }
            break;
            
        case IM_DISCONNECTED: {
            NSLog(@"未连接");
            [JDStatusBarNotification showWithStatus:@"未连接" styleName:JDStatusBarStyleError];
        }
            break;
            
        case IM_RECEIVING: {
            NSLog(@"收取中");
            [JDStatusBarNotification showWithStatus:@"收取中"];
        }
            break;
            
        case IM_RECEIVED: {
            NSLog(@"IM_RECEIVED");
            self.navigationItem.title = @"Talk";
            [JDStatusBarNotification dismissAfter:0.3];

        }
            break;
            
        case IM_CONNECTED: {
            NSLog(@"IM_CONNECTED");

            [JDStatusBarNotification showWithStatus:@"已链接~"];
            [JDStatusBarNotification dismissAfter:0.7];
        }
            
        default:
            [JDStatusBarNotification dismiss];
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
    [nCtl.navigationBar setBackgroundImage:[UIImage imageNamed:@"navi_bkg.png"] forBarMetrics:UIBarMetricsDefault];
    nCtl.navigationBar.translucent = YES;
    [self presentViewController:nCtl animated:YES completion:nil];
}

- (IBAction)addAction:(UIButton *)sender
{
//    NSInteger numberOfOptions = 2;
//    NSArray *items = @[
//                       [[RNGridMenuItem alloc] initWithImage:[UIImage imageNamed:@"ic_new_talk"] title:@"Talk"],
//                       [[RNGridMenuItem alloc] initWithImage:[UIImage imageNamed:@"ic_add_friend"] title:@"加好友"]
//                       ];
//    
//    _av = [[RNGridMenu alloc] initWithItems:[items subarrayWithRange:NSMakeRange(0, numberOfOptions)]];
//    _av.delegate = self;
//    [_av showInViewController:self.navigationController center:CGPointMake(self.navigationController.view.bounds.size.width/2.f, self.navigationController.view.bounds.size.height/2.f)];
    
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:nil
                                                       delegate:self
                                              cancelButtonTitle:@"取消"
                                         destructiveButtonTitle:nil
                                              otherButtonTitles:@"新建Talk", @"加好友", nil];
    [sheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        [self addConversation:nil];
        [MobClick event:@"event_create_new_talk"];
    } else if (buttonIndex == 1) {
        [self addUserContact:nil];
        [MobClick event:@"event_add_new_friend"];
    }
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

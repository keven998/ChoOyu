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
#import "ChatViewController.h"
#import "ContactListViewController.h"
#import "AccountManager.h"

@interface IMRootViewController () <RNGridMenuDelegate, CreateConversationDelegate, MHChildViewControllerDeleagate>

@property (nonatomic, strong) NSArray *addItems;

@property (nonatomic, strong) CreateConversationViewController *createCoversationCtl;

@property (nonatomic, strong) RNGridMenu *av;

@end

@implementation IMRootViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"桃•Talk";
    UIBarButtonItem * makePlanBtn = [[UIBarButtonItem alloc]initWithTitle:nil style:UIBarButtonItemStyleBordered target:self action:@selector(addAction:)];
    [makePlanBtn setImage:[UIImage imageNamed:@"ic_menu_add.png"]];
    self.navigationItem.rightBarButtonItem = makePlanBtn;

    self.view.backgroundColor = APP_PAGE_COLOR;
    
    for (MHChildViewController *ctl in self.viewControllers) {
        ctl.delegate = self;
    }
    if ([[self.viewControllers lastObject] isKindOfClass:[ContactListViewController class]]) {
        AccountManager *accountManager = [AccountManager shareAccountManager];
        if ([accountManager numberOfUnReadFrendRequest]) {
            ContactListViewController *ctl = [self.viewControllers lastObject];
            [ctl.delegate updateNotify:ctl notify:YES];
        }
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(goBack) name:userDidLogoutNoti object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateFrendRequestStatus) name:receiveFrendRequestNoti object:nil];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setIMState:(IM_CONNECT_STATE)IMState
{
    NSLog(@"%@", [NSThread currentThread]);
    
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
    ContactListViewController *ctl = [self.viewControllers lastObject];
    [ctl.delegate updateNotify:ctl notify:YES];
}

- (void)goBack
{
    [self.navigationController popToRootViewControllerAnimated:YES];
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

#pragma mark - MHChildViewControllerDeleagate

- (void)updateNotify:(MHChildViewController *)needUpdateCtl notify:(BOOL)notify
{
    NSUInteger index = [self.viewControllers indexOfObject:needUpdateCtl];
    [super updateNotify:index notify:notify];
}

@end

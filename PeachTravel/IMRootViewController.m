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

@interface IMRootViewController () <RNGridMenuDelegate, CreateConversationDelegate>

@property (nonatomic, strong) NSArray *addItems;

@property (nonatomic, strong) CreateConversationViewController *createCoversationCtl;

@end

@implementation IMRootViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = APP_PAGE_COLOR;
    
    UIButton *addBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 32.0, 32.0)];
    [addBtn setImage:[UIImage imageNamed:@"ic_menu_add.png"] forState:UIControlStateNormal];
    [addBtn addTarget:self action:@selector(addAction:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:addBtn];
    
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
                       [[RNGridMenuItem alloc] initWithImage:[UIImage imageNamed:@"ic_menu_circle_chat.png"] title:@"新建讨论"],
                       [[RNGridMenuItem alloc] initWithImage:[UIImage imageNamed:@"ic_menu_add_friend.png"] title:@"添加朋友"]
                       ];
    
    RNGridMenu *av = [[RNGridMenu alloc] initWithItems:[items subarrayWithRange:NSMakeRange(0, numberOfOptions)]];
    av.backgroundColor = [UIColor clearColor];
    av.delegate = self;
    [av showInViewController:self center:CGPointMake(self.view.bounds.size.width/2.f, self.view.bounds.size.height/2.f)];
}

#pragma mark - RNGridMenuDelegate

- (void)gridMenu:(RNGridMenu *)gridMenu willDismissWithSelectedItem:(RNGridMenuItem *)item atIndex:(NSInteger)itemIndex {
    if (itemIndex == 0) {
        [self addConversation:nil];
    } else {
        [self addUserContact:nil];
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

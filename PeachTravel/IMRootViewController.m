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

@interface IMRootViewController ()<RNGridMenuDelegate>

@property (nonatomic, strong) NSArray *addItems;

@end

@implementation IMRootViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = APP_PAGE_COLOR;
    
    UIButton *addBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 32.0, 32.0)];
//    [addBtn setTitle:@"添加好友" forState:UIControlStateNormal];
//    addBtn.titleLabel.font = [UIFont systemFontOfSize:12.0];
//    [addBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [addBtn setImage:[UIImage imageNamed:@"ic_menu_add.png"] forState:UIControlStateNormal];
    [addBtn addTarget:self action:@selector(addAction:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:addBtn];
    
}

//- (NSArray *)addItems
//{
//    if (!_addItems) {
//        _addItems = @[ [KxMenuItem menuItem:@"添加好友"
//                                      image:[UIImage imageNamed:@"action_icon"]
//                                     target:self
//                                     action:@selector(addUserContact:)],
//                       
//                       [KxMenuItem menuItem:@"群聊/聊天"
//                                      image:nil
//                                     target:self
//                                     action:@selector(addConversation:)]];
//    }
//    return _addItems;
//}


- (IBAction)addUserContact:(id)sender
{
    AddContactTableViewController *addContactCtl = [[AddContactTableViewController alloc] init];
    [self.navigationController pushViewController:addContactCtl animated:YES];
}

- (IBAction)addConversation:(id)sender
{
    CreateConversationViewController *createCoversationCtl = [[CreateConversationViewController alloc] init];
    [self.navigationController pushViewController:createCoversationCtl animated:YES];
}

- (IBAction)addAction:(UIButton *)sender
{
//    [KxMenu showMenuInView:self.view
//                  fromRect:CGRectMake(self.view.frame.size.width-40, 64, 0, 0)
//                 menuItems:self.addItems];
    
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

#pragma RNGridMenuDelegate
- (void)gridMenu:(RNGridMenu *)gridMenu willDismissWithSelectedItem:(RNGridMenuItem *)item atIndex:(NSInteger)itemIndex {
    if (itemIndex == 0) {
        [self addConversation:nil];
    } else {
        [self addUserContact:nil];
    }
}

@end

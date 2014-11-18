//
//  IMRootViewController.m
//  PeachTravel
//
//  Created by liangpengshuai on 11/18/14.
//  Copyright (c) 2014 com.aizou.www. All rights reserved.
//

#import "IMRootViewController.h"
#import "KxMenu.h"
#import "AddContactTableViewController.h"
#import "CreateConversationViewController.h"

@interface IMRootViewController ()

@property (nonatomic, strong) NSArray *addItems;

@end

@implementation IMRootViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    UIButton *addBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    [addBtn setTitle:@"添加好友" forState:UIControlStateNormal];
    addBtn.titleLabel.font = [UIFont systemFontOfSize:12];
    [addBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [addBtn addTarget:self action:@selector(userAdd:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:addBtn];
    
}

- (NSArray *)addItems
{
    if (!_addItems) {
        _addItems = @[ [KxMenuItem menuItem:@"添加好友"
                                      image:[UIImage imageNamed:@"action_icon"]
                                     target:self
                                     action:@selector(addUserContact:)],
                       
                       [KxMenuItem menuItem:@"群聊/聊天"
                                      image:nil
                                     target:self
                                     action:@selector(addConversation:)]];
    }
    return _addItems;
}


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

- (IBAction)userAdd:(UIButton *)sender
{
    [KxMenu showMenuInView:self.view
                  fromRect:CGRectMake(self.view.frame.size.width-40, 64, 0, 0)
                 menuItems:self.addItems];
    
}

@end

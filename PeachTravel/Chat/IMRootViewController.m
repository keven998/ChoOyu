//
//  IMRootViewController.m
//  PeachTravel
//
//  Created by liangpengshuai on 14/10/23.
//  Copyright (c) 2014年 com.aizou.www. All rights reserved.
//

#import "IMRootViewController.h"
#import "ChatListViewController.h"
#import "ContactListTableViewController.h"
#import "AddressBook.h"

@interface IMRootViewController ()

@property (nonatomic, strong) UISegmentedControl *segmentedControl;
@property (nonatomic, strong) ChatListViewController *chatListCtl;
@property (nonatomic, strong) ContactListTableViewController *contactListCtl;

@end

@implementation IMRootViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _segmentedControl = [[UISegmentedControl alloc] initWithItems:@[@"会话", @"小伙伴"]];
    
    self.navigationItem.titleView = _segmentedControl;
    [_segmentedControl addTarget:self action:@selector(switchController:) forControlEvents:UIControlEventValueChanged];
    [_segmentedControl setSelectedSegmentIndex:0];
    
    UIButton *addBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    [addBtn setTitle:@"添加好友" forState:UIControlStateNormal];
    addBtn.titleLabel.font = [UIFont systemFontOfSize:12];
    [addBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [addBtn addTarget:self action:@selector(userAdd:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:addBtn];
    
    [self setCurrentController:self.chatListCtl];
}

#pragma mark - setter & getter

- (ChatListViewController *)chatListCtl
{
    if (!_chatListCtl) {
        _chatListCtl = [[ChatListViewController alloc] init];
        _chatListCtl.rootCtl = self;
    }
    return _chatListCtl;
}

- (ContactListTableViewController *)contactListCtl
{
    if (!_contactListCtl) {
        _contactListCtl = [[ContactListTableViewController alloc] init];
        _contactListCtl.rootCtl = self;
    }
    return _contactListCtl;
}

#pragma mark - Private Methods

- (void)setCurrentController:(UIViewController *)controller
{
    [self.view addSubview:[controller view]];
    [controller didMoveToParentViewController:self];
}

#pragma mark - IBAction Methods

- (IBAction)switchController:(UISegmentedControl *)sender
{
    switch (sender.selectedSegmentIndex) {
        case 0:
            [self setCurrentController:self.chatListCtl];
            break;
            
        case 1:
            [self setCurrentController:self.contactListCtl];
            break;
            
        default:
            break;
    }
}

- (IBAction)userAdd:(id)sender
{
    AddressBook *addressBook = [[AddressBook alloc] init];
    [addressBook getAllPerson];
}

@end



//
//  BaseProfileViewController.m
//  PeachTravel
//
//  Created by 王聪 on 8/31/15.
//  Copyright (c) 2015 com.aizou.www. All rights reserved.
//

#import "BaseProfileViewController.h"

@interface BaseProfileViewController ()

@property (nonatomic, strong) id userInfo;

@property (nonatomic, strong) NSMutableArray *albumArray;

@property (nonatomic, weak) UITableView *tableView;

@property (nonatomic, strong) UIButton *addFriendBtn;
@property (nonatomic, strong) UIButton *beginTalk;

@end

@implementation BaseProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

@end

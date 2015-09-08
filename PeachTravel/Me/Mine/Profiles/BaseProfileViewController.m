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

- (void)createFooterBar
{
    UIImageView *barView = [[UIImageView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height-49, CGRectGetWidth(self.view.bounds), 49)];
    barView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    [barView setImage:[UIImage imageNamed:@"account_button_default.png"]];
    barView.contentMode = UIViewContentModeScaleToFill;
    barView.userInteractionEnabled = YES;
    [self.view addSubview:barView];
    
    AccountManager *accountManager = [AccountManager shareAccountManager];
    
    _beginTalk = [[UIButton alloc]initWithFrame:CGRectMake(kWindowWidth*0.5, 0, kWindowWidth*0.5, 48)];
    [_beginTalk setTitle:@"发送消息" forState:UIControlStateNormal];
    [_beginTalk setBackgroundImage:[UIImage new] forState:UIControlStateNormal];
    [_beginTalk setTitleColor:COLOR_TEXT_II forState:UIControlStateNormal];
    [_beginTalk setImage:[UIImage imageNamed:@"chat_friend"] forState:UIControlStateNormal];
    //    [_beginTalk setBackgroundImage:[UIImage imageNamed:@"account_button_selected.png"] forState:UIControlStateHighlighted];
    _beginTalk.titleLabel.font = [UIFont systemFontOfSize:13];
    [_beginTalk setImageEdgeInsets:UIEdgeInsetsMake(3, -5, 0, 0)];
    [_beginTalk setTitleEdgeInsets:UIEdgeInsetsMake(4, 0, 0, -5)];
    [_beginTalk addTarget:self action:@selector(talkToFriend) forControlEvents:UIControlEventTouchUpInside];
    [barView addSubview:_beginTalk];
    
    _addFriendBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, kWindowWidth*0.5, 48)];
    
    _addFriendBtn.titleLabel.font = [UIFont systemFontOfSize:13];
    [_addFriendBtn setTitleColor:COLOR_TEXT_II forState:UIControlStateNormal];
    [_addFriendBtn setImage:[UIImage imageNamed:@"add_friend"] forState:UIControlStateNormal];
    [_addFriendBtn setBackgroundImage:[UIImage new] forState:UIControlStateHighlighted];
    //    [_addFriendBtn setBackgroundImage:[UIImage imageNamed:@"account_button_selected.png"] forState:UIControlStateHighlighted];
    [_addFriendBtn setImageEdgeInsets:UIEdgeInsetsMake(3, -5, 0, 0)];
    [_addFriendBtn setTitleEdgeInsets:UIEdgeInsetsMake(4, 0, 0, -5)];
    [barView addSubview:_addFriendBtn];
    
    if ([accountManager frendIsMyContact:self.userId]) {
        [_addFriendBtn setTitle:@"修改备注" forState:UIControlStateNormal];
        [_addFriendBtn addTarget:self action:@selector(remarkFriend) forControlEvents:UIControlEventTouchUpInside];
    } else {
        [_addFriendBtn setTitle:@"加为朋友" forState:UIControlStateNormal];
        [_addFriendBtn addTarget:self action:@selector(addToFriend) forControlEvents:UIControlEventTouchUpInside];
        
    }
}



@end

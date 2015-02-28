//
//  ChatSettingViewController.m
//  PeachTravel
//
//  Created by liangpengshuai on 12/6/14.
//  Copyright (c) 2014 com.aizou.www. All rights reserved.
//

#import "ChatSettingViewController.h"

@interface ChatSettingViewController ()

@end

@implementation ChatSettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"聊天设置";

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [MobClick beginLogPageView:@"page_talk_setting"];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:@"page_talk_setting"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


- (IBAction)deleteContact:(id)sender {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"确认清空全部聊天记录" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确认", nil];
    [alertView showAlertViewWithBlock:^(NSInteger buttonIndex) {
        if (buttonIndex == 1) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"RemoveAllMessages" object:_chatter];
            [self.navigationController popViewControllerAnimated:YES];
        }
    }];
}
@end

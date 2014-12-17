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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)deleteContact:(id)sender {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"确认清空全部聊天记录" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确认", nil];
    [alertView showAlertViewWithBlock:^(NSInteger buttonIndex) {
        if (buttonIndex == 1) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"RemoveAllMessages" object:_chatter];
            
        }
    }];
}
@end

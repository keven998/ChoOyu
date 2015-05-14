//
//  FeedbackController.m
//  fanny
//
//  Created by Luo Yong on 13-6-7.
//  Copyright (c) 2013年 shinro. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "FeedbackViewController.h"
#import "AppUtils.h"
#import "AccountManager.h"

@interface FeedbackController ()

@property (nonatomic, strong) UITextView *contentEditor;

@end

@implementation FeedbackController
@synthesize contentEditor;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = APP_PAGE_COLOR;
    self.navigationItem.title = @"意见和需求";

    CGFloat width = self.view.frame.size.width;
    
    UILabel *desc1 = [[UILabel alloc]initWithFrame:CGRectMake(15.0, 20.0, width-30, 20.0)];
    desc1.font = [UIFont systemFontOfSize:13.0];
    desc1.textColor = UIColorFromRGB(0x5a5a5a);
    desc1.textAlignment = NSTextAlignmentCenter;
    desc1.text = @"你的意见和需求，我们在认真听取";
    desc1.backgroundColor = [UIColor clearColor];
    [self.view addSubview:desc1];
    
    UIView *eborder = [[UIView alloc] initWithFrame:CGRectMake(0., 45, width, 86.0)];
    eborder.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:eborder];
    
    UITextView *suggestion = [[UITextView alloc] initWithFrame:CGRectMake(5.0, 5.0, width - 10.0, 76.0)];
    suggestion.backgroundColor = [UIColor clearColor];
    suggestion.textColor = TEXT_COLOR_TITLE;
    suggestion.font = [UIFont systemFontOfSize:14.0];
    suggestion.scrollEnabled = YES;
    [eborder addSubview:suggestion];
    contentEditor = suggestion;
    [contentEditor becomeFirstResponder];
}

- (void)goBack
{
    [contentEditor resignFirstResponder];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
    [super touchesEnded:touches withEvent:event];
}

- (IBAction)sendFeedback:(id)sender {
    [contentEditor resignFirstResponder];
    [self feedback];
}

- (void) feedback {
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    AppUtils *utils = [[AppUtils alloc] init];
    [manager.requestSerializer setValue:utils.appVersion forHTTPHeaderField:@"Version"];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"iOS %@",utils.systemVersion] forHTTPHeaderField:@"Platform"];
    
    NSString *contents = contentEditor.text;
    NSString *trimText = [contents stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if ([trimText length] < 5) {
        [SVProgressHUD showHint:@"多说点什么吧"];
        return;
    }
    
    __weak typeof(FeedbackController *)weakSelf = self;
    TZProgressHUD *hud = [[TZProgressHUD alloc] init];
    [hud showHUDInViewController:weakSelf];

    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   trimText, @"body",
                                   nil];
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [manager.requestSerializer setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    
    AccountManager *accountManager = [AccountManager shareAccountManager];
    if ([accountManager isLogin]) {
        [manager.requestSerializer setValue:[NSString stringWithFormat:@"%@", accountManager.account.userId] forHTTPHeaderField:@"UserId"];
    }

    [manager POST:API_FEEDBACK parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [hud hideTZHUD];
        if ([[responseObject objectForKey:@"code"] integerValue] == 0) {
            [SVProgressHUD showHint:@"谢谢反馈，我们在努力做到更好"];
            [self performSelector:@selector(dismissCtl) withObject:nil afterDelay:0.3];
        } else {
             if (self.isShowing) {
                [SVProgressHUD showHint:@"请求也是失败了"];
             }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [hud hideTZHUD];
        [SVProgressHUD showHint:@"呃～网络也是醉了"];
    }];
}

- (void)dismissCtl
{
    [self.navigationController popViewControllerAnimated:YES];
}
@end

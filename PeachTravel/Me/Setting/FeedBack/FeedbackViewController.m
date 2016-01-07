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

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = APP_PAGE_COLOR;
    self.navigationItem.title = @"意见反馈";
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"发送" style:UIBarButtonItemStylePlain target:self action:@selector(sendFeedback:)];
    
    CGFloat width = self.view.frame.size.width;
    
    UILabel *desc1 = [[UILabel alloc]initWithFrame:CGRectMake(5, 20.0+64, width-10, 20.0)];
    desc1.font = [UIFont systemFontOfSize:13.0];
    desc1.textColor = COLOR_TEXT_II;
    desc1.textAlignment = NSTextAlignmentLeft;
    desc1.text = @"你的意见和建议，是我们改进的动力";
    desc1.backgroundColor = [UIColor clearColor];
    [self.view addSubview:desc1];
    
    UIView *eborder = [[UIView alloc] initWithFrame:CGRectMake(5, 45+64, width - 10, 86.0)];
    eborder.backgroundColor = [UIColor whiteColor];
    eborder.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    eborder.layer.borderColor = COLOR_LINE.CGColor;
    eborder.layer.borderWidth = 1.0;
    eborder.layer.cornerRadius = 3.0;
    [self.view addSubview:eborder];
    
    UITextView *suggestion = [[UITextView alloc] initWithFrame:CGRectMake(5.0, 4, width - 10.0, 78.0)];
    suggestion.backgroundColor = [UIColor clearColor];
    suggestion.textColor = COLOR_TEXT_I;
    suggestion.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    suggestion.font = [UIFont systemFontOfSize:14.0];
    suggestion.scrollEnabled = YES;
    [eborder addSubview:suggestion];
    _contentEditor = suggestion;
}

- (void) showkeyboard
{
    [_contentEditor becomeFirstResponder];
}

- (void)goBack
{
    [_contentEditor resignFirstResponder];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
    [super touchesEnded:touches withEvent:event];
}

- (IBAction)sendFeedback:(id)sender
{
    [_contentEditor resignFirstResponder];
    [self feedback];
}

- (void)feedback
{
    NSString *contents = _contentEditor.text;
    NSString *trimText = [contents stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if ([trimText length] < 5) {
        [SVProgressHUD showHint:@"多说点什么吧"];
        return;
    }
    
    __weak typeof(FeedbackController *)weakSelf = self;
    TZProgressHUD *hud = [[TZProgressHUD alloc] init];
    [hud showHUDInViewController:weakSelf content:64];
    
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   trimText, @"body",
                                   nil];
    
    [LXPNetworking POST:API_FEEDBACK parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [hud hideTZHUD];
        if ([[responseObject objectForKey:@"code"] integerValue] == 0) {
            [SVProgressHUD showHint:@"意见已收到，非常感谢"];
            [self performSelector:@selector(dismissCtl) withObject:nil afterDelay:0.3];
        } else {
            if (self.isShowing) {
                [SVProgressHUD showHint:@"请求失败了"];
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [hud hideTZHUD];
        [SVProgressHUD showHint:@"呃～网络没找到"];
    }];
}

- (void)dismissCtl
{
    [self.navigationController popViewControllerAnimated:YES];
}
@end

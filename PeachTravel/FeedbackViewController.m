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

@interface FeedbackController () {
}

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
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.title = @"意见反馈";

    CGFloat width = self.view.frame.size.width;
    
    UILabel *desc1 = [[UILabel alloc]initWithFrame:CGRectMake(15.0, 74.0, width-30, 20.0)];
    desc1.font = [UIFont systemFontOfSize:13.0];
    desc1.textColor = UIColorFromRGB(0x5a5a5a);
    desc1.textAlignment = NSTextAlignmentCenter;
    desc1.text = @"快来说说你的意见吧~";
    desc1.backgroundColor = [UIColor clearColor];
    [self.view addSubview:desc1];
    
    UIView *eborder = [[UIView alloc] initWithFrame:CGRectMake(15., 94.0, width - 30.0, 86.0)];
    eborder.backgroundColor = [UIColor whiteColor];
    eborder.layer.borderColor = UIColorFromRGB(0xdbdbdb).CGColor;
    eborder.layer.borderWidth = 1.0;
    eborder.layer.cornerRadius = 4.0;
    [self.view addSubview:eborder];
    
    UITextView *suggestion = [[UITextView alloc] initWithFrame:CGRectMake(5.0, 5.0, width - 40.0, 86.0)];
    suggestion.backgroundColor = [UIColor clearColor];
    suggestion.textColor = UIColorFromRGB(0x313131);
    suggestion.font = [UIFont systemFontOfSize:14.0];
    suggestion.scrollEnabled = YES;
    [eborder addSubview:suggestion];
    contentEditor = suggestion;
    [contentEditor becomeFirstResponder];
    
    UIButton *send = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40., 40.)];
    [send setTitle:@"发送" forState:UIControlStateNormal];
    [send setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    send.titleLabel.font = [UIFont systemFontOfSize:14.];
    [send addTarget:self action:@selector(sendFeedback:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:send];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
    [super touchesEnded:touches withEvent:event];
}

- (IBAction)sendFeedback:(id)sender {
    [self feedback];
}

- (void) feedback {
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    NSString *contents = contentEditor.text;
    NSString *trimText = [contents stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if ([trimText length] < 1) {
        return;
    }
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   trimText, @"body",
                                   nil];
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [manager.requestSerializer setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [manager POST:nil parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
    }];
}

@end

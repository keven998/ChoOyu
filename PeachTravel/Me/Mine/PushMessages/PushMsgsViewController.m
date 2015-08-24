//
//  PushMsgsViewController.m
//  PeachTravel
//
//  Created by Luo Yong on 14/12/1.
//  Copyright (c) 2014年 com.aizou.www. All rights reserved.
//

#import "PushMsgsViewController.h"

@interface PushMsgsViewController ()
@property (weak, nonatomic) IBOutlet UIWebView *webView;

@end

@implementation PushMsgsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.navigationItem.title = @"我收到的消息";
    self.view.backgroundColor = APP_PAGE_COLOR;
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

//
//  GoodsDetailWebViewController.m
//  PeachTravel
//
//  Created by liangpengshuai on 2/2/16.
//  Copyright © 2016 com.aizou.www. All rights reserved.
//

#import "GoodsDetailWebViewController.h"

@interface GoodsDetailWebViewController ()

@end

@implementation GoodsDetailWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.webView = [[UIWebView alloc] initWithFrame: CGRectMake(0, 64, kWindowWidth, kWindowHeight-64-49)];
    self.webView.backgroundColor = APP_PAGE_COLOR;
    UIButton *closeBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, kWindowHeight-49, kWindowWidth, 49)];
    [closeBtn setBackgroundColor:[UIColor whiteColor]];
    [closeBtn setTitle:@"关闭" forState:UIControlStateNormal];
    [closeBtn setTitleColor:APP_THEME_COLOR forState:UIControlStateNormal];
    [closeBtn addTarget:self action:@selector(dismissCtl) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:closeBtn];
    
    UIView *spaceView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kWindowWidth, 0.5)];
    spaceView.backgroundColor = COLOR_LINE;
    [closeBtn addSubview:spaceView];
}

- (void)dismissCtl
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end

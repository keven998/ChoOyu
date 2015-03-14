//
//  SuperWebViewController.m
//  PeachTravel
//
//  Created by liangpengshuai on 12/13/14.
//  Copyright (c) 2014 com.aizou.www. All rights reserved.
//

#import "SuperWebViewController.h"
#import "NJKWebViewProgress.h"
#import "NJKWebViewProgressView.h"

@interface SuperWebViewController () <UIWebViewDelegate, NJKWebViewProgressDelegate> {
    UIWebView *_webView;
    
    NJKWebViewProgressView *_progressView;
    NJKWebViewProgress *_progressProxy;
}

@end

@implementation SuperWebViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = APP_PAGE_COLOR;
    self.navigationItem.title = _titleStr;
    
    _progressProxy = [[NJKWebViewProgress alloc] init];
    _progressProxy.webViewProxyDelegate = self;
    _progressProxy.progressDelegate = self;
    self.automaticallyAdjustsScrollViewInsets = NO; 
    CGFloat progressBarHeight = 3.0f;
    CGRect navigaitonBarBounds = self.navigationController.navigationBar.bounds;
    CGRect barFrame = CGRectMake(0, navigaitonBarBounds.size.height - progressBarHeight, navigaitonBarBounds.size.width, progressBarHeight);
    _progressView = [[NJKWebViewProgressView alloc] initWithFrame:barFrame];
    _progressView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    
    _webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 64, self.view.bounds.size.width, self.view.bounds.size.height-64)];
    [self.view addSubview:_webView];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:_urlStr]];
    _webView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _webView.delegate = _progressProxy;
    [_webView loadRequest:request];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 25, self.view.bounds.size.width, 32)];
    label.text = @"桃子旅行\n你最贴心的旅行助手";
    label.textColor = TEXT_COLOR_TITLE_HINT;
    label.font = [UIFont fontWithName:@"MicroSoftYahei" size:11.0];
    label.textAlignment = NSTextAlignmentCenter;
    label.numberOfLines = 2;
    [_webView addSubview:label];
    [_webView bringSubviewToFront:_webView.scrollView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar addSubview:_progressView];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [_progressView removeFromSuperview];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void) dealloc {
    _progressProxy.progressDelegate = nil;
    _progressProxy.webViewProxyDelegate = nil;
    _progressProxy = nil;
    _progressView = nil;
    [_webView removeFromSuperview];
    [_webView stopLoading];
    _webView.delegate = nil;
    _webView = nil;
}

/**
 *  重写父类的返回事件
 */
- (void)goBack
{
    if ([_webView canGoBack]) {
        [_webView goBack];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark - NJKWebViewProgressDelegate
-(void)webViewProgress:(NJKWebViewProgress *)webViewProgress updateProgress:(float)progress
{
    [_progressView setProgress:progress animated:YES];
}

@end

//
//  TravelNoteDetailViewController.m
//  PeachTravel
//
//  Created by liangpengshuai on 12/15/14.
//  Copyright (c) 2014 com.aizou.www. All rights reserved.
//

#import "TravelNoteDetailViewController.h"

@interface TravelNoteDetailViewController () <UIWebViewDelegate> {
    UIWebView *_webView;
    UIActivityIndicatorView *_activeView;
}
@end

@implementation TravelNoteDetailViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.title = _titleStr;
    
    _webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 64, self.view.bounds.size.width, self.view.bounds.size.height-64)];
    [self.view addSubview:_webView];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:_urlStr]];
    _webView.delegate = self;
    [_webView loadRequest:request];
    
    _activeView = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
    [_activeView setCenter:CGPointMake(self.view.bounds.size.width/2, self.view.bounds.size.height/2 - 64.0)];
    [_activeView setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
    [self.view addSubview:_activeView];
}

- (void) dealloc {
    [_webView stopLoading];
    _webView.delegate = nil;
    _webView = nil;
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    [_activeView stopAnimating];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    [_activeView stopAnimating];
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    [_activeView startAnimating];
}

- (void)setChatMessageModel:(TaoziChatMessageBaseViewController *)taoziMessageCtl
{
    taoziMessageCtl.messageId = _travelNoteId;
    taoziMessageCtl.messageImage = _travelNoteCover;
    taoziMessageCtl.messageDesc = _desc;
    taoziMessageCtl.messageName = _travelNoteTitle;
    taoziMessageCtl.chatType = TZChatTypeTravelNote;
}

@end

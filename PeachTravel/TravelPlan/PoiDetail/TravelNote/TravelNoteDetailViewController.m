//
//  TravelNoteDetailViewController.m
//  PeachTravel
//
//  Created by liangpengshuai on 12/15/14.
//  Copyright (c) 2014 com.aizou.www. All rights reserved.
//

#import "TravelNoteDetailViewController.h"
#import "RNGridMenu.h"
#import "NJKWebViewProgress.h"
#import "NJKWebViewProgressView.h"

@interface TravelNoteDetailViewController () <UIWebViewDelegate, RNGridMenuDelegate, NJKWebViewProgressDelegate> {
    UIWebView *_webView;
//    UIActivityIndicatorView *_activeView;
    
    NJKWebViewProgressView *_progressView;
    NJKWebViewProgress *_progressProxy;
}

@property (nonatomic, strong) RNGridMenu *av;

@end

@implementation TravelNoteDetailViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.title = _titleStr;
    
    UIButton *talkBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    [talkBtn setImage:[UIImage imageNamed:@"ic_favorite_unselected.png"] forState:UIControlStateNormal];
    [talkBtn setImage:[UIImage imageNamed:@"ic_favorite_selected.png"] forState:UIControlStateSelected];
    [talkBtn addTarget:self action:@selector(doFavorite:) forControlEvents:UIControlEventTouchUpInside];
    talkBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    UIBarButtonItem *moreBarItem = [[UIBarButtonItem alloc] initWithCustomView:talkBtn];
    
    UIButton *cb = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    [cb setImage:[UIImage imageNamed:@"ic_chat.png"] forState:UIControlStateNormal];
    [cb addTarget:self action:@selector(chat:) forControlEvents:UIControlEventTouchUpInside];
    cb.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    UIBarButtonItem *chatItem = [[UIBarButtonItem alloc] initWithCustomView:cb];
    self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:chatItem, moreBarItem, nil];
    
    _progressProxy = [[NJKWebViewProgress alloc] init];
    _progressProxy.webViewProxyDelegate = self;
    _progressProxy.progressDelegate = self;
    
    CGFloat progressBarHeight = 3.0f;
    CGRect navigaitonBarBounds = self.navigationController.navigationBar.bounds;
    CGRect barFrame = CGRectMake(0, navigaitonBarBounds.size.height - progressBarHeight, navigaitonBarBounds.size.width, progressBarHeight);
    _progressView = [[NJKWebViewProgressView alloc] initWithFrame:barFrame];
    _progressView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    
    _webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 64, self.view.bounds.size.width, self.view.bounds.size.height-64)];
    [self.view addSubview:_webView];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:_urlStr]];
    _webView.delegate = _progressProxy;
    [_webView loadRequest:request];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 25, self.view.bounds.size.width, 32)];
    label.text = @"桃子旅行\n你贴心的旅行助手";
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

- (void) dealloc {
    [_webView stopLoading];
    _webView.delegate = nil;
    _webView = nil;
    _progressProxy.progressDelegate = nil;
    _progressProxy.webViewProxyDelegate = nil;
    _progressProxy = nil;
    _progressView = nil;
}


- (void)gridMenuWillDismiss:(RNGridMenu *)gridMenu
{
    _av = nil;
}

- (IBAction)doFavorite:(id)sender {
    UIButton *bi = sender;
    bi.selected = !bi.selected;
    [self asyncFavorite:_travelNoteId poiType:@"travelNote" isFavorite:bi.selected completion:^(BOOL isSuccess) {
        if (!isSuccess) {
            bi.selected = !bi.selected;
        } else {
//            bi.selected = !bi.selected;
        }
    }];
}

- (void)setChatMessageModel:(TaoziChatMessageBaseViewController *)taoziMessageCtl
{
    taoziMessageCtl.messageId = _travelNoteId;
    taoziMessageCtl.messageImage = _travelNoteCover;
    taoziMessageCtl.messageDesc = _desc;
    taoziMessageCtl.messageName = _travelNoteTitle;
    taoziMessageCtl.messageDetailUrl = _urlStr;
    taoziMessageCtl.chatType = TZChatTypeTravelNote;
}

#pragma mark - NJKWebViewProgressDelegate
-(void)webViewProgress:(NJKWebViewProgress *)webViewProgress updateProgress:(float)progress
{
    [_progressView setProgress:progress animated:YES];
//    self.title = [_webView stringByEvaluatingJavaScriptFromString:@"document.title"];
}

@end

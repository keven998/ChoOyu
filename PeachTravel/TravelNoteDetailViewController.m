//
//  TravelNoteDetailViewController.m
//  PeachTravel
//
//  Created by liangpengshuai on 12/15/14.
//  Copyright (c) 2014 com.aizou.www. All rights reserved.
//

#import "TravelNoteDetailViewController.h"
#import "RNGridMenu.h"

@interface TravelNoteDetailViewController () <UIWebViewDelegate, RNGridMenuDelegate> {
    UIWebView *_webView;
    UIActivityIndicatorView *_activeView;
}

@property (nonatomic, strong) RNGridMenu *av;

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
    
    UIBarButtonItem * moreBarItem = [[UIBarButtonItem alloc]initWithTitle:nil style:UIBarButtonItemStyleBordered target:self action:@selector(moreAction:)];
    [moreBarItem setImage:[UIImage imageNamed:@"ic_more.png"]];
    [moreBarItem setImageInsets:UIEdgeInsetsMake(0, 10, 0, 0)];
    self.navigationItem.rightBarButtonItem = moreBarItem;
}

- (void) dealloc {
    [_webView stopLoading];
    _webView.delegate = nil;
    _webView = nil;
}

- (IBAction)moreAction:(UIButton *)sender
{
    NSInteger numberOfOptions = 2;
    NSArray *items = @[
                       [[RNGridMenuItem alloc] initWithImage:[UIImage imageNamed:@"ic_new_talk"] title:@"桃Talk"],
                       [[RNGridMenuItem alloc] initWithImage:[UIImage imageNamed:@"ic_add_favorite.png"] title:@"收藏"],
                       ];
    
    _av = [[RNGridMenu alloc] initWithItems:[items subarrayWithRange:NSMakeRange(0, numberOfOptions)]];
    _av.backgroundColor = [UIColor clearColor];
    _av.delegate = self;
    [_av showInViewController:self.navigationController center:CGPointMake(self.view.bounds.size.width/2.f, self.view.bounds.size.height/2.f)];
}

#pragma mark - RNGridMenuDelegate

- (void)gridMenu:(RNGridMenu *)gridMenu willDismissWithSelectedItem:(RNGridMenuItem *)item atIndex:(NSInteger)itemIndex
{
    if (itemIndex == 0) {
        [self chat:nil];
    }
    if (itemIndex == 1) {
        [self asyncFavorite:_travelNoteId poiType:@"travelNote" isFavorite:YES completion:^(BOOL isSuccess) {
            if (isSuccess) {

            }
        }];
    }
    _av = nil;
}

- (void)gridMenuWillDismiss:(RNGridMenu *)gridMenu
{
    _av = nil;
}

#pragma mark - WebViewDelegate

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

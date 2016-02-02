//
//  SuperWebViewController.h
//  PeachTravel
//
//  Created by liangpengshuai on 12/13/14.
//  Copyright (c) 2014 com.aizou.www. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SVWebViewController.h"

@interface SuperWebViewController : TZViewController <UIWebViewDelegate>

@property (nonatomic, strong) UIWebView *webView;
@property (nonatomic, copy) NSString *urlStr;
@property (nonatomic, copy) NSString *titleStr;

//开始加载URL Request
- (void)didStartLoadURLRequest:(NSURLRequest *)request;

@end


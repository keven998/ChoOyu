//
//  TZSchemeManager.m
//  TestScheme
//
//  Created by liangpengshuai on 12/10/15.
//  Copyright © 2015 com.lps. All rights reserved.
//

#import "TZSchemeManager.h"
#import "JLRoutes.h"
#import "GoodsDetailViewController.h"
#import "NSString+UrlEncodeing.h"
#import "SuperWebViewController.h"
#import "NSURL+TZURL.h"

@interface TZSchemeManager ()

@property (nonatomic, copy) void (^handleCompletionBlock)(UIViewController *controller, NSString *uri);

@end

@implementation TZSchemeManager

- (instancetype)init
{
    self = [super init];
    if (self) {
        [JLRoutes addRoute:@"/marketplace/commodities/:commoditeId" handler:^BOOL(NSDictionary *parameters) {
            NSInteger commoditeId = [parameters[@"commoditeId"] integerValue];
            if (_handleCompletionBlock) {
                GoodsDetailViewController *goodsDetailCtl = [[GoodsDetailViewController alloc] init];
                goodsDetailCtl.goodsId = commoditeId;
                _handleCompletionBlock(goodsDetailCtl, nil);
            }
            return YES;
        }];
    }
    return self;
}

- (void)handleUri:(NSString *)urlStr handleUriCompletionBlock:(void (^)(UIViewController *, NSString *))completionBlock
{
    self.handleCompletionBlock = completionBlock;
    NSString *safeUrl = [urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *URL = [NSURL URLWithString:safeUrl];

    if ([URL.scheme isEqualToString:@"http"]) {
        SuperWebViewController *webView = [[SuperWebViewController alloc] init];
        webView.urlStr = URL.absoluteString;
        NSString *title = [URL parameterForKey:@"title"];
        webView.titleStr = [title stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        _handleCompletionBlock(webView, URL.absoluteString);
    } else {
        [JLRoutes routeURL:URL];
    }
}



@end

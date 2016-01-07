//
//  TZPayManager.m
//  PeachTravel
//
//  Created by liangpengshuai on 12/15/15.
//  Copyright © 2015 com.aizou.www. All rights reserved.
//

#import "TZPayManager.h"
#import "WXApi.h"
#import <AlipaySDK/AlipaySDK.h>

NSString *const kOrderPayResultNoti = @"kOrderPayResultNoti";

@interface TZPayManager ()
@property (nonatomic) NSString *as;

@property (nonatomic, copy) void (^payCompletionBlock)(BOOL isSuccess, NSString *error);

@end

@implementation TZPayManager

- (instancetype)init
{
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orderPayResult:) name:kOrderPayResultNoti object:nil];
        
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

//订单支付后的回调  userInfo: 结构体 result = {@"code" : 0    (0成功，其余失败)
//                                         @"error" : 错误原因
                                        //}
- (void)orderPayResult:(NSNotification *)noti
{
    NSInteger code = [[[noti.userInfo objectForKey:@"result"] objectForKey:@"code"] integerValue];
    if (code == 0) {
        if (_payCompletionBlock) {
            _payCompletionBlock(YES, nil);
        }
    } else {
        if (_payCompletionBlock) {
            if ([[noti.userInfo objectForKey:@"result"] objectForKey:@"error"]) {
                _payCompletionBlock(NO, [[noti.userInfo objectForKey:@"result"] objectForKey:@"error"]);

            } else {
                _payCompletionBlock(NO, @"支付失败");
            }
        }
    }
    _payCompletionBlock = nil;
}

- (void)asyncPayOrder:(NSInteger)orderId payPlatform:(TZPayPlatform)payPlatform completionBlock:(void (^)(BOOL, NSString *))completion
{
    _payCompletionBlock = completion;

    NSString *platFormDesc = @"";
    if (payPlatform == kWeichatPay) {
        platFormDesc = @"wechat";
    } else if (payPlatform == kAlipay) {
        platFormDesc = @"alipay";
    }
    
    NSString *url = [NSString stringWithFormat:@"%@/%ld/payments", API_ORDERS, orderId];

    NSDictionary *params = @{
                             @"provider": platFormDesc
                             };
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    [LXPNetworking POST:url parameters: params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"***对订单进行支付接口: %@", operation);
        NSInteger code = [[responseObject objectForKey:@"code"] integerValue];
        if (code == 0) {
            if (payPlatform == kWeichatPay) {
                [self sendWechatPayRequest:[responseObject objectForKey:@"result"]];
            } else {
                [self sendAliPayRequest:[[responseObject objectForKey:@"result"] objectForKey:@"requestString"]];
            }
            
        } else {
            completion(NO, @"支付失败");
            _payCompletionBlock = nil;
            
        }
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        completion(NO, @"支付失败");
        _payCompletionBlock = nil;
        
    }];
}

- (void)sendWechatPayRequest:(NSDictionary *)payInfo
{
    PayReq *request = [[PayReq alloc] init];
    request.openID = [payInfo objectForKey:@"appid"];
    request.partnerId = [payInfo objectForKey:@"partnerid"];
    request.prepayId= [payInfo objectForKey:@"prepayid"];
    request.package = [payInfo objectForKey:@"package"];
    request.nonceStr= [payInfo objectForKey:@"noncestr"];
    request.timeStamp= (UInt32)[[payInfo objectForKey:@"timestamp"] longLongValue];
    request.sign= [payInfo objectForKey:@"sign"];
    [WXApi sendReq: request];
}

- (void)sendAliPayRequest:(NSString *)payInfo
{
    [[AlipaySDK defaultService] payOrder:payInfo fromScheme:@"lvxingpai" callback:^(NSDictionary *resultDic) {
        NSString *status=[NSString stringWithFormat:@"%@",resultDic[@"resultStatus"]];
        if ([status isEqualToString:@"9000"]) {
            [SVProgressHUD showSuccessWithStatus:@"支付成功"];
            if (_payCompletionBlock) {
                _payCompletionBlock(YES, nil);
            }
        } else{
            if (_payCompletionBlock) {
                _payCompletionBlock(NO, @"支付失败");
            }
        }
        _payCompletionBlock = nil;
    }];

}


@end

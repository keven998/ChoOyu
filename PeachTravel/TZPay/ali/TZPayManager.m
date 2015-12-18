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

@implementation TZPayManager

- (void)asyncPayOrder:(NSInteger)orderId payPlatform:(TZPayPlatform)payPlatform completionBlock:(void (^)(BOOL, NSString *))completion
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    AppUtils *utils = [[AppUtils alloc] init];
    
    [manager.requestSerializer setValue:utils.appVersion forHTTPHeaderField:@"Version"];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"iOS %@",utils.systemVersion] forHTTPHeaderField:@"Platform"];
    AccountManager *accountManager = [AccountManager shareAccountManager];
    if ([accountManager isLogin]) {
        [manager.requestSerializer setValue:[NSString stringWithFormat:@"%ld", (long)accountManager.account.userId] forHTTPHeaderField:@"UserId"];
    }
    [manager.requestSerializer setValue:@"application/vnd.lvxingpai.v1+json" forHTTPHeaderField:@"Accept"];
    [manager.requestSerializer setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    NSString *platFormDesc = @"";
    if (payPlatform == kWeichatPay) {
        platFormDesc = @"wechat";
    } else if (payPlatform == kAlipay) {
        platFormDesc = @"alipay";
    }
    
//    NSString *url = [NSString stringWithFormat:@"%@/%ld/payments", @"http://182.92.168.171:11219/marketplace/orders", orderId];
    NSString *url = [NSString stringWithFormat:@"%@/%ld/payments", API_ORDERS, orderId];

    NSDictionary *params = @{
                             @"provider": platFormDesc
                             };
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    [manager POST:url parameters: params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"***对订单进行支付接口: %@", operation);
        NSInteger code = [[responseObject objectForKey:@"code"] integerValue];
        if (code == 0) {
            if (payPlatform == kWeichatPay) {
                [self sendWechatPayRequest:[responseObject objectForKey:@"result"]];
            } else {
                [self sendAliPayRequest:[[responseObject objectForKey:@"result"] objectForKey:@"requestString"]];
            }
            
        } else {
            completion(NO, nil);
            
        }
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        completion(NO, nil);
        
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
        if ([status isEqualToString:@"9000"])
        {
            [SVProgressHUD showSuccessWithStatus:@"支付成功"];

        }
        else{
            [SVProgressHUD showErrorWithStatus:@"支付失败，请稍后再试"];
            
        }
    }];

}


@end

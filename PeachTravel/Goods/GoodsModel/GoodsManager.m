//
//  GoodsManager.m
//  PeachTravel
//
//  Created by liangpengshuai on 11/12/15.
//  Copyright © 2015 com.aizou.www. All rights reserved.
//

#import "GoodsManager.h"
#import "GoodsDetailModel.h"

@implementation GoodsManager

//TODO: 实现真正的网络加载数据
+ (void)asyncLoadGoodsOfCity:(NSString *)cityId completionBlock:(void (^)(BOOL, NSArray *))completion
{
    NSMutableArray *retArray = [[NSMutableArray alloc] init];
    for (int i=0; i<10; i++) {
        GoodsDetailModel *goodsModel = [[GoodsDetailModel alloc] init];
        goodsModel.goodsId = @"123456";
        goodsModel.goodsName = @"韩国首尔5日自由行·经典热销 限时0元赠接送机";
        goodsModel.goodsDesc = @" 五日行程畅销产品，赠送免费接送机，不进购物店。";
        TaoziImage *image = [[TaoziImage alloc] init];
        image.imageUrl = @"http://images.taozilvxing.com/28c2d1ef35c12100e99fecddb63c436a?imageView2/2/w/1200";
        goodsModel.image = image;
        goodsModel.rating = 0.7;
        goodsModel.saleCount = 100;
        goodsModel.primePrice = 12345;
        goodsModel.currentPrice = 1234;
        goodsModel.store = [[StoreDetailModel alloc] init];
        goodsModel.store.storeName = @"三亚大海哇";
        goodsModel.tags = @[@"货到付款", @"双十一"];
        GoodsPackageModel *package = [[GoodsPackageModel alloc] init];
        package.primePrice = 1234;
        package.currentPrice = 2345;
        package.packageName = @"我的名字是套餐一";
        package.packageDesc = @"我是一个套餐，简简单单";
        goodsModel.packages = @[package, package, package];
        [retArray addObject: goodsModel];
    }
    completion(YES, retArray);
}

+ (void)asyncLoadRecommendGoodsWithCompletionBlock:(void (^)(BOOL isSuccess, NSArray<NSDictionary *> *goodsList))completion
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    AppUtils *utils = [[AppUtils alloc] init];
    [manager.requestSerializer setValue:utils.appVersion forHTTPHeaderField:@"Version"];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"iOS %@",utils.systemVersion] forHTTPHeaderField:@"Platform"];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [manager.requestSerializer setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    [manager GET:API_GET_RECOMMEND parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSInteger code = [[responseObject objectForKey:@"code"] integerValue];
        if (code == 0) {
            NSMutableArray *retArray = [[NSMutableArray alloc] init];
            for (NSDictionary *dic in [responseObject objectForKey:@"result"]) {
                NSMutableDictionary *retDic = [[NSMutableDictionary alloc] init];
                [retDic setObject:[dic objectForKey:@"topicType"] forKey:@"title"];
                NSMutableArray *goodsList = [[NSMutableArray alloc] init];
                for (NSDictionary *goodsDic in [dic objectForKey:@"commodities"]) {
                    GoodsDetailModel *goods = [[GoodsDetailModel alloc] initWithJson:goodsDic];
                    [goodsList addObject:goods];
                }
                [retDic setObject:goodsList forKey:@"goodsList"];
                [retArray addObject:retDic];
            }
            completion(YES, retArray);
            
        } else {
            [SVProgressHUD showHint:HTTP_FAILED_HINT];
            completion(NO, nil);
        }
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [SVProgressHUD showHint:HTTP_FAILED_HINT];
        completion(NO, nil);
        
    }];

}

@end

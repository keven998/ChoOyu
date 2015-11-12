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
        [retArray addObject: goodsModel];
    }
    completion(YES, retArray);
}

@end

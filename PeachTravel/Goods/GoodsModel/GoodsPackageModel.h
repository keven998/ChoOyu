//
//  GoodsPackageModel.h
//  PeachTravel
//
//  Created by liangpengshuai on 11/12/15.
//  Copyright © 2015 com.aizou.www. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GoodsPackageModel : NSObject

@property (nonatomic, copy) NSString *packageId;
@property (nonatomic, copy) NSString *packageName;
@property (nonatomic, copy) NSString *packageDesc;
@property (nonatomic) float currentPrice;
@property (nonatomic) float primePrice;

//套餐开始时间
@property (nonatomic) NSTimeInterval startPriceTimeInterval;
@property (nonatomic, strong) NSDate *startPriceDate;

//套餐终止时间
@property (nonatomic) NSTimeInterval endPriceTimeInterval;
@property (nonatomic, strong) NSDate *endPriceDate;


/******  套餐价格区间 具体格式为
 [
    {
        price: 23,
        timeRange: [
            1449100800000,
            1450396800000
            ]
    },
    {
        price: 32,
        timeRange: [
            1450483200000,
            1450915200000
        ]
    }
 ],
 */
@property (nonatomic, strong) NSArray *priceList;
- (id)initWithJson:(id)json;

@end


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

@end

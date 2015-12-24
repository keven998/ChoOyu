//
//  StoreDetailModel.h
//  PeachTravel
//
//  Created by liangpengshuai on 11/12/15.
//  Copyright © 2015 com.aizou.www. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CityDestinationPoi.h"
#import "PeachTravel-swift.h"

@interface StoreDetailModel : NSObject

@property (nonatomic) NSInteger storeId;
@property (nonatomic, copy) NSString *storeName;
@property (nonatomic, strong) NSArray<NSString *> *languages;      //语言
@property (nonatomic, strong) NSArray<NSString *> *serviceTags;    //服务标签
@property (nonatomic, strong) NSArray<NSString *> *qualifications;           //商家资质 (认证商家等)
@property (nonatomic, strong) CityDestinationPoi *city;

@property (nonatomic, strong) BusinessMoel *business;

- (id)initWithJson:(id)json;

@end

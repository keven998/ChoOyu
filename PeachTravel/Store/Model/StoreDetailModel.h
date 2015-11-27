//
//  StoreDetailModel.h
//  PeachTravel
//
//  Created by liangpengshuai on 11/12/15.
//  Copyright © 2015 com.aizou.www. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface StoreDetailModel : NSObject

@property (nonatomic) NSInteger storeId;
@property (nonatomic, copy) NSString *storeName;
@property (nonatomic, strong) NSArray *qualifications;

- (id)initWithJson:(id)json;

@end

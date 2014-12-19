//
//  OperationData.h
//  PeachTravel
//
//  Created by liangpengshuai on 11/20/14.
//  Copyright (c) 2014 com.aizou.www. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OperationData : NSObject

@property (nonatomic, copy) NSString *imageUrl;
@property (nonatomic, copy) NSString *content;
@property (nonatomic, copy) NSString *linkUrl;

- (id)initWithJson:(id)json;
@end

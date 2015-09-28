//
//  TaoziImage.h
//  PeachTravel
//
//  Created by liangpengshuai on 11/17/14.
//  Copyright (c) 2014 com.aizou.www. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TaoziImage : NSObject<NSCoding>

@property (nonatomic ,copy) NSString *imageUrl;
@property (nonatomic, copy) NSString *imageDesc;


- (id)initWithJson:(id)json;

@end

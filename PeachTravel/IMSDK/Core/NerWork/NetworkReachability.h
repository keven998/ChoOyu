//
//  NetworkReachability.h
//  PeachTravel
//
//  Created by liangpengshuai on 5/26/15.
//  Copyright (c) 2015 com.aizou.www. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Reachability.h"

@interface NetworkReachability : NSObject

@property (nonatomic) Reachability *hostReachability;

+ (AccountManager *)shareInstance;

@end

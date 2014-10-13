//
//  AppUtils.h
//  lvxingpai
//
//  Created by Luo Yong on 14-6-24.
//  Copyright (c) 2014年 aizou. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AppUtils : NSObject

@property (nonatomic, assign) long long currentTime;
@property (nonatomic, copy) NSString *appVersion;
@property (nonatomic, copy) NSString *unid;

@property (nonatomic, copy) NSString *systemVersion;
@property (nonatomic, copy) NSString *deviceName;

@end

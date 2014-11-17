//
//  SpotDetailBean.h
//  lvxingpai
//
//  Created by Luo Yong on 14-6-24.
//  Copyright (c) 2014年 aizou. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SpotDetailBean : NSObject

@property (nonatomic, strong) NSArray *pictures;

@property (nonatomic, copy) NSString *spotId;
@property (nonatomic, assign) NSInteger score;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, assign) NSInteger favorCnt;
@property (nonatomic, assign) NSInteger checkinCnt;
@property (nonatomic, assign) NSString *fee;
@property (nonatomic, copy) NSString *feeDesc;
@property (nonatomic, copy) NSString *bestTime;
@property (nonatomic, copy) NSString *costTime;
@property (nonatomic, copy) NSString *openTime;

@property (nonatomic, copy) NSString *infoUrl;
@property (nonatomic, copy) NSString *tipsUrl;
@property (nonatomic, copy) NSString *warningUrl;

@property (nonatomic, assign) double latitude;
@property (nonatomic, assign) double longitude;
@property (nonatomic, strong) NSArray *tags;
@property (nonatomic, copy) NSString *intro;
@property (nonatomic, copy) NSString *locationDesc;

@property (nonatomic, assign) BOOL traffic;
@property (nonatomic, assign) BOOL tips;

- (id) initWithData:(id)json;

- (NSData *)toData;

@end

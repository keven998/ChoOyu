//
//  UploadUserPhotoStatus.h
//  PeachTravel
//
//  Created by liangpengshuai on 1/22/16.
//  Copyright © 2016 com.aizou.www. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UploadUserPhotoStatus : NSObject

@property (nonatomic) BOOL isBegin;
@property (nonatomic) BOOL isFinish;
@property (nonatomic) BOOL isFailure;
@property (nonatomic) BOOL isSuccess;
@property (nonatomic) CGFloat uploadProgressValue;


@end

//
//  CommonPoiDetailViewController.h
//  PeachTravel
//
//  Created by liangpengshuai on 11/22/14.
//  Copyright (c) 2014 com.aizou.www. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PoiDetailSuperViewController.h"

@interface CommonPoiDetailViewController : PoiDetailSuperViewController

@property (nonatomic, copy) NSString *poiId;

@property (nonatomic) TZPoiType poiType;

@end

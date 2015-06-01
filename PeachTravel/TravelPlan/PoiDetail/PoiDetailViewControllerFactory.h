//
//  PoiDetailViewControllerFactory.h
//  PeachTravel
//
//  Created by liangpengshuai on 3/18/15.
//  Copyright (c) 2015 com.aizou.www. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CommonPoiDetailViewController.h"

@interface PoiDetailViewControllerFactory : NSObject

+ (CommonPoiDetailViewController *)poiDetailViewControllerWithPoiType:(TZPoiType)poiType;

@end

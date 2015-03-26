//
//  FootprintMapViewController.h
//  PeachTravel
//
//  Created by liangpengshuai on 3/26/15.
//  Copyright (c) 2015 com.aizou.www. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FootprintMapViewController : UIViewController

/**
 *  在地图上添加一个标记的点
 *
 *  @param location
 */
- (void)addPoint:(CLLocation *)location;

/**
 *  在地图上移除一个标记的点
 *
 *  @param location
 */
- (void)removePoint:(CLLocation *)location;

@end

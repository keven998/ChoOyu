//
//  FootprintMapViewController.h
//  PeachTravel
//
//  Created by liangpengshuai on 3/26/15.
//  Copyright (c) 2015 com.aizou.www. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FootprintMapViewController : UIViewController

@property (nonatomic, strong) NSArray *dataSource;

- (void)selectPointAtIndex:(NSInteger)index;

@end

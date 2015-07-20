//
//  FootPrintViewController.h
//  PeachTravel
//
//  Created by liangpengshuai on 3/26/15.
//  Copyright (c) 2015 com.aizou.www. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Destinations.h"

@protocol updataTracksDelegate <NSObject>

- (void)updataTracks:(NSInteger) country
               citys:(NSInteger) city
            trackStr:(NSString *) track;

@end

@interface FootPrintViewController : UIViewController

//要看攻略人的 userid
@property (nonatomic) NSInteger userId;

@property (nonatomic, weak) id<updataTracksDelegate> delegate;

@end

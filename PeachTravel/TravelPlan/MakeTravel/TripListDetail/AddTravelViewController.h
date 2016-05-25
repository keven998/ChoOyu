//
//  AddTravelViewController.h
//  PeachTravel
//
//  Created by liangpengshuai on 5/19/16.
//  Copyright © 2016 com.aizou.www. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PlanTravelModel.h"

@protocol AddTravelViewControllerDelegate <NSObject>

- (void)endEditTravel:(PlanTravelModel *)model;

@end

@interface AddTravelViewController : UIViewController
@property (nonatomic, weak) id<AddTravelViewControllerDelegate> delegate;

@end

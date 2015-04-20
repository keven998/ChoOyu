//
//  MakePlanViewController.h
//  PeachTravel
//
//  Created by liangpengshuai on 11/18/14.
//  Copyright (c) 2014 com.aizou.www. All rights reserved.
//

#import "CityDestinationPoi.h"
#import "Destinations.h"
#import "TZSegmentedViewController.h"

@protocol UpdateDestinationsDelegate <NSObject>

- (void)updateDestinations:(NSArray *)destinations;

@end

@interface MakePlanViewController : TZSegmentedViewController

@property (nonatomic, strong) UICollectionView *selectPanel;
@property (nonatomic, strong) Destinations *destinations;
@property (nonatomic, weak) id <UpdateDestinationsDelegate> myDelegate;

/**
 *  当点击下一步的时候是不是只更新目的地列表。因为如果从三账单进来的话，只需要更新目的地列表就好
 */
@property (nonatomic) BOOL shouldOnlyChangeDestinationWhenClickNextStep;

- (void)hideDestinationBar;
- (void)showDestinationBar;

@end
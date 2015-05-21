//
//  ScreeningViewController.h
//  PeachTravel
//
//  Created by dapiao on 15/4/28.
//  Copyright (c) 2015年 com.aizou.www. All rights reserved.
//

#import "TZSegmentedViewController.h"

@protocol doScreenning <NSObject>

- (void)screeningTravelers:(NSArray *)destination;

@end



@interface ScreeningViewController : TZSegmentedViewController
@property (nonatomic, strong) UICollectionView *selectPanel;
@property (nonatomic, copy) NSMutableArray *selectedCityArray;
@property (nonatomic, weak) id <doScreenning> delegate;
-(void)doScreening;
@end

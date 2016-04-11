//
//  PTMakeSelectCityViewController.h
//  PeachTravel
//
//  Created by liangpengshuai on 11/19/14.
//  Copyright (c) 2014 com.aizou.www. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Destinations.h"
#import "MakePlanViewController.h"

@protocol PTMakeSelectCityViewControllerDelegate <NSObject>

- (void)didSelectCitys:(NSArray *)cityList;

@end

@interface PTMakeSelectCityViewController : TZViewController

@property (nonatomic, strong) UICollectionView *selectPanel;

@property (nonatomic, strong) NSArray *selectCitys;
@property (nonatomic, weak) id<PTMakeSelectCityViewControllerDelegate>delegate;

@end

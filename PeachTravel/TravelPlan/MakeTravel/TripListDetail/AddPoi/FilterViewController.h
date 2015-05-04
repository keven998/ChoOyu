//
//  FilterViewController.h
//  PeachTravel
//
//  Created by Luo Yong on 15/4/24.
//  Copyright (c) 2015年 com.aizou.www. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FilterViewController : UIViewController

@property (nonatomic, strong) NSArray *contentItems;

@property (nonatomic, assign) NSInteger selectedCategoryIndex;
@property (nonatomic, assign) NSInteger selectedCityIndex;

@end

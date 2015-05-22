//
//  FilterViewController.h
//  PeachTravel
//
//  Created by Luo Yong on 15/4/24.
//  Copyright (c) 2015年 com.aizou.www. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol didSelectedDelegate <NSObject>

-(void)didSelectedcityIndex:(NSIndexPath *)cityindexPath
              categaryIndex:(NSIndexPath *)categaryIndexPath;

@end

@interface FilterViewController : UIViewController

@property (nonatomic, strong) NSArray *contentItems;

@property (nonatomic, strong) NSIndexPath *selectedCategoryIndex;
@property (nonatomic, strong) NSIndexPath *selectedCityIndex;

@property (nonatomic,weak) id<didSelectedDelegate> delegate;
@end

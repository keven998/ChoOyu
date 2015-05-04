//
//  CategoryTableViewCell.h
//  PeachTravel
//
//  Created by Luo Yong on 15/4/24.
//  Copyright (c) 2015年 com.aizou.www. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CategoryTableViewCell : UITableViewCell

@property (nonatomic, strong) NSArray *selectedItems;
@property (nonatomic, strong) UISegmentedControl *segmentControl;

@end

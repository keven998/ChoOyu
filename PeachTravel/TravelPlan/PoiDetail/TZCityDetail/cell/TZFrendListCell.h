//
//  TZFrendListCell.h
//  TZCityDetail
//
//  Created by 冯宁 on 15/9/19.
//  Copyright © 2015年 PeachTravel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PeachTravel-swift.h"

@interface TZFrendListCell : UITableViewCell

@property (nonatomic, strong) ExpertModel* model;

@property (nonatomic, strong) UILabel* titleLabel;
@property (nonatomic, strong) UICollectionView* tagCollectionView;


@end

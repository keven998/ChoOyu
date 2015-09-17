//
//  GuiderProfileTourViewCell.h
//  PeachTravel
//
//  Created by 王聪 on 8/28/15.
//  Copyright (c) 2015 com.aizou.www. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ExpertTourView.h"
@class FrendModel;
@interface GuiderProfileTourViewCell : UITableViewCell

@property (weak, nonatomic) UILabel *footprintCount;

@property (weak, nonatomic) UILabel *planCount;

@property (weak, nonatomic) ExpertTourView *footprintBtn;

@property (weak, nonatomic) ExpertTourView *planBtn;

@property (weak, nonatomic) ExpertTourView *tourBtn;

@property (weak, nonatomic) UILabel *tourTitle;

@property (weak, nonatomic) UILabel *tourCount;

@property (nonatomic, strong) FrendModel *userInfo;

@end

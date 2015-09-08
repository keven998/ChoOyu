//
//  MineProfileTourViewCell.h
//  PeachTravel
//
//  Created by 王聪 on 15/9/6.
//  Copyright (c) 2015年 com.aizou.www. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ExpertTourView.h"

@interface MineProfileTourViewCell : UITableViewCell

@property (weak, nonatomic) UILabel *footprintCount;

@property (weak, nonatomic) UILabel *planCount;

@property (weak, nonatomic) ExpertTourView *footprintBtn;

@property (weak, nonatomic) ExpertTourView *planBtn;

@property (weak, nonatomic) ExpertTourView *tourBtn;

@property (weak, nonatomic) UILabel *tourTitle;

@property (weak, nonatomic) UILabel *tourCount;

@property (nonatomic, strong) AccountModel *userInfo;

@property (nonatomic, strong) FrendModel *otherUserinfo;

@end

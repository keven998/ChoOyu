//
//  MineDetailInfoCell.h
//  PeachTravel
//
//  Created by 王聪 on 8/31/15.
//  Copyright (c) 2015 com.aizou.www. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GuiderProfileImageView, AccountModel, GuiderProfileHeaderView;

@interface MineDetailInfoCell : UITableViewCell

@property (nonatomic, strong) GuiderProfileImageView *profileHeader;

@property (nonatomic, strong) AccountModel *accountModel;

@property (nonatomic, weak) UILabel *name;

@property (nonatomic, strong) GuiderProfileHeaderView *profileView;

+ (id)guiderDetailInfo;

@end

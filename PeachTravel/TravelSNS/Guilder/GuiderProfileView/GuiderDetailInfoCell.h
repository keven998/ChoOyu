//
//  GuiderDetailInfoCell.h
//  PeachTravel
//
//  Created by 王聪 on 8/28/15.
//  Copyright (c) 2015 com.aizou.www. All rights reserved.
//

#import <UIKit/UIKit.h>
@class GuiderProfileImageView, FrendModel, GuiderProfileHeaderView;

@interface GuiderDetailInfoCell : UITableViewCell

@property (nonatomic, strong) GuiderProfileImageView *profileHeader;

@property (nonatomic, strong) FrendModel *userInfo;

@property (nonatomic, weak) UILabel *name;

@property (nonatomic, strong) GuiderProfileHeaderView *profileView;

@property (nonatomic, strong) NSArray *collectionArray;

+ (id)guiderDetailInfo;

@end

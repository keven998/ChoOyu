//
//  PoisOfCityTableViewCell.h
//  PeachTravel
//
//  Created by liangpengshuai on 11/25/14.
//  Copyright (c) 2014 com.aizou.www. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EDStarRating.h"

@interface PoisOfCityTableViewCell : UITableViewCell
@property (nonatomic) BOOL shouldEdit;

@property (weak, nonatomic) IBOutlet UIButton *naviBtn;
@property (weak, nonatomic) IBOutlet UIButton *addBtn;
@property (weak, nonatomic) IBOutlet UIButton *pAddBtn;

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *distanceLabel;

@property (weak, nonatomic) IBOutlet UIImageView *headerImageView;
@property (weak, nonatomic) IBOutlet UILabel *propertyLabel;
@property (weak, nonatomic) IBOutlet EDStarRating *ratingView;
@property (weak, nonatomic) IBOutlet UILabel *rankingLabel;
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;
@property (weak, nonatomic) IBOutlet UIView *bkgFrame;

@property (nonatomic) BOOL hideActionBtn;

/**
 *  是否是我身边的 cell
 */
@property (nonatomic) BOOL isNearByCell;

/**
 *  添加状态的是否添加
 */
@property (nonatomic) BOOL isAdded;

@property (nonatomic, strong) SuperPoi *poi;


@end

//
//  CommonPoiListTableViewCell.h
//  PeachTravel
//
//  Created by liangpengshuai on 11/24/14.
//  Copyright (c) 2014 com.aizou.www. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TripDetail.h"
#import "EDStarRating.h"

@interface CommonPoiListTableViewCell : UITableViewCell

@property (nonatomic, strong) SuperPoi *tripPoi;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *labCons;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *valueCons;

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *headerImageView;
@property (weak, nonatomic) IBOutlet UILabel *propertyLabel;
@property (weak, nonatomic) IBOutlet UILabel *valueLabel;
@property (weak, nonatomic) IBOutlet EDStarRating *ratingView;

@property (weak, nonatomic) IBOutlet UIButton *cellAction;

@end

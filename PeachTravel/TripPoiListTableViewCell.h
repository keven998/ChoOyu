//
//  TripPoiListTableViewCell.h
//  PeachTravel
//
//  Created by liangpengshuai on 11/24/14.
//  Copyright (c) 2014 com.aizou.www. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TripDetail.h"
#import "EDStarRating.h"

@interface TripPoiListTableViewCell : UITableViewCell
@property (nonatomic) BOOL isShouldEditing;

@property (strong, nonatomic) TripPoi *tripPoi;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIButton *property;
@property (weak, nonatomic) IBOutlet UIView *ratingBackgroundView;
@property (weak, nonatomic) IBOutlet EDStarRating *ratingView;


@property (weak, nonatomic) IBOutlet UIView *spaceView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *pictureHorizontalSpace;
@property (weak, nonatomic) IBOutlet UIImageView *headerImageView;

@end

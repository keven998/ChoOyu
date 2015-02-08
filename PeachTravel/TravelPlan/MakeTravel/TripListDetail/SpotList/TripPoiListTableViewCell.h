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
#import "PoiSummary.h"

@interface TripPoiListTableViewCell : UITableViewCell

@property (strong, nonatomic) PoiSummary *tripPoi;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIButton *property;
@property (weak, nonatomic) IBOutlet UIView *spaceview;

@property (weak, nonatomic) IBOutlet UIImageView *headerImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *spateHight;

@end

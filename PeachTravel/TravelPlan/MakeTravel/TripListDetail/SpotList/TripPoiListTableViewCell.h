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

@property (strong, nonatomic) SuperPoi *tripPoi;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *headerImageView;
@property (weak, nonatomic) IBOutlet UIButton *propertyBtn;

@property (weak, nonatomic) IBOutlet UIButton *actionBtn;

@property (weak, nonatomic) IBOutlet UILabel *imageTitle;

@property (weak, nonatomic) IBOutlet UILabel *foodNumber;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *rightLengthContraint;

@end

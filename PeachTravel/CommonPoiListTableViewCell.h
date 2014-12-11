//
//  CommonPoiListTableViewCell.h
//  PeachTravel
//
//  Created by liangpengshuai on 11/24/14.
//  Copyright (c) 2014 com.aizou.www. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TripDetail.h"

@interface CommonPoiListTableViewCell : UITableViewCell

@property (nonatomic) BOOL isEditing;

@property (nonatomic, strong) TripPoi *tripPoi;

@property (weak, nonatomic) IBOutlet UIButton *titleBtn;
@property (weak, nonatomic) IBOutlet UIImageView *photoImageView;

@property (weak, nonatomic) IBOutlet UIButton *priceBtn;
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;
@property (weak, nonatomic) IBOutlet UIButton *mapViewBtn;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *titleLabelConstraint;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *addressLabelConstraint;
@end

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

@property (nonatomic) BOOL shouldEditing;

@property (nonatomic, strong) TripPoi *tripPoi;

@end

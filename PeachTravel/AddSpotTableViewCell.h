//
//  AddSpotTableViewCell.h
//  PeachTravel
//
//  Created by liangpengshuai on 11/26/14.
//  Copyright (c) 2014 com.aizou.www. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TripDetail.h"
#import "EDStarRating.h"
#import "PoiSummary.h"

@interface AddSpotTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *headerImageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIButton *timeCostBtn;
@property (weak, nonatomic) IBOutlet UIButton *addBtn;
@property (weak, nonatomic) IBOutlet UILabel *descLabel;
@property (weak, nonatomic) IBOutlet EDStarRating *ratingView;
@property (weak, nonatomic) IBOutlet UILabel *distanceLabel;

/**
 *  是否显示添加按钮
 */
@property (nonatomic) BOOL shouldEdit;
/**
 *  是否已经添加到路线里了
 */
@property (nonatomic) BOOL isAdded;


@property (nonatomic, strong) PoiSummary *tripPoi;

@end

//
//  PoisOfCityTableViewCell.h
//  PeachTravel
//
//  Created by liangpengshuai on 11/25/14.
//  Copyright (c) 2014 com.aizou.www. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PoiSummary.h"

@interface PoisOfCityTableViewCell : UITableViewCell
@property (nonatomic) BOOL shouldEdit;
@property (weak, nonatomic) IBOutlet UIButton *actionBtn;
@property (weak, nonatomic) IBOutlet UIButton *jumpCommentBtn;

@property (nonatomic, strong) PoiSummary *poi;

@end

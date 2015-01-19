//
//  MyGuidesTableViewCell.h
//  PeachTravel
//
//  Created by liangpengshuai on 11/28/14.
//  Copyright (c) 2014 com.aizou.www. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SWTableViewCell.h>
#import "MyGuideSummary.h"

@interface MyGuidesTableViewCell : SWTableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *headerImageView;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *titleBtn;
@property (weak, nonatomic) IBOutlet UILabel *countBtn;
@property (weak, nonatomic) IBOutlet UILabel *descLabel;

@property (nonatomic, strong) MyGuideSummary *guideSummary;

@end

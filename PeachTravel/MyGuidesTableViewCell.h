//
//  MyGuidesTableViewCell.h
//  PeachTravel
//
//  Created by liangpengshuai on 11/28/14.
//  Copyright (c) 2014 com.aizou.www. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MyGuideSummary.h"

@interface MyGuidesTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *headerImageView;
@property (weak, nonatomic) IBOutlet UIButton *deleteBtn;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UIButton *titleBtn;
//@property (weak, nonatomic) IBOutlet UIButton *editTitleBtn;
@property (weak, nonatomic) IBOutlet UIButton *countBtn;
@property (weak, nonatomic) IBOutlet UILabel *descLabel;
@property (weak, nonatomic) IBOutlet UIView *frameView;

@property (nonatomic) BOOL isEditing;

@property (nonatomic, strong) MyGuideSummary *guideSummary;

@end

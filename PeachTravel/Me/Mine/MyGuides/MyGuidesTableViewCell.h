//
//  MyGuidesTableViewCell.h
//  PeachTravel
//
//  Created by liangpengshuai on 11/28/14.
//  Copyright (c) 2014 com.aizou.www. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SWTableViewCell.h"
#import "MyGuideSummary.h"

@interface MyGuidesTableViewCell : UITableViewCell

@property (strong, nonatomic) UIImageView *headerImageView;

@property (nonatomic, strong) MyGuideSummary *guideSummary;

@property (weak, nonatomic) IBOutlet UIButton *timeBtn;
@property (weak, nonatomic) IBOutlet UILabel *titleBtn;
@property (weak, nonatomic) IBOutlet UILabel *countBtn;
@property (weak, nonatomic) IBOutlet UILabel *descLabel;
@property (weak, nonatomic) IBOutlet UIButton *sendBtn;
@property (nonatomic) BOOL isCanSend;
@property (weak, nonatomic) IBOutlet UIButton *deleteBtn;
@property (weak, nonatomic) IBOutlet UIButton *playedBtn;
@property (weak, nonatomic) IBOutlet UIButton *changBtn;
@property (strong, nonatomic) UIImageView *playedImage;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;

@end

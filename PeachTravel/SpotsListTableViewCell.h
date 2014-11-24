//
//  SpotsListTableViewCell.h
//  PeachTravel
//
//  Created by liangpengshuai on 11/24/14.
//  Copyright (c) 2014 com.aizou.www. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SpotsListTableViewCell : UITableViewCell
@property (nonatomic) BOOL isEditing;

@property (weak, nonatomic) IBOutlet UIView *spaceView;
@property (weak, nonatomic) IBOutlet UIButton *nearBy;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *pictureHorizontalSpace;
@property (weak, nonatomic) IBOutlet UIImageView *headerImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *timeCostConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *titleContstraint;

@end

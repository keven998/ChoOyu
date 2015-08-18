//
//  GuiderCollectionCell.h
//  PeachTravel
//
//  Created by dapiao on 15/7/8.
//  Copyright (c) 2015年 com.aizou.www. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GuiderCollectionCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIView *backGroundView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *subtitleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *genderBkgImageView;
@property (weak, nonatomic) IBOutlet UIImageView *scoreImageView;
@property (weak, nonatomic) IBOutlet UIImageView *headerImageView;
@property (weak, nonatomic) IBOutlet UIButton *addressBtn;
@property (weak, nonatomic) IBOutlet UIButton *costellationBtn;
@property (weak, nonatomic) IBOutlet UILabel *nickNmaeLabel;
@property (weak, nonatomic) IBOutlet UILabel *ageLabel;

@end

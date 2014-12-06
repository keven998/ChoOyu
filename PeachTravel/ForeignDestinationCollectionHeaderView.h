//
//  ForeignDestinationCollectionHeaderView.h
//  PeachTravel
//
//  Created by liangpengshuai on 11/19/14.
//  Copyright (c) 2014 com.aizou.www. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ForeignDestinationCollectionHeaderView : UICollectionReusableView
@property (weak, nonatomic) IBOutlet UIImageView *spaceLineView;
@property (weak, nonatomic) IBOutlet UIImageView *headerImageView;

@property (weak, nonatomic) IBOutlet UILabel *descLabel;

@property (weak, nonatomic) IBOutlet UIButton *titleBtn;
@property (weak, nonatomic) IBOutlet UIButton *contentBtn;

@end

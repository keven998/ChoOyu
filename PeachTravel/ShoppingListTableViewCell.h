//
//  ShoppingListTableViewCell.h
//  PeachTravel
//
//  Created by liangpengshuai on 11/24/14.
//  Copyright (c) 2014 com.aizou.www. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ShoppingListTableViewCell : UITableViewCell

@property (nonatomic) BOOL isEditing;

@property (weak, nonatomic) IBOutlet UIButton *titleBtn;
@property (weak, nonatomic) IBOutlet UIImageView *photoImageView;
@property (weak, nonatomic) IBOutlet UIButton *rattingBtn;

@property (weak, nonatomic) IBOutlet UILabel *addressLabel;
@property (weak, nonatomic) IBOutlet UIButton *mapViewBtn;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *titleLabelConstraint;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *addressLabelConstraint;
@end

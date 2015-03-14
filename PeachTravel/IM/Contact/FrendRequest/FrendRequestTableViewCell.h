//
//  FrendRequestTableViewCell.h
//  PeachTravel
//
//  Created by liangpengshuai on 14/11/1.
//  Copyright (c) 2014年 com.aizou.www. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FrendRequestTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UILabel *nickNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *attachMsgLabel;
@property (weak, nonatomic) IBOutlet UIButton *requestBtn;

@end

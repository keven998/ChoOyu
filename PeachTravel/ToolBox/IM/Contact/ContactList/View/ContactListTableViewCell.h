//
//  ContactListTableViewCell.h
//  PeachTravel
//
//  Created by liangpengshuai on 14/11/8.
//  Copyright (c) 2014年 com.aizou.www. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ContactListTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIView *frameBg;

@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;

@property (weak, nonatomic) IBOutlet UILabel *nickNameLabel;

@property (weak, nonatomic) IBOutlet UILabel *phoneLabel;

@end

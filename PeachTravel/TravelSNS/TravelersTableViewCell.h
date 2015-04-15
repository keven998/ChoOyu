//
//  TravelersTableViewCell.h
//  PeachTravel
//
//  Created by Luo Yong on 15/4/15.
//  Copyright (c) 2015年 com.aizou.www. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TravelersTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *avatarView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *statusLable;
@property (weak, nonatomic) IBOutlet UILabel *levelLabel;

@end

//
//  OptionOfFASKTableViewCell.h
//  PeachTravel
//
//  Created by Luo Yong on 14/11/19.
//  Copyright (c) 2014年 com.aizou.www. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OptionOfFASKTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *requestNoti;

@property (nonatomic) NSUInteger numberOfUnreadFrendRequest;

@end

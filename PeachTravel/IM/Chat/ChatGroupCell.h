//
//  ChatGroupCell.h
//  PeachTravel
//
//  Created by dapiao on 15/5/21.
//  Copyright (c) 2015年 com.aizou.www. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SWTableViewCell.h"
@interface ChatGroupCell : SWTableViewCell
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *ownerLabel;

@property (weak, nonatomic) IBOutlet UIImageView *headerImage;
@end

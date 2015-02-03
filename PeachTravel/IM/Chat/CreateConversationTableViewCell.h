//
//  CreateConversationTableViewCell.h
//  PeachTravel
//
//  Created by liangpengshuai on 14/11/4.
//  Copyright (c) 2014年 com.aizou.www. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    unChecked,
    checked,
    disable
} CheckStatus;

@interface CreateConversationTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *selectImageView;
@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UILabel *nickNameLabel;

@property (nonatomic) CheckStatus checkStatus;

@end

//
//  ChatQuestionTableViewCell.h
//  PeachTravel
//
//  Created by liangpengshuai on 7/21/15.
//  Copyright (c) 2015 com.aizou.www. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MessageModel.h"

@protocol ChatQuestionTableViewCellDelegate <NSObject>

- (void)chatQuestionTableCellDidSelectedWithQuestionModel:(QuestionModel *)questionModel;


@end

@interface ChatQuestionTableViewCell : UITableViewCell

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, weak) id <ChatQuestionTableViewCellDelegate> delegate;

@property (nonatomic, strong) MessageModel *messageModel;

+ (CGFloat)heightForBubbleWithObject:(MessageModel *)model;

@end

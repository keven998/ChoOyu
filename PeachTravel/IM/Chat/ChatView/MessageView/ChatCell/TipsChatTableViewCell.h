//
//  TipsChatTableViewCell.h
//  PeachTravel
//
//  Created by liangpengshuai on 12/4/14.
//  Copyright (c) 2014 com.aizou.www. All rights reserved.
//
/**
 *  聊天界面提示的消息，如：“添加了浪人到旅行派小组”
 */
#import <UIKit/UIKit.h>

@class MessageModel;

@interface TipsChatTableViewCell : UITableViewCell

@property (nonatomic, copy) NSString *content;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier;

+ (CGFloat)heightForBubbleWithObject:(MessageModel *)model;

@end

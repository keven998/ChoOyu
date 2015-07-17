/************************************************************
 *  * EaseMob CONFIDENTIAL
 * __________________
 * Copyright (C) 2013-2014 EaseMob Technologies. All rights reserved.
 *
 * NOTICE: All information contained herein is, and remains
 * the property of EaseMob Technologies.
 * Dissemination of this information or reproduction of this material
 * is strictly forbidden unless prior written permission is obtained
 * from EaseMob Technologies.
 */

#import "EMChatViewBaseCell.h"
#import <SDWebImage/UIImageView+WebCache.h>

NSString *const kRouterEventChatHeadImageTapEventName = @"kRouterEventChatHeadImageTapEventName";

@interface EMChatViewBaseCell()

@end

@implementation EMChatViewBaseCell

- (id)initWithMessageModel:(MessageModel *)model reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(headImagePressed:)];
        _headImageView = [[UIImageView alloc] initWithFrame:CGRectMake(HEAD_PADDING, CELLPADDING, HEAD_SIZE, HEAD_SIZE)];
        [_headImageView addGestureRecognizer:tap];
        _headImageView.userInteractionEnabled = YES;
        _headImageView.multipleTouchEnabled = YES;
        [self.contentView addSubview:_headImageView];
        
        _nameLabel = [[UILabel alloc] init];
        _nameLabel.backgroundColor = [UIColor clearColor];
        _nameLabel.textColor = COLOR_TEXT_II;
        _nameLabel.textAlignment = NSTextAlignmentLeft;
        _nameLabel.font = [UIFont systemFontOfSize:11];
        [self.contentView addSubview:_nameLabel];
        
        [self setupSubviewsForMessageModel:model];
    }
    return self;
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect frame = _headImageView.frame;
    frame.origin.x = _messageModel.isSender ? (self.bounds.size.width - _headImageView.frame.size.width - HEAD_PADDING) : HEAD_PADDING;
    _headImageView.frame = frame;
    
    CGRect nameFrame = CGRectMake(0, _headImageView.frame.origin.y, NAME_LABEL_WIDTH, NAME_LABEL_HEIGHT);
    nameFrame.origin.x = _messageModel.isSender ? 0 : (_headImageView.frame.size.width + _headImageView.frame.origin.x + NAME_LABEL_PADDING);
    _nameLabel.frame = nameFrame;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

#pragma mark - setter

- (void)setMessageModel:(MessageModel *)messageModel
{
    _messageModel = messageModel;
    _messageModel.senderId = 10001;
    _nameLabel.hidden = !(messageModel.chatType != IMChatTypeIMChatSingleType);
    if (messageModel.senderId == 10001) {
        self.headImageView.image = [UIImage imageNamed:@"lvxingwenwen.png"];
        
    } else if (messageModel.senderId == 10000) {
        self.headImageView.image = [UIImage imageNamed:@"lvxingpaipai.png"];
        
    } else {
        [self.headImageView sd_setImageWithURL:_messageModel.headImageURL placeholderImage:[UIImage imageNamed:@"ic_home_default_avatar.png"]];
    }
}

#pragma mark - private

-(void)headImagePressed:(id)sender
{
    [super routerEventWithName:kRouterEventChatHeadImageTapEventName userInfo:@{KMESSAGEKEY:self.messageModel}];
}

- (void)routerEventWithName:(NSString *)eventName userInfo:(NSDictionary *)userInfo
{
    [super routerEventWithName:eventName userInfo:userInfo];
}

#pragma mark - public

- (void)setupSubviewsForMessageModel:(MessageModel *)model
{
    if (model.isSender) {
        self.headImageView.frame = CGRectMake(self.bounds.size.width - HEAD_SIZE - HEAD_PADDING, CELLPADDING, HEAD_SIZE, HEAD_SIZE);
    }
    else{
        self.headImageView.frame = CGRectMake(0, CELLPADDING, HEAD_SIZE, HEAD_SIZE);
    }
}

+ (NSString *)cellIdentifierForMessageModel:(MessageModel *)model
{
    NSString *identifier = @"MessageCell";
    if (model.isSender) {
        identifier = [identifier stringByAppendingString:@"Sender"];
    }
    else{
        identifier = [identifier stringByAppendingString:@"Receiver"];
    }
    
    switch (model.type) {
        case IMMessageTypeTextMessageType:
        {
            identifier = [identifier stringByAppendingString:@"Text"];
        }
            break;
        case IMMessageTypeImageMessageType:
        {
            identifier = [identifier stringByAppendingString:@"Image"];
        }
            break;
        case IMMessageTypeAudioMessageType:
        {
            identifier = [identifier stringByAppendingString:@"Audio"];
        }
            break;
            
        case IMMessageTypeCityPoiMessageType: {
            identifier = [identifier stringByAppendingString:@"city"];
        }
            break;
            
        case IMMessageTypeLocationMessageType: {
            identifier = [identifier stringByAppendingString:@"location"];
        }
            break;
            
        case IMMessageTypeGuideMessageType: case IMMessageTypeSpotMessageType: case IMMessageTypeRestaurantMessageType: case IMMessageTypeHotelMessageType: case IMMessageTypeShoppingMessageType: case IMMessageTypeTravelNoteMessageType:{
            identifier = [identifier stringByAppendingString:@"taoziExt"];
        }
            break;
            
            
        default: {
            model.content = @"升级新版本才可以查看这条神秘消息哦";
            identifier = [identifier stringByAppendingString:@"Text"];
        }
            break;
    }
    
    return identifier;
}

+ (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath withObject:(MessageModel *)model
{
    return HEAD_SIZE + CELLPADDING;
}

@end

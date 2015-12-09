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

#import "EMChatViewCell.h"
#import "EMChatVideoBubbleView.h"
#import "ChatGoodsBubbleView.h"
#import "UIResponder+Router.h"
#import "TipsChatTableViewCell.h"

NSString *const kResendButtonTapEventName = @"kResendButtonTapEventName";
NSString *const kShouldResendCell = @"kShouldResendCell";

@implementation EMChatViewCell

- (id)initWithMessageModel:(MessageModel *)model reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithMessageModel:model reuseIdentifier:reuseIdentifier];
    if (self) {
        self.headImageView.clipsToBounds = YES;
        self.headImageView.layer.cornerRadius = HEAD_SIZE/2.0;
        self.headImageView.contentMode = UIViewContentModeScaleAspectFill;
        if (model.chatType != IMChatTypeIMChatSingleType) {
            _showNickName = YES;
        } else {
            _showNickName = NO;
        }
    }
    return self;
}

- (BOOL)canBecomeFirstResponder
{
    return YES;
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect bubbleFrame = _bubbleView.frame;
    bubbleFrame.origin.y = self.headImageView.frame.origin.y;
    
    if (self.messageModel.isSender) {
        // 菊花状态 （因不确定菊花具体位置，要在子类中实现位置的修改）
        switch (self.messageModel.status) {
            case IMMessageStatusIMMessageSending:
            {
                [_activityView setHidden:NO];
                [_retryButton setHidden:YES];
                [_activtiy setHidden:NO];
                [_activtiy startAnimating];
            }
                break;
            case IMMessageStatusIMMessageSuccessful:
            {
                [_activtiy stopAnimating];
                [_activityView setHidden:YES];
            }
                break;
            case IMMessageStatusIMMessageFailed:
            {
                [_activityView setHidden:NO];
                [_activtiy stopAnimating];
                [_activtiy setHidden:YES];
                [_retryButton setHidden:NO];
            }
                break;
            default:
                break;
        }
        
        bubbleFrame.origin.x = self.headImageView.frame.origin.x - bubbleFrame.size.width - HEAD_PADDING;
        _bubbleView.frame = bubbleFrame;
        CGRect frame = self.activityView.frame;
        frame.origin.x = bubbleFrame.origin.x - frame.size.width - ACTIVTIYVIEW_BUBBLE_PADDING;
        frame.origin.y = _bubbleView.center.y - frame.size.height / 2;
        self.activityView.frame = frame;
    } else{
        if (_showNickName) {
            bubbleFrame.origin.y = self.headImageView.frame.origin.y + 20;
        }
        
        bubbleFrame.origin.x = HEAD_PADDING * 2 + HEAD_SIZE;
        _bubbleView.frame = bubbleFrame;
    }
}

- (void)updateSendStatus
{
    // 菊花状态 （因不确定菊花具体位置，要在子类中实现位置的修改）
    switch (self.messageModel.status) {
        case IMMessageStatusIMMessageSending:
        {
            [_activityView setHidden:NO];
            [_retryButton setHidden:YES];
            [_activtiy setHidden:NO];
            [_activtiy startAnimating];
        }
            break;
        case IMMessageStatusIMMessageSuccessful:
        {
            [_activtiy stopAnimating];
            [_activityView setHidden:YES];
            
        }
            break;
        case IMMessageStatusIMMessageFailed:
        {
            [_activityView setHidden:NO];
            [_activtiy stopAnimating];
            [_activtiy setHidden:YES];
            [_retryButton setHidden:NO];
        }
            break;
        default:
            break;
    }
    
}

- (void)setMessageModel:(MessageModel *)model
{
    [super setMessageModel:model];
    
    if (model.chatType != IMChatTypeIMChatSingleType) {
        _nameLabel.text = model.nickName;
        _nameLabel.hidden = model.isSender;
    }
    
    _bubbleView.model = self.messageModel;
    [_bubbleView sizeToFit];
    [self updateSendStatus];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

#pragma mark - action

// 重发按钮事件
-(void)retryButtonPressed:(UIButton *)sender
{
    [self routerEventWithName:kResendButtonTapEventName
                     userInfo:@{kShouldResendCell:self}];
}

#pragma mark - private

- (void)setupSubviewsForMessageModel:(MessageModel *)messageModel
{
    [super setupSubviewsForMessageModel:messageModel];
    
    if (messageModel.isSender) {
        // 发送进度显示view
        _activityView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SEND_STATUS_SIZE, SEND_STATUS_SIZE)];
        [_activityView setHidden:YES];
        [self.contentView addSubview:_activityView];
        
        // 重发按钮
        _retryButton = [[UIButton alloc] init];
        _retryButton.frame = CGRectMake(0, 0, SEND_STATUS_SIZE, SEND_STATUS_SIZE);
        [_retryButton addTarget:self action:@selector(retryButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [_retryButton setImage:[UIImage imageNamed:@"MessageSendFail.png"] forState:UIControlStateNormal];
        [_activityView addSubview:_retryButton];
        
        // 菊花
        _activtiy = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        _activtiy.backgroundColor = [UIColor clearColor];
        [_activityView addSubview:_activtiy];
    }
    
    _bubbleView = [self bubbleViewForMessageModel:messageModel];
    [self.contentView addSubview:_bubbleView];
}

- (EMChatBaseBubbleView *)bubbleViewForMessageModel:(MessageModel *)messageModel
{
    switch (messageModel.type) {
        case IMMessageTypeTextMessageType:
            return [[EMChatTextBubbleView alloc] init];
            
        case IMMessageTypeImageMessageType:
            return [[EMChatImageBubbleView alloc] init];
            
        case IMMessageTypeAudioMessageType:
            return [[EMChatAudioBubbleView alloc] init];
            
        case IMMessageTypeLocationMessageType:
            return [[EMChatLocationBubbleView alloc] init];
            
        case IMMessageTypeCityPoiMessageType: case IMMessageTypeGuideMessageType: case IMMessageTypeSpotMessageType: case IMMessageTypeTravelNoteMessageType: case IMMessageTypeRestaurantMessageType: case IMMessageTypeHotelMessageType: case IMMessageTypeShoppingMessageType: case IMMessageTypeHtml5MessageType: {
            return [[TaoziChatBaseBubbleView alloc] init];
        }
            break;
            
        case IMMessageTypeGoodsMessageType: {
            return [[ChatGoodsBubbleView alloc] init];
        }
            break;
            
        default: {
            messageModel.content = @"升级新版本才可以查看这条神秘消息哦";
            return [[EMChatTextBubbleView alloc] init];
        }
            break;
    }
    
    return nil;
}

/**
 *  返回cell 的高度
 *
 *  @param messageModel
 *
 *  @return
 */
+ (CGFloat)bubbleViewHeightForMessageModel:(MessageModel *)messageModel
{
    CGFloat nickNameHeight = 0;
    if (messageModel.chatType != IMChatTypeIMChatSingleType) {
        nickNameHeight = 20;
    }
    switch (messageModel.type) {
        case IMMessageTypeTextMessageType:
        {
            return [EMChatTextBubbleView heightForBubbleWithObject:messageModel] + nickNameHeight;
        }
            break;
        case IMMessageTypeImageMessageType:
        {
            return [EMChatImageBubbleView heightForBubbleWithObject:messageModel] + nickNameHeight;
        }
            break;
        case IMMessageTypeAudioMessageType:
        {
            return [EMChatAudioBubbleView heightForBubbleWithObject:messageModel] + nickNameHeight;
        }
            break;
            
            
        case IMMessageTypeCityPoiMessageType: {
            return [TaoziChatCityBubbleView heightForBubbleWithObject:messageModel] + nickNameHeight;
            
        }
            break;
            
        case IMMessageTypeGoodsMessageType: {
            return [ChatGoodsBubbleView heightForBubbleWithObject:messageModel] + nickNameHeight;
        }
            
        case IMMessageTypeLocationMessageType:
            return [EMChatLocationBubbleView heightForBubbleWithObject:messageModel] + nickNameHeight;
            
        case IMMessageTypeGuideMessageType: case IMMessageTypeSpotMessageType: case IMMessageTypeRestaurantMessageType: case IMMessageTypeHotelMessageType: case IMMessageTypeShoppingMessageType: case IMMessageTypeTravelNoteMessageType: case IMMessageTypeHtml5MessageType: {
            return [TaoziChatBaseBubbleView heightForBubbleWithObject:messageModel] + nickNameHeight;
        }
            break;
            
        case IMMessageTypeTipsMessageType: {
            return [TipsChatTableViewCell heightForBubbleWithObject:messageModel];
        }
            
        default: {
            return [EMChatTextBubbleView heightForBubbleWithObject:messageModel] + nickNameHeight;
        }
            break;
    }
    
    return HEAD_SIZE;
}

#pragma mark - public

+ (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath withObject:(MessageModel *)model
{
    NSInteger bubbleHeight = [self bubbleViewHeightForMessageModel:model];
    NSInteger headHeight = HEAD_SIZE;
    if ((model.chatType != IMChatTypeIMChatSingleType) && !model.isSender) {
        headHeight += NAME_LABEL_HEIGHT;
    }
    return MAX(headHeight, bubbleHeight) + 2*CELLPADDING;
}


@end

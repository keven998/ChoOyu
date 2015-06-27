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

#import "DXChatBarMoreView.h"

#define CHAT_BUTTON_SIZE (200 - 36)/2
#define CHAT_BUTTON_HEIGHT (CHAT_BUTTON_SIZE + 18) //panel height: 200

#define CHAT_LABEL_HEIGHT 18
#define INSETS 5

@implementation DXChatBarMoreView

- (instancetype)initWithFrame:(CGRect)frame typw:(ChatMoreType)type
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = APP_PAGE_COLOR;
        UIView *shadowImg = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.bounds), 0.6)];
        shadowImg.backgroundColor = COLOR_LINE;
        [self addSubview:shadowImg];
        [self setupSubviewsForType:type];
    }
    return self;
}

//width = 320, left/right-margin: 40, 240
//top-margin: 10
- (void)setupSubviewsForType:(ChatMoreType)type
{
    CGFloat screentWidth = CGRectGetWidth(self.frame);
    CGFloat caculateItemWidth = screentWidth/4.0; //left+righmargin = 10;
    CGFloat itemWidth = (caculateItemWidth < CHAT_BUTTON_SIZE ? caculateItemWidth : CHAT_BUTTON_SIZE);
    CGFloat itemHeight = (itemWidth + CHAT_LABEL_HEIGHT);
    CGFloat topMagin = (200 - itemHeight*2)/2.0;
    CGFloat itemMargin = (screentWidth - 4*itemWidth)/5.0;
    CGFloat innerMargin = 5;
    itemWidth -= 2*innerMargin;
    itemHeight -= 2*innerMargin;
    
    _myStrategyButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_myStrategyButton setFrame:CGRectMake(itemMargin+innerMargin, topMagin + 2*innerMargin, itemWidth , itemWidth)];
    [_myStrategyButton setImage:[UIImage imageNamed:@"messages_plus_plan_default"] forState:UIControlStateNormal];
    [_myStrategyButton setImage:[UIImage imageNamed:@"messages_plus_plan_selected"] forState:UIControlStateHighlighted];
    [_myStrategyButton addTarget:self action:@selector(myStrategyAction) forControlEvents:UIControlEventTouchUpInside];
    _myStrategyButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    _myStrategyButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    [self addSubview:_myStrategyButton];
    UILabel *planLabel = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMinX(_myStrategyButton.frame), CGRectGetMaxY(_myStrategyButton.frame), itemWidth, CHAT_LABEL_HEIGHT)];
    planLabel.text = @"计划";
    planLabel.textAlignment = NSTextAlignmentCenter;
    planLabel.font = [UIFont systemFontOfSize:11];
    planLabel.textColor = COLOR_TEXT_II;
    [self addSubview:planLabel];
    
    _myFavoriteButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_myFavoriteButton setFrame:CGRectMake(CGRectGetMaxX(_myStrategyButton.frame) + 2*innerMargin + itemMargin, topMagin + 2*innerMargin, itemWidth , itemWidth)];
    [_myFavoriteButton setImage:[UIImage imageNamed:@"messages_plus_search_default"] forState:UIControlStateNormal];
    [_myFavoriteButton setImage:[UIImage imageNamed:@"messages_plus_search_selected"] forState:UIControlStateHighlighted];
    [_myFavoriteButton addTarget:self action:@selector(destinationAction) forControlEvents:UIControlEventTouchUpInside];
    _myFavoriteButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    _myFavoriteButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    [self addSubview:_myFavoriteButton];
    UILabel *lxpsearchLabel = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMinX(_myFavoriteButton.frame), CGRectGetMaxY(_myFavoriteButton.frame), itemWidth, CHAT_LABEL_HEIGHT)];
    lxpsearchLabel.text = @"搜搜";
    lxpsearchLabel.textAlignment = NSTextAlignmentCenter;
    lxpsearchLabel.font = [UIFont systemFontOfSize:11];
    lxpsearchLabel.textColor = COLOR_TEXT_II;
    [self addSubview:lxpsearchLabel];
    
    
    _destinationButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_destinationButton setFrame:CGRectMake(CGRectGetMaxX(_myFavoriteButton.frame) + 2*innerMargin + itemMargin, topMagin + 2*innerMargin, itemWidth , itemWidth)];
    [_destinationButton setImage:[UIImage imageNamed:@"messages_plus_pin_default"] forState:UIControlStateNormal];
    [_destinationButton setImage:[UIImage imageNamed:@"messages_plus_pin_selected"] forState:UIControlStateHighlighted];
    [_destinationButton addTarget:self action:@selector(locationAction) forControlEvents:UIControlEventTouchUpInside];
    _destinationButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    _destinationButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    [self addSubview:_destinationButton];
    UILabel *localLabel = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMinX(_destinationButton.frame), CGRectGetMaxY(_destinationButton.frame), itemWidth, CHAT_LABEL_HEIGHT)];
    localLabel.text = @"位置";
    localLabel.textAlignment = NSTextAlignmentCenter;
    localLabel.font = [UIFont systemFontOfSize:11];
    localLabel.textColor = COLOR_TEXT_II;
    [self addSubview:localLabel];
    
    _photoButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_photoButton setFrame:CGRectMake(CGRectGetMaxX(_destinationButton.frame) + 2*innerMargin + itemMargin, topMagin + 2*innerMargin, itemWidth , itemWidth)];
    [_photoButton setImage:[UIImage imageNamed:@"messages_plus_picture_default"] forState:UIControlStateNormal];
    [_photoButton setImage:[UIImage imageNamed:@"messages_plus_picture_selected"] forState:UIControlStateHighlighted];
    [_photoButton addTarget:self action:@selector(photoAction) forControlEvents:UIControlEventTouchUpInside];
    _photoButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    [self addSubview:_photoButton];
    UILabel *pLabel = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMinX(_photoButton.frame), CGRectGetMaxY(_photoButton.frame), itemWidth, CHAT_LABEL_HEIGHT)];
    pLabel.text = @"相册";
    pLabel.textAlignment = NSTextAlignmentCenter;
    pLabel.font = [UIFont systemFontOfSize:11];
    pLabel.textColor = COLOR_TEXT_II;
    [self addSubview:pLabel];
    
    _takePicButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_takePicButton setFrame:CGRectMake(itemMargin+innerMargin, topMagin + 3*innerMargin+itemHeight, itemWidth , itemWidth)];
    [_takePicButton setImage:[UIImage imageNamed:@"messages_plus_camera_default"] forState:UIControlStateNormal];
    [_takePicButton setImage:[UIImage imageNamed:@"messages_plus_camera_selected"] forState:UIControlStateHighlighted];
    [_takePicButton addTarget:self action:@selector(takePicAction) forControlEvents:UIControlEventTouchUpInside];
    _takePicButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    _takePicButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    [self addSubview:_takePicButton];
    UILabel *tpLabel = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMinX(_takePicButton.frame), CGRectGetMaxY(_takePicButton.frame), itemWidth , CHAT_LABEL_HEIGHT)];
    tpLabel.text = @"拍照";
    tpLabel.textAlignment = NSTextAlignmentCenter;
    tpLabel.font = [UIFont systemFontOfSize:11];
    tpLabel.textColor = COLOR_TEXT_II;
    [self addSubview:tpLabel];
    
    
    /******暂时屏蔽掉发送视频功能*****/
    /*
     _videoButton =[UIButton buttonWithType:UIButtonTypeCustom];
     [_videoButton setFrame:CGRectMake(INSETS * 4 + CHAT_BUTTON_SIZE * 3, 10, CHAT_BUTTON_SIZE , CHAT_BUTTON_SIZE)];
     [_videoButton setImage:[UIImage imageNamed:@"chatBar_colorMore_video"] forState:UIControlStateNormal];
     [_videoButton setImage:[UIImage imageNamed:@"chatBar_colorMore_videoSelected"] forState:UIControlStateHighlighted];
     [_videoButton addTarget:self action:@selector(takeVideoAction) forControlEvents:UIControlEventTouchUpInside];
     [self addSubview:_videoButton];
     
     CGRect frame = self.frame;
     if (type == ChatMoreTypeChat) {
     frame.size.height = 190;
     
     _audioCallButton =[UIButton buttonWithType:UIButtonTypeCustom];
     [_audioCallButton setFrame:CGRectMake(INSETS, 10 * 2 + CHAT_BUTTON_SIZE, CHAT_BUTTON_SIZE , CHAT_BUTTON_SIZE)];
     [_audioCallButton setImage:[UIImage imageNamed:@"chatBar_colorMore_video"] forState:UIControlStateNormal];
     [_audioCallButton setImage:[UIImage imageNamed:@"chatBar_colorMore_videoSelected"] forState:UIControlStateHighlighted];
     [_audioCallButton addTarget:self action:@selector(takeAudioCallAction) forControlEvents:UIControlEventTouchUpInside];
     [self addSubview:_audioCallButton];
     }
     else if (type == ChatMoreTypeGroupChat)
     {
     frame.size.height = 120;
     }
     self.frame = frame;
     */
}

#pragma mark - action

- (void)myStrategyAction
{
    if(_delegate && [_delegate respondsToSelector:@selector(moreViewMyStrategyAction:)]){
        [_delegate moreViewMyStrategyAction:self];
    }
}

- (void)myFavoriteAction
{
    if(_delegate && [_delegate respondsToSelector:@selector(moreViewMyFavoriteAction:)]){
        [_delegate moreViewMyFavoriteAction:self];
    }
}

- (void)destinationAction
{
    if(_delegate && [_delegate respondsToSelector:@selector(moreViewDestinationAction:)]){
        [_delegate moreViewDestinationAction:self];
    }
}

- (void)travelNoteAction
{
    if(_delegate && [_delegate respondsToSelector:@selector(moreViewTravelNoteAction:)]){
        [_delegate moreViewTravelNoteAction:self];
    }
}

- (void)photoAction
{
    if (_delegate && [_delegate respondsToSelector:@selector(moreViewPhotoAction:)]) {
        [_delegate moreViewPhotoAction:self];
    }
}

- (void)takePicAction
{
    if(_delegate && [_delegate respondsToSelector:@selector(moreViewTakePicAction:)]){
        [_delegate moreViewTakePicAction:self];
    }
}

- (void)locationAction
{
    if (_delegate && [_delegate respondsToSelector:@selector(moreViewLocationAction:)]) {
        [_delegate moreViewLocationAction:self];
    }
}

/*******屏蔽掉发送即使语音和视频功能*******/
/*
 - (void)takeVideoAction{
 if (_delegate && [_delegate respondsToSelector:@selector(moreViewLocationAction:)]) {
 [_delegate moreViewVideoAction:self];
 }
 }
 - (void)takeAudioCallAction
 {
 if (_delegate && [_delegate respondsToSelector:@selector(moreViewAudioCallAction:)]) {
 [_delegate moreViewAudioCallAction:self];
 }
 }
 */
@end

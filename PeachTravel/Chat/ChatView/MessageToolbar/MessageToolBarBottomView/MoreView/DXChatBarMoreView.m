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

#define CHAT_BUTTON_SIZE 60
#define CHAT_LABEL_HEIGHT 20
#define INSETS 8

@implementation DXChatBarMoreView

- (instancetype)initWithFrame:(CGRect)frame typw:(ChatMoreType)type
{
    NSLog(@"ToolBar的尺寸为： %@", NSStringFromCGRect(frame));
    self = [super initWithFrame:frame];
    if (self) {
        [self setupSubviewsForType:type];
    }
    return self;
}

- (void)setupSubviewsForType:(ChatMoreType)type
{
    self.backgroundColor = [UIColor clearColor];
    CGFloat insets = (self.frame.size.width - 4 * CHAT_BUTTON_SIZE) / 5;
    
    _myStrategyButton =[UIButton buttonWithType:UIButtonTypeCustom];
    [_myStrategyButton setFrame:CGRectMake(insets, 10, CHAT_BUTTON_SIZE , CHAT_BUTTON_SIZE)];
    [_myStrategyButton setImage:[UIImage imageNamed:@"chatBar_colorMore_photo"] forState:UIControlStateNormal];
    [_myStrategyButton setImage:[UIImage imageNamed:@"chatBar_colorMore_photoSelected"] forState:UIControlStateHighlighted];
    [_myStrategyButton addTarget:self action:@selector(myStrategyAction) forControlEvents:UIControlEventTouchUpInside];
    _myStrategyLabel = [[UILabel alloc] initWithFrame:CGRectMake(insets, 10 + CHAT_BUTTON_SIZE, CHAT_BUTTON_SIZE, CHAT_LABEL_HEIGHT)];
    _myStrategyLabel.text = @"我的攻略";
    _myStrategyLabel.textAlignment = NSTextAlignmentCenter;
    _myStrategyLabel.font = [UIFont systemFontOfSize:14.0];
    [self addSubview:_myStrategyLabel];
    [self addSubview:_myStrategyButton];
    
    _myFavoriteButton =[UIButton buttonWithType:UIButtonTypeCustom];
    [_myFavoriteButton setFrame:CGRectMake(insets * 2 + CHAT_BUTTON_SIZE, 10, CHAT_BUTTON_SIZE , CHAT_BUTTON_SIZE)];
    [_myFavoriteButton setImage:[UIImage imageNamed:@"chatBar_colorMore_photo"] forState:UIControlStateNormal];
    [_myFavoriteButton setImage:[UIImage imageNamed:@"chatBar_colorMore_photoSelected"] forState:UIControlStateHighlighted];
    [_myFavoriteButton addTarget:self action:@selector(myFavoriteAction) forControlEvents:UIControlEventTouchUpInside];
    _myFavoriteLabel = [[UILabel alloc] initWithFrame:CGRectMake(insets * 2 + CHAT_BUTTON_SIZE, 10 + CHAT_BUTTON_SIZE, CHAT_BUTTON_SIZE, CHAT_LABEL_HEIGHT)];
    _myFavoriteLabel.text = @"收藏夹";
    _myFavoriteLabel.textAlignment = NSTextAlignmentCenter;
    _myFavoriteLabel.font = [UIFont systemFontOfSize:14.0];
    [self addSubview:_myFavoriteLabel];
    [self addSubview:_myFavoriteButton];
    
    _destinationButton =[UIButton buttonWithType:UIButtonTypeCustom];
    [_destinationButton setFrame:CGRectMake(insets * 3 + CHAT_BUTTON_SIZE*2, 10, CHAT_BUTTON_SIZE , CHAT_BUTTON_SIZE)];
    [_destinationButton setImage:[UIImage imageNamed:@"chatBar_colorMore_photo"] forState:UIControlStateNormal];
    [_destinationButton setImage:[UIImage imageNamed:@"chatBar_colorMore_photoSelected"] forState:UIControlStateHighlighted];
    [_destinationButton addTarget:self action:@selector(destinationAction) forControlEvents:UIControlEventTouchUpInside];
    _destinationLabel = [[UILabel alloc] initWithFrame:CGRectMake(insets * 3 + CHAT_BUTTON_SIZE*2, 10 + CHAT_BUTTON_SIZE, CHAT_BUTTON_SIZE, CHAT_LABEL_HEIGHT)];
    _destinationLabel.text = @"目的地";
    _destinationLabel.textAlignment = NSTextAlignmentCenter;
    _destinationLabel.font = [UIFont systemFontOfSize:14.0];
    [self addSubview:_destinationLabel];
    [self addSubview:_destinationButton];
    
    _travelNoteButton =[UIButton buttonWithType:UIButtonTypeCustom];
    [_travelNoteButton setFrame:CGRectMake(insets * 4 + CHAT_BUTTON_SIZE*3, 10, CHAT_BUTTON_SIZE , CHAT_BUTTON_SIZE)];
    [_travelNoteButton setImage:[UIImage imageNamed:@"chatBar_colorMore_photo"] forState:UIControlStateNormal];
    [_travelNoteButton setImage:[UIImage imageNamed:@"chatBar_colorMore_photoSelected"] forState:UIControlStateHighlighted];
    [_travelNoteButton addTarget:self action:@selector(travelNoteAction) forControlEvents:UIControlEventTouchUpInside];
    _travelNoteLabel = [[UILabel alloc] initWithFrame:CGRectMake(insets * 4 + CHAT_BUTTON_SIZE*3, 10 + CHAT_BUTTON_SIZE, CHAT_BUTTON_SIZE, CHAT_LABEL_HEIGHT)];
    _travelNoteLabel.text = @"游记";
    _travelNoteLabel.textAlignment = NSTextAlignmentCenter;
    _travelNoteLabel.font = [UIFont systemFontOfSize:14.0];
    [self addSubview:_travelNoteLabel];
    [self addSubview:_travelNoteButton];

    _photoButton =[UIButton buttonWithType:UIButtonTypeCustom];
    [_photoButton setFrame:CGRectMake(insets, 10 * 2+CHAT_BUTTON_SIZE+CHAT_LABEL_HEIGHT, CHAT_BUTTON_SIZE , CHAT_BUTTON_SIZE)];
    [_photoButton setImage:[UIImage imageNamed:@"chatBar_colorMore_photo"] forState:UIControlStateNormal];
    [_photoButton setImage:[UIImage imageNamed:@"chatBar_colorMore_photoSelected"] forState:UIControlStateHighlighted];
    [_photoButton addTarget:self action:@selector(photoAction) forControlEvents:UIControlEventTouchUpInside];
    _photoLabel = [[UILabel alloc] initWithFrame:CGRectMake(insets, 10 * 2+CHAT_BUTTON_SIZE*2+CHAT_LABEL_HEIGHT, CHAT_BUTTON_SIZE, CHAT_LABEL_HEIGHT)];
    _photoLabel.text = @"相册";
    _photoLabel.textAlignment = NSTextAlignmentCenter;
    _photoLabel.font = [UIFont systemFontOfSize:14.0];
    [self addSubview:_photoLabel];
    [self addSubview:_photoButton];
    
    _takePicButton =[UIButton buttonWithType:UIButtonTypeCustom];
    [_takePicButton setFrame:CGRectMake(insets * 2 + CHAT_BUTTON_SIZE, 10 * 2+CHAT_BUTTON_SIZE+CHAT_LABEL_HEIGHT, CHAT_BUTTON_SIZE , CHAT_BUTTON_SIZE)];
    [_takePicButton setImage:[UIImage imageNamed:@"chatBar_colorMore_camera"] forState:UIControlStateNormal];
    [_takePicButton setImage:[UIImage imageNamed:@"chatBar_colorMore_cameraSelected"] forState:UIControlStateHighlighted];
    [_takePicButton addTarget:self action:@selector(takePicAction) forControlEvents:UIControlEventTouchUpInside];
    _takePicLabel = [[UILabel alloc] initWithFrame:CGRectMake(insets * 2 + CHAT_BUTTON_SIZE, 10 * 2+CHAT_BUTTON_SIZE*2+CHAT_LABEL_HEIGHT, CHAT_BUTTON_SIZE, CHAT_LABEL_HEIGHT)];
    _takePicLabel.text = @"相机";
    _takePicLabel.textAlignment = NSTextAlignmentCenter;
    _takePicLabel.font = [UIFont systemFontOfSize:14.0];
    [self addSubview:_takePicLabel];
    [self addSubview:_takePicButton];
    
    _locationButton =[UIButton buttonWithType:UIButtonTypeCustom];
    [_locationButton setFrame:CGRectMake(insets * 3 + CHAT_BUTTON_SIZE*2, 10 * 2+CHAT_BUTTON_SIZE+CHAT_LABEL_HEIGHT, CHAT_BUTTON_SIZE , CHAT_BUTTON_SIZE)];
    [_locationButton setImage:[UIImage imageNamed:@"chatBar_colorMore_location"] forState:UIControlStateNormal];
    [_locationButton setImage:[UIImage imageNamed:@"chatBar_colorMore_locationSelected"] forState:UIControlStateHighlighted];
    [_locationButton addTarget:self action:@selector(locationAction) forControlEvents:UIControlEventTouchUpInside];
    _locationLabel = [[UILabel alloc] initWithFrame:CGRectMake(insets * 3 + CHAT_BUTTON_SIZE*2, 10 * 2+CHAT_BUTTON_SIZE*2+CHAT_LABEL_HEIGHT, CHAT_BUTTON_SIZE, CHAT_LABEL_HEIGHT)];
    _locationLabel.text = @"我的位置";
    _locationLabel.textAlignment = NSTextAlignmentCenter;
    _locationLabel.font = [UIFont systemFontOfSize:14.0];
    [self addSubview:_locationLabel];
    [self addSubview:_locationButton];
    
    
    /******暂时屏蔽掉发送视频功能*****/
    /*
    _videoButton =[UIButton buttonWithType:UIButtonTypeCustom];
    [_videoButton setFrame:CGRectMake(insets * 4 + CHAT_BUTTON_SIZE * 3, 10, CHAT_BUTTON_SIZE , CHAT_BUTTON_SIZE)];
    [_videoButton setImage:[UIImage imageNamed:@"chatBar_colorMore_video"] forState:UIControlStateNormal];
    [_videoButton setImage:[UIImage imageNamed:@"chatBar_colorMore_videoSelected"] forState:UIControlStateHighlighted];
    [_videoButton addTarget:self action:@selector(takeVideoAction) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_videoButton];
    
    CGRect frame = self.frame;
    if (type == ChatMoreTypeChat) {
        frame.size.height = 190;
        
        _audioCallButton =[UIButton buttonWithType:UIButtonTypeCustom];
        [_audioCallButton setFrame:CGRectMake(insets, 10 * 2 + CHAT_BUTTON_SIZE, CHAT_BUTTON_SIZE , CHAT_BUTTON_SIZE)];
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

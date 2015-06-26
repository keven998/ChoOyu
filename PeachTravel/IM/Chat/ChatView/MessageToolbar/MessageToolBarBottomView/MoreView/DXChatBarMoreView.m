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

#define CHAT_BUTTON_SIZE 80
#define CHAT_BUTTON_HEIGHT 187/2

#define CHAT_LABEL_HEIGHT 20
#define INSETS 40

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
    CGFloat spaceWidth = (self.bounds.size.width - 3 * CHAT_BUTTON_SIZE-80) / 2;
    
    _myStrategyButton = [TZButton buttonWithType:UIButtonTypeCustom];
    [_myStrategyButton setFrame:CGRectMake(INSETS, 0, CHAT_BUTTON_SIZE , CHAT_BUTTON_HEIGHT)];
    _myStrategyButton.topSpaceHight = 12;
    _myStrategyButton.spaceHight = 5;
    [_myStrategyButton setImage:[UIImage imageNamed:@"messages_plus_plan_default"] forState:UIControlStateNormal];
    [_myStrategyButton setImage:[UIImage imageNamed:@"messages_plus_plan_selected"] forState:UIControlStateHighlighted];
    [_myStrategyButton addTarget:self action:@selector(myStrategyAction) forControlEvents:UIControlEventTouchUpInside];
    _myStrategyButton.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
//    [_myStrategyButton setTitle:@"计划" forState:UIControlStateNormal];
    [_myStrategyButton setTitleColor:TEXT_COLOR_TITLE_SUBTITLE forState:UIControlStateNormal];
    _myStrategyButton.titleLabel.font = [UIFont systemFontOfSize:12.0];
    _myStrategyButton.titleLabel.adjustsFontSizeToFitWidth = YES;
    _myStrategyButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    _myFavoriteButton.titleLabel.backgroundColor = [UIColor redColor];
    [self addSubview:_myStrategyButton];
    
    _myFavoriteButton = [TZButton buttonWithType:UIButtonTypeCustom];
    _myFavoriteButton.topSpaceHight = 10;
    _myFavoriteButton.spaceHight = 5;
    [_myFavoriteButton setFrame:CGRectMake(spaceWidth + CHAT_BUTTON_SIZE+INSETS, 0, CHAT_BUTTON_SIZE , CHAT_BUTTON_SIZE)];
    [_myFavoriteButton setImage:[UIImage imageNamed:@"messages_plus_search_default"] forState:UIControlStateNormal];
    [_myFavoriteButton setImage:[UIImage imageNamed:@"messages_plus_search_selected"] forState:UIControlStateHighlighted];
    [_myFavoriteButton addTarget:self action:@selector(destinationAction) forControlEvents:UIControlEventTouchUpInside];
//    [_myFavoriteButton setTitle:@"搜搜" forState:UIControlStateNormal];
    [_myFavoriteButton setTitleColor:TEXT_COLOR_TITLE_SUBTITLE forState:UIControlStateNormal];
    _myFavoriteButton.titleLabel.font = [UIFont systemFontOfSize:12.0];
    _myFavoriteButton.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _myFavoriteButton.titleLabel.adjustsFontSizeToFitWidth = YES;
    _myFavoriteButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    [self addSubview:_myFavoriteButton];
    
    
    _destinationButton = [TZButton buttonWithType:UIButtonTypeCustom];
    _destinationButton.topSpaceHight = 12;
    _destinationButton.spaceHight = 5;
    [_destinationButton setFrame:CGRectMake(INSETS + 2*(CHAT_BUTTON_SIZE+spaceWidth), 0, CHAT_BUTTON_SIZE , CHAT_BUTTON_SIZE)];
    [_destinationButton setImage:[UIImage imageNamed:@"messages_plus_pin_default"] forState:UIControlStateNormal];
    [_destinationButton setImage:[UIImage imageNamed:@"messages_plus_pin_selected"] forState:UIControlStateHighlighted];
    [_destinationButton addTarget:self action:@selector(locationAction) forControlEvents:UIControlEventTouchUpInside];
//    [_destinationButton setTitle:@"位置" forState:UIControlStateNormal];
    [_destinationButton setTitleColor:TEXT_COLOR_TITLE_SUBTITLE forState:UIControlStateNormal];
    _destinationButton.titleLabel.font = [UIFont systemFontOfSize:12.0];
    _destinationButton.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _destinationButton.titleLabel.adjustsFontSizeToFitWidth = YES;
    _destinationButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    [self addSubview:_destinationButton];
    
//    _travelNoteButton = [TZButton buttonWithType:UIButtonTypeCustom];
//    _travelNoteButton.topSpaceHight = 10;
//    _travelNoteButton.spaceHight = 5;
//    [_travelNoteButton setFrame:CGRectMake(INSETS, CHAT_BUTTON_SIZE + 10.0, CHAT_BUTTON_SIZE , CHAT_BUTTON_SIZE)];
//    [_travelNoteButton setImage:[UIImage imageNamed:@"ic_love_normal"] forState:UIControlStateNormal];
//    [_travelNoteButton setImage:[UIImage imageNamed:@"ic_love_selected"] forState:UIControlStateHighlighted];
//    [_travelNoteButton addTarget:self action:@selector(myFavoriteAction) forControlEvents:UIControlEventTouchUpInside];
//    [_travelNoteButton setTitle:@"收藏夹" forState:UIControlStateNormal];
//    [_travelNoteButton setTitleColor:TEXT_COLOR_TITLE_SUBTITLE forState:UIControlStateNormal];
//    _travelNoteButton.titleLabel.font = [UIFont systemFontOfSize:12.0];
//    _travelNoteButton.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
//    _travelNoteButton.titleLabel.adjustsFontSizeToFitWidth = YES;
//    _travelNoteButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
//    [self addSubview:_travelNoteButton];
    
    _photoButton = [TZButton buttonWithType:UIButtonTypeCustom];
    _photoButton.topSpaceHight = 12;
    _photoButton.spaceHight = 5;
    [_photoButton setFrame:CGRectMake(INSETS, CHAT_BUTTON_SIZE + 10.0, CHAT_BUTTON_SIZE , CHAT_BUTTON_SIZE)];
    [_photoButton setImage:[UIImage imageNamed:@"messages_plus_picture_default"] forState:UIControlStateNormal];
    [_photoButton setImage:[UIImage imageNamed:@"messages_plus_picture_selected"] forState:UIControlStateHighlighted];
    [_photoButton addTarget:self action:@selector(photoAction) forControlEvents:UIControlEventTouchUpInside];
//    [_photoButton setTitle:@"图片" forState:UIControlStateNormal];
    [_photoButton setTitleColor:TEXT_COLOR_TITLE_SUBTITLE forState:UIControlStateNormal];
    _photoButton.titleLabel.font = [UIFont systemFontOfSize:12.0];
    _photoButton.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _photoButton.titleLabel.adjustsFontSizeToFitWidth = YES;
    _photoButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    [self addSubview:_photoButton];
    
    _takePicButton = [TZButton buttonWithType:UIButtonTypeCustom];
    _takePicButton.topSpaceHight = 12;
    _takePicButton.spaceHight = 5;
    [_takePicButton setFrame:CGRectMake(INSETS + CHAT_BUTTON_SIZE + spaceWidth, CHAT_BUTTON_SIZE + 10.0, CHAT_BUTTON_SIZE , CHAT_BUTTON_SIZE)];
    [_takePicButton setImage:[UIImage imageNamed:@"messages_plus_camera_default"] forState:UIControlStateNormal];
    [_takePicButton setImage:[UIImage imageNamed:@"messages_plus_camera_selected"] forState:UIControlStateHighlighted];
    [_takePicButton addTarget:self action:@selector(takePicAction) forControlEvents:UIControlEventTouchUpInside];
//    [_takePicButton setTitle:@"拍照" forState:UIControlStateNormal];
    [_takePicButton setTitleColor:TEXT_COLOR_TITLE_SUBTITLE forState:UIControlStateNormal];
    _takePicButton.titleLabel.font = [UIFont systemFontOfSize:12.0];
    _takePicButton.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _takePicButton.titleLabel.adjustsFontSizeToFitWidth = YES;
    _takePicButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    [self addSubview:_takePicButton];
    
    
    
    CGFloat w = SCREEN_WIDTH/6;
    CGFloat bloderW = SCREEN_WIDTH/15;
    
    _myStrategyButton.frame = CGRectMake(bloderW, 0, w, w);
    UILabel *planLabel = [[UILabel alloc]initWithFrame:CGRectMake(bloderW, w+13, w, 20)];
    planLabel.text = @"计划";
    planLabel.textAlignment = NSTextAlignmentCenter;
    planLabel.font = [UIFont systemFontOfSize:12];
    planLabel.textColor = TEXT_COLOR_TITLE_SUBTITLE;
    [self addSubview:planLabel];
    
    
    
    _photoButton.frame = CGRectMake(bloderW + w + bloderW, 0, w, w);
    UILabel *photoLabel = [[UILabel alloc]initWithFrame:CGRectMake(bloderW + w + bloderW, w+13, w, 20)];
    photoLabel.text = @"图片";
    photoLabel.textAlignment = NSTextAlignmentCenter;
    photoLabel.font = [UIFont systemFontOfSize:12];
    photoLabel.textColor = TEXT_COLOR_TITLE_SUBTITLE;
    [self addSubview:photoLabel];
    
    
    _takePicButton.frame = CGRectMake(bloderW * 3+ 2 * w , 0, w, w);
    UILabel *caremaLabel = [[UILabel alloc]initWithFrame:CGRectMake(bloderW * 3+ 2 * w, w+13, w, 20)];
    caremaLabel.text = @"拍照";
    caremaLabel.textAlignment = NSTextAlignmentCenter;
    caremaLabel.font = [UIFont systemFontOfSize:12];
    caremaLabel.textColor = TEXT_COLOR_TITLE_SUBTITLE;
    [self addSubview:caremaLabel];
    
    
    _destinationButton.frame = CGRectMake(bloderW * 4 + 3 * w, 0, w, w);
    UILabel *positionLabel = [[UILabel alloc]initWithFrame:CGRectMake(bloderW * 4 + 3 * w, w+13, w, 20)];
    positionLabel.text = @"位置";
    positionLabel.textAlignment = NSTextAlignmentCenter;
    positionLabel.font = [UIFont systemFontOfSize:12];
    positionLabel.textColor = TEXT_COLOR_TITLE_SUBTITLE;
    [self addSubview:positionLabel];

    _myFavoriteButton.frame = CGRectMake(bloderW, self.bounds.size.height/2-1, w, w);
    UILabel *sousouLabel = [[UILabel alloc]initWithFrame:CGRectMake(bloderW, self.bounds.size.height/2+w+9, w, 20)];
    sousouLabel.text = @"搜搜";
    sousouLabel.textAlignment = NSTextAlignmentCenter;
    sousouLabel.font = [UIFont systemFontOfSize:12];
    sousouLabel.textColor = TEXT_COLOR_TITLE_SUBTITLE;
    [self addSubview:sousouLabel];

//    _locationButton =[UIButton buttonWithType:UIButtonTypeCustom];
//    [_locationButton setFrame:CGRectMake(INSETS * 3 + CHAT_BUTTON_SIZE*2, 10 * 2+CHAT_BUTTON_SIZE+CHAT_LABEL_HEIGHT, CHAT_BUTTON_SIZE , CHAT_BUTTON_SIZE)];
//    [_locationButton setImage:[UIImage imageNamed:@"chatBar_colorMore_location"] forState:UIControlStateNormal];
//    [_locationButton setImage:[UIImage imageNamed:@"chatBar_colorMore_locationSelected"] forState:UIControlStateHighlighted];
//    [_locationButton addTarget:self action:@selector(locationAction) forControlEvents:UIControlEventTouchUpInside];
//    _locationLabel = [[UILabel alloc] initWithFrame:CGRectMake(INSETS * 3 + CHAT_BUTTON_SIZE*2, 10 * 2+CHAT_BUTTON_SIZE*2+CHAT_LABEL_HEIGHT, CHAT_BUTTON_SIZE, CHAT_LABEL_HEIGHT)];
//    _locationLabel.text = @"我的位置";
//    _locationLabel.textAlignment = NSTextAlignmentCenter;
//    _locationLabel.font = [UIFont systemFontOfSize:12.0];
//    [self addSubview:_locationLabel];
//    [self addSubview:_locationButton];
    
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

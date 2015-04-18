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

#import <UIKit/UIKit.h>

typedef enum{
    ChatMoreTypeChat,
    ChatMoreTypeGroupChat,
}ChatMoreType;

@protocol DXChatBarMoreViewDelegate;
@interface DXChatBarMoreView : UIView

@property (nonatomic,weak) id<DXChatBarMoreViewDelegate> delegate;

@property (nonatomic, strong) TZButton *photoButton;
@property (nonatomic, strong) TZButton *takePicButton;
@property (nonatomic, strong) TZButton *locationButton;
@property (nonatomic, strong) TZButton *myStrategyButton;
@property (nonatomic, strong) TZButton *myFavoriteButton;
@property (nonatomic, strong) TZButton *destinationButton;
@property (nonatomic, strong) TZButton *travelNoteButton;

/****暂时屏蔽及时语音和拍视频的功能******/
/*
@property (nonatomic, strong) UIButton *videoButton;
@property (nonatomic, strong) UIButton *audioCallButton;

*/

- (instancetype)initWithFrame:(CGRect)frame typw:(ChatMoreType)type;

- (void)setupSubviewsForType:(ChatMoreType)type;

@end

@protocol DXChatBarMoreViewDelegate <NSObject>

@required

/****暂时屏蔽掉照相和拍视频的功能******/
/*
- (void)moreViewVideoAction:(DXChatBarMoreView *)moreView;
- (void)moreViewAudioCallAction:(DXChatBarMoreView *)moreView;
*/

- (void)moreViewMyStrategyAction:(DXChatBarMoreView *)moreView;
- (void)moreViewMyFavoriteAction:(DXChatBarMoreView *)moreView;
- (void)moreViewDestinationAction:(DXChatBarMoreView *)moreView;
- (void)moreViewTravelNoteAction:(DXChatBarMoreView *)moreView;
- (void)moreViewPhotoAction:(DXChatBarMoreView *)moreView;
- (void)moreViewTakePicAction:(DXChatBarMoreView *)moreView;
- (void)moreViewLocationAction:(DXChatBarMoreView *)moreView;


@end






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

#define CHAT_PANEL_VIEW_HEIGHT 200 // moreview高度
#define CHAT_PANEL_VIEW_MARGIN 5 // item间距
#define CHAT_PANEL_VIEW_RANK 4 // 列数
#define CHAT_BUTTON_SIZE (200 - 36)/2 // 
#define CHAT_BUTTON_HEIGHT (CHAT_BUTTON_SIZE + 18) //panel height: 200
#define CHAT_LABEL_HEIGHT 18
#define INSETS 5

typedef enum{
    ChatMoreTypeChat,
    ChatMoreTypeGroupChat,
}ChatMoreType;

@protocol DXChatBarMoreViewDelegate;
@interface DXChatBarMoreView : UIView

@property (nonatomic,weak) id<DXChatBarMoreViewDelegate> delegate;

@property (nonatomic, strong) UIButton *photoButton;
@property (nonatomic, strong) UIButton *takePicButton;
@property (nonatomic, strong) UIButton *locationButton;
@property (nonatomic, strong) UIButton *myStrategyButton;
@property (nonatomic, strong) UIButton *myFavoriteButton;
@property (nonatomic, strong) UIButton *destinationButton;
@property (nonatomic, strong) UIButton *travelNoteButton;


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






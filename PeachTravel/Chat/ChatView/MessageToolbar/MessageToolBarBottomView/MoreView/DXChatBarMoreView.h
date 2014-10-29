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

@property (nonatomic,assign) id<DXChatBarMoreViewDelegate> delegate;

@property (nonatomic, strong) UIButton *photoButton;
@property (nonatomic, strong) UIButton *takePicButton;
@property (nonatomic, strong) UIButton *locationButton;
@property (nonatomic, strong) UIButton *myStrategyButton;
@property (nonatomic, strong) UIButton *myFavoriteButton;
@property (nonatomic, strong) UIButton *destinationButton;
@property (nonatomic, strong) UIButton *travelNoteButton;

@property (nonatomic, strong) UILabel *photoLabel;
@property (nonatomic, strong) UILabel *takePicLabel;
@property (nonatomic, strong) UILabel *locationLabel;
@property (nonatomic, strong) UILabel *myStrategyLabel;
@property (nonatomic, strong) UILabel *myFavoriteLabel;
@property (nonatomic, strong) UILabel *destinationLabel;
@property (nonatomic, strong) UILabel *travelNoteLabel;

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






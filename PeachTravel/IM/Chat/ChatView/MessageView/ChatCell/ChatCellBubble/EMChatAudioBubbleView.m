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

#import "EMChatAudioBubbleView.h"

NSString *const kRouterEventAudioBubbleTapEventName = @"kRouterEventAudioBubbleTapEventName";

@interface EMChatAudioBubbleView ()
{
    NSMutableArray *_senderAnimationImages;
    NSMutableArray *_recevierAnimationImages;
    UIImageView    *_isReadView;
}

@end

@implementation EMChatAudioBubbleView

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        _animationImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 12, 16)];
        _animationImageView.animationDuration = ANIMATION_IMAGEVIEW_SPEED;
        [self addSubview:_animationImageView];
        
        _timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, ANIMATION_TIME_LABEL_WIDHT, ANIMATION_TIME_LABEL_HEIGHT)];
        _timeLabel.font = [UIFont boldSystemFontOfSize:ANIMATION_TIME_LABEL_FONT_SIZE];
        _timeLabel.textAlignment = NSTextAlignmentCenter;
        
        _timeLabel.textColor = [UIColor whiteColor];
        _timeLabel.backgroundColor = [UIColor clearColor];
        [self addSubview:_timeLabel];
        
        _isReadView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 8, 8)];
        _isReadView.layer.cornerRadius = 4;
        [_isReadView setClipsToBounds:YES];
        [_isReadView setBackgroundColor:APP_THEME_COLOR];
        [self addSubview:_isReadView];
        
        _senderAnimationImages = [[NSMutableArray alloc] initWithObjects: [UIImage imageNamed:SENDER_ANIMATION_IMAGEVIEW_IMAGE_01], [UIImage imageNamed:SENDER_ANIMATION_IMAGEVIEW_IMAGE_02], [UIImage imageNamed:SENDER_ANIMATION_IMAGEVIEW_IMAGE_03], [UIImage imageNamed:SENDER_ANIMATION_IMAGEVIEW_IMAGE_04], nil];
        _recevierAnimationImages = [[NSMutableArray alloc] initWithObjects: [UIImage imageNamed:RECEIVER_ANIMATION_IMAGEVIEW_IMAGE_01], [UIImage imageNamed:RECEIVER_ANIMATION_IMAGEVIEW_IMAGE_02], [UIImage imageNamed:RECEIVER_ANIMATION_IMAGEVIEW_IMAGE_03], [UIImage imageNamed:RECEIVER_ANIMATION_IMAGEVIEW_IMAGE_04], nil];
    }
    return self;
}

- (CGSize)sizeThatFits:(CGSize)size
{
    float time = (float)roundf(self.model.time);
    float audioLength = time/60 * (kWindowWidth/2);
    if (audioLength > kWindowWidth/2) {
        audioLength = kWindowWidth/2;
    }
    audioLength += 60;
    return CGSizeMake(audioLength+40, 40);
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect frame = _animationImageView.frame;
    
    if (self.model.isSender) {
        self.backImageView.frame = CGRectMake(40, 0, self.bounds.size.width - 40, 40);
        frame.origin.x = self.frame.size.width - BUBBLE_ARROW_WIDTH - frame.size.width - BUBBLE_VIEW_PADDING;
        frame.origin.y = self.frame.size.height / 2 - frame.size.height / 2;
        _animationImageView.frame = frame;
        _timeLabel.textColor = UIColorFromRGB(0x797979);

        frame = _timeLabel.frame;
        frame.origin.x = 0;
        frame.origin.y = _animationImageView.center.y - frame.size.height / 2;
        _timeLabel.frame = frame;

    } else {
        self.backImageView.frame = CGRectMake(0, 0, self.bounds.size.width - 40, 40);
        _animationImageView.image = [UIImage imageNamed:RECEIVER_ANIMATION_IMAGEVIEW_IMAGE_DEFAULT];
        _timeLabel.textColor = UIColorFromRGB(0x797979);

        frame.origin.x = BUBBLE_ARROW_WIDTH + BUBBLE_VIEW_PADDING;
        frame.origin.y = self.frame.size.height / 2 - frame.size.height / 2;
        _animationImageView.frame = frame;
        
        frame.origin.x = self.backImageView.bounds.size.width + 4;
        frame.origin.y = 0;
        frame.size = _isReadView.frame.size;
        _isReadView.frame = frame;
        
        frame = _timeLabel.frame;
        frame.origin.x = self.backImageView.bounds.size.width + 4;
        frame.origin.y = _animationImageView.center.y - frame.size.height / 2;
        _timeLabel.frame = frame;

    }
}

#pragma mark - setter

- (void)setModel:(MessageModel *)model
{
    [super setModel:model];
    int time = (int)roundf(self.model.time);
    int min = time/60;
    int second = time%60;
    if (min == 0) {
        _timeLabel.text = [NSString stringWithFormat:@"%d\"", second];
    } else {
        _timeLabel.text = [NSString stringWithFormat:@"%d' %d\"", min, second];
    }
    
    if (self.model.isSender) {
        [_isReadView setHidden:YES];
        _animationImageView.image = [UIImage imageNamed:SENDER_ANIMATION_IMAGEVIEW_IMAGE_DEFAULT];
        _animationImageView.animationImages = _senderAnimationImages;
        
    } else {
        if (model.isPlayed) {
            [_isReadView setHidden:YES];
        } else {
            [_isReadView setHidden:NO];
        }
        _animationImageView.image = [UIImage imageNamed:RECEIVER_ANIMATION_IMAGEVIEW_IMAGE_DEFAULT];
        _animationImageView.animationImages = _recevierAnimationImages;
    }
    
    if (self.model.isPlaying) {
        [self startAudioAnimation];
    } else {
        [self stopAudioAnimation];
    }
}

#pragma mark - public

- (void)bubbleViewPressed:(id)sender
{
    [self routerEventWithName:kRouterEventAudioBubbleTapEventName userInfo:@{KMESSAGEKEY:self.model}];
}


+ (CGFloat)heightForBubbleWithObject:(MessageModel *)object
{
    return 60;
}

-(void)startAudioAnimation
{
    [_animationImageView startAnimating];
}

-(void)stopAudioAnimation
{
    [_animationImageView stopAnimating];
}

@end

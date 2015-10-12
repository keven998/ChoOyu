//
//  TZEmojiKeyBoardCell.m
//  emojiKeyBoard
//
//  Created by 冯宁 on 15/9/17.
//  Copyright (c) 2015年 PeachTravel. All rights reserved.
//

#import "TZEmojiKeyBoardCell.h"
#import "SQLiteManager.h"

@interface TZEmojiKeyBoardCell ()

@property (nonatomic, strong) UIButton* emoticonButton;

@end

@implementation TZEmojiKeyBoardCell

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self prepareViews];
    }
    return self;
}

- (void)prepareViews{
    [self.contentView addSubview:self.emoticonButton];
    self.emoticonButton.translatesAutoresizingMaskIntoConstraints = NO;

    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat:@"H:|-%f-[imageView]-%f-|",self.frame.size.width * 0.2,self.frame.size.width * 0.2] options:0 metrics:nil views:@{@"imageView":self.emoticonButton}]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat:@"V:|-%f-[imageView]-%f-|",self.frame.size.width * 0.2,self.frame.size.width * 0.2] options:0 metrics:nil views:@{@"imageView":self.emoticonButton}]];
    
}

#pragma mark - setter & getter
- (UIButton *)emoticonButton{
    if (_emoticonButton == nil) {
        _emoticonButton = [[UIButton alloc] init];
        _emoticonButton.titleLabel.font = [UIFont systemFontOfSize: EMOJI_EMOJI_FONTSIZE];
        _emoticonButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
        [_emoticonButton addTarget:self action:@selector(emotionBtnClickEvent) forControlEvents:UIControlEventTouchUpInside];
    }
    return _emoticonButton;
}

- (void)emotionBtnClickEvent{
    if ([self.delegate respondsToSelector:@selector(emoticonBtnClickEventWithModel:)]) {
        [self.delegate emoticonBtnClickEventWithModel:self.model];
        
    }
}

- (void)setModel:(EmoticonModel *)model{
    _model = model;
    
    if (model.isDeleteBtn) {
        [self.emoticonButton setTitle:nil forState:UIControlStateNormal];
        [self.emoticonButton setImage:[UIImage imageWithContentsOfFile:[[[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"Emoticons.bundle"]  stringByAppendingPathComponent:@"compose_emotion_delete@2x.png"]] forState:UIControlStateNormal];
        [self.emoticonButton setImage:[UIImage imageWithContentsOfFile:[[[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"Emoticons.bundle"]  stringByAppendingPathComponent:@"compose_emotion_delete_highlighted@2x.png"]] forState:UIControlStateHighlighted];
        return;
    }
    
    [self.emoticonButton setImage:nil forState:UIControlStateHighlighted];
    [self.emoticonButton setTitle:model.emoji forState:UIControlStateNormal];
    [self.emoticonButton setImage:model.image forState:UIControlStateNormal];
    self.emoticonButton.titleLabel.font =  [UIFont systemFontOfSize:(self.frame.size.width > self.frame.size.height ? self.frame.size.height : self.frame.size.width) * 0.5];
    
}

@end

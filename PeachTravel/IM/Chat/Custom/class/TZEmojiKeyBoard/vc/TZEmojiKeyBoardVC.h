//
//  TZEmojiKeyBoardVC.h
//  emojiKeyBoard
//
//  Created by 冯宁 on 15/9/17.
//  Copyright (c) 2015年 PeachTravel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EmoticonPackageModel.h"
#import "EmoticonModel.h"
@protocol TZEmojiKeyBoardVCDelegate <NSObject>

- (void)insertEmoticonWithModel:(EmoticonModel*)model;
- (void)sendBtnClickEvent;

@end

@interface TZEmojiKeyBoardVC : UIViewController

@property (nonatomic, weak) id <TZEmojiKeyBoardVCDelegate> delegate;

@end

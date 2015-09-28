//
//  TZEmojiKeyBoardCell.h
//  emojiKeyBoard
//
//  Created by 冯宁 on 15/9/17.
//  Copyright (c) 2015年 PeachTravel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EmoticonModel.h"
#import "ARGUMENTS.h"

@protocol TZEmojiKeyBoardCellDelegate <NSObject>

- (void)emoticonBtnClickEventWithModel:(EmoticonModel*)model;

@end

@interface TZEmojiKeyBoardCell : UICollectionViewCell

@property (nonatomic, weak) id <TZEmojiKeyBoardCellDelegate> delegate;

@property (nonatomic, strong) EmoticonModel* model;

@end

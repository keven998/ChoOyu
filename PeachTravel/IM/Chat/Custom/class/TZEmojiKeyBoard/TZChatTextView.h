//
//  TZChatTextView.h
//  emojiKeyBoard
//
//  Created by 冯宁 on 15/9/18.
//  Copyright © 2015年 PeachTravel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HPTextViewInternal.h"

@protocol TZChatTextViewDelegate <NSObject>

- (void)sendMessageAction:(NSString*)messege;

@end

@interface TZChatTextView : HPTextViewInternal

@property (nonatomic, weak) id <TZChatTextViewDelegate> TZdelegate;

- (void)changeInputViewToEmoji;
@end

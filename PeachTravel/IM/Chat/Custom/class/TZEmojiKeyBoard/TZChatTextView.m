//
//  TZChatTextView.m
//  emojiKeyBoard
//
//  Created by 冯宁 on 15/9/18.
//  Copyright © 2015年 PeachTravel. All rights reserved.
//

#import "TZChatTextView.h"
#import "TZEmojiKeyBoardVC.h"
#import "EmoticonAttachment.h"
#import "EmoticonPackageModel.h"
#import <objc/runtime.h>

@interface TZChatTextView () <TZEmojiKeyBoardVCDelegate>
@property (nonatomic, strong) UIView* emojiKeyBoard;
@property (nonatomic, strong) TZEmojiKeyBoardVC* keyBoardVC;
@property (nonatomic, strong) UILabel* label;
@property (nonatomic, copy) NSString* placeHolderStr;
@end

@implementation TZChatTextView

- (void)layoutSubviews{
    [EmoticonPackageModel emoticonPackages];
}

#pragma mark - 启动emoji与收起emoji
- (void)changeInputViewToEmoji{
    NSLog(@"%@",[NSDate date]);
    if (self.inputView != nil) {
        [self resignFirstResponder];
        self.inputView = nil;
        [self becomeFirstResponder];
    }else{
        [self resignFirstResponder];
        self.inputView = self.emojiKeyBoard;
        [self becomeFirstResponder];
    }
    NSLog(@"%@",[NSDate date]);
}

- (BOOL)resignFirstResponder{
    
    self.inputView = nil;
    
    return [super resignFirstResponder];
    
}

- (void)insertText:(NSString *)text{
    [super insertText:text];
    if (self.placeHolderStr.length == 0) {
        self.placeHolderStr = self.placeholder;
    }
}

- (void)deleteBackward{
    [super deleteBackward];
    if (self.attributedText.length == 0) {
        self.placeholder = self.placeHolderStr;
    }else{
        if (self.placeHolderStr.length == 0) {
            self.placeHolderStr = self.placeholder;
        }
    }
}

#pragma mark - keyBoardVCDelegate
- (void)insertEmoticonWithModel:(EmoticonModel *)model{
    if (model.isDeleteBtn) {
        [self deleteBackward];
        return;
    }
    if (model.emoji != nil) {
        [self insertText:model.emoji];
        return;
    }

    NSNumber* beginNum = [self.selectedTextRange.start valueForKey:@"_offset"];
    NSNumber* endStr = [self.selectedTextRange.start valueForKey:@"_offset"];
    
    UITextRange* currentRange = self.selectedTextRange;
    
    NSInteger begin = [beginNum integerValue];
    NSInteger end = [endStr integerValue];
    
    NSRange range;
    
    if (begin == end) {
        range = NSMakeRange(end, 0);
    }else {
        range = NSMakeRange(begin, end - begin);
    }

    EmoticonAttachment* attachment = [[EmoticonAttachment alloc] init];
    //    attachment.image = model.image;
    attachment.chs = model.chs;
    attachment.image = model.image;
    CGFloat height = self.font.lineHeight;
//    attachment.bounds = CGRectMake(0, -self.font.lineHeight * 0.13, height * 0.85, height * 0.85);
    attachment.bounds = CGRectMake(0, -self.font.lineHeight * 0.21, height, height);
    
    
    NSMutableAttributedString* attrString = [[NSMutableAttributedString alloc] initWithAttributedString:[NSAttributedString attributedStringWithAttachment:attachment]];
    [attrString addAttribute:NSFontAttributeName value:self.font range:NSMakeRange(0, 1)];
    NSMutableAttributedString* currentAttr = [[NSMutableAttributedString alloc] initWithAttributedString:self.attributedText];
    [currentAttr replaceCharactersInRange:range withAttributedString:attrString];

    self.attributedText = currentAttr;
    self.selectedTextRange = [self textRangeFromPosition:[self positionFromPosition:currentRange.end offset:attrString.length] toPosition:[self positionFromPosition:currentRange.end offset:attrString.length]];
//    self.attributedText = attrString;
    if (self.attributedText.length == 0) {
        self.placeholder = self.placeHolderStr;
    }else {
        if (self.placeHolderStr.length == 0) {
            self.placeHolderStr = self.placeholder;
        }
        
        self.placeholder = @"";
    }
    
    [self.delegate textViewDidChange:self];

}

- (void)sendBtnClickEvent{
    
    NSMutableString* tempString = [NSMutableString string];
    
    [self.attributedText enumerateAttributesInRange:NSMakeRange(0, self.attributedText.length) options:0 usingBlock:^(NSDictionary<NSString *,id> * _Nonnull attrs, NSRange range, BOOL * _Nonnull stop) {
        NSAttributedString* attrStr = [self.attributedText attributedSubstringFromRange:range];
        if (attrs[@"NSAttachment"] != nil) {
            EmoticonAttachment* emoticonAtt = attrs[@"NSAttachment"];
            [tempString appendString:emoticonAtt.chs];
        }else{
            [tempString appendString:attrStr.string];
        }
    }];
    
    NSRange range;
    range.location = 0;
    range.length = tempString.length;
    [tempString replaceOccurrencesOfString:@"😖"
                             withString:@"[:s]"
                                options:NSLiteralSearch
                                  range:range];
    range.location = 0;
    range.length = tempString.length;
    [tempString replaceOccurrencesOfString:@"😐"
                                withString:@"[:|]"
                                   options:NSLiteralSearch
                                     range:range];
    range.location = 0;
    range.length = tempString.length;
    [tempString replaceOccurrencesOfString:@"😇"
                                withString:@"[(a)]"
                                   options:NSLiteralSearch
                                     range:range];
    range.location = 0;
    range.length = tempString.length;
    [tempString replaceOccurrencesOfString:@"🎅"
                                withString:@"[<o)]"
                                   options:NSLiteralSearch
                                     range:range];
    range.location = 0;
    range.length = tempString.length;
    [tempString replaceOccurrencesOfString:@"😯"
                                withString:@"[:-*]"
                                   options:NSLiteralSearch
                                     range:range];
    range.location = 0;
    range.length = tempString.length;
    [tempString replaceOccurrencesOfString:@"😑"
                                withString:@"[8-)]"
                                   options:NSLiteralSearch
                                     range:range];
    
    if ([self.TZdelegate respondsToSelector:@selector(sendMessageAction:)]) {
        [self.TZdelegate sendMessageAction:tempString];
    }
    
    NSLog(@" send %@",tempString);
    self.attributedText = nil;
    
    self.placeholder = self.placeHolderStr;
    
}

#pragma mark - lazyLoad
- (UIView *)emojiKeyBoard{
    if (_emojiKeyBoard == nil) {
        self.keyBoardVC = [[TZEmojiKeyBoardVC alloc] init];
        _emojiKeyBoard = self.keyBoardVC.view;
        self.keyBoardVC.delegate = self;
    }
    return _emojiKeyBoard;
}


@end

//
//  TZEmojiTextConvertor.m
//  emojiKeyBoard
//
//  Created by 冯宁 on 15/9/25.
//  Copyright © 2015年 PeachTravel. All rights reserved.
//

#import "TZEmojiTextConvertor.h"
#import "EmoticonPackageModel.h"
#import "EmoticonModel.h"
#import "EmoticonAttachment.h"

@implementation TZEmojiTextConvertor

+ (NSString*)convertToTextWithAttrbuteString:(NSAttributedString*)emojiAttrStr {
    NSMutableString* tempString = [NSMutableString string];
    
    [emojiAttrStr enumerateAttributesInRange:NSMakeRange(0, emojiAttrStr.length) options:0 usingBlock:^(NSDictionary<NSString *,id> * _Nonnull attrs, NSRange range, BOOL * _Nonnull stop) {
        NSAttributedString* attrStr = [emojiAttrStr attributedSubstringFromRange:range];
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
    
    return [tempString copy];
    

}

+ (NSAttributedString*)convertToEmojiTextWithText:(NSString*)text withFont:(UIFont*)font{
    
    NSMutableString* tempString = [[NSMutableString alloc] initWithString:text];
    
    NSRange range;
    range.location = 0;
    range.length = tempString.length;
    [tempString replaceOccurrencesOfString:@"[:s]"
                                withString:@"😖"
                                   options:NSLiteralSearch
                                     range:range];
    range.location = 0;
    range.length = tempString.length;
    [tempString replaceOccurrencesOfString:@"[:|]"
                                withString:@"😐"
                                   options:NSLiteralSearch
                                     range:range];
    range.location = 0;
    range.length = tempString.length;
    [tempString replaceOccurrencesOfString:@"[(a)]"
                                withString:@"😇"
                                   options:NSLiteralSearch
                                     range:range];
    range.location = 0;
    range.length = tempString.length;
    [tempString replaceOccurrencesOfString:@"[<o)]"
                                withString:@"🎅"
                                   options:NSLiteralSearch
                                     range:range];
    range.location = 0;
    range.length = tempString.length;
    [tempString replaceOccurrencesOfString:@"[:-*]"
                                withString:@"😯"
                                   options:NSLiteralSearch
                                     range:range];
    range.location = 0;
    range.length = tempString.length;
    [tempString replaceOccurrencesOfString:@"[8-)]"
                                withString:@"😑"
                                   options:NSLiteralSearch
                                     range:range];
    
    NSMutableAttributedString* tempAttrStr = [[NSMutableAttributedString alloc] initWithString:@""];

    NSRange range1;
    NSRange range2;
    
    while ([tempString containsString:@"["] && [tempString containsString:@"]"]) {
        range1 = [tempString rangeOfString:@"["];
        range2 = [tempString rangeOfString:@"]"];
        
        NSMutableAttributedString* textAttr = [[NSMutableAttributedString alloc] initWithString:[tempString substringWithRange:NSMakeRange(0, range1.location)]];
        
        [textAttr addAttribute:NSFontAttributeName value:font range:NSMakeRange(0, textAttr.length)];
        
        [tempAttrStr appendAttributedString:textAttr];
        
        if (range1.location > range2.location) {
            [tempString deleteCharactersInRange:NSMakeRange(0, range1.location)];
            continue;
        }
        
        NSString* chs = [tempString substringWithRange:NSMakeRange(range1.location, range2.location - range1.location + 1)];
        [tempString deleteCharactersInRange:NSMakeRange(0, range2.location + 1)];
        NSArray* emoticonsPackages = [EmoticonPackageModel emoticonPackages];
        
        BOOL isEmoticon = NO;
        for (EmoticonPackageModel* package in emoticonsPackages) {
            for (EmoticonModel* model in package.emoticons) {
                if ([chs isEqualToString:model.chs]) {
                    EmoticonAttachment* attachment = [[EmoticonAttachment alloc] init];
                    attachment.chs = model.chs;
                    attachment.image = model.image;
                    CGFloat height = font.lineHeight;
                    attachment.bounds = CGRectMake(0, -font.lineHeight * 0.21, height * 1., height * 1);
                    NSMutableAttributedString* attrString = [[NSMutableAttributedString alloc] initWithAttributedString:[NSAttributedString attributedStringWithAttachment:attachment]];
                    [attrString addAttribute:NSFontAttributeName value:font range:NSMakeRange(0, 1)];
                    [tempAttrStr appendAttributedString:attrString];
                    isEmoticon = YES;
                }
            }
        }
        if (!isEmoticon) {
            [tempAttrStr appendAttributedString:[[NSAttributedString alloc] initWithString:chs]];
        }
    }
    
    [tempAttrStr appendAttributedString:[[NSAttributedString alloc] initWithString:tempString]];
    [tempAttrStr addAttribute:NSFontAttributeName value:font range:NSMakeRange(0, tempAttrStr.length)];
    return [tempAttrStr copy];
    
}

@end

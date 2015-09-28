//
//  TZEmojiTextConvertor.h
//  emojiKeyBoard
//
//  Created by 冯宁 on 15/9/25.
//  Copyright © 2015年 PeachTravel. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TZEmojiTextConvertor : NSObject

+ (NSString*)convertToTextWithAttrbuteString:(NSAttributedString*)emojiAttrStr;

+ (NSAttributedString*)convertToEmojiTextWithText:(NSString*)text withFont:(UIFont*)font;

@end

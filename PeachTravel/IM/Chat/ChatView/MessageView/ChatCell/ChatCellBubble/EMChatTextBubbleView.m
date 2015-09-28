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

#import <CoreText/CoreText.h>
#import "EMChatTextBubbleView.h"
#import "TZEmojiTextConvertor.h"

NSString *const kRouterEventTextURLTapEventName = @"kRouterEventTextURLTapEventName";

@interface EMChatTextBubbleView ()
{
    NSDataDetector *_detector;
    NSArray *_urlMatches;
}

@end

@implementation EMChatTextBubbleView

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        _textLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _textLabel.numberOfLines = 0;
        _textLabel.lineBreakMode = NSLineBreakByCharWrapping;
        _textLabel.font = [UIFont systemFontOfSize:LABEL_FONT_SIZE];
        _textLabel.backgroundColor = [UIColor clearColor];
        _textLabel.userInteractionEnabled = NO;
        _textLabel.multipleTouchEnabled = NO;
        _textLabel.textAlignment = NSTextAlignmentLeft;
        [self addSubview:_textLabel];
        
        /** #define BUBBLE_ARROW_WIDTH 5 // bubbleView中，箭头的宽度
         #define BUBBLE_VIEW_PADDING 5 // bubbleView 与 在其中的控件内边距
         #define BUBBLE_VIEW_TOP_PADDING 7 // bubbleView 与 在其中的控件上下边距
         
         #define BUBBLE_VIEW_WIDTH_PADDING  12   //bubbleView 与左右边距
         
         #define BUBBLE_RIGHT_LEFT_CAP_WIDTH 10 // 文字在右侧时,bubble用于拉伸点的X坐标
         #define BUBBLE_RIGHT_TOP_CAP_HEIGHT 25 // 文字在右侧时,bubble用于拉伸点的Y坐标
         
         #define BUBBLE_LEFT_LEFT_CAP_WIDTH 15 // 文字在左侧时,bubble用于拉伸点的X坐标
         #define BUBBLE_LEFT_TOP_CAP_HEIGHT 25 // 文字在左侧时,bubble用于拉伸点的Y坐标
         
         #define BUBBLE_PROGRESSVIEW_HEIGHT 10 // progressView 高度 */
        
//        NSDictionary* metrics = @{@"marginTop":@BUBBLE_VIEW_TOP_PADDING,@"marginSide":@BUBBLE_VIEW_WIDTH_PADDING,@"minHeight":    };
        
//        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H" options:<#(NSLayoutFormatOptions)#> metrics:<#(nullable NSDictionary<NSString *,id> *)#> views:<#(nonnull NSDictionary<NSString *,id> *)#>]];
        
        _detector = [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypeLink error:nil];
    }
    
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect frame = self.bounds;
    frame.size.width -= BUBBLE_ARROW_WIDTH;
    frame = CGRectInset(frame, BUBBLE_VIEW_PADDING, BUBBLE_VIEW_TOP_PADDING);
    if (self.model.isSender) {
        frame.origin.x = BUBBLE_VIEW_WIDTH_PADDING;
        _textLabel.textColor = [UIColor whiteColor];
    }else{
        frame.origin.x = BUBBLE_VIEW_WIDTH_PADDING + BUBBLE_ARROW_WIDTH;
        _textLabel.textColor = COLOR_TEXT_I;
    }
    
    frame.origin.y = BUBBLE_VIEW_TOP_PADDING;
    
//    CGSize textBlockMinSize = {TEXTLABEL_MAX_WIDTH, CGFLOAT_MAX};
//    CGSize retSize = [[TZEmojiTextConvertor convertToEmojiTextWithText:self.model.content withFont:_textLabel.font] boundingRectWithSize:textBlockMinSize options:NSStringDrawingUsesLineFragmentOrigin context:nil].size;
    
//    frame.size = retSize;
    
    [self.textLabel setFrame:frame];
}

- (CGSize)sizeThatFits:(CGSize)size
{
    CGSize textBlockMinSize = {TEXTLABEL_MAX_WIDTH, CGFLOAT_MAX};
//    CGSize retSize = [self.model.content boundingRectWithSize:textBlockMinSize options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[[self class] textLabelFont]} context:nil].size;
    CGSize retSize = [[TZEmojiTextConvertor convertToEmojiTextWithText:self.model.content withFont:_textLabel.font] boundingRectWithSize:textBlockMinSize options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading) context:nil].size;
    
//    CGSize retSize = [[TZEmojiTextConvertor convertToEmojiTextWithText:self.model.content withFont:_textLabel.font] sizewi];
    
    _textLabel.numberOfLines = 0;
    NSLog(@" 对应的文字  -------- %@",self.model.content);
    NSLog(@" boundingSize ------  %@",NSStringFromCGSize(retSize));
    
    CGFloat height = 42;
    if (2*BUBBLE_VIEW_TOP_PADDING + retSize.height > height) {
        height = 2*BUBBLE_VIEW_TOP_PADDING + retSize.height;
    }
    
    return CGSizeMake(retSize.width + BUBBLE_VIEW_WIDTH_PADDING*2 + BUBBLE_VIEW_PADDING, height);
}

#pragma mark - setter
- (void)setModel:(MessageModel *)model
{
    [super setModel:model];
    
    _urlMatches = [_detector matchesInString:self.model.content options:0 range:NSMakeRange(0, self.model.content.length)];
    NSAttributedString* attrStr = [TZEmojiTextConvertor convertToEmojiTextWithText:self.model.content withFont:_textLabel.font];
    _textLabel.attributedText = attrStr;
    
    [_textLabel sizeToFit];
    NSLog(@" recieve %@",self.model.content);
    [self highlightLinksWithIndex:NSNotFound];
}

- (BOOL)isIndex:(CFIndex)index inRange:(NSRange)range
{
    return index > range.location && index < range.location+range.length;
}

- (void)highlightLinksWithIndex:(CFIndex)index {
    
    NSMutableAttributedString* attributedString = [_textLabel.attributedText mutableCopy];
    
    for (NSTextCheckingResult *match in _urlMatches) {
        
        if ([match resultType] == NSTextCheckingTypeLink) {
            
            NSRange matchRange = [match range];
            
            if ([self isIndex:index inRange:matchRange]) {
                [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor grayColor] range:matchRange];
            }
            else {
                [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor blueColor] range:matchRange];
            }
            
            [attributedString addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInteger:NSUnderlineStyleSingle] range:matchRange];
        }
    }
    
    _textLabel.attributedText = attributedString;
}

- (CFIndex)characterIndexAtPoint:(CGPoint)point
{
    NSMutableAttributedString* optimizedAttributedText = [self.textLabel.attributedText mutableCopy];
    
    [self.textLabel.attributedText enumerateAttributesInRange:NSMakeRange(0, [self.textLabel.attributedText length]) options:0 usingBlock:^(NSDictionary *attrs, NSRange range, BOOL *stop) {
        
        if (!attrs[(NSString*)kCTFontAttributeName])
        {
            [optimizedAttributedText addAttribute:(NSString*)kCTFontAttributeName value:self.textLabel.font range:NSMakeRange(0, [self.textLabel.attributedText length])];
        }
        
        if (!attrs[(NSString*)kCTParagraphStyleAttributeName])
        {
            NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
            [paragraphStyle setLineBreakMode:self.textLabel.lineBreakMode];
            
            [optimizedAttributedText addAttribute:(NSString*)kCTParagraphStyleAttributeName value:paragraphStyle range:range];
        }
    }];
    
    [optimizedAttributedText enumerateAttribute:(NSString*)kCTParagraphStyleAttributeName inRange:NSMakeRange(0, [optimizedAttributedText length]) options:0 usingBlock:^(id value, NSRange range, BOOL *stop)
     {
         NSMutableParagraphStyle* paragraphStyle = [value mutableCopy];
         
         if ([paragraphStyle lineBreakMode] == NSLineBreakByTruncatingTail) {
             [paragraphStyle setLineBreakMode:NSLineBreakByWordWrapping];
         }
         
         [optimizedAttributedText removeAttribute:(NSString*)kCTParagraphStyleAttributeName range:range];
         [optimizedAttributedText addAttribute:(NSString*)kCTParagraphStyleAttributeName value:paragraphStyle range:range];
     }];
    
    if (!CGRectContainsPoint(self.bounds, point)) {
        return NSNotFound;
    }
    
    CGRect textRect = self.textLabel.frame;
    
    if (!CGRectContainsPoint(textRect, point)) {
        return NSNotFound;
    }
    
    point = CGPointMake(point.x - textRect.origin.x, point.y - textRect.origin.y);
    point = CGPointMake(point.x, textRect.size.height - point.y);
    
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((__bridge CFAttributedStringRef)optimizedAttributedText);
    
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, textRect);
    
    CTFrameRef frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, [self.textLabel.attributedText length]), path, NULL);
    
    if (frame == NULL) {
        CFRelease(path);
        return NSNotFound;
    }
    
    CFArrayRef lines = CTFrameGetLines(frame);
    
    NSInteger numberOfLines = self.textLabel.numberOfLines > 0 ? MIN(self.textLabel.numberOfLines, CFArrayGetCount(lines)) : CFArrayGetCount(lines);
    
    //NSLog(@"num lines: %d", numberOfLines);
    
    if (numberOfLines == 0) {
        CFRelease(frame);
        CFRelease(path);
        return NSNotFound;
    }
    
    NSUInteger idx = NSNotFound;
    
    CGPoint lineOrigins[numberOfLines];
    CTFrameGetLineOrigins(frame, CFRangeMake(0, numberOfLines), lineOrigins);
    
    for (CFIndex lineIndex = 0; lineIndex < numberOfLines; lineIndex++) {
        
        CGPoint lineOrigin = lineOrigins[lineIndex];
        CTLineRef line = CFArrayGetValueAtIndex(lines, lineIndex);
        
        // Get bounding information of line
        CGFloat ascent, descent, leading, width;
        width = CTLineGetTypographicBounds(line, &ascent, &descent, &leading);
        CGFloat yMin = floor(lineOrigin.y - descent);
        CGFloat yMax = ceil(lineOrigin.y + ascent);
        
        // Check if we've already passed the line
        if (point.y > yMax) {
            break;
        }
        
        // Check if the point is within this line vertically
        if (point.y >= yMin) {
            
            // Check if the point is within this line horizontally
            if (point.x >= lineOrigin.x && point.x <= lineOrigin.x + width) {
                
                // Convert CT coordinates to line-relative coordinates
                CGPoint relativePoint = CGPointMake(point.x - lineOrigin.x, point.y - lineOrigin.y);
                idx = CTLineGetStringIndexForPosition(line, relativePoint);
                
                break;
            }
        }
    }
    
    CFRelease(frame);
    CFRelease(path);
    
    return idx;
}

#pragma mark - public

- (void)bubbleViewPressed:(id)sender
{
    UITapGestureRecognizer *tap = (UITapGestureRecognizer *)sender;
    CGPoint point = [tap locationInView:_textLabel];
    CFIndex charIndex = [self characterIndexAtPoint:point];
    [self highlightLinksWithIndex:NSNotFound];
    for (NSTextCheckingResult *match in _urlMatches) {
        if ([match resultType] == NSTextCheckingTypeLink) {
            NSRange matchRange = [match range];
            if ([self isIndex:charIndex inRange:matchRange]) {
                [self routerEventWithName:kRouterEventTextURLTapEventName userInfo:@{KMESSAGEKEY:self.model, @"url":match.URL}];
                break;
            }
        }
    }
}

+ (CGFloat)heightForBubbleWithObject:(MessageModel *)object
{
    CGSize textBlockMinSize = {TEXTLABEL_MAX_WIDTH, CGFLOAT_MAX};
    CGSize size;
    size = [object.content boundingRectWithSize:textBlockMinSize options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[self textLabelFont]} context:nil].size;
    return 2*BUBBLE_VIEW_TOP_PADDING + size.height+10;
}

+ (UIFont *)textLabelFont
{
    return [UIFont systemFontOfSize:LABEL_FONT_SIZE];
}

+ (NSLineBreakMode)textLabelLineBreakModel
{
    return NSLineBreakByCharWrapping;
}


@end

//
//  ResizableView.h
//  PeachTravel
//
//  Created by liangpengshuai on 11/17/14.
//  Copyright (c) 2014 com.aizou.www. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ResizableView : UILabel

@property (nonatomic, copy) NSString *content;
@property (nonatomic) CGFloat resizeHeight;

- (void)showMoreContent;

- (void)hideContent;

/**
 *  全部展开需要的行数
 *
 *  @return
 */
- (NSInteger)maxNumberOfLine;

@end

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

- (void)showMoreContent;

- (void)hideContent;

@end

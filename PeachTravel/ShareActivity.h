//
//  ShareActivity.h
//  lvxingpai
//
//  Created by liangpengshuai on 14-8-4.
//  Copyright (c) 2014年 aizou. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ActivityDelegate <NSObject>
- (void)didClickOnImageIndex:(NSInteger)imageIndex;
@optional
- (void)didClickOnCancelButton;
@end

@interface ShareActivity : UIView

- (id)initWithTitle:(NSString *)title delegate:(id<ActivityDelegate>)delegate cancelButtonTitle:(NSString *)cancelButtonTitle ShareButtonTitles:(NSArray *)shareButtonTitlesArray withShareButtonImagesName:(NSArray *)shareButtonImagesNameArray;
- (void)showInView:(UIView *)view;

@end


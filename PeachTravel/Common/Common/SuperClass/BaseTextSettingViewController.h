//
//  ChangeUserInfoViewController.h
//  PeachTravel
//
//  Created by liangpengshuai on 14/10/15.
//  Copyright (c) 2014年 com.aizou.www. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^saveComplteBlock)(BOOL completed);
typedef void(^saveEdition)(NSString *text, saveComplteBlock(completed));
@interface BaseTextSettingViewController : TZViewController

@property (nonatomic) UserInfoChangeType changeType;

@property (copy, nonatomic) NSString *content;
@property (nonatomic, copy) NSString *navTitle;
@property (nonatomic, assign) BOOL acceptEmptyContent;

@property (nonatomic, copy) void (^saveEdition)(NSString *editText, saveComplteBlock(completed));

@end

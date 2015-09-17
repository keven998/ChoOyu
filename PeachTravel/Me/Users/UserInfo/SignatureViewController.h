//
//  SignatureViewController.h
//  PeachTravel
//
//  Created by dapiao on 15/5/14.
//  Copyright (c) 2015年 com.aizou.www. All rights reserved.
//

#import "TZViewController.h"

typedef void(^saveComplteBlock)(BOOL completed);
typedef void(^saveEdition)(NSString *text, saveComplteBlock(completed));

@interface SignatureViewController : TZViewController

@property (nonatomic) UserInfoChangeType changeType;

@property (copy, nonatomic) NSString *content;
@property (nonatomic, copy) NSString *navTitle;
@property (nonatomic, assign) BOOL acceptEmptyContent;

@property (nonatomic, copy) void (^saveEdition)(NSString *editText, saveComplteBlock(completed));

@end

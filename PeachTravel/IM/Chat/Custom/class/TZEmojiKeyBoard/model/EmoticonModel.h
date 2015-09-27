//
//  EmoticonModel.h
//  emojiKeyBoard
//
//  Created by 冯宁 on 15/9/17.
//  Copyright (c) 2015年 PeachTravel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ARGUMENTS.h"

@interface EmoticonModel : NSObject

@property (nonatomic, copy) NSString* chs;
@property (nonatomic, copy) NSString* gif;
@property (nonatomic, copy) NSString* png;
@property (nonatomic, copy) NSString* path;
@property (nonatomic, copy) NSString* code;
@property (nonatomic, copy) NSString* emoji;
@property (nonatomic, assign) BOOL isDeleteBtn;
@property (nonatomic, assign) NSInteger count;

@property (nonatomic, strong) UIImage* image;

+ (NSMutableArray*)emoticonArrayWithArray:(NSArray*)array path:(NSString*)path;

@end

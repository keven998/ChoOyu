//
//  EmoticonPackageModel.h
//  emojiKeyBoard
//
//  Created by 冯宁 on 15/9/17.
//  Copyright (c) 2015年 PeachTravel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ARGUMENTS.h"

@interface EmoticonPackageModel : NSObject

@property (nonatomic, copy) NSString* identity;
@property (nonatomic, copy) NSMutableArray* emoticons;
@property (nonatomic, copy) NSString* group_name_cn;
@property (nonatomic, copy) NSString* group_name_tw;
@property (nonatomic, copy) NSString* group_name_en;

+ (NSMutableArray*)emoticonPackages;

@end

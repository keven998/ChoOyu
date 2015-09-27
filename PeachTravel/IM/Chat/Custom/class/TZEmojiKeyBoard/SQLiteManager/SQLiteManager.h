//
//  SQLiteManager.h
//  SQLite_text
//
//  Created by 冯宁 on 15/8/17.
//  Copyright (c) 2015年 itcheima. All rights reserved.
//
@class EmoticonModel;
#import <Foundation/Foundation.h>
#import "ARGUMENTS.h"

@interface SQLiteManager : NSObject

+ (instancetype)sharedSQLiteManager;


- (void)upDateGoodWithModel:(EmoticonModel*)model;
- (void)loadModelWithModel:(EmoticonModel*)model;


@end

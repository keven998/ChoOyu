//
//  EmoticonModel.m
//  emojiKeyBoard
//
//  Created by 冯宁 on 15/9/17.
//  Copyright (c) 2015年 PeachTravel. All rights reserved.
//

#import "EmoticonModel.h"
#import "SQLiteManager.h"

#define EMOJI_CODE_TO_SYMBOL(x) ((((0x808080F0 | (x & 0x3F000) >> 4) | (x & 0xFC0) << 10) | (x & 0x1C0000) << 18) | (x & 0x3F) << 24);

@implementation EmoticonModel

- (instancetype)initWithDict:(NSDictionary*)dict path:(NSString*)path{
    if (self = [super init]) {
        self.path = path;
        [self setValuesForKeysWithDictionary:dict];
#ifndef EMOJI_SQLITE_LOCK
        SQLiteManager* manager = [SQLiteManager sharedSQLiteManager];
        [manager loadModelWithModel:self];
#endif
    }
    return self;
}

+ (NSMutableArray*)emoticonArrayWithArray:(NSArray*)array path:(NSString*)path{
    NSMutableArray* tempArray = [NSMutableArray array];
    NSInteger tag = 1;
    for (NSDictionary* dict in array) {
        if (tag % 21 == 0) {
            EmoticonModel* model = [[EmoticonModel alloc] init];
            model.isDeleteBtn = YES;
            [tempArray addObject:model];
            tag++;
        }
        EmoticonModel* model = [[EmoticonModel alloc] initWithDict:dict path:path];
        if (model.png.length == 0) {
            if ([model.chs isEqualToString:@"[:s]"]) {
                model.emoji = @"😖";
            }else if ([model.chs isEqualToString:@"[:|]"]) {
                model.emoji = @"😐";
            }else if ([model.chs isEqualToString:@"[(a)]"]) {
                model.emoji = @"😇";
            }else if ([model.chs isEqualToString:@"[<o)]"]) {
                model.emoji = @"🎅";
            }else if ([model.chs isEqualToString:@"[:-*]"]) {
                model.emoji = @"😯";
            }else if ([model.chs isEqualToString:@"[8-)]"]) {
                model.emoji = @"😑";
            }
        }
        [tempArray addObject:model];
        tag++;
    }
    return tempArray;
}

+ (NSString *)emojiWithCode:(int)code {
    int sym = EMOJI_CODE_TO_SYMBOL(code);
    return [[NSString alloc] initWithBytes:&sym length:sizeof(sym) encoding:NSUTF8StringEncoding];
}

- (void)setValue:(id)value forKey:(NSString *)key{
    if ([key isEqualToString:@"png"]) {
        _png = value;
        self.image = [UIImage imageWithContentsOfFile:[self.path stringByAppendingPathComponent:[NSString stringWithFormat:@"%@",self.png]]];
        return;
    }else if ([key isEqualToString:@"code"]){
        self.code = value;
        NSScanner* scanner = [NSScanner scannerWithString:self.code];
        UInt32 charactor = 0;
        [scanner scanHexInt:&charactor];
        self.emoji = [[NSString alloc] initWithBytes:&charactor length:4 encoding:NSUTF32LittleEndianStringEncoding];
        
    }
    [super setValue:value forKey:key];
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key {}

- (void)setIsDeleteBtn:(BOOL)isDeleteBtn{
    _isDeleteBtn = isDeleteBtn;
    if (isDeleteBtn) {
        self.count = -1;
    }
}

/** @property (nonatomic, copy) NSString* chs;
 @property (nonatomic, copy) NSString* gif;
 @property (nonatomic, copy) NSString* png; */
- (NSString *)description{
    
    NSArray* array = @[@"chs",@"gif",@"png",@"image",@"code"];
    
    return [[self dictionaryWithValuesForKeys:array] description];
}

@end

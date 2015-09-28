//
//  EmoticonPackageModel.m
//  emojiKeyBoard
//
//  Created by 冯宁 on 15/9/17.
//  Copyright (c) 2015年 PeachTravel. All rights reserved.
//

#import "EmoticonPackageModel.h"
#import "EmoticonModel.h"

@interface EmoticonPackageModel ()

@property (nonatomic, assign) BOOL isRecent;

@end

@implementation EmoticonPackageModel

- (instancetype)initWithDict:(NSDictionary*)dict{
    if (self = [super init]) {
        [self setValuesForKeysWithDictionary:dict];
    }
    return self;
}


+ (NSArray*)emoticonPackages{

    static NSMutableArray* tempArray;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        tempArray = [NSMutableArray array];
        
        NSString* path = [[[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"Emoticons.bundle"] stringByAppendingPathComponent:@"emoticons.plist"];
        NSDictionary* dict = [NSDictionary dictionaryWithContentsOfFile:path];
        NSArray* array = dict[@"packages"];
        
        
#ifndef EMOJI_SQLITE_LOCK
        EmoticonPackageModel* firstModel = [[EmoticonPackageModel alloc] init];
        //    firstModel.emoticons = [NSMutableArray array];
        firstModel.group_name_cn = @"最近";
        firstModel.group_name_tw = @"最近";
        firstModel.group_name_en = @"Recent";
        firstModel.isRecent = YES;
        [tempArray addObject:firstModel];
        NSMutableArray* firstModelEmoticons = [NSMutableArray array];
#endif
        for (NSDictionary* tempDict in array) {
            EmoticonPackageModel* model = [[EmoticonPackageModel alloc] initWithDict:tempDict];
#ifndef EMOJI_SQLITE_LOCK
            for (EmoticonModel* sonModel in model.emoticons) {
                if (sonModel.count > 0) {
                    [firstModelEmoticons addObject:sonModel];
                }
            }
#endif
            [tempArray addObject:model];
        }
#ifndef EMOJI_SQLITE_LOCK
        [firstModelEmoticons sortUsingComparator:^NSComparisonResult(EmoticonModel* obj1, EmoticonModel* obj2) {
            //NSOrderedAscending = -1L, NSOrderedSame, NSOrderedDescending
            if (obj1.count > obj2.count) {
                return NSOrderedAscending;
            }else{
                return NSOrderedDescending;
            }
        }];
        
        firstModel.emoticons = firstModelEmoticons;
#endif

    });
    
    return tempArray;
}

#pragma mark - setValue ForKey
- (void)setValue:(id)value forKey:(NSString *)key{
    if ([key isEqualToString:@"identity"]) {
        _identity = value;
        NSString* path = [[[[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"Emoticons.bundle"]  stringByAppendingPathComponent:self.identity] stringByAppendingPathComponent:@"info.plist"];
        NSDictionary* dict = [NSDictionary dictionaryWithContentsOfFile:path];
        [self setValuesForKeysWithDictionary:dict];
        return;
    }else if ([key isEqualToString:@"emoticons"]) {
        NSArray* array = value;
        self.emoticons = [EmoticonModel emoticonArrayWithArray:array path:[[[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"Emoticons.bundle"]  stringByAppendingPathComponent:self.identity]];
        return;
    }
    [super setValue:value forKey:key];
}

#pragma mark - setter & getter

- (void)setEmoticons:(NSMutableArray *)emoticons{
    
    if (self.isRecent) {
        if (emoticons.count > EMOJI_RANK * EMOJI_ROW - 1) {
            for (NSInteger i = emoticons.count - 1; i >= EMOJI_RANK * EMOJI_ROW - 1; i--) {
                [emoticons removeObjectAtIndex:i];
            }
        }
    }
    
    NSInteger insertNum = emoticons.count % (EMOJI_RANK * EMOJI_ROW);
    if (insertNum == 0 && emoticons.count > 0) {
        _emoticons = emoticons;
        return;
    }
    insertNum = EMOJI_RANK * EMOJI_ROW - insertNum;
    NSMutableArray* tempArray = [NSMutableArray arrayWithArray:emoticons];
    for (NSInteger i = 0; i < insertNum - 1; i++) {
        [tempArray addObject:[[EmoticonModel alloc] init]];
    }
    EmoticonModel* deleteModel = [[EmoticonModel alloc] init];
    deleteModel.isDeleteBtn = YES;
    [tempArray addObject:deleteModel];
    _emoticons = tempArray;

}

#pragma mark - other
/** @property (nonatomic, copy) NSString* identity;
 @property (nonatomic, copy) NSArray* emoticons;
 @property (nonatomic, copy) NSString* group_name_cn;
 @property (nonatomic, copy) NSString* group_name_tw;
 @property (nonatomic, copy) NSString* group_name_en; */
- (NSString *)description{
    
    NSArray* array = @[@"identity",@"emoticons",@"group_name_cn",@"group_name_tw",@"group_name_en"];

    return [[self dictionaryWithValuesForKeys:array] description];
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key{ }


@end

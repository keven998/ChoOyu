//
//  SQLiteManager.m
//  SQLite_text
//
//  Created by 冯宁 on 15/8/17.
//  Copyright (c) 2015年 itcheima. All rights reserved.
//

#import "SQLiteManager.h"
#import "FMDB.h"
#import "EmoticonModel.h"

@interface SQLiteManager ()

@property (nonatomic, strong) FMDatabaseQueue* queue;

@end

@implementation SQLiteManager

+ (instancetype)sharedSQLiteManager {
    static SQLiteManager* manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[SQLiteManager alloc] init];
        NSString* path = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"FavoriteEmoticon.db"];
        NSLog(@"SQLitePath ---- %@",path);
        manager.queue = [[FMDatabaseQueue alloc] initWithPath:path];
        [manager creatTable];
    });
    return manager;
}

- (void)creatTable {
    NSString* path = [[NSBundle mainBundle] pathForResource:@"favouriteEmoticon.sql" ofType:nil];
    NSError* error;
    NSString* statement = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&error];
    if (error != nil) {
        NSLog(@"创表字符串错误 ----- %@",error);
    }
    
    [self.queue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        if ([db executeUpdate:statement]) {
            NSLog(@"创表成功");
        }else{
            NSLog(@"创表失败");
        }
    }];
}

- (void)insertGoodWithModel:(EmoticonModel*)model {

    NSString* insertStatement = @"INSERT INTO emoticon (png,code,count) VALUES (?,?,?);";
    [self.queue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        if ([db executeUpdate:insertStatement withArgumentsInArray:@[model.png != nil ? model.png : @"",model.code != nil ? model.code : @"",[NSNumber numberWithInteger:model.count]]]) {
            NSLog(@"添加成功");
        }else{
            NSLog(@"添加失败");
        }
    }];
    
}

- (void)upDateGoodWithModel:(EmoticonModel*)model{
    
    if (![self searchModelWithModel:model]) {
        [self insertGoodWithModel:model];
        return;
    }
    
    NSString* updateStatement = [NSString string];
    NSString* arguments = [NSString string];
    if (model.png != nil) {
        updateStatement = @"UPDATE emoticon SET count = ? WHERE png = ?;";
        arguments = model.png;
    }else if (model.code != nil){
        updateStatement = @"UPDATE emoticon SET count = ? WHERE code = ?;";
        arguments = model.code;
    }
    
    [self.queue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        [db executeUpdate:updateStatement withArgumentsInArray:@[[NSNumber numberWithInteger:model.count],arguments]];
    }];
}

- (void)loadModelWithModel:(EmoticonModel*)model {

        NSString* upDateStatement = [NSString string];
        NSString* arguments = [NSString string];
        if (model.png != nil) {
            upDateStatement = @"SELECT * FROM emoticon WHERE png = ?;";
            arguments = model.png;
        }else if (model.code != nil){
            upDateStatement = @"SELECT * FROM emoticon WHERE code = ?;";
            arguments = model.code;
        }

    if ([model.png isEqualToString:@"d_haha.png"]) {
        NSLog(@"");
    }
    
        [self.queue inTransaction:^(FMDatabase *db, BOOL *rollback) {
            FMResultSet* result = [db executeQuery:upDateStatement withArgumentsInArray:@[arguments]];
           
            while ([result next]) {
                model.count = [result longForColumn:@"count"];
//                NSLog(@"%ld",model.count);
            }
            
        }];

}


- (BOOL)searchModelWithModel:(EmoticonModel*)searchModel {
    NSString* loadStatement = [NSString string];
    NSString* arguments = [NSString string];
    if (searchModel.png != nil) {
        loadStatement = @"SELECT * FROM emoticon WHERE png = ?;";
        arguments = searchModel.png;
    }else if (searchModel.code != nil){
        loadStatement = @"SELECT * FROM emoticon WHERE code = ?;";
        arguments = searchModel.code;
    }
    __block BOOL returnResult = NO;
    [self.queue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        FMResultSet* result = [db executeQuery:loadStatement withArgumentsInArray:@[arguments]];
        
        if (![result next]) {
            return;
        }
        NSLog(@"%@",result);
        returnResult = YES;
    }];
    
    return returnResult;
    
}


@end

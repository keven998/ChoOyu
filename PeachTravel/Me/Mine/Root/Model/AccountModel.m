//
//  AccountModel.m
//  PeachTravel
//
//  Created by liangpengshuai on 4/1/15.
//  Copyright (c) 2015 com.aizou.www. All rights reserved.
//

#import "AccountModel.h"
#import "AppDelegate.h"


@implementation AlbumImage

- (id)initWithJson: (id)json
{
    if (self = [super init]) {
        _imageId = [json objectForKey:@"id"];
        _image = [[TaoziImage alloc] initWithJson:[[json objectForKey:@"image"] firstObject]];
        _createTime = [[json objectForKey:@"cTime"] longValue];
    }
    return self;
}

@end

@implementation AccountModel

- (Account *)basicUserInfo
{
    if (!_basicUserInfo) {
        NSError *error = nil;
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        NSManagedObjectContext *context = [((AppDelegate *)[[UIApplication sharedApplication] delegate]) managedObjectContext];
        request.entity = [NSEntityDescription entityForName:@"Account" inManagedObjectContext:context];
        NSArray *objes = [context executeFetchRequest:request error:&error];
        if (error) {
            [NSException raise:@"查询错误" format:@"%@", [error localizedDescription]];
        }
        _basicUserInfo = [objes firstObject];
    }
    return _basicUserInfo;
}

- (NSMutableArray *)frendList
{
    if (!_frendList) {
        _frendList = [[NSMutableArray alloc] init];
    }
    return _frendList;
}

/**
 *  更新用户信息
 *
 *  @param json 从网上加载的用户信息
 */
- (void)updateUserInfo:(id)json
{
    if ([json objectForKey:@"residence"] == [NSNull null]) {
        _residence = @"";
    } else {
        _residence = [json objectForKey:@"residence"];
    }
    if ([json objectForKey:@"zodiac"] == [NSNull null]) {
        _zodiac = @"";
    } else {
        _zodiac = [json objectForKey:@"zodiac"];
    }
    if ([json objectForKey:@"birthday"] == [NSNull null]) {
        _birthday = @"";
    } else {
        _birthday = [json objectForKey:@"birthday"];
    }
    
    if ([json objectForKey:@"tracks"] == [NSNull null]) {
        _tracks = [[NSMutableDictionary alloc] init];
    } else {
        _tracks = [json objectForKey:@"tracks"];
    }
    
    if ([json objectForKey:@"travelStatus"] == [NSNull null]) {
        _travelStatus = @"";
    } else {
        _travelStatus = [json objectForKey:@"travelStatus"];
    }
}

- (void)loadUserInfoFromServer:(void (^)(bool isSuccess))completion
{
    AccountManager *accountManager = [AccountManager shareAccountManager];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    AppUtils *utils = [[AppUtils alloc] init];
    [manager.requestSerializer setValue:utils.appVersion forHTTPHeaderField:@"Version"];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"iOS %@",utils.systemVersion] forHTTPHeaderField:@"Platform"];
    
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [manager.requestSerializer setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"%@", accountManager.account.userId] forHTTPHeaderField:@"UserId"];
    NSString *url = [NSString stringWithFormat:@"%@%@", API_USERINFO, accountManager.account.userId];
    
    [manager GET:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"%@", responseObject);
        NSInteger code = [[responseObject objectForKey:@"code"] integerValue];
        if (code == 0) {
            [self updateUserInfo:[responseObject objectForKey:@"result"]];
            [accountManager updateUserInfo:[responseObject objectForKey:@"result"]];
            completion(YES);
        } else {
            completion(NO);

        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        completion(NO);
    }];
}

@end

//
//  AccountModel.m
//  PeachTravel
//
//  Created by liangpengshuai on 4/1/15.
//  Copyright (c) 2015 com.aizou.www. All rights reserved.
//

#import "AccountModel.h"
#import "AppDelegate.h"
#import "PeachTravel-swift.h"

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

- (id)initWithJson: (id)json
{
    if (self = [super init]) {
        _userId = [[json objectForKey:@"userId"] integerValue];
        _nickName = [json objectForKey:@"nickName"];
        if ([json objectForKey:@"avatar"]) {
            _avatar = [json objectForKey:@"avatar"];
        } else {
            _avatar = @"";
        }
        if ([json objectForKey:@"avatarSmall"]) {
            _avatarSmall = [json objectForKey:@"avatarSmall"];
        } else {
            _avatarSmall = @"";
        }
        if ([json objectForKey:@"tel"]) {
            _tel = [json objectForKey:@"tel"];
        } else {
            _tel = @"";
        }
        
        if ([json objectForKey:@"secToken"]) {
            _secToken = [json objectForKey:@"secToken"];
        } else {
            _secToken = @"";
        }
        if ([json objectForKey:@"signature"]) {
            _signature = [json objectForKey:@"signature"];
        } else {
            _signature = @"";
        }
        _gender = [json objectForKey:@"gender"];
        if (!_gender) {
            _gender = @"U";
        }
    
    }
    return self;
}

- (NSMutableArray *)frendList
{
    if (!_frendList) {
        FrendManager *frendManager = [[FrendManager alloc] init];
        _frendList = [[frendManager getAllMyContacts] mutableCopy];
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
    if ([json objectForKey:@"guideCnt"] == [NSNull null]) {
        _guideCnt = 0;
    } else {
        _guideCnt = [[json objectForKey:@"guideCnt"] integerValue];
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
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    AppUtils *utils = [[AppUtils alloc] init];
    [manager.requestSerializer setValue:utils.appVersion forHTTPHeaderField:@"Version"];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"iOS %@",utils.systemVersion] forHTTPHeaderField:@"Platform"];
    
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [manager.requestSerializer setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"%ld", self.userId] forHTTPHeaderField:@"UserId"];
    NSString *url = [NSString stringWithFormat:@"%@%ld", API_USERINFO, self.userId];
    
    [manager GET:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"%@", responseObject);
        NSInteger code = [[responseObject objectForKey:@"code"] integerValue];
        if (code == 0) {
            [self updateUserInfo:[responseObject objectForKey:@"result"]];
            completion(YES);
        } else {
            completion(NO);

        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        completion(NO);
    }];
}

@end

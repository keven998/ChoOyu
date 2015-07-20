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
        NSString *genderStr = [json objectForKey:@"gender"];
        if ([genderStr isEqualToString:@"M"]) {
            _gender = Male;
        } else if ([genderStr isEqualToString:@"F"]) {
            _gender = Female;
        } else if ([genderStr isEqualToString:@"S"]) {
            _gender = Secret;
        }
        if (!_gender) {
            _gender = Unknown;
        }
    
    }
    return self;
}

- (NSMutableArray *)frendList
{
    if (!_frendList) {
        FrendManager *frendManager = [IMClientManager shareInstance].frendManager;
        _frendList = [[frendManager getAllMyContactsInDB] mutableCopy];
    }
    return _frendList;
}

- (NSArray *)userAlbum
{
    if (!_userAlbum) {
        _userAlbum = [NSArray array];
    }
    return _userAlbum;
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
    
    if ([json objectForKey:@"travelStatus"] == [NSNull null]) {
        _travelStatus = @"";
    } else {
        _travelStatus = [json objectForKey:@"travelStatus"];
    }
    
    _footprintsDesc = @"0国家0城市";
    
    NSString *genderStr = [json objectForKey:@"gender"];
    if ([genderStr isEqualToString:@"F"]) {
        _gender = Female;
    } else if ([genderStr isEqualToString:@"M"]) {
        _gender = Male;
    } else if ([genderStr isEqualToString:@"S"]) {
        _gender = Secret;
    } else if ([genderStr isEqualToString:@"U"]) {
        _gender = Unknown;
    }
}

- (void)setFootprints:(NSMutableArray *)footprints
{
    _footprints = footprints;
    _footprintsDesc = [self footprintsDescWithFootprints];
    
}

- (NSString *)footprintsDescWithFootprints
{
    NSMutableArray *countriesArray = [[NSMutableArray alloc] init];
    for (CityDestinationPoi *poi in _footprints) {
        BOOL find = NO;
        for (NSString *countryId in countriesArray) {
            if ([poi.country.coutryId isEqualToString:countryId]) {
                find = YES;
                break;
            }
        }
        if (!find && poi.country.coutryId) {
            [countriesArray addObject:poi.country.coutryId];
        }
    }
    return [NSString stringWithFormat:@"%ld个国家，%ld个城市", countriesArray.count, _footprints.count];
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
    NSString *url = [NSString stringWithFormat:@"%@%ld", API_USERS, self.userId];
    
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

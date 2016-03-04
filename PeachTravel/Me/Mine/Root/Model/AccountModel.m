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

@implementation AccountModel

- (id)initWithJson: (id)json
{
    if (self = [super init]) {
        [self updateUserInfo:json];
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

- (NSMutableArray *)userAlbum
{
    if (!_userAlbum) {
        _userAlbum = [NSMutableArray array];
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
    
    if ([json objectForKey:@"signature"]) {
        _signature = [json objectForKey:@"signature"];
    } else {
        _signature = @"";
    }
    
    if ([json objectForKey:@"promotionCode"] == [NSNull null]) {
        _inviteCode = @"";
    } else {
        _inviteCode = [json objectForKey:@"promotionCode"];
    }
    
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
    
    if ([json objectForKey:@"level"] == [NSNull null]) {
        _level = 0;
    } else {
        _level = [[json objectForKey:@"level"] integerValue];
    }
    
    if ([json objectForKey:@"countryCnt"] == [NSNull null]) {
        _countryCount = 0;
    } else {
        _countryCount = [[json objectForKey:@"countryCnt"] intValue];
    }

    if ([json objectForKey:@"trackCnt"] == [NSNull null]) {
        _cityCount = 0;
    } else {
        _cityCount = [[json objectForKey:@"trackCnt"] intValue];;
    }

    int countryCount = [[json objectForKey:@"countryCnt"] intValue];
    int cityCount = [[json objectForKey:@"trackCnt"] intValue];
    
    _footprintsDesc = [NSString stringWithFormat:@"%d国%d城市", countryCount, cityCount];
    
    NSString *genderStr = [json objectForKey:@"gender"];
    if ([genderStr isEqualToString:@"F"]) {
        _gender = Female;
    } else if ([genderStr isEqualToString:@"M"]) {
        _gender = Male;
    } else if ([genderStr isEqualToString:@"S"]) {
        _gender = Secret;
    } else if ([genderStr isEqualToString:@"B"]) {
        _gender = Unknown;
    }
    if ([[json objectForKey:@"secretKey"] objectForKey:@"key"]) {
        _secToken = [[json objectForKey:@"secretKey"] objectForKey:@"key"];
    } 
    [[AccountDaoHelper shareInstance] addAccount2DB:self];
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
    _countryCount = countriesArray.count;
    _cityCount = _footprints.count;
    return [NSString stringWithFormat:@"%ld国%ld城市", (long)countriesArray.count, (long)_footprints.count];
}

- (void)loadUserInfoFromServer:(void (^)(bool isSuccess))completion
{
    NSString *url = [NSString stringWithFormat:@"%@%ld", API_USERS, (long)self.userId];
    
    [LXPNetworking GET:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
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


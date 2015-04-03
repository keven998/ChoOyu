//
//  AccountModel.m
//  PeachTravel
//
//  Created by liangpengshuai on 4/1/15.
//  Copyright (c) 2015 com.aizou.www. All rights reserved.
//

#import "AccountModel.h"
#import "AppDelegate.h"

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

- (id)initWihtJson:(id)json
{
    if (self = [super init]) {
        _residence = [json objectForKey:@"residence"];
        _zodiac = [json objectForKey:@"zodiac"];
    }
    return self;
}

- (void)loadUserInfoFromServer:(void (^)(bool isSuccess))completion
{
    
}

@end

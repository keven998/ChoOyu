//
//  UserProfile.m
//  PeachTravel
//
//  Created by Luo Yong on 15/4/17.
//  Copyright (c) 2015年 com.aizou.www. All rights reserved.
//

#import "UserProfile.h"

@implementation UserProfile


- (id) initWithJsonObject:(id)json {
    if (self = [super init]) {
        _userId = [json objectForKey:@"userId"];
        _avatarSmall = [json objectForKey:@"avatarSmall"];
        _name = [json objectForKey:@"nickName"];
        _gender = [json objectForKey:@"gender"];
        _residence = [json objectForKey:@"residence"];
        _level = [[json objectForKey:@"level"] integerValue];
        _signature = [json objectForKey:@"signature"];
        _roles = [json objectForKey:@"roles"];
        _travels = [json objectForKey:@"tracks"];
        _birthday = [json objectForKey:@"birthday"];
        _easemobUser = [json objectForKey:@"easemobUser"];
        _travelStatus = [json objectForKey:@"travelStatus"];
    }
    return self;
}

- (NSString *)getFootprintDescription {
    if (_travels == nil) return @"";
    NSInteger count = [_travels count];
    if (count == 0) return @"";
    int cityCount = 0;
    for (id key in _travels) {
        id vals = [_travels objectForKey:key];
        cityCount += [vals count];
    }
    return [NSString stringWithFormat:@"%ld国 %d个城市", count, cityCount];
    
}

- (NSString *)getRolesDescription {
    if (_roles == nil || _roles.count == 0) return @"";
    if ([[_roles objectAtIndex:0] isEqualToString:@"expert"]) {
        return @"达";
    }
    return @"";
}


- (NSString *)getConstellation {
    NSDate *date = [ConvertMethods stringToDate:_birthday withFormat:@"yyyy-MM-dd" withTimeZone:[NSTimeZone systemTimeZone]];
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:date];
    NSString *star = @"";
    NSInteger month = [components month];
    NSInteger day = [components day];
    if ((month == 1 && day >= 20) || (month == 2 && day <= 18)) {
        star = @"水瓶座";
    }
    else if ((month == 2 && day >= 19) || (month == 3 && day <= 20)) {
        star = @"双鱼座";
    }
    else if ((month == 3 && day >= 21) || (month == 4 && day <= 19)) {
        star = @"白羊座";
    }
    else if ((month == 4 && day >= 20) || (month == 5 && day <= 20)) {
        star = @"金牛座";
    }
    else if ((month == 5 && day >= 21) || (month == 6 && day <= 21)) {
        star = @"双子座";
    }
    else if ((month == 6 && day >= 22) || (month == 7 && day <= 22)) {
        star = @"巨蟹座";
    }
    else if ((month == 7 && day >= 23) || (month == 8 && day <= 22)) {
        star = @"狮子座";
    }
    else if ((month == 8 && day >= 23) || (month == 9 && day <= 22)) {
        star = @"处女座";
    }
    else if ((month == 9 && day >= 23) || (month == 10 && day <= 22)) {
        star = @"天秤座";
    }
    else if ((month == 10 && day >= 23) || (month == 11 && day <= 21)) {
        star = @"天蝎座";
    }
    else if ((month == 11 && day >= 22) || (month == 12 && day <= 21)) {
        star = @"射手座";
    }
    else if ((month == 12 && day >= 22) || (month == 1 && day <= 19)) {
        star = @"摩羯座";
    }
    return star;
}

@end

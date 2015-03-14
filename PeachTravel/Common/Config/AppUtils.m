//
//  AppUtils.m
//  lvxingpai
//
//  Created by Luo Yong on 14-6-24.
//  Copyright (c) 2014年 aizou. All rights reserved.
//

#include <sys/sysctl.h>
#import "AppUtils.h"
#import "OpenUDID.h"

@implementation AppUtils

@synthesize appVersion;
@synthesize unid;
@synthesize currentTime;
@synthesize systemVersion;
@synthesize deviceName;

- (long long) currentTime {
    long long time = [[NSDate date] timeIntervalSince1970];
    return time;
}

- (NSString *)appVersion {
    NSDictionary *infoDic = [[NSBundle mainBundle] infoDictionary];
    NSString *version = [infoDic objectForKey:@"CFBundleShortVersionString"];
    return version;
}

- (NSString *)unid {
//    [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
//    return [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    return [OpenUDID value];
}

- (NSString *)systemVersion {
    return [[UIDevice currentDevice] systemVersion];
}

- (NSString *)deviceName {
//    return [UIDevice currentDevice].systemName;
//    return [[UIDevice currentDevice] name];
    
    size_t size;
    sysctlbyname("hw.machine", NULL, &size, NULL, 0);
    char *machine = malloc(size);
    sysctlbyname("hw.machine", machine, &size, NULL, 0);
    NSString *platform = [NSString stringWithCString:machine encoding:NSUTF8StringEncoding];
    free(machine);
    
    return platform;
}

@end

//
//  NetworkReachability.m
//  PeachTravel
//
//  Created by liangpengshuai on 5/26/15.
//  Copyright (c) 2015 com.aizou.www. All rights reserved.
//

#import "NetworkReachability.h"

@interface NetworkReachability ()

@end

@implementation NetworkReachability

+ (NetworkReachability *)shareInstance
{
    static NetworkReachability *reachabililty;
    static dispatch_once_t token;
    dispatch_once(&token,^{
        //这里调用私有的initSingle方法
        reachabililty = [[NetworkReachability alloc] init];
    });
    return reachabililty;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setupNetworkListener];
    }
    return self;
}

- (void)setupNetworkListener
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];
    
    //Change the host name here to change the server you want to monitor.
    NSString *remoteHostName = @"www.baidu.com";
    
    self.hostReachability = [Reachability reachabilityWithHostName:remoteHostName];
    [self.hostReachability startNotifier];
    [self updateInterfaceWithReachability:self.hostReachability];
}

- (void)reachabilityChanged:(NSNotification *)note
{
    Reachability* curReach = [note object];
    NSParameterAssert([curReach isKindOfClass:[Reachability class]]);
    [self updateInterfaceWithReachability:curReach];
}


- (void)updateInterfaceWithReachability:(Reachability *)reachability
{
    if (reachability == self.hostReachability)
    {
        NetworkStatus netStatus = [reachability currentReachabilityStatus];
        NSDictionary *dic = @{@"status": [NSNumber numberWithInt:netStatus]};
        [[NSNotificationCenter defaultCenter] postNotificationName:networkConnectionStatusChangeNoti object:nil userInfo:dic];
    }
}


@end

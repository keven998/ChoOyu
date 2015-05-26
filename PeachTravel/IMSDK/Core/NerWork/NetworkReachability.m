//
//  NetworkReachability.m
//  PeachTravel
//
//  Created by liangpengshuai on 5/26/15.
//  Copyright (c) 2015 com.aizou.www. All rights reserved.
//

#import "NetworkReachability.h"
#import "Reachability.h"

@interface NetworkReachability ()

@property (nonatomic) Reachability *hostReachability;
@property (nonatomic) Reachability *internetReachability;
@property (nonatomic) Reachability *wifiReachability;

@end

@implementation NetworkReachability

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
    NSString *remoteHostName = @"www.apple.com";
    
    self.hostReachability = [Reachability reachabilityWithHostName:remoteHostName];
    [self.hostReachability startNotifier];
    [self updateInterfaceWithReachability:self.hostReachability];
    
    self.internetReachability = [Reachability reachabilityForInternetConnection];
    [self.internetReachability startNotifier];
    [self updateInterfaceWithReachability:self.internetReachability];
    
    self.wifiReachability = [Reachability reachabilityForLocalWiFi];
    [self.wifiReachability startNotifier];
    [self updateInterfaceWithReachability:self.wifiReachability];
}

- (void) reachabilityChanged:(NSNotification *)note
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
    
    if (reachability == self.internetReachability)
    {
    }
    
    if (reachability == self.wifiReachability)
    {
    }
}


@end

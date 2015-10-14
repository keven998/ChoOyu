//
//  DestinationManager.h
//  PeachTravel
//
//  Created by liangpengshuai on 9/24/15.
//  Copyright © 2015 com.aizou.www. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Destinations.h"

@interface DestinationManager : NSObject

+ (void)loadDomesticDestinationFromServer:(Destinations *)destinations lastModifiedTime:(NSString *)time completionBlock:(void (^)(BOOL isSuccess, Destinations *destination)) completetion;

+ (void)loadForeignDestinationFromServer:(Destinations *)destinations lastModifiedTime:(NSString *)time completionBlock:(void (^)(BOOL isSuccess, Destinations *destination)) completetion;

+ (void)loadDomesticDestinationFromCache:(Destinations *)destinations completionBlock:(void (^)(BOOL isSuccess, Destinations *destination, NSString *saveTime)) completetion;

+ (void)loadForeignDestinationFromCache:(Destinations *)destinations completionBlock:(void (^)(BOOL isSuccess, Destinations *destination, NSString *saveTime)) completetion;

+ (void)saveDomesticDestinations2Cache:(NSDictionary *)destinationDic lastModifiedTime:(NSString *)time;

+ (void)saveForeignDestinations2Cache:(NSDictionary *)destinationDic lastModifiedTime:(NSString *)time;

@end

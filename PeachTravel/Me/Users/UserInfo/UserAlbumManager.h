//
//  UserAlbumManager.h
//  PeachTravel
//
//  Created by liangpengshuai on 9/19/15.
//  Copyright © 2015 com.aizou.www. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserAlbumManager : NSObject

+ (void)uploadUserAlbums:(NSArray *)albums withCommonDesc:(NSString *)desc completion:(void(^)(BOOL isSuccess))completionBlock;

@end

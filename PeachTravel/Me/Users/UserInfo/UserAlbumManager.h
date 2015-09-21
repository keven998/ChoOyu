//
//  UserAlbumManager.h
//  PeachTravel
//
//  Created by liangpengshuai on 9/19/15.
//  Copyright © 2015 com.aizou.www. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserAlbumManager : NSObject

+ (void)uploadUserAlbumPhoto:(UIImage *)photo withPhotoDesc:(NSString *)desc progress:(void (^) (CGFloat progressValue))progressBlock completion:(void(^)(BOOL isSuccess))completionBlock;

@end

//
//  UploadUserAlbumViewController.h
//  PeachTravel
//
//  Created by liangpengshuai on 9/18/15.
//  Copyright © 2015 com.aizou.www. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UploadUserAlbumViewController : UIViewController

@property (nonatomic, strong) NSMutableArray *selectedPhotos;

@end



@interface UploadUserAlbumStatus : NSObject

@property (nonatomic) BOOL isBegin;
@property (nonatomic) BOOL isFinish;
@property (nonatomic) BOOL isFailure;
@property (nonatomic) BOOL isSuccess;
@property (nonatomic) CGFloat uploadProgressValue;

@end
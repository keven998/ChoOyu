//
//  UserAlbumSelectViewController.h
//  PeachTravel
//
//  Created by liangpengshuai on 9/17/15.
//  Copyright © 2015 com.aizou.www. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>

@interface UserAlbumSelectViewController : TZViewController

@property (nonatomic, strong) ALAssetsGroup *assetsGroup;

@property (nonatomic, strong) NSMutableArray *selectedPhotos;

@end
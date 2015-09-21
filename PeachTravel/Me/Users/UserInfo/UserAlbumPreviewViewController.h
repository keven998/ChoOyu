//
//  UserAlbumPreviewViewController.h
//  PeachTravel
//
//  Created by liangpengshuai on 9/16/15.
//  Copyright (c) 2015 com.aizou.www. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UserAlbumPreviewViewController : TZViewController

@property (nonatomic, strong) NSMutableArray *dataSource;

@property (nonatomic) NSUInteger currentIndex;

@property (nonatomic, strong) NSMutableArray *selectedPhotos;
@end

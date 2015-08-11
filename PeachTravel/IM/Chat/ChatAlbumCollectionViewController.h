//
//  ChatAlbumCollectionViewController.h
//  PeachTravel
//
//  Created by liangpengshuai on 8/11/15.
//  Copyright (c) 2015 com.aizou.www. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChatAlbumCollectionViewController : UICollectionViewController

//显示图集的集合
@property (nonatomic, strong) NSArray *albumList;

//显示大图的集合
@property (nonatomic, strong) NSArray *imageList;

@end

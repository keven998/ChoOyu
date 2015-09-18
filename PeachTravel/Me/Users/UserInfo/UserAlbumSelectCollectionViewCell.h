//
//  UserAlbumSelectCollectionViewCell.h
//  PeachTravel
//
//  Created by liangpengshuai on 9/16/15.
//  Copyright (c) 2015 com.aizou.www. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>

@interface UserAlbumSelectCollectionViewCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIImageView *backGroundImageView;

@property (weak, nonatomic) IBOutlet UIButton *selectBtn;

@property (nonatomic, strong) ALAsset *asset;


@end

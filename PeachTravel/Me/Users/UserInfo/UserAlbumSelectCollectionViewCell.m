//
//  UserAlbumSelectCollectionViewCell.m
//  PeachTravel
//
//  Created by liangpengshuai on 9/16/15.
//  Copyright (c) 2015 com.aizou.www. All rights reserved.
//

#import "UserAlbumSelectCollectionViewCell.h"

@implementation UserAlbumSelectCollectionViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setAsset:(ALAsset *)asset
{
    _asset = asset;
    [_backGroundImageView setImage:[UIImage imageWithCGImage:_asset.thumbnail]];
}

@end

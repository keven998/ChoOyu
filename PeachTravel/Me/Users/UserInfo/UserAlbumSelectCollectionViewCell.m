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
    [_selectBtn setImage:[UIImage imageNamed:@"icon_photo_normal.png"] forState:UIControlStateNormal];
    [_selectBtn setImage:[UIImage imageNamed:@"icon_photo_selected.png"] forState:UIControlStateSelected];
}

- (void)setAsset:(ALAsset *)asset
{
    _asset = asset;
    [_backGroundImageView setImage:[UIImage imageWithCGImage:_asset.thumbnail]];
}

@end

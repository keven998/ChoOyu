//
//  UploadUserAlbumCollectionViewCell.m
//  PeachTravel
//
//  Created by liangpengshuai on 9/18/15.
//  Copyright © 2015 com.aizou.www. All rights reserved.
//

#import "UploadUserAlbumCollectionViewCell.h"

@implementation UploadUserAlbumCollectionViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setImage:(UIImage *)image
{
    _image = image;
    _imageView.image = _image;
}

@end

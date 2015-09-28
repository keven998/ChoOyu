//
//  UploadUserAlbumCollectionViewCell.h
//  PeachTravel
//
//  Created by liangpengshuai on 9/18/15.
//  Copyright © 2015 com.aizou.www. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>

#import "UCZProgressView.h"

@class UploadUserAlbumStatus;

@interface UploadUserAlbumCollectionViewCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (nonatomic, strong) UIImage *image;

@property (weak, nonatomic) IBOutlet UCZProgressView *progressView;

@property (nonatomic, strong) UploadUserAlbumStatus *uploadStatus;

@property (weak, nonatomic) IBOutlet UILabel *failureTextLabel;
@end

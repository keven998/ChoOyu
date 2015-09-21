//
//  UploadUserAlbumCollectionViewCell.m
//  PeachTravel
//
//  Created by liangpengshuai on 9/18/15.
//  Copyright © 2015 com.aizou.www. All rights reserved.
//

#import "UploadUserAlbumCollectionViewCell.h"
#import "UploadUserAlbumViewController.h"

@implementation UploadUserAlbumCollectionViewCell

- (void)awakeFromNib {
    UIView *backgroundView = [[UIView alloc] initWithFrame:self.bounds];
    backgroundView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.2];
    _progressView.backgroundView = backgroundView;
    _progressView.tintColor = APP_THEME_COLOR;
    _progressView.showsText = YES;
    _progressView.indeterminate = NO;
    _progressView.hidden = YES;
}

- (void)setImage:(UIImage *)image
{
    _image = image;
    _imageView.image = _image;
}

- (void)setUploadStatus:(UploadUserAlbumStatus *)uploadStatus
{
    _uploadStatus = uploadStatus;
    if (_uploadStatus.isBegin) {
        _progressView.hidden = NO;
        _progressView.progress = 0;
    } else {
        _progressView.hidden = YES;
    }
    if (_uploadStatus.isSuccess) {
        NSLog(@"上传成功了");
        _progressView.hidden = YES;
        _progressView.progress = 0;
    }
    if (_uploadStatus.uploadProgressValue > 0.0) {
        _progressView.progress = _uploadStatus.uploadProgressValue;
    }
    
    if (_uploadStatus.isFailure) {
        _progressView.hidden = YES;
        _progressView.progress = 0;
        NSLog(@"上传失败了");
    }
    
}

@end

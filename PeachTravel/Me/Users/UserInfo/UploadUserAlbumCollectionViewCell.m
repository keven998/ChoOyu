//
//  UploadUserAlbumCollectionViewCell.m
//  PeachTravel
//
//  Created by liangpengshuai on 9/18/15.
//  Copyright © 2015 com.aizou.www. All rights reserved.
//

#import "UploadUserAlbumCollectionViewCell.h"
#import "UploadUserAlbumViewController.h"
#import "UploadUserPhotoStatus.h"

@implementation UploadUserAlbumCollectionViewCell

- (void)awakeFromNib {
    UIView *backgroundView = [[UIView alloc] initWithFrame:self.bounds];
    backgroundView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.3];
    _progressView.backgroundView = backgroundView;
    _progressView.tintColor = [UIColor whiteColor];
    _progressView.showsText = YES;
    _progressView.indeterminate = NO;
    _progressView.hidden = YES;
    _failureTextLabel.hidden = YES;
    _failureTextLabel.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.3];
    _failureTextLabel.text = @"上传失败";
    _failureTextLabel.textColor = [UIColor whiteColor];
}

- (void)setImage:(UIImage *)image
{
    _image = image;
    _imageView.image = _image;
}

- (void)setUploadStatus:(UploadUserPhotoStatus *)uploadStatus
{
    _uploadStatus = uploadStatus;
    if (_uploadStatus.isBegin) {
        _progressView.hidden = NO;
        _failureTextLabel.hidden = YES;
        _progressView.progress = 0;
    } else {
        _progressView.hidden = YES;
        _failureTextLabel.hidden = YES;
    }
    if (_uploadStatus.isSuccess) {
        NSLog(@"上传成功了");
        _progressView.hidden = YES;
        _failureTextLabel.hidden = YES;
        _progressView.progress = 0;
    }
    if (_uploadStatus.uploadProgressValue > 0.0) {
        _progressView.progress = _uploadStatus.uploadProgressValue;
    }
    
    if (_uploadStatus.isFailure) {
        _progressView.hidden = YES;
        _progressView.progress = 0;
        _failureTextLabel.hidden = NO;
        NSLog(@"上传失败了");
    }
    
}

@end








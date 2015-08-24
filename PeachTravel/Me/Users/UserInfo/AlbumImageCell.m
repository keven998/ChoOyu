//
//  AlbumImageCell.m
//  PeachTravel
//
//  Created by liangpengshuai on 7/2/15.
//  Copyright (c) 2015 com.aizou.www. All rights reserved.
//

#import "AlbumImageCell.h"

@implementation AlbumImageCell

- (void)awakeFromNib
{
    _imageView.contentMode = UIViewContentModeScaleAspectFill;
    [_editBtn setImage:[UIImage imageNamed:@"delete_album.png"] forState:UIControlStateNormal];
    _editBtn.hidden = YES;
}

@end

//
//  UserAlbumOverviewCell.m
//  PeachTravel
//
//  Created by liangpengshuai on 9/16/15.
//  Copyright (c) 2015 com.aizou.www. All rights reserved.
//

#import "UserAlbumOverviewCell.h"

@implementation UserAlbumOverviewCell

- (void)awakeFromNib {
    _titleLabel.textColor = COLOR_TEXT_I;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void)setAssetsGroup:(ALAssetsGroup *)assetsGroup
{
    _assetsGroup = assetsGroup;
    CGImageRef posterImage      = assetsGroup.posterImage;
    self.headerImageView.image        = [UIImage imageWithCGImage:posterImage scale:2 orientation:UIImageOrientationUp];
    
    NSString *title = [NSString stringWithFormat:@"%@ (共%ld张)",[assetsGroup valueForProperty:ALAssetsGroupPropertyName],  (long)[assetsGroup numberOfAssets]];
    self.titleLabel.text = title;
    self.accessoryType          = UITableViewCellAccessoryDisclosureIndicator;
}

@end

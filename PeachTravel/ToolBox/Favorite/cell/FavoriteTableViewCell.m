//
//  FavoriteTableViewCell.m
//  PeachTravel
//
//  Created by Luo Yong on 14/12/2.
//  Copyright (c) 2014年 com.aizou.www. All rights reserved.
//

#import "FavoriteTableViewCell.h"

@implementation FavoriteTableViewCell


- (void)awakeFromNib {
    self.backgroundColor = APP_PAGE_COLOR;

    _standardImageView.clipsToBounds = YES;
    _standardImageView.layer.borderColor = APP_BORDER_COLOR.CGColor;
    _standardImageView.layer.borderWidth = 0.5;
    _standardImageView.backgroundColor = APP_IMAGEVIEW_COLOR;
    
    _contentDescExpandView.titleLabel.numberOfLines = 4;
    _contentDescExpandView.clipsToBounds = YES;
    _contentDescExpandView.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    [_contentDescExpandView sizeToFit];
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}


- (void) resizeHeight:(BOOL)resize {
    if (resize) {
        _contentDescExpandView.titleLabel.numberOfLines = 0;
        CGSize size = [_contentDescExpandView.titleLabel.text sizeWithAttributes:@{NSFontAttributeName : _contentDescExpandView.titleLabel.font}];
        _contentDescExpandView.frame = CGRectMake(_contentDescExpandView.frame.origin.x, _contentDescExpandView.frame.origin.y, _contentDescExpandView.frame.size.width, size.height);
        [_contentDescExpandView.titleLabel sizeToFit];
        self.contentView.frame = CGRectMake(0.0, 0.0, self.contentView.frame.size.width, _contentDescExpandView.frame.origin.y + _contentDescExpandView.frame.size.height + 10.0);
    } else {
        _contentDescExpandView.titleLabel.numberOfLines = 2;
        self.contentView.frame = CGRectMake(0.0, 0.0, self.contentView.frame.size.width, 200.0);
    }
}

@end

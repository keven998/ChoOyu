//
//  FavoriteTableViewCell.m
//  PeachTravel
//
//  Created by Luo Yong on 14/12/2.
//  Copyright (c) 2014年 com.aizou.www. All rights reserved.
//

#import "FavoriteTableViewCell.h"

@implementation FavoriteTableViewCell

- (void)awakeFromNib
{
    self.backgroundColor = APP_PAGE_COLOR;
    
    _contentType.font = [UIFont systemFontOfSize:26.0];
    _contentType.textColor = APP_THEME_COLOR;
    _contentLocation.font = [UIFont systemFontOfSize:13.0];
    _contentTitle.font = [UIFont systemFontOfSize:15.0];
    _timeBtn.titleLabel.font = [UIFont systemFontOfSize:10.0];
    
    _standardImageView.clipsToBounds = YES;
//    _standardImageView.layer.borderColor = APP_BORDER_COLOR.CGColor;
//    _standardImageView.layer.borderWidth = 0.5;
    _standardImageView.backgroundColor = APP_IMAGEVIEW_COLOR;
    
    _contentDescLabel.numberOfLines = 4;
    
    _contentDescLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    _contentDescLabel.font = [UIFont systemFontOfSize:11.0];
    
    _titleBkgImageView.image = [UIImage imageNamed:@"titleImageBackground"];
    
    _contentBkgView.layer.cornerRadius = 2.0;
    _contentBkgView.clipsToBounds = YES;
    _sendBtn.layer.cornerRadius = 2.0;
    _sendBtn.backgroundColor = APP_THEME_COLOR;
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (void)setIsCanSend:(BOOL)isCanSend
{
    _isCanSend = isCanSend;
    if (_isCanSend) {
        _sendBtn.hidden = NO;
        _sendBtnBkgImageView.hidden = NO;
    } else {
        _sendBtn.hidden = YES;
        _sendBtnBkgImageView.hidden = YES;
    }
    
}


@end

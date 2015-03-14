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
    
    _contentType.font = [UIFont fontWithName:@"MicrosoftYaHei" size:26.0];
    _contentLocation.font = [UIFont fontWithName:@"MicrosoftYaHei" size:13.0];
    _contentTitle.font = [UIFont fontWithName:@"MicrosoftYaHei" size:15.0];
    _timeBtn.titleLabel.font = [UIFont fontWithName:@"MicrosoftYaHei" size:10.0];

    _standardImageView.clipsToBounds = YES;
//    _standardImageView.layer.borderColor = APP_BORDER_COLOR.CGColor;
//    _standardImageView.layer.borderWidth = 0.5;
    _standardImageView.backgroundColor = APP_IMAGEVIEW_COLOR;
    
    _contentDescLabel.numberOfLines = 4;
    
    _contentDescLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    _contentDescLabel.font = [UIFont fontWithName:@"MicrosoftYaHei" size:11.0];
    
    _titleBkgImageView.image = [[UIImage imageNamed:@"bg_guide_title.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(2, 2, 2, 5)];
    
    _contentBkgView.layer.cornerRadius = 2.0;
    _contentBkgView.clipsToBounds = YES;
    _sendBtn.layer.cornerRadius = 2.0;
    
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

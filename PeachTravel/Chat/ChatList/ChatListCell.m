/************************************************************
  *  * EaseMob CONFIDENTIAL 
  * __________________ 
  * Copyright (C) 2013-2014 EaseMob Technologies. All rights reserved. 
  *  
  * NOTICE: All information contained herein is, and remains 
  * the property of EaseMob Technologies.
  * Dissemination of this information or reproduction of this material 
  * is strictly forbidden unless prior written permission is obtained
  * from EaseMob Technologies.
  */


#import "ChatListCell.h"

@interface ChatListCell (){
    UILabel *_timeLabel;
    UILabel *_unreadLabel;
    UILabel *_detailLabel;
    UIView *_lineView;
    
    UIView *frameView;
    UIActivityIndicatorView *activityView;
    UIImageView *sendFailedImageView;
}

@end

@implementation ChatListCell

- (id)initWithStyle:(UITableViewCellStyle)style
    reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = APP_PAGE_COLOR;
        
        frameView = [[UIView alloc] initWithFrame:CGRectZero];
        frameView.backgroundColor = [UIColor whiteColor];
        frameView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        frameView.layer.cornerRadius = 2.0;
        [self.contentView addSubview:frameView];
        
        _timeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _timeLabel.font = [UIFont italicSystemFontOfSize:10.0];
        _timeLabel.textColor = TEXT_COLOR_TITLE_HINT;
        _timeLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _timeLabel.textAlignment = NSTextAlignmentRight;
        [frameView addSubview:_timeLabel];
        
        _detailLabel = [[UILabel alloc] init];
        _detailLabel.font = [UIFont fontWithName:@"MicrosoftYaHei" size:11];
        _detailLabel.textColor = TEXT_COLOR_TITLE_SUBTITLE;
        _detailLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [frameView addSubview:_detailLabel];
        
        activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [activityView.layer setValue:[NSNumber numberWithFloat:0.7f]
                           forKeyPath:@"transform.scale"];
        activityView.hidesWhenStopped = YES;
        [activityView stopAnimating];
        activityView.color = [UIColor lightGrayColor];
        [frameView addSubview:activityView];
        
        sendFailedImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"MessageSendFail.png"]];
        sendFailedImageView.hidden = YES;
        [frameView addSubview:sendFailedImageView];
        
        _unreadLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _unreadLabel.backgroundColor = APP_THEME_COLOR;
        _unreadLabel.textAlignment = NSTextAlignmentCenter;
        _unreadLabel.font = [UIFont fontWithName:@"MicrosoftYaHei" size:13.0];
        _unreadLabel.adjustsFontSizeToFitWidth = NO;
        _unreadLabel.layer.cornerRadius = 3.0;
        _unreadLabel.clipsToBounds = YES;
        [self.contentView insertSubview:_unreadLabel aboveSubview:self.imageView];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    if (![_unreadLabel isHidden]) {
        _unreadLabel.backgroundColor = APP_THEME_COLOR;
    }
}

-(void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated{
    [super setHighlighted:highlighted animated:animated];
    if (![_unreadLabel isHidden]) {
        _unreadLabel.backgroundColor = APP_THEME_COLOR;
    }
}

-(void)layoutSubviews{
    [super layoutSubviews];
    
    CGFloat width = self.frame.size.width;
    
    self.imageView.frame = CGRectMake(10.0, 10.5, 39, 39);
    self.imageView.layer.cornerRadius = 19.5;
    self.imageView.layer.masksToBounds = YES;
    
    self.textLabel.text = _name;
    self.textLabel.backgroundColor = [UIColor clearColor];
    self.textLabel.font = [UIFont fontWithName:@"MicrosoftYaHei" size:14.0];
    self.textLabel.textColor = TEXT_COLOR_TITLE;
    self.textLabel.frame = CGRectMake(60.0, 10.0, width - 110.0, 18.0);
    
    _timeLabel.frame = CGRectMake(width - 95.0, 12.0, 90.0, 18.0);
    frameView.frame = CGRectMake(0, 0.0, width, self.frame.size.height-1);
    
    _detailLabel.text = _detailMsg;
    
    
    CGSize size = [_detailMsg sizeWithAttributes:@{NSFontAttributeName : _detailLabel.font}];
    CGFloat popW = size.width > (self.textLabel.frame.size.width-50) ? (self.textLabel.frame.size.width-50) : size.width;

    CGFloat offsetX = 0;
    if (_sendStatus == MSGSending) {
        offsetX = 15;
        sendFailedImageView.hidden = YES;
        [activityView startAnimating];
        
    } if (_sendStatus == MSGSended) {
        sendFailedImageView.hidden = YES;
        [activityView stopAnimating];
        
    } if (_sendStatus == MSGSendFaild) {
        sendFailedImageView.hidden = NO;
        offsetX = 15;
        [activityView stopAnimating];
    }
    
    sendFailedImageView.frame = CGRectMake(61, 33, 12, 12);
    activityView.frame = CGRectMake(61, 40, 8, 8);
    _detailLabel.frame = CGRectMake(61+offsetX, 28.0, popW+30-offsetX, 26);
    
    _timeLabel.text = _time;
    
    if (_unreadCount > 0) {
        if (_unreadCount < 9) {
            _unreadLabel.font = [UIFont fontWithName:@"MicrosoftYaHei" size:12];
        }else if(_unreadCount > 9 && _unreadCount < 99){
            _unreadLabel.font = [UIFont fontWithName:@"MicrosoftYaHei" size:11];
        }else{
            _unreadLabel.font = [UIFont fontWithName:@"MicrosoftYaHei" size:10];
        }
        [_unreadLabel setHidden:NO];
        [self.contentView bringSubviewToFront:_unreadLabel];
//        _unreadLabel.text = [NSString stringWithFormat:@"%d",_unreadCount];
        
        _unreadLabel.frame = CGRectMake(width-11, 5.0, 6.0, 6.0);
    }else{
        [_unreadLabel setHidden:YES];
    }
    
    self.selectedBackgroundView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
}

-(void)setName:(NSString *)name{
    _name = name;
    self.textLabel.text = name;
}

- (void)setPlaceholderImageUrl:(NSURL *)placeholderImageUrl
{
    _placeholderImageUrl = placeholderImageUrl;
    if (_placeholderImageUrl) {
        [self.imageView sd_setImageWithURL:_placeholderImageUrl placeholderImage:[UIImage imageNamed:_imageName]];
    } else {
        [self.imageView setImage:[UIImage imageNamed:_imageName]];
    }

}

+ (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 59;
}

@end

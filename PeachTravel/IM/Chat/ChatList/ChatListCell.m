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
    UIView *spaceView;
    
    UIImageView *activityView;
    UIImageView *sendFailedImageView;
}

@end

@implementation ChatListCell

- (id)initWithStyle:(UITableViewCellStyle)style
    reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        self.imageView.backgroundColor = APP_PAGE_COLOR;
        _timeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _timeLabel.font = [UIFont fontWithName:@"MicrosoftYaHei" size:11.0];
        _timeLabel.textColor = TEXT_COLOR_TITLE_HINT;
        _timeLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _timeLabel.textAlignment = NSTextAlignmentRight;
        [self.contentView addSubview:_timeLabel];
        
        _detailLabel = [[UILabel alloc] init];
        _detailLabel.font = [UIFont fontWithName:@"MicrosoftYaHei" size:15];
        _detailLabel.textColor = UIColorFromRGB(0xbbbbbb);
        _detailLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self.contentView addSubview:_detailLabel];
        
        activityView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ic_msg_sending.png"]];
        [self.contentView addSubview:activityView];
        
        sendFailedImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"MessageSendFail.png"]];
        sendFailedImageView.hidden = YES;
        [self.contentView addSubview:sendFailedImageView];
        
        _unreadLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _unreadLabel.backgroundColor = [UIColor redColor];
        _unreadLabel.textAlignment = NSTextAlignmentCenter;
        _unreadLabel.font = [UIFont fontWithName:@"MicrosoftYaHei" size:13.0];
        _unreadLabel.adjustsFontSizeToFitWidth = NO;
        _unreadLabel.clipsToBounds = YES;
        _unreadLabel.textColor = [UIColor whiteColor];
        [self.contentView insertSubview:_unreadLabel aboveSubview:self.imageView];
        
        spaceView = [[UIView alloc] init];
        spaceView.backgroundColor = APP_DIVIDE_COLOR;
        [self.contentView addSubview:spaceView];
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

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated{
    [super setHighlighted:highlighted animated:animated];
    if (![_unreadLabel isHidden]) {
        _unreadLabel.backgroundColor = APP_THEME_COLOR;
    }
}

- (void)layoutSubviews{
    [super layoutSubviews];
    
    CGFloat width = self.frame.size.width;
    
    self.imageView.frame = CGRectMake(10.0, 10, 60, 60);
    self.imageView.layer.cornerRadius = 10;
    self.imageView.layer.masksToBounds = YES;
    
    self.textLabel.text = _name;
    self.textLabel.backgroundColor = [UIColor clearColor];
    self.textLabel.font = [UIFont fontWithName:@"MicrosoftYaHei" size:17.0];
    self.textLabel.textColor = TEXT_COLOR_TITLE;
    self.textLabel.frame = CGRectMake(85.0, 20.0, width - 80.0-85, 18.0);
    
    _timeLabel.frame = CGRectMake(width - 80.0, 14.0, 70.0, 18.0);
    
    _detailLabel.text = _detailMsg;

    CGFloat offsetX = 0;
    if (_sendStatus == MSGSending) {
        offsetX = 15;
        sendFailedImageView.hidden = YES;
        activityView.hidden = NO;
        
    } if (_sendStatus == MSGSended) {
        sendFailedImageView.hidden = YES;
        activityView.hidden = YES;
        
    } if (_sendStatus == MSGSendFaild) {
        sendFailedImageView.hidden = NO;
        offsetX = 15;
        activityView.hidden = YES;
    }
    
    sendFailedImageView.frame = CGRectMake(85, 48, 12, 12);
    activityView.frame = CGRectMake(85, 51, 13, 12);
    _detailLabel.frame = CGRectMake(85+offsetX, 45.0, width - 85.0-55, 26);
    
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
        _unreadLabel.text = [NSString stringWithFormat:@"%ld",(long)_unreadCount];
        
        _unreadLabel.frame = CGRectMake(width-50, 35.0, 35.0, 20.0);
        _unreadLabel.layer.cornerRadius = 10;
    }else{
        [_unreadLabel setHidden:YES];
    }
    
    spaceView.frame = CGRectMake(0, self.contentView.frame.size.height-0.5, self.contentView.frame.size.width, 0.5);
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
    return 80;
}

@end

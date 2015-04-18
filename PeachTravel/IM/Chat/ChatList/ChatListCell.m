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
        
        self.imageView.backgroundColor = APP_IMAGEVIEW_COLOR;
        
        _timeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _timeLabel.font = [UIFont systemFontOfSize:12];
        _timeLabel.textColor = TEXT_COLOR_TITLE_PH;
        _timeLabel.textAlignment = NSTextAlignmentRight;
        [self.contentView addSubview:_timeLabel];
        
        _detailLabel = [[UILabel alloc] init];
        _detailLabel.font = [UIFont systemFontOfSize:13.5];
        _detailLabel.textColor = TEXT_COLOR_TITLE_HINT;
        _detailLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        _detailLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        [self.contentView addSubview:_detailLabel];
        
        activityView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ic_msg_sending.png"]];
        [self.contentView addSubview:activityView];
        
        sendFailedImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"MessageSendFail.png"]];
        sendFailedImageView.hidden = YES;
        [self.contentView addSubview:sendFailedImageView];
        
        _unreadLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 14, 21, 21)];
        _unreadLabel.backgroundColor = APP_HIGNLIGHT_COLOR;
        _unreadLabel.textAlignment = NSTextAlignmentCenter;
        _unreadLabel.font = [UIFont systemFontOfSize:12];
        _unreadLabel.adjustsFontSizeToFitWidth = NO;
        _unreadLabel.clipsToBounds = YES;
        _unreadLabel.textColor = [UIColor whiteColor];
        _unreadLabel.layer.cornerRadius = 10.5;
        _unreadLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        [self.contentView insertSubview:_unreadLabel aboveSubview:self.imageView];
        
        spaceView = [[UIView alloc] init];
        spaceView.backgroundColor = APP_DIVIDER_COLOR;
        [self.contentView addSubview:spaceView];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated{
    [super setHighlighted:highlighted animated:animated];
}

- (void)layoutSubviews{
    [super layoutSubviews];
    
    CGFloat width = CGRectGetWidth(self.bounds);
    
    self.textLabel.text = _name;
    self.textLabel.frame = CGRectMake(54, 17, width - 54 - 85, 18.0);
    self.textLabel.font = [UIFont systemFontOfSize:16];
    self.textLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    self.textLabel.textColor = TEXT_COLOR_TITLE_SUBTITLE;
    
    self.imageView.frame = CGRectMake(12, 19, 32, 32);
    self.imageView.layer.cornerRadius = 8;
    self.imageView.layer.masksToBounds = YES;
    
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
    _detailLabel.frame = CGRectMake(54+offsetX, 35, width - 85.0-54, 25);
    
    _timeLabel.text = _time;
    
    if (_unreadCount > 0) {
        _unreadCount = 679;
        CGRect lf = _unreadLabel.frame;
        if (_unreadCount < 9) {
            lf.size.width = 21;
        } else if (_unreadCount > 9 && _unreadCount < 99){
            lf.size.width = 29;
        } else {
            lf.size.width = 33;
        }
        [_unreadLabel setHidden:NO];
        [self.contentView bringSubviewToFront:_unreadLabel];
        _unreadLabel.text = [NSString stringWithFormat:@"%ld",(long)_unreadCount];
        
        CGRect tf = self.textLabel.frame;
        CGFloat maxw = tf.size.width - lf.size.width - 5;
        CGSize labelSize = [_name boundingRectWithSize:CGSizeMake(maxw, tf.size.height)
                                                                       options:NSStringDrawingUsesLineFragmentOrigin
                                                                    attributes:@{
                                                                                 NSFontAttributeName : [UIFont systemFontOfSize:16]
                                                                                 }
                                                                       context:nil].size;
        
        tf.size.width = labelSize.width;
        self.textLabel.frame = tf;
        lf.origin.x = tf.origin.x + tf.size.width + 5;
        _unreadLabel.frame = lf;
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
    return 70;
}

@end

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
        
        self.imageView.contentMode = UIViewContentModeScaleAspectFill;
        self.imageView.clipsToBounds = YES;
        
        _timeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _timeLabel.font = [UIFont systemFontOfSize:14];
        _timeLabel.textColor = COLOR_TEXT_III;
        _timeLabel.textAlignment = NSTextAlignmentRight;
        [self.contentView addSubview:_timeLabel];
        
        _detailLabel = [[UILabel alloc] init];
        _detailLabel.font = [UIFont systemFontOfSize:14];
        _detailLabel.textColor = COLOR_TEXT_III;
        _detailLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        _detailLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        [self.contentView addSubview:_detailLabel];
        
        activityView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ic_msg_sending.png"]];
        [self.contentView addSubview:activityView];
        
        sendFailedImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"MessageSendFail.png"]];
        sendFailedImageView.hidden = YES;
        [self.contentView addSubview:sendFailedImageView];
        
        _unreadLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 14, 21, 21)];
        _unreadLabel.backgroundColor = COLOR_CHECKED;
        if (_unreadLabel.isHighlighted) {
            _unreadLabel.backgroundColor = [UIColor redColor];
        }
        _unreadLabel.textAlignment = NSTextAlignmentCenter;
        _unreadLabel.font = [UIFont systemFontOfSize:12];
        _unreadLabel.adjustsFontSizeToFitWidth = NO;
        _unreadLabel.clipsToBounds = YES;
        _unreadLabel.textColor = [UIColor whiteColor];
        _unreadLabel.layer.cornerRadius = 10.5;
        _unreadLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        [self.contentView insertSubview:_unreadLabel aboveSubview:self.imageView];
        
        spaceView = [[UIView alloc] init];
        spaceView.backgroundColor = COLOR_LINE;
        [self.contentView addSubview:spaceView];
        
        self.textLabel.font = [UIFont systemFontOfSize:18];
        self.textLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        self.textLabel.textColor = COLOR_TEXT_I;
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
    self.imageView.frame = CGRectMake(12, 10, 56, 56);
    
    CGFloat contentOffsetX = CGRectGetMaxX(self.imageView.frame) + 10;
    
    self.textLabel.text = _name;
    self.textLabel.frame = CGRectMake(contentOffsetX, 15, width - contentOffsetX - 85, 22);
    
    _timeLabel.frame = CGRectMake(width - 80.0, 15, 70.0, 22);
    _detailLabel.text = _detailMsg;
    
    CGFloat offsetX = 0;
    if (_sendStatus == MSGSending) {
        offsetX = 18;
        sendFailedImageView.hidden = YES;
        activityView.hidden = NO;
    } else if (_sendStatus == MSGSended) {
        sendFailedImageView.hidden = YES;
        activityView.hidden = YES;
        
    } else if (_sendStatus == MSGSendFaild) {
        sendFailedImageView.hidden = NO;
        offsetX = 18;
        activityView.hidden = YES;
        
    } else {
        sendFailedImageView.hidden = YES;
        activityView.hidden = YES;
    }
    
    sendFailedImageView.frame = CGRectMake(contentOffsetX, 48.5, 12, 12);
    activityView.frame = CGRectMake(contentOffsetX, 48.5, 13, 12);
    _detailLabel.frame = CGRectMake(contentOffsetX+offsetX, 46, width - 85.0-contentOffsetX, 16);
    
    _timeLabel.text = _time;
    
    if (_unreadCount > 0) {
        CGRect lf = _unreadLabel.frame;
        if (_unreadCount < 10) {
            lf.size.width = 21;
            _unreadLabel.text = [NSString stringWithFormat:@"%ld",(long)_unreadCount];
        } else if (_unreadCount > 9 && _unreadCount < 100){
            lf.size.width = 29;
            _unreadLabel.text = [NSString stringWithFormat:@"%ld",(long)_unreadCount];
        } else {
            lf.size.width = 33;
            _unreadLabel.text = [NSString stringWithFormat:@"99+"];
        }
        [_unreadLabel setHidden:NO];
        [self.contentView bringSubviewToFront:_unreadLabel];
        
        
        CGRect tf = self.textLabel.frame;
        CGFloat maxw = tf.size.width - lf.size.width - 5;
        CGSize labelSize = [_name boundingRectWithSize:CGSizeMake(maxw, tf.size.height)
                                               options:NSStringDrawingUsesLineFragmentOrigin
                                            attributes:@{
                                                         NSFontAttributeName : [UIFont systemFontOfSize:16]
                                                         }
                                               context:nil].size;
        
        tf.size.width = labelSize.width+ 20;
        self.textLabel.frame = tf;
        lf.origin.x = tf.origin.x + tf.size.width + 5;
        _unreadLabel.frame = lf;
    } else{
        [_unreadLabel setHidden:YES];
    }
    _unreadLabel.center = CGPointMake(65, 12);
    spaceView.frame = CGRectMake(13.5, self.contentView.frame.size.height-0.7, width - 13, 0.7);
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

@end

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
    UIImageView *popBgView;
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
        [self.contentView addSubview:frameView];
        
        _timeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _timeLabel.font = [UIFont systemFontOfSize:10.0];
        _timeLabel.textColor = UIColorFromRGB(0x999999);
        _timeLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _timeLabel.textAlignment = NSTextAlignmentRight;
        [frameView addSubview:_timeLabel];
        
        popBgView = [[UIImageView alloc] init];
        popBgView.autoresizesSubviews = YES;
        popBgView.contentMode = UIViewContentModeScaleToFill;
        [frameView addSubview:popBgView];
        
        _detailLabel = [[UILabel alloc] init];
        _detailLabel.font = [UIFont systemFontOfSize:11];
        _detailLabel.textColor = [UIColor whiteColor];
        _detailLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [popBgView addSubview:_detailLabel];
        
        _unreadLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _unreadLabel.textColor = [UIColor whiteColor];
        _unreadLabel.backgroundColor = [UIColor redColor];
        _unreadLabel.textAlignment = NSTextAlignmentCenter;
        _unreadLabel.font = [UIFont systemFontOfSize:13.0];
        _unreadLabel.adjustsFontSizeToFitWidth = NO;
        _unreadLabel.layer.cornerRadius = 8.0;
        _unreadLabel.clipsToBounds = YES;
        [self.contentView insertSubview:_unreadLabel aboveSubview:self.imageView];
    }
    return self;
}

- (void)awakeFromNib
{
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    if (![_unreadLabel isHidden]) {
        _unreadLabel.backgroundColor = [UIColor redColor];
    }
}

-(void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated{
    [super setHighlighted:highlighted animated:animated];
    if (![_unreadLabel isHidden]) {
        _unreadLabel.backgroundColor = [UIColor redColor];
    }
}

-(void)layoutSubviews{
    [super layoutSubviews];
    
    CGFloat width = self.frame.size.width;
    
    self.imageView.frame = CGRectMake(20.0, 10.5, 39, 39);
    self.imageView.layer.cornerRadius = 19.5;
    self.imageView.layer.masksToBounds = YES;
    
    self.textLabel.text = _name;
    self.textLabel.backgroundColor = [UIColor clearColor];
    self.textLabel.font = [UIFont systemFontOfSize:11.0];
    self.textLabel.textColor = TEXT_COLOR_TITLE;
    self.textLabel.frame = CGRectMake(80.0, 5.0, width - 80.0 - 110.0, 20.0);
    
    _timeLabel.frame = CGRectMake(width - 120.0, 12.0, 90.0, 15.0);
    frameView.frame = CGRectMake(11.0, 0.0, width - 22.0, self.frame.size.height);
    
    _detailLabel.text = _detailMsg;
    CGSize size = [_detailMsg sizeWithAttributes:@{NSFontAttributeName : _detailLabel.font}];
    CGFloat popW = size.width > self.textLabel.frame.size.width ? self.textLabel.frame.size.width : size.width;
    popBgView.frame = CGRectMake(60.0, 26.0, popW + 30.0, 26.0);
    
    popBgView.image = [[UIImage imageNamed:@"chat_list_cell_bubble.png"] stretchableImageWithLeftCapWidth:15 topCapHeight:17];
    _detailLabel.frame = CGRectMake(15, 0.0, popBgView.frame.size.width - 23.0, popBgView.frame.size.height);
    
    _timeLabel.text = _time;
    
    if (_unreadCount > 0) {
        if (_unreadCount < 9) {
            _unreadLabel.font = [UIFont systemFontOfSize:12];
        }else if(_unreadCount > 9 && _unreadCount < 99){
            _unreadLabel.font = [UIFont systemFontOfSize:11];
        }else{
            _unreadLabel.font = [UIFont systemFontOfSize:10];
        }
        [_unreadLabel setHidden:NO];
        [self.contentView bringSubviewToFront:_unreadLabel];
        _unreadLabel.text = [NSString stringWithFormat:@"%d",_unreadCount];
        _unreadLabel.frame = CGRectMake(52.0, 3.0, 16.0, 16.0);
    }else{
        [_unreadLabel setHidden:YES];
    }
    
    self.selectedBackgroundView.frame = CGRectMake(10.0, 0, self.frame.size.width - 20.0, self.frame.size.height);
    
    UIView *spaceView = [[UIView alloc] initWithFrame:CGRectMake(11, frameView.frame.size.height-1, frameView.frame.size.width, 1)];
    spaceView.backgroundColor = APP_DIVIDER_COLOR;
    [self addSubview:spaceView];
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

+(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

@end

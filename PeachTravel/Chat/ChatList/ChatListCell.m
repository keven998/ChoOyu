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
        frameView.layer.borderColor = UIColorFromRGB(0xcccccc).CGColor;
        frameView.layer.borderWidth = 0.5;
        [self.contentView addSubview:frameView];
        
        _timeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _timeLabel.font = [UIFont systemFontOfSize:12.0];
        _timeLabel.textColor = UIColorFromRGB(0x999999);
        _timeLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _timeLabel.textAlignment = NSTextAlignmentRight;
        [frameView addSubview:_timeLabel];
        
        popBgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ic_notify_flag.png"]];
        popBgView.autoresizesSubviews = YES;
        popBgView.contentMode = UIViewContentModeScaleToFill;
        [frameView addSubview:popBgView];
        
        _detailLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0, 0.0, popBgView.frame.size.width - 15.0, popBgView.frame.size.height)];
        _detailLabel.font = [UIFont systemFontOfSize:15];
        _detailLabel.textColor = UIColorFromRGB(0x666666);
        _detailLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        //        [frameView addSubview:_detailLabel];
        [popBgView addSubview:_detailLabel];
        
        _unreadLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _unreadLabel.textColor = [UIColor whiteColor];
        _unreadLabel.backgroundColor = [UIColor redColor];
        _unreadLabel.textAlignment = NSTextAlignmentCenter;
        _unreadLabel.font = [UIFont systemFontOfSize:13.0];
        _unreadLabel.adjustsFontSizeToFitWidth = NO;
        _unreadLabel.layer.cornerRadius = 10.0;
        _unreadLabel.clipsToBounds = YES;
        [self.contentView insertSubview:_unreadLabel aboveSubview:self.imageView];
        
//        _lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kWindowWidth, 1)];
//        _lineView.backgroundColor = RGBACOLOR(207, 210, 213, 0.7);
//        [self.contentView addSubview:_lineView];

        self.textLabel.backgroundColor = [UIColor clearColor];
        self.textLabel.textColor = UIColorFromRGB(0x393939);
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
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
    
    self.imageView.frame = CGRectMake(20.0, 7, 45, 45);
    self.imageView.layer.cornerRadius = 22.5;
    self.imageView.layer.masksToBounds = YES;
    
    self.textLabel.text = _name;
    self.textLabel.frame = CGRectMake(80.0, 7.0, width - 80.0 - 110.0, 20.0);
    
    _timeLabel.frame = CGRectMake(width - 120.0, 12.0, 90.0, 15.0);
    frameView.frame = CGRectMake(10.0, 0.0, width - 20.0, self.frame.size.height);
    
    _detailLabel.text = _detailMsg;
    CGSize size = [_detailMsg sizeWithAttributes:@{NSFontAttributeName : _detailLabel.font}];
    CGFloat popW = size.width > self.textLabel.frame.size.width ? self.textLabel.frame.size.width : size.width;
    popBgView.frame = CGRectMake(70.0, 30.0, popW + 30.0, 24.0);
    
    _timeLabel.text = _time;
    
    if (_unreadCount > 0) {
        if (_unreadCount < 9) {
            _unreadLabel.font = [UIFont systemFontOfSize:13];
        }else if(_unreadCount > 9 && _unreadCount < 99){
            _unreadLabel.font = [UIFont systemFontOfSize:12];
        }else{
            _unreadLabel.font = [UIFont systemFontOfSize:10];
        }
        [_unreadLabel setHidden:NO];
        [self.contentView bringSubviewToFront:_unreadLabel];
        _unreadLabel.text = [NSString stringWithFormat:@"%d",_unreadCount];
        _unreadLabel.frame = CGRectMake(52.0, 3.0, 20.0, 20.0);
    }else{
        [_unreadLabel setHidden:YES];
    }
    
//    CGRect frame = _lineView.frame;
//    frame.origin.y = self.contentView.frame.size.height - 1;
//    _lineView.frame = frame;
    
    self.selectedBackgroundView.frame = CGRectMake(10.0, 0, self.frame.size.width - 20.0, self.frame.size.height);
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

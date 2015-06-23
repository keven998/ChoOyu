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

#import "EMChatTimeCell.h"

@interface EMChatTimeCell ()

@property (nonatomic, strong) UILabel *timeLabel;
//@property (nonatomic,strong) UIView *leftSpaceView;
//@property (nonatomic,strong) UIView *rightSpaceView;


@end


@implementation EMChatTimeCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _timeLabel = [[UILabel alloc] init];
        _timeLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        _timeLabel.textColor = [UIColor whiteColor];
        _timeLabel.textAlignment = NSTextAlignmentCenter;
        _timeLabel.font = [UIFont systemFontOfSize:9];
        _timeLabel.layer.backgroundColor = COLOR_DISABLE.CGColor;
        _timeLabel.layer.cornerRadius = 4.0;
        [self addSubview:_timeLabel];
        
        //        _leftSpaceView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 35, 0.5)];
        //        _leftSpaceView.backgroundColor = COLOR_LINE;
        //        _rightSpaceView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 35, 0.5)];
        //        _rightSpaceView.backgroundColor = COLOR_LINE;
        //        [self addSubview:_leftSpaceView];
        //        [self addSubview:_rightSpaceView];
    }
    
    return self;
}

- (void)setTime:(NSString *)time
{
    _time = time;
    CGSize contentSize = [time sizeWithAttributes:@{NSFontAttributeName : _timeLabel.font}];
    //    _leftSpaceView.frame = CGRectMake(kWindowWidth/2-contentSize.width/2-35-10, 22, 35, 0.5);
    //    _rightSpaceView.frame = CGRectMake(kWindowWidth/2+contentSize.width/2+10, 22, 35, 0.5);
    _timeLabel.frame = CGRectMake(0, 0, contentSize.width+8, contentSize.height+4);
    _timeLabel.center = CGPointMake(CGRectGetWidth(self.bounds)/2.0, CGRectGetHeight(self.bounds)/2.0);
    _timeLabel.text = time;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

-(void)layoutSubviews
{
    [super layoutSubviews];
}

@end

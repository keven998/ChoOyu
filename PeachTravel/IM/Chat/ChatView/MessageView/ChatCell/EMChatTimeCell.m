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

@property (nonatomic, strong) UIButton *textBtn;
@property (nonatomic,strong) UIView *leftSpaceView;
@property (nonatomic,strong) UIView *rightSpaceView;


@end


@implementation EMChatTimeCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _textBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, kWindowWidth, self.frame.size.height)];
        [_textBtn setTitleColor:UIColorFromRGB(0x797979) forState:UIControlStateNormal];
        _textBtn.userInteractionEnabled = NO;
        _textBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
        _textBtn.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        _textBtn.backgroundColor = [UIColor clearColor];
        _textBtn.titleLabel.font = [UIFont fontWithName:@"MicrosoftYaHei" size:9.0];
        [self addSubview:_textBtn];
        
        _leftSpaceView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 35, 0.5)];
        _leftSpaceView.backgroundColor = APP_DIVIDE_COLOR;
        
        _rightSpaceView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 35, 0.5)];
        _rightSpaceView.backgroundColor = APP_DIVIDE_COLOR;
        
        [self addSubview:_leftSpaceView];
        [self addSubview:_rightSpaceView];
    }
   
    return self;
}

- (void)setTime:(NSString *)time
{
    _time = time;
    CGSize contentSize = [_time sizeWithAttributes:@{NSFontAttributeName :  [UIFont fontWithName:@"MicrosoftYaHei" size:9.0]}];
    _leftSpaceView.frame = CGRectMake(kWindowWidth/2-contentSize.width/2-35-10, 22, 35, 0.5);
    _rightSpaceView.frame = CGRectMake(kWindowWidth/2+contentSize.width/2+10, 22, 35, 0.5);
    [_textBtn setTitle:_time forState:UIControlStateNormal];
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

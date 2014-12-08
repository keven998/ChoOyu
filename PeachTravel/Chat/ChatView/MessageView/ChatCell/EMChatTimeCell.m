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

@end


@implementation EMChatTimeCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        NSLog(@"%@", NSStringFromCGRect(self.frame));
        _textBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, kWindowWidth, self.frame.size.height)];
        [_textBtn setTitleColor:UIColorFromRGB(0x797979) forState:UIControlStateNormal];
        _textBtn.userInteractionEnabled = NO;
        _textBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
        _textBtn.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        [_textBtn setImage:[UIImage imageNamed:@"chat_time.png"] forState:UIControlStateNormal];
        [_textBtn setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 5)];
        [_textBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, 5, 0, 0)];
        _textBtn.titleLabel.numberOfLines = 2;
        _textBtn.backgroundColor = [UIColor clearColor];
        _textBtn.titleLabel.font = [UIFont systemFontOfSize:9.0];
        [self addSubview:_textBtn];
    }
   
    return self;
}

- (void)setTime:(NSString *)time
{
    _time = time;
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

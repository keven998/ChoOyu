//
//  MapMarkMenuCell.m
//  MapMark
//
//  Created by 冯宁 on 15/9/24.
//  Copyright © 2015年 PeachTravel. All rights reserved.
//

#import "MapMarkMenuCell.h"
#import "Constants.h"

@interface MapMarkMenuCell ()

@property (nonatomic, strong) UIButton* connectBtn;
@property (nonatomic, strong) UIButton* titleBtn;
@property (nonatomic, strong) UIView* seperateView;

@end

@implementation MapMarkMenuCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self setUpViews];
        self.backgroundColor = [UIColor clearColor];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return  self;
}

- (void)setUpViews{
    
    [self.contentView addSubview:self.connectBtn];
    [self.contentView addSubview:self.titleBtn];
    [self.contentView addSubview:self.seperateView];
    
    self.connectBtn.translatesAutoresizingMaskIntoConstraints = NO;
    self.titleBtn.translatesAutoresizingMaskIntoConstraints = NO;
    self.seperateView.translatesAutoresizingMaskIntoConstraints = NO;
    
    NSDictionary* dict = @{@"connect":self.connectBtn,@"title":self.titleBtn,@"seperate":self.seperateView};
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-27-[connect]-20.7-[title]" options:0 metrics:nil views:dict]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[connect]-5-[seperate]-22.7-|" options:0 metrics:nil views:dict]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[connect]-0-|" options:0 metrics:nil views:dict]];
//    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[connect]-0-|" options:0 metrics:nil views:dict]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[title]-13-[seperate(0.7)]-0-|" options:0 metrics:nil views:dict]];
    
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event{
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    if (selected) {
        self.connectBtn.highlighted = YES;
        self.titleBtn.highlighted = YES;
    }else {
        self.connectBtn.highlighted = NO;
        self.titleBtn.highlighted = NO;
    }

}

- (void)setDayIndex:(NSInteger)dayIndex{
    _dayIndex = dayIndex;
    if (dayIndex == 0) {
        [self.connectBtn setImage:[UIImage imageNamed:@"mapMark_point_line_half"] forState:UIControlStateHighlighted];
        [self.connectBtn setImage:[UIImage imageNamed:@"mapMark_point_line_half_white"] forState:UIControlStateNormal];
    }else{
        [_connectBtn setImage:[UIImage imageNamed:@"mapMark_point_line_white"] forState:UIControlStateNormal];
        [_connectBtn setImage:[UIImage imageNamed:@"mapMark_point_line_green"] forState:UIControlStateHighlighted];
    }
    
    [self.titleBtn setTitle:[NSString stringWithFormat:@"DAY%ld",self.dayIndex] forState:UIControlStateNormal];
}


#pragma mark - setter & getter
- (UIButton *)connectBtn{
    if (_connectBtn == nil) {
        _connectBtn = [[UIButton alloc] init];
        
    
    }
    return _connectBtn;
}
- (UIButton *)titleBtn{
    if (_titleBtn == nil) {
        _titleBtn = [[UIButton alloc] init];
        [_titleBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_titleBtn setTitleColor:APP_THEME_COLOR forState:UIControlStateHighlighted];
        _titleBtn.titleLabel.font = [UIFont systemFontOfSize:16.3];
    }
    return _titleBtn;
}
- (UIView *)seperateView{
    if (_seperateView == nil) {
        _seperateView = [[UIView alloc] init];
        _seperateView.backgroundColor = [UIColor whiteColor];
    }
    return _seperateView;
}

@end

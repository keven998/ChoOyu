//
//  MakeOrderSelectCountTableViewCell.m
//  PeachTravel
//
//  Created by liangpengshuai on 11/9/15.
//  Copyright © 2015 com.aizou.www. All rights reserved.
//

#import "MakeOrderSelectCountTableViewCell.h"

@implementation MakeOrderSelectCountTableViewCell

- (void)awakeFromNib {
    [_deleteBtn addTarget:self action:@selector(deleteNumber:) forControlEvents:UIControlEventTouchUpInside];
    [_addBtn addTarget:self action:@selector(addNumber:) forControlEvents:UIControlEventTouchUpInside];

}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

}

- (void)setCount:(NSUInteger)count
{
    _count = count;
    _countLabel.text = [NSString stringWithFormat:@"%ld", _count];
}

- (void)addNumber:(UIButton *)btn
{
    self.count++;
    if ([_delegate respondsToSelector:@selector(updateSelectCount:)]) {
        [_delegate updateSelectCount:_count];
    }
    if ([_delegate respondsToSelector:@selector(updateSelectCount: andIndex:)]) {
        [_delegate updateSelectCount:_count andIndex:_countLabel.tag];
    }
}

- (void)deleteNumber:(UIButton *)btn
{
    if (_count > 1) {
        self.count--;
    }
    if ([_delegate respondsToSelector:@selector(updateSelectCount:)]) {
        [_delegate updateSelectCount:_count];
    }
    if ([_delegate respondsToSelector:@selector(updateSelectCount: andIndex:)]) {
        [_delegate updateSelectCount:_count andIndex:_countLabel.tag];
    }
}

@end

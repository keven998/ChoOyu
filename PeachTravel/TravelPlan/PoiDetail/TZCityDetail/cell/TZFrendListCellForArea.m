//
//  TZFrendListCellForArea.m
//  PeachTravel
//
//  Created by 冯宁 on 15/9/21.
//  Copyright © 2015年 com.aizou.www. All rights reserved.
//

#import "TZFrendListCellForArea.h"

@interface TZFrendListCellForArea ()

@end

@implementation TZFrendListCellForArea

- (void)prepareSubViewsForArea{
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.cityAndAgeLabel attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:14]];
}
- (void)setModel:(ExpertModel *)model{
    [super setModel:model];
    self.cityAndAgeLabel.text = [NSString stringWithFormat:@"%@  %ld岁",model.residence,model.age];
}

@end

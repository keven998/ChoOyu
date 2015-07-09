//
//  GuiderCollectionCell.m
//  PeachTravel
//
//  Created by dapiao on 15/7/8.
//  Copyright (c) 2015年 com.aizou.www. All rights reserved.
//

#import "GuiderCollectionCell.h"

@implementation GuiderCollectionCell

- (void)awakeFromNib {
    _backGroundView.layer.cornerRadius = 4.0;
    _backGroundView.clipsToBounds = YES;
}

@end

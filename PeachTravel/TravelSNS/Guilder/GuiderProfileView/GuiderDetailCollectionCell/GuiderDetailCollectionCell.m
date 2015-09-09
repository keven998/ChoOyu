//
//  GuiderDetailCollectionCell.m
//  PeachTravel
//
//  Created by 王聪 on 8/31/15.
//  Copyright (c) 2015 com.aizou.www. All rights reserved.
//

#import "GuiderDetailCollectionCell.h"

@implementation GuiderDetailCollectionCell

- (void)awakeFromNib {
    _titleLab.layer.cornerRadius = 10.0;
    _titleLab.textColor = [UIColor whiteColor];
    _titleLab.font = [UIFont fontWithName:@"STHeitiSC-Light" size:12.0];
    _titleLab.clipsToBounds = YES;
}

@end

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
    _titleLab.layer.cornerRadius = 5.0;
    _titleLab.layer.borderColor = UIColorFromRGB(0xF0F0F0).CGColor;
    
//    _titleLab.backgroundColor = TZRandomColor;
    _titleLab.textColor = [UIColor whiteColor];
    _titleLab.layer.borderWidth = 1.0;
    _titleLab.font = [UIFont fontWithName:@"STHeitiSC-Light" size:12.0];
    _titleLab.clipsToBounds = YES;
}

@end

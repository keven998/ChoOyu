//
//  SelectContactUnitView.m
//  PeachTravel
//
//  Created by liangpengshuai on 12/1/14.
//  Copyright (c) 2014 com.aizou.www. All rights reserved.
//

#import "SelectContactUnitView.h"

@implementation SelectContactUnitView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _avatarBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 20, 40, 40)];
        _avatarBtn.layer.cornerRadius = 20.0;
        _avatarBtn.clipsToBounds = YES;
        _deleteBtn = [[UIButton alloc] initWithFrame:CGRectMake(30, 50, 10, 10)];
        _deleteBtn.layer.cornerRadius = 5.0;
        _deleteBtn.backgroundColor = APP_THEME_COLOR;
        _nickNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 60, 40, 20)];
        _nickNameLabel.textAlignment = NSTextAlignmentCenter;
        _nickNameLabel.font = [UIFont systemFontOfSize:13.0];
        _nickNameLabel.textColor = [UIColor grayColor];
        [self addSubview:_avatarBtn];
        [self addSubview:_deleteBtn];
        [self addSubview:_nickNameLabel];
    }
    return self;
}
@end

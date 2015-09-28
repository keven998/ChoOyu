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
        _avatarBtn.imageView.contentMode = UIViewContentModeScaleAspectFill;
        _deleteBtn = [[UIButton alloc] initWithFrame:CGRectMake(28, 48, 12, 12)];
        [_deleteBtn setImage:[UIImage imageNamed:@"ic_remove_select_one.png"] forState:UIControlStateNormal];
        _nickNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 60, 40, 20)];
        _nickNameLabel.textAlignment = NSTextAlignmentCenter;
        _nickNameLabel.font = [UIFont systemFontOfSize:12.0];
        _nickNameLabel.textColor = TEXT_COLOR_TITLE;
        [self addSubview:_avatarBtn];
        [self addSubview:_deleteBtn];
        [self addSubview:_nickNameLabel];
    }
    return self;
}
@end

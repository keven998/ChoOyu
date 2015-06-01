//
//  SelectContactScrollView.m
//  PeachTravel
//
//  Created by liangpengshuai on 12/1/14.
//  Copyright (c) 2014 com.aizou.www. All rights reserved.
//

#import "SelectContactScrollView.h"

@interface SelectContactScrollView ()

//@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic) NSInteger countPerLine;
@property (nonatomic) NSInteger lineCount;

@end

@implementation SelectContactScrollView


- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
    }
    return self;
}

- (void)addSelectUnit:(SelectContactUnitView *)selectContactUnit
{
    [self addNewUnit:selectContactUnit];
    [selectContactUnit.avatarBtn addTarget:self action:@selector(removeUnitCell:) forControlEvents:UIControlEventTouchUpInside];
}

- (IBAction)removeUnitCell:(UIButton *)cell
{
    UIView *unitView = cell.superview;
    [self unitCellTouched:unitView];
}

@end

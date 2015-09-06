//
//  BaseProfileHeaderView.m
//  PeachTravel
//
//  Created by 王聪 on 15/9/6.
//  Copyright (c) 2015年 com.aizou.www. All rights reserved.
//

#import "BaseProfileHeaderView.h"

@implementation BaseProfileHeaderView

+ (BaseProfileHeaderView *)profileHeaderView
{
    return [[[NSBundle mainBundle] loadNibNamed:@"BaseProfileHeaderView" owner:nil options:nil] lastObject];
}

@end

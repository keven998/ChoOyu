//
//  CityHeaderView.m
//  PeachTravel
//
//  Created by liangpengshuai on 11/13/14.
//  Copyright (c) 2014 com.aizou.www. All rights reserved.
//

#import "CityHeaderView.h"

@implementation CityHeaderView

+ (CityHeaderView *)instanceHeaderView
{
    NSArray* nibView =  [[NSBundle mainBundle] loadNibNamed:@"CityHeaderView" owner:nil options:nil];
    return [nibView objectAtIndex:0];
}


@end

//
//  CustomSegue.m
//  PeachTravel
//
//  Created by Luo Yong on 14/11/27.
//  Copyright (c) 2014年 com.aizou.www. All rights reserved.
//

#import "CustomSegue.h"

@implementation CustomSegue

- (void)perform {
    UINavigationController *nctl = [self.sourceViewController navigationController];
    NSArray *newViewControllers = [NSArray arrayWithObject:[self destinationViewController]];
    [nctl setViewControllers:newViewControllers animated:YES];
}

@end

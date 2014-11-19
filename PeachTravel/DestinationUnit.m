//
//  DestinationUnit.m
//  PeachTravel
//
//  Created by liangpengshuai on 11/19/14.
//  Copyright (c) 2014 com.aizou.www. All rights reserved.
//

#import "DestinationUnit.h"

@implementation DestinationUnit

- (id)initWithFrame:(CGRect)frame andName:(NSString *)name
{
    return [self initWithFrame:frame andIcon:nil andName:name];
}

- (id)initWithFrame:(CGRect)frame andIcon:(NSString *)icon andName:(NSString *)name
{
    
    CGSize size = [name sizeWithAttributes:@{NSFontAttributeName :[UIFont systemFontOfSize:16.0]}];
    CGRect tempFrame = CGRectMake(frame.origin.x, frame.origin.y, size.width+20, 30);
    if (self = [super initWithFrame:tempFrame]) {
        self.frame = tempFrame;
        self.layer.borderColor = [UIColor whiteColor].CGColor;
        self.layer.borderWidth = 1.0;
        [self setTitle:name forState:UIControlStateNormal];
        [self setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        self.titleLabel.font = [UIFont systemFontOfSize:16.0];
    }
   
    return self;
}

@end

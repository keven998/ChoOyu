//
//  TZButton.m
//  PeachTravel
//
//  Created by liangpengshuai on 12/12/14.
//  Copyright (c) 2014 com.aizou.www. All rights reserved.
//

#import "TZButton.h"

@implementation TZButton

-(void)layoutSubviews {
    [super layoutSubviews];

    CGPoint center = self.imageView.center;
    center.x = self.frame.size.width/2;
    center.y = self.imageView.frame.size.height/2+14;
    self.imageView.center = center;
    
    //Center text
    CGRect newFrame = [self titleLabel].frame;
    newFrame.origin.x = 0;
    newFrame.origin.y = self.imageView.frame.size.height + self.imageView.frame.origin.y + 9.0;
    newFrame.size.width = self.frame.size.width;
    
    self.titleLabel.frame = newFrame;
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
}

@end

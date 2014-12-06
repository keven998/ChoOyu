//
//  CityCardReusableView.m
//  PeachTravel
//
//  Created by Luo Yong on 14/12/5.
//  Copyright (c) 2014年 com.aizou.www. All rights reserved.
//

#import "CityCardReusableView.h"

@implementation CityCardReusableView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self setBackgroundColor:[UIColor whiteColor]];
        self.layer.cornerRadius = 2.0;
        self.layer.shadowColor = UIColorFromRGB(0xdcdcdc).CGColor;
        self.layer.shadowOffset = CGSizeMake(0.0, 1.0);
        self.layer.shadowOpacity = 1.0;
        self.layer.shadowRadius = 1.0;
    }
    return self;
}

@end

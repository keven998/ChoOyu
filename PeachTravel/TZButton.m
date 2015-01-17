//
//  TZButton.m
//  PeachTravel
//
//  Created by liangpengshuai on 12/12/14.
//  Copyright (c) 2014 com.aizou.www. All rights reserved.
//

#import "TZButton.h"

@implementation TZButton

-(id) initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        
        _title = [[UILabel alloc] initWithFrame:CGRectMake(10.0, 10.0, frame.size.width - 20.0, 22)];
        _title.font = [UIFont boldSystemFontOfSize:18];
        _title.textColor = APP_THEME_COLOR;
        [self addSubview:_title];
        
        _subTitle = [[UILabel alloc] initWithFrame:CGRectMake(10.0, 35, frame.size.width - 20.0, 60)];
        _subTitle.font = [UIFont systemFontOfSize:12];
        _subTitle.numberOfLines = 3;
        _subTitle.textColor = TEXT_COLOR_TITLE_PH;
        [self addSubview:_subTitle];
        
        _ghostImage = [[UIImageView alloc] initWithFrame:CGRectZero];
        [self addSubview:_ghostImage];
        
        _simButton = [[UILabel alloc] initWithFrame:CGRectMake(10.0, frame.size.height - 38, frame.size.width - 20.0, 28)];
        _simButton.textColor = [UIColor whiteColor];
        _simButton.backgroundColor = APP_THEME_COLOR;
        _simButton.font = [UIFont systemFontOfSize:13.];
        _simButton.layer.cornerRadius = 4.0;
        _simButton.textAlignment = NSTextAlignmentCenter;
        _simButton.clipsToBounds = YES;
        [self addSubview:_simButton];
    }
    return self;
}

//-(void)layoutSubviews {
//    [super layoutSubviews];
//
//    CGPoint center = self.imageView.center;
//    center.x = self.frame.size.width/2;
//    center.y = self.imageView.frame.size.height/2+14;
//    self.imageView.center = center;
//    
//    //Center text
//    CGRect newFrame = [self titleLabel].frame;
//    newFrame.origin.x = 0;
//    newFrame.origin.y = self.imageView.frame.size.height + self.imageView.frame.origin.y + 9.0;
//    newFrame.size.width = self.frame.size.width;
//    
//    self.titleLabel.frame = newFrame;
//    self.titleLabel.textAlignment = NSTextAlignmentCenter;
//}

@end

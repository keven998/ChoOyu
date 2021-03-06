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
    CGSize size = [name sizeWithAttributes:@{NSFontAttributeName :[UIFont systemFontOfSize:13.0]}];
    CGRect tempFrame;
    if (icon) {
        tempFrame = CGRectMake(frame.origin.x, frame.origin.y, size.width+32, frame.size.height);
    } else {
        tempFrame = CGRectMake(frame.origin.x, frame.origin.y, size.width+32, frame.size.height);
    }
    
    if (self = [super initWithFrame:tempFrame]) {
        self.frame = tempFrame;
        self.layer.borderColor = [UIColor whiteColor].CGColor;
        self.layer.cornerRadius = 4.0;
//        self.layer.borderWidth = 1.0;
        self.backgroundColor = APP_PAGE_COLOR;
        [self setTitle:name forState:UIControlStateNormal];
        [self setTitleColor:TEXT_COLOR_TITLE forState:UIControlStateNormal];
        self.titleEdgeInsets = UIEdgeInsetsMake(2.5, 4, 0, 0);
        self.titleLabel.font = [UIFont systemFontOfSize:13.0];
        if (icon) {
            [self setContentEdgeInsets:UIEdgeInsetsMake(0, 4, 1, 20)];
            _indictatorView = [[UIButton alloc] initWithFrame:CGRectMake(tempFrame.size.width-23, 0, 20, frame.size.height)];
            [_indictatorView setImage:[UIImage imageNamed:icon] forState:UIControlStateNormal];
            _indictatorView.userInteractionEnabled = NO;
            
            [self addSubview:_indictatorView];
        }
        
    }
    
   
    return self;
}

@end

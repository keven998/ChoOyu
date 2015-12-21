//
//  StoreDetailCollectionReusableView.m
//  PeachTravel
//
//  Created by liangpengshuai on 12/21/15.
//  Copyright © 2015 com.aizou.www. All rights reserved.
//

#import "StoreDetailCollectionReusableView.h"

@implementation StoreDetailCollectionReusableView

- (void)awakeFromNib {
    
    UIView *spaceView = [[UIView alloc] initWithFrame:CGRectMake(0, self.bounds.size.height-0.5, self.bounds.size.width, 0.5)];
    spaceView.backgroundColor = COLOR_LINE;
    [self addSubview:spaceView];
}

@end

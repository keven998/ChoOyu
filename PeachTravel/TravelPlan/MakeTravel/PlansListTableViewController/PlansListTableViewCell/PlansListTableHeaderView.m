//
//  PlansListTableHeaderView.m
//  PeachTravel
//
//  Created by 王聪 on 15/8/11.
//  Copyright (c) 2015年 com.aizou.www. All rights reserved.
//

#import "PlansListTableHeaderView.h"
#import "UIImage+resized.h"
@implementation PlansListTableHeaderView

+ (id)planListHeaderView {
    
    return [[[NSBundle mainBundle] loadNibNamed:@"PlansListTableHeaderView" owner:nil options:nil] lastObject];
}

- (void)awakeFromNib
{
    self.bgImageView.image = [[UIImage imageNamed:@"plan_bg_add"] resizableImageWithCapInsets:UIEdgeInsetsMake(26, 10, 3, 187)];
    
    [self.addTourPlan setTitleColor:APP_THEME_COLOR forState:UIControlStateNormal];
    
    self.backgroundColor = APP_PAGE_COLOR;
}


@end
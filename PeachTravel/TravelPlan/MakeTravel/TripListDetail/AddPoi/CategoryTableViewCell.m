//
//  CategoryTableViewCell.m
//  PeachTravel
//
//  Created by Luo Yong on 15/4/24.
//  Copyright (c) 2015年 com.aizou.www. All rights reserved.
//

#import "CategoryTableViewCell.h"

@implementation CategoryTableViewCell
@synthesize segmentControl;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = APP_PAGE_COLOR;
        [self setupView];
    }
    return self;
}

- (void) setSelectedItems:(NSArray *)selectedItems {
    segmentControl = [[UISegmentedControl alloc] initWithItems:selectedItems];
    segmentControl.layer.borderColor = APP_DIVIDER_COLOR.CGColor;
    segmentControl.layer.borderWidth = 1.0;
    segmentControl.frame = CGRectMake(0, 0, CGRectGetWidth(self.bounds), 44);
    [segmentControl setBackgroundImage:[ConvertMethods createImageWithColor:[UIColor whiteColor]] forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    [segmentControl setBackgroundImage:[ConvertMethods createImageWithColor:APP_THEME_COLOR] forState:UIControlStateSelected barMetrics:UIBarMetricsDefault];
    [segmentControl setDividerImage:[ConvertMethods createImageWithColor:APP_DIVIDER_COLOR] forLeftSegmentState:UIControlStateNormal rightSegmentState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    [segmentControl setTitleTextAttributes:@{NSFontAttributeName : [UIFont systemFontOfSize:17.0], NSForegroundColorAttributeName : TEXT_COLOR_TITLE} forState:UIControlStateNormal];
    [segmentControl setTitleTextAttributes:@{NSFontAttributeName : [UIFont systemFontOfSize:17.0], NSForegroundColorAttributeName : [UIColor whiteColor]} forState:UIControlStateSelected];
    [self.contentView addSubview:segmentControl];
}

- (void) setupView {
    
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end

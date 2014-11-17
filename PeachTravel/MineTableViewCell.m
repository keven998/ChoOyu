//
//  MineTableViewCell.m
//  PeachTravel
//
//  Created by Luo Yong on 14/11/17.
//  Copyright (c) 2014年 com.aizou.www. All rights reserved.
//

#import "MineTableViewCell.h"

@implementation MineTableViewCell

@synthesize flagView;
@synthesize titleView;

- (void)awakeFromNib {
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.selectionStyle = UITableViewCellSelectionStyleDefault;
        CGFloat w = self.contentView.frame.size.width;
        
        self.backgroundColor = APP_PAGE_COLOR;
        
        UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(10.0, 0.0, w- 20.0, 44.0)];
        bgView.backgroundColor = [UIColor whiteColor];
        [self.contentView addSubview:bgView];
        
        CALayer *layer = [bgView layer];
        layer.borderColor = UIColorFromRGB(0xdddddd).CGColor;
        layer.borderWidth = 0.25f;
        
        flagView = [[UIImageView alloc] initWithFrame:CGRectMake(10.0, 10.0, 24.0, 24.0)];
        flagView.contentMode = UIViewContentModeScaleAspectFit;
        [bgView addSubview:flagView];
        
        titleView = [[UILabel alloc] initWithFrame:CGRectMake(flagView.frame.origin.x + 24.0 + 10.0, 0, 108.0, 44.0)];
        titleView.textColor = UIColorFromRGB(0x666666);
        titleView.font = [UIFont systemFontOfSize:14.0];
        [bgView addSubview:titleView];
        
        self.selectedBackgroundView = [[UIView alloc] initWithFrame:CGRectMake(10.0, 0.0, w- 20.0, 44.0)];
//        self.selectedBackgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        self.selectedBackgroundView.backgroundColor = UIColorFromRGB(0xdddddd);
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.selectedBackgroundView.frame = CGRectMake(10.0, 0.0, self.frame.size.width- 20.0, 44.0);
}

@end

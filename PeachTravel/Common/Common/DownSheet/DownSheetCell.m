//
//  DownSheetCell.m
//  audioWriting
//
//  Created by wolf on 14-7-19.
//  Copyright (c) 2014年 wangruiyy. All rights reserved.
//

#import "DownSheetCell.h"

@implementation DownSheetCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        leftView = [[UIImageView alloc]init];
        InfoLabel = [[UILabel alloc]init];
        InfoLabel.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:leftView];
        [self.contentView addSubview:InfoLabel];
        InfoLabel.textColor = COLOR_TEXT_II;
        InfoLabel.font = [UIFont systemFontOfSize:14.0];
    }
    return self;
}

-(void)layoutSubviews{
    [super layoutSubviews];
    leftView.frame = CGRectMake(20, (self.frame.size.height-20)/2, 20, 20);
    InfoLabel.frame = CGRectMake(leftView.frame.size.width+leftView.frame.origin.x+15, (self.frame.size.height-20)/2, 140, 20);
}

-(void)setData:(DownSheetModel *)dicdata{
    cellData = dicdata;
    leftView.image = [UIImage imageNamed:dicdata.icon];
    InfoLabel.text = dicdata.title;
}

@end

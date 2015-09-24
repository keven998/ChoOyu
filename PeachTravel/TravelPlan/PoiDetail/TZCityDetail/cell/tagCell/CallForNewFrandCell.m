//
//  CallForNewFrandCell.m
//  PeachTravel
//
//  Created by 冯宁 on 15/9/23.
//  Copyright © 2015年 com.aizou.www. All rights reserved.
//

#import "CallForNewFrandCell.h"

@interface CallForNewFrandCell ()

@property (nonatomic, strong) UIImageView* imageViewFill;

@end

@implementation CallForNewFrandCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self setUpSubviews];
        self.backgroundColor = [UIColor clearColor];
    }
    return  self;
}

- (void)setUpSubviews {
    [self.contentView addSubview:self.imageViewFill];
    self.imageViewFill.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-6-[fill]-6-|" options:0 metrics:nil views:@{@"fill":self.imageViewFill}]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-7.3-[fill]-7.3-|" options:0 metrics:nil views:@{@"fill":self.imageViewFill}]];
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (UIImageView *)imageViewFill{
    if (_imageViewFill == nil) {
        _imageViewFill = [[UIImageView alloc] init];
        _imageViewFill.image = [UIImage imageNamed:@"citydetail_master_recruit"];
//        _imageViewFill.contentMode = UIViewContentModeScaleAspectFill;
        _imageViewFill.clipsToBounds = YES;
    }
    return _imageViewFill;
}

@end

//
//  TipsChatTableViewCell.m
//  PeachTravel
//
//  Created by liangpengshuai on 12/4/14.
//  Copyright (c) 2014 com.aizou.www. All rights reserved.
//

#import "TipsChatTableViewCell.h"
#import "MessageModel.h"

@interface TipsChatTableViewCell()

@property (nonatomic, strong) UILabel *contentLabel;

@end

@implementation TipsChatTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _contentLabel = [[UILabel alloc] init];
        _contentLabel.numberOfLines = 0;
        _contentLabel.textColor = [UIColor whiteColor];
        _contentLabel.textAlignment = NSTextAlignmentCenter;
        _contentLabel.font = [UIFont systemFontOfSize:10];
        _contentLabel.layer.backgroundColor = COLOR_DISABLE.CGColor;
        _contentLabel.layer.cornerRadius = 4.0;
        [self addSubview:_contentLabel];
    }
    return self;
}

- (void)setContent:(NSString *)content
{
    _content = content;
    _contentLabel.text = _content;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

+ (CGFloat)heightForBubbleWithObject:(MessageModel *)model
{
    CGSize textMaxSize = CGSizeMake(kWindowWidth-20, CGFLOAT_MAX);
    CGSize size = [model.content boundingRectWithSize:textMaxSize options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:10]} context:nil].size;
    return size.height+8;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    CGSize textMaxSize = CGSizeMake(self.bounds.size.width-20, CGFLOAT_MAX);
    CGSize size = [_content boundingRectWithSize:textMaxSize options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:10]} context:nil].size;
    _contentLabel.frame = CGRectMake((self.bounds.size.width-size.width)/2, 0, size.width+8, size.height+8);
    _contentLabel.center = CGPointMake(CGRectGetWidth(self.bounds)/2.0, CGRectGetHeight(self.bounds)/2.0);
    _contentLabel.text = _content;
}

@end



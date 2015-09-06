//
//  GuiderProfileAbout.m
//  PeachTravel
//
//  Created by 王聪 on 8/28/15.
//  Copyright (c) 2015 com.aizou.www. All rights reserved.
//

#import "GuiderProfileAbout.h"

@implementation GuiderProfileAbout

#pragma mark - lifeCycle

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self setupAlbum];
    }
    return self;
}

- (void)setupAlbum
{
    // 正文
    UILabel *contentLab = [[UILabel alloc] init];
    contentLab.font = [UIFont fontWithName:@"Helvetica-Bold" size:14.0];
    contentLab.textColor = UIColorFromRGB(0x646464);
    contentLab.text = @"他还没有达人点评哦..";
    contentLab.numberOfLines = 0;
    contentLab.lineBreakMode = NSLineBreakByWordWrapping;//换行方式
    self.contentLab = contentLab;
    [self addSubview:contentLab];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGSize size = CGSizeMake(kWindowWidth - 40,CGFLOAT_MAX);//LableWight标签宽度，固定的
    
    //计算实际frame大小，并将label的frame变成实际大小
    NSDictionary *dict = @{NSFontAttributeName: [UIFont systemFontOfSize:14.0]};
    CGSize contentSize = [self.content boundingRectWithSize:size options:NSStringDrawingUsesLineFragmentOrigin attributes:dict context:nil].size;
    
    CGFloat contentH = contentSize.height;
    if (self.content.length == 0) {
        contentH = 40;
    }
    
    self.contentLab.frame = CGRectMake(42, 10, kWindowWidth - 84, contentH);
}

#pragma mark - 传入内容
- (void)setContent:(NSString *)content
{
    _content = content;
    
    if (![content isEqualToString:@""]) {
        self.contentLab.text = content;
    }
    [self setNeedsLayout];
}
@end

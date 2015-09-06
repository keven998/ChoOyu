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
    // 1.标题
    UILabel *titleLab = [[UILabel alloc] init];
    titleLab.text = @"个人相册";
    titleLab.textAlignment = NSTextAlignmentCenter;
    titleLab.textColor = UIColorFromRGB(0x646464);
    titleLab.font = [UIFont fontWithName:@"Helvetica-Bold" size:16.0];
    self.titleLab = titleLab;
//    [self addSubview:titleLab];

    // 2.正文
    UILabel *contentLab = [[UILabel alloc] init];
    contentLab.font = [UIFont fontWithName:@"Helvetica-Bold" size:14.0];
    contentLab.textColor = UIColorFromRGB(0x646464);
    contentLab.text = @"他还没有个人签名哦..";
    contentLab.numberOfLines = 0;
    contentLab.lineBreakMode = NSLineBreakByWordWrapping;//换行方式
    self.contentLab = contentLab;
    [self addSubview:contentLab];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.titleLab.frame = CGRectMake(10, 0, kWindowWidth - 20, 50);

    CGSize size = CGSizeMake(kWindowWidth - 40,CGFLOAT_MAX);//LableWight标签宽度，固定的
    
    //计算实际frame大小，并将label的frame变成实际大小
    NSDictionary *dict = @{NSFontAttributeName: [UIFont systemFontOfSize:14.0]};
    CGSize contentSize = [self.content boundingRectWithSize:size options:NSStringDrawingUsesLineFragmentOrigin attributes:dict context:nil].size;
    
    CGFloat contentH = contentSize.height;
    if (self.content.length == 0) {
        contentH = 50;
    }
    
    self.contentLab.frame = CGRectMake(42, 10, kWindowWidth - 84, contentH);
}

#pragma mark - 传入内容
- (void)setContent:(NSString *)content
{
    _content = content;
    self.contentLab.text = content;
    [self setNeedsLayout];
}
@end

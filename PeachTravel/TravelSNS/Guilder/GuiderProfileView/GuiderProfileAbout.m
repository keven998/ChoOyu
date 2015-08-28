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
    self.titleLab = titleLab;
    [self addSubview:titleLab];

    // 2.正文
    UILabel *contentLab = [[UILabel alloc] init];
    contentLab.font = [UIFont systemFontOfSize:14.0];
    contentLab.text = @"我是个好人,我真的是个好人我是个好人,我真的是个好人我是个好人,我真的是个好人我是个好人,我真的是个好人我是个好人,我真的是个好人我是个好人,我真的是个好人我是个好人,我真的是个好人我是个好人,我真的是个好人";
    contentLab.numberOfLines = 0;
    self.contentLab = contentLab;
    [self addSubview:contentLab];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.titleLab.frame = CGRectMake(10, 0, kWindowWidth - 20, 50);
    self.contentLab.frame = CGRectMake(20, CGRectGetMaxY(self.titleLab.frame), kWindowWidth - 40, 100);
}

@end

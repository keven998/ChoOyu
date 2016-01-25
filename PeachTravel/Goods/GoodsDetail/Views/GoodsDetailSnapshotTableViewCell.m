//
//  GoodsDetailSnapshotTableViewCell.m
//  PeachTravel
//
//  Created by liangpengshuai on 1/21/16.
//  Copyright © 2016 com.aizou.www. All rights reserved.
//

#import "GoodsDetailSnapshotTableViewCell.h"

@implementation GoodsDetailSnapshotTableViewCell

- (void)awakeFromNib {
    self.backgroundColor = APP_PAGE_COLOR;
    
    _contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, kWindowWidth, 35)];
    _contentLabel.backgroundColor = [UIColor whiteColor];
    _contentLabel.textColor = COLOR_TEXT_II;
    _contentLabel.font = [UIFont systemFontOfSize:13.0];
    NSMutableAttributedString *content = [[NSMutableAttributedString alloc] initWithString:@"   您现在查看的是交易快照, 点击查看最新的商品详情"];
    [content addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:NSMakeRange(16, 11)];
    _contentLabel.attributedText = content;
    
    _showLatestGoodsInfoBtn = [[UIButton alloc] initWithFrame:_contentLabel.bounds];
    
    [self addSubview:_contentLabel];
    [self addSubview:_showLatestGoodsInfoBtn];
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

@end

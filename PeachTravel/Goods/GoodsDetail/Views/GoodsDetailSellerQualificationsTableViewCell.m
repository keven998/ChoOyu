//
//  GoodsDetailSellerQualificationsTableViewCell.m
//  PeachTravel
//
//  Created by liangpengshuai on 1/20/16.
//  Copyright © 2016 com.aizou.www. All rights reserved.
//

#import "GoodsDetailSellerQualificationsTableViewCell.h"

@implementation GoodsDetailSellerQualificationsTableViewCell

- (void)awakeFromNib {
    self.backgroundColor = APP_PAGE_COLOR;
}

- (void)setQualifications:(NSArray *)qualifications
{
    _qualifications = qualifications;
    
    NSArray *qulificationsImages = @[@"icon_store_server_certification", @"icon_store_server_true", @"icon_store_server_24"];
    CGFloat offsetX = 0;
    NSInteger index = 0;
    
    for (NSString *tag in _qualifications) {
        
        UIButton *tagBtn = [[UIButton alloc] initWithFrame:CGRectMake(offsetX, 10, self.bounds.size.width/3, 35)];
        tagBtn.userInteractionEnabled = NO;
        tagBtn.backgroundColor = [UIColor whiteColor];
        tagBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
        [tagBtn setTitle:tag forState:UIControlStateNormal];
        [tagBtn setTitleColor:COLOR_TEXT_II forState:UIControlStateNormal];
        tagBtn.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 5);
        tagBtn.titleEdgeInsets = UIEdgeInsetsMake(0, 5, 0, 0);
        tagBtn.titleLabel.font = [UIFont systemFontOfSize:13];
        [tagBtn setImage:[UIImage imageNamed:qulificationsImages[index]] forState:UIControlStateNormal];
        offsetX += self.bounds.size.width/3;
        [self addSubview:tagBtn];
        index++;
    }
    
    if (_qualifications.count) {
        
        UIView *spaceView = [[UIView alloc] initWithFrame:CGRectMake(0, 10, self.bounds.size.width, 0.5)];
        spaceView.backgroundColor = COLOR_LINE;
        [self addSubview:spaceView];
        
        UIView *spaceButtomView = [[UIView alloc] initWithFrame:CGRectMake(0, 45-0.5, self.bounds.size.width, 0.5)];
        spaceButtomView.backgroundColor = COLOR_LINE;
        [self addSubview:spaceButtomView];
    }
   

}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

@end

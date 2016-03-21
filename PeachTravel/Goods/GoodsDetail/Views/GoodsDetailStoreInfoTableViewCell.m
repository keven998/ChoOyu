//
//  GoodsDetailStoreInfoTableViewCell.m
//  PeachTravel
//
//  Created by liangpengshuai on 1/21/16.
//  Copyright © 2016 com.aizou.www. All rights reserved.
//

#import "GoodsDetailStoreInfoTableViewCell.h"

@implementation GoodsDetailStoreInfoTableViewCell

+ (CGFloat)storeHeaderHeightWithStoreDetail:(StoreDetailModel *)storeDetail
{
    CGFloat height = 90;
    if (storeDetail.serviceTags.count) {
        height += 30;
    } else {
        height += 5;
    }
    return height;
}


- (void)awakeFromNib {
    self.backgroundColor = [UIColor whiteColor];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void)setGoodsDetail:(GoodsDetailModel *)goodsDetail
{
    _goodsDetail = goodsDetail;
    StoreDetailModel *storeDetail = _goodsDetail.store;
    
    for (UIView *view in self.subviews) {
        [view removeFromSuperview];
    }
    
    UIImageView *storeNameImageView = [[UIImageView alloc] initWithFrame:CGRectMake(12, 20, 18, 18)];
    storeNameImageView.image = [UIImage imageNamed:@"icon_store_name"];
    [self addSubview:storeNameImageView];
    _storeNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(38, 20, self.frame.size.width-50, 18)];
    _storeNameLabel.textColor = COLOR_TEXT_I;
    _storeNameLabel.font = [UIFont systemFontOfSize:15.0];
    [self addSubview:_storeNameLabel];
    _storeNameLabel.text = storeDetail.storeName;
    
    CGFloat offsetX = 38;
    CGFloat offsetY = 40;
    
    UILabel *addressLabel = [[UILabel alloc] initWithFrame:CGRectMake(offsetX, offsetY, self.bounds.size.width-offsetX-20, 20)];
    addressLabel.font = [UIFont systemFontOfSize:13.0];
    addressLabel.textColor = COLOR_TEXT_II;
    addressLabel.text = [NSString stringWithFormat:@"%@ %@  %@", _goodsDetail.country.zhName, _goodsDetail.locality.zhName, _goodsDetail.address];;
    [self addSubview:addressLabel];
    
    offsetY += 25;
    for (NSString *language in storeDetail.languages) {
        UILabel *lable = [[UILabel alloc] initWithFrame:CGRectMake(offsetX, offsetY, 50, 15)];
        lable.textColor = [UIColor whiteColor];
        lable.font = [UIFont systemFontOfSize:10.0];
        lable.layer.cornerRadius = 4.0;
        lable.clipsToBounds = YES;
        lable.textAlignment = NSTextAlignmentCenter;
        lable.text = language;
        [self addSubview:lable];
        if ([language isEqualToString:@"中文"]) {
            lable.backgroundColor = APP_THEME_COLOR;
        } else if ([language isEqualToString:@"英文"]) {
            lable.backgroundColor = UIColorFromRGB(0x99ccff);
        } else {
            lable.backgroundColor = UIColorFromRGB(0xf9932e);
        }
        offsetX += 60;
    }
    offsetY += 20;
    if (storeDetail.serviceTags.count) {
        offsetX = 38;
        UIImageView *serverImageView = [[UIImageView alloc] initWithFrame:CGRectMake(offsetX, offsetY+1.5, 17, 17)];
        serverImageView.image = [UIImage imageNamed:@"icon_store_free"];
        [self addSubview:serverImageView];
        offsetX += 20;
        for (NSString *serverName in storeDetail.serviceTags) {
            UIButton *serverBtn = [[UIButton alloc] initWithFrame:CGRectMake(offsetX, offsetY, 60, 20)];
            serverBtn.userInteractionEnabled = NO;
            [serverBtn setTitle:serverName forState:UIControlStateNormal];
            [serverBtn setTitleColor:COLOR_TEXT_II forState:UIControlStateNormal];
            serverBtn.titleLabel.font = [UIFont systemFontOfSize:12];
            offsetX += 65;
            [self addSubview:serverBtn];
        }
        offsetY += 25;
    }
    
    UIView *spaceView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, 0.5)];
    spaceView.backgroundColor = COLOR_LINE;
    [self addSubview:spaceView];
    
    UIView *buttomSpaceView = [[UIView alloc] initWithFrame:CGRectMake(0, self.bounds.size.height-0.5, self.bounds.size.width, 0.5)];
    buttomSpaceView.backgroundColor = COLOR_LINE;
    [self addSubview:buttomSpaceView];
}


@end

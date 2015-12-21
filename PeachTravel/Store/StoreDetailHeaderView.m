//
//  StoreDetailHeaderView.m
//  PeachTravel
//
//  Created by liangpengshuai on 12/19/15.
//  Copyright © 2015 com.aizou.www. All rights reserved.
//

#import "StoreDetailHeaderView.h"

@interface StoreDetailHeaderView ()

@property (nonatomic, strong) UILabel *storeNameLabel;

@end

@implementation StoreDetailHeaderView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        UIImageView *storeNameImageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 18, 18)];
        storeNameImageView.image = [UIImage imageNamed:@"icon_store_name"];
        [self addSubview:storeNameImageView];
        _storeNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(35, 10, frame.size.width-50, 18)];
        _storeNameLabel.textColor = COLOR_TEXT_I;
        _storeNameLabel.font = [UIFont systemFontOfSize:15.0];
        [self addSubview:_storeNameLabel];
    }
    return self;
}

- (void)setStoreDetail:(StoreDetailModel *)storeDetail
{
    _storeDetail = storeDetail;
    _storeNameLabel.text = _storeDetail.storeName;
    CGFloat offsetX = 35;
    for (NSString *language in _storeDetail.languages) {
        UILabel *lable = [[UILabel alloc] initWithFrame:CGRectMake(offsetX, 36, 45, 15)];
        lable.textColor = [UIColor whiteColor];
        lable.font = [UIFont systemFontOfSize:10.0];
        lable.layer.cornerRadius = 5.0;
        lable.clipsToBounds = YES;
        lable.textAlignment = NSTextAlignmentCenter;
        lable.text = language;
        [self addSubview:lable];
        if ([language isEqualToString:@"中文"]) {
            lable.backgroundColor = APP_THEME_COLOR;
        } else if ([language isEqualToString:@"英文"]) {
            lable.backgroundColor = UIColorFromRGB(0x89BFFF);
        } else {
            lable.backgroundColor = UIColorFromRGB(0xF57F24);
        }
        offsetX += 60;
    }
    offsetX = 30;
    for (NSString *serverName in _storeDetail.serviceTags) {
        UIButton *serverBtn = [[UIButton alloc] initWithFrame:CGRectMake(offsetX, 60, 80, 20)];
        serverBtn.userInteractionEnabled = NO;
        [serverBtn setTitle:serverName forState:UIControlStateNormal];
        [serverBtn setTitleColor:COLOR_TEXT_II forState:UIControlStateNormal];
        [serverBtn setImage:[UIImage imageNamed:@"icon_store_free"] forState:UIControlStateNormal];
        serverBtn.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 5);
        serverBtn.titleEdgeInsets = UIEdgeInsetsMake(0, 5, 0, 0);
        serverBtn.titleLabel.font = [UIFont systemFontOfSize:12];
        offsetX += 90;
        [self addSubview:serverBtn];
    }
    UIView *spaceView = [[UIView alloc] initWithFrame:CGRectMake(0, 85, self.bounds.size.width, 0.5)];
    spaceView.backgroundColor = COLOR_LINE;
    [self addSubview:spaceView];
    
    offsetX = 0;
    NSArray *qulificationsImages = @[@"icon_store_server_certification", @"icon_store_server_true", @"icon_store_server_24"];
    NSInteger index = 0;
    for (NSString *tag in _storeDetail.qualifications) {
        UIButton *tagBtn = [[UIButton alloc] initWithFrame:CGRectMake(offsetX, 85, self.bounds.size.width/3, 30)];
        tagBtn.userInteractionEnabled = NO;
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
    UIView *buttomSpaceView = [[UIView alloc] initWithFrame:CGRectMake(0, 114.5, self.bounds.size.width, 0.5)];
    buttomSpaceView.backgroundColor = COLOR_LINE;
    [self addSubview:buttomSpaceView];
}

@end

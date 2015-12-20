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
        UIImageView *sotreNameImageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 18, 18)];
        [self addSubview:sotreNameImageView];
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
    CGFloat offsetX = 35;
    for (NSString *language in _storeDetail.languages) {
        UILabel *lable = [[UILabel alloc] initWithFrame:CGRectMake(offsetX, 36, 38, 15)];
        lable.textColor = [UIColor whiteColor];
        lable.font = [UIFont systemFontOfSize:10.0];
        lable.text = language;
        [self addSubview:lable];
        offsetX += 50;
    }
    offsetX = 35;
    for (NSString *serverName in _storeDetail.serviceTags) {
        UIButton *serverBtn = [[UIButton alloc] initWithFrame:CGRectMake(offsetX, 60, 60, 20)];
        serverBtn.userInteractionEnabled = NO;
        [serverBtn setTitle:serverName forState:UIControlStateNormal];
        [serverBtn setTitleColor:COLOR_TEXT_II forState:UIControlStateNormal];
        serverBtn.titleLabel.font = [UIFont systemFontOfSize:12];
        [self addSubview:serverBtn];
    }
    UIView *spaceView = [[UIView alloc] initWithFrame:CGRectMake(0, 85, self.bounds.size.width, 0.5)];
    spaceView.backgroundColor = COLOR_LINE;
    [self addSubview:spaceView];
    
    NSArray *tagsImageName = @[];
    for (NSString *tag in _storeDetail.tags) {
        UIButton *tagBtn = [[UIButton alloc] initWithFrame:CGRectMake(offsetX, 60, 60, 20)];
        tagBtn.userInteractionEnabled = NO;
        [tagBtn setTitle:tag forState:UIControlStateNormal];
        [tagBtn setTitleColor:COLOR_TEXT_II forState:UIControlStateNormal];
        tagBtn.titleLabel.font = [UIFont systemFontOfSize:13];
        [self addSubview:tagBtn];
    }

}

@end

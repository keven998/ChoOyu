//
//  MineHeaderView.m
//  PeachTravel
//
//  Created by 王聪 on 15/9/2.
//  Copyright (c) 2015年 com.aizou.www. All rights reserved.
//

#import "MineHeaderView.h"
#import "PeachTravel-swift.h"
#import "MyOrderRootViewController.h"

@implementation MineHeaderView

#pragma mark - lifeCycle

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = APP_PAGE_COLOR;
        UIImageView *bgImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, 215)];
        bgImageView.image = [UIImage imageNamed:@"icon_mine_header_bg"];
        [self addSubview:bgImageView];
        
        _avatarImageViewBG = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 80, 80)];
        _avatarImageViewBG.center = CGPointMake(frame.size.width/2, 120);
        _avatarImageViewBG.layer.cornerRadius = 40;
        _avatarImageViewBG.clipsToBounds = YES;
        _avatarImageViewBG.image = [UIImage imageNamed:@"icon_mine_avatarbg"];
        [self addSubview:_avatarImageViewBG];
        
        _avatarImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 72, 72)];
        _avatarImageView.center = CGPointMake(_avatarImageViewBG.bounds.size.width/2, _avatarImageViewBG.bounds.size.height/2);
        _avatarImageView.layer.cornerRadius = 36;
        _avatarImageView.clipsToBounds = YES;
        _avatarImageView.image = [UIImage imageNamed:@"icon_mine_avatarbg"];
        [_avatarImageViewBG addSubview:_avatarImageView];
        
        _nickNameLabel= [[UILabel alloc] initWithFrame:CGRectMake(21, _avatarImageViewBG.bounds.size.height+_avatarImageViewBG.frame.origin.y+5, frame.size.width-42, 44)];
        _nickNameLabel.textColor = [UIColor whiteColor];
        _nickNameLabel.font = [UIFont systemFontOfSize:15.0];
        _nickNameLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_nickNameLabel];
        
        UIView *orderButtonsBg = [[UIView alloc] initWithFrame:CGRectMake(0, bgImageView.bounds.size.height+15, frame.size.width, 75)];
        orderButtonsBg.backgroundColor = [UIColor whiteColor];
        [self addSubview:orderButtonsBg];
        
        NSArray *orderButtonDataSource = @[@{@"title": @"全部订单", @"image": @"icon_mine_order_all", @"action": @"allOrderAction"},
                                          @{@"title": @"待付款", @"image": @"icon_mine_order_waitpay", @"action": @"waitPayOrderAction"},
                                          @{@"title": @"处理中", @"image": @"icon_mine_order_inprogress", @"action": @"inProgressOrderAction"},
                                          @{@"title": @"可使用", @"image": @"icon_mine_order_inuse", @"action": @"inUseOrderAction"},
                                          @{@"title": @"退款", @"image": @"icon_mine_order_refundmoney", @"action": @"refundMoneyOrderAction"}
                                          ];
        
        CGFloat itemWidth = frame.size.width/orderButtonDataSource.count;
        CGFloat itemHeight = orderButtonsBg.bounds.size.height;
        NSInteger index = 0;
        for (NSDictionary *dic in orderButtonDataSource) {
            TZButton *button = [[TZButton alloc] initWithFrame:CGRectMake(index*itemWidth, 0, itemWidth, itemHeight)];
            NSString *title = [dic objectForKey:@"title"];
            NSString *imageStr = [dic objectForKey:@"image"];
            NSString *actionStr = [dic objectForKey:@"action"];
            [button setTitle:title forState:UIControlStateNormal];
            [button setTitleColor:COLOR_TEXT_II forState:UIControlStateNormal];
            button.topSpaceHight = 15;
            button.spaceHight = 15;
            button.titleLabel.font = [UIFont systemFontOfSize:14.0];
            [button setImage:[UIImage imageNamed:imageStr] forState:UIControlStateNormal];
            [button addTarget:self action:NSSelectorFromString(actionStr) forControlEvents:UIControlEventTouchUpInside];
            [orderButtonsBg addSubview:button];
            index++;
        }
    }
    return self;
}

- (void)setAccount:(AccountModel *)account
{
    _account = account;
    _nickNameLabel.text = account.nickName;
    [_avatarImageView sd_setImageWithURL:[NSURL URLWithString:_account.avatarSmall] placeholderImage:nil];
}

- (void)allOrderAction
{
    MyOrderRootViewController *ctl = [[MyOrderRootViewController alloc] init];
    ctl.selectIndex = 0;
    ctl.hidesBottomBarWhenPushed = YES;
    [_containerViewController.navigationController pushViewController:ctl animated:YES];
}

- (void)waitPayOrderAction
{
    MyOrderRootViewController *ctl = [[MyOrderRootViewController alloc] init];
    ctl.selectIndex = 1;
    ctl.hidesBottomBarWhenPushed = YES;
    [_containerViewController.navigationController pushViewController:ctl animated:YES];
}

- (void)inProgressOrderAction
{
    MyOrderRootViewController *ctl = [[MyOrderRootViewController alloc] init];
    ctl.selectIndex = 2;
    ctl.hidesBottomBarWhenPushed = YES;
    [_containerViewController.navigationController pushViewController:ctl animated:YES];
}

- (void)inUseOrderAction
{
    MyOrderRootViewController *ctl = [[MyOrderRootViewController alloc] init];
    ctl.selectIndex = 3;
    ctl.hidesBottomBarWhenPushed = YES;
    [_containerViewController.navigationController pushViewController:ctl animated:YES];
}

- (void)refundMoneyOrderAction
{
    MyOrderRootViewController *ctl = [[MyOrderRootViewController alloc] init];
    ctl.selectIndex = 4;
    ctl.hidesBottomBarWhenPushed = YES;
    [_containerViewController.navigationController pushViewController:ctl animated:YES];
}
@end

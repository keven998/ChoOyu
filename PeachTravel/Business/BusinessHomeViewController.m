//
//  BusinessHomeViewController.m
//  PeachTravel
//
//  Created by liangpengshuai on 3/7/16.
//  Copyright © 2016 com.aizou.www. All rights reserved.
//

#import "BusinessHomeViewController.h"
#import "BNGoodsListRootViewController.h"
#import "BNOrderListRootViewController.h"
#import "TZButton.h"
#import "StoreManager.h"

@interface BusinessHomeViewController ()

@end

@implementation BusinessHomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"我的店铺";
    
    CGFloat spaceWidth = (kWindowWidth-160)/3;
    TZButton *totalPriceButton = [[TZButton alloc] initWithFrame:CGRectMake(spaceWidth, 120, 80, 150)];
    totalPriceButton.userInteractionEnabled = NO;
    totalPriceButton.spaceHight = 20;
    totalPriceButton.titleLabel.numberOfLines = 0;
    totalPriceButton.titleLabel.font = [UIFont systemFontOfSize:15];
    [totalPriceButton setTitleColor:COLOR_TEXT_II forState:UIControlStateNormal];
    [totalPriceButton setImage:[UIImage imageNamed:@"icon_business_order_totalPrice.png"] forState:UIControlStateNormal];
    [self.view addSubview:totalPriceButton];
    
    TZButton *orderCountButton = [[TZButton alloc] initWithFrame:CGRectMake(spaceWidth*2+80, 120, 80, 150)];
    orderCountButton.userInteractionEnabled = NO;
    orderCountButton.spaceHight = 20;
    orderCountButton.titleLabel.numberOfLines = 0;
    orderCountButton.titleLabel.font = [UIFont systemFontOfSize:15];
    [orderCountButton setTitleColor:COLOR_TEXT_II forState:UIControlStateNormal];
    [orderCountButton setImage:[UIImage imageNamed:@"icon_business_order_number.png"] forState:UIControlStateNormal];
    [self.view addSubview:orderCountButton];
    
    [StoreManager asyncLoadStoreInfoWithStoreId:[AccountManager shareAccountManager].account.userId completionBlock:^(BOOL isSuccess, StoreDetailModel *storeDetail) {
        NSMutableAttributedString *totalPrice = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"总销售额\n%@元", @"10000"]];
        [totalPrice addAttributes:@{NSForegroundColorAttributeName: COLOR_PRICE_RED} range:NSMakeRange(5, totalPrice.length-5)];
        [totalPriceButton setAttributedTitle:totalPrice forState:UIControlStateNormal];
        
        NSMutableAttributedString *orderCount = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"总订单量\n%@单", @"10000"]];
        [orderCount addAttributes:@{NSForegroundColorAttributeName: COLOR_PRICE_RED} range:NSMakeRange(5, totalPrice.length-5)];
        [orderCountButton setAttributedTitle:orderCount forState:UIControlStateNormal];

    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)myOrdersAction:(id)sender {
    BNOrderListRootViewController *ctl = [[BNOrderListRootViewController alloc] init];
    ctl.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:ctl animated:YES];
}

- (IBAction)myGoodsAction:(id)sender {
    BNGoodsListRootViewController *ctl = [[BNGoodsListRootViewController alloc] init];
    ctl.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:ctl animated:YES];
}

@end

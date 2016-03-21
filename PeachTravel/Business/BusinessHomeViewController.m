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
@property (weak, nonatomic) IBOutlet UIButton *myGoodsButton;

@property (weak, nonatomic) IBOutlet UIButton *myOrderButton;
@end

@implementation BusinessHomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"我的店铺";
    
    _myGoodsButton.layer.borderColor = [UIColor whiteColor].CGColor;
    _myGoodsButton.layer.borderWidth = 1;
    _myGoodsButton.layer.cornerRadius = 3.0;
    
    _myOrderButton.layer.borderColor = [UIColor whiteColor].CGColor;
    _myOrderButton.layer.borderWidth = 1;
    _myOrderButton.layer.cornerRadius = 3.0;
    
    CGFloat spaceWidth = (kWindowWidth-200)/3;
    UIImageView *totalPriceImageView = [[UIImageView alloc] initWithFrame:CGRectMake(spaceWidth, 120, 100, 80)];
    totalPriceImageView.image = [UIImage imageNamed:@"icon_business_order_totalPrice.png"];
    totalPriceImageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:totalPriceImageView];
    
    UILabel *totalPriceLabel = [[UILabel alloc] initWithFrame:CGRectMake(spaceWidth, 220, 100, 40)];
    totalPriceLabel.textColor = [UIColor whiteColor];
    totalPriceLabel.font = [UIFont systemFontOfSize:15.0];
    totalPriceLabel.numberOfLines = 0;
    totalPriceLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:totalPriceLabel];

    UIImageView *orderCountImageView = [[UIImageView alloc] initWithFrame:CGRectMake(spaceWidth*2+100, 120, 100, 80)];
    orderCountImageView.image = [UIImage imageNamed:@"icon_business_order_number.png"];
    orderCountImageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:orderCountImageView];
    
    UILabel *orderCountLabel = [[UILabel alloc] initWithFrame:CGRectMake(spaceWidth*2+100, 220, 100, 40)];
    orderCountLabel.textColor = [UIColor whiteColor];
    orderCountLabel.font = [UIFont systemFontOfSize:15.0];
    orderCountLabel.numberOfLines = 0;
    orderCountLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:orderCountLabel];

    
    [StoreManager asyncLoadStoreInfoWithStoreId:[AccountManager shareAccountManager].account.userId completionBlock:^(BOOL isSuccess, StoreDetailModel *storeDetail) {
        NSMutableAttributedString *totalPrice = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"总销售额\n%@元", storeDetail.formatTotalSales]];
        [totalPrice addAttributes:@{NSFontAttributeName: [UIFont boldSystemFontOfSize:15.0]} range:NSMakeRange(5, totalPrice.length-5)];
        totalPriceLabel.attributedText = totalPrice;
        
        NSMutableAttributedString *orderCount = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"总订单量\n%ld单", storeDetail.totalOrderCnt]];
        [orderCount addAttributes:@{NSFontAttributeName: [UIFont boldSystemFontOfSize:15.0]} range:NSMakeRange(5, orderCount.length-5)];
        orderCountLabel.attributedText = orderCount;
        
        if (storeDetail.pendingOrderCnt) {
            [_myOrderButton setTitle:[NSString stringWithFormat:@"我的订单 (%ld单待处理)", storeDetail.pendingOrderCnt] forState:UIControlStateNormal];
        }

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

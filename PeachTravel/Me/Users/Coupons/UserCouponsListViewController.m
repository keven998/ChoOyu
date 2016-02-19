//
//  UserCouponsListViewController.m
//  PeachTravel
//
//  Created by liangpengshuai on 2/18/16.
//  Copyright © 2016 com.aizou.www. All rights reserved.
//

#import "UserCouponsListViewController.h"
#import "UserCouponsManager.h"
#import "UserCouponTableViewCell.h"

@interface UserCouponsListViewController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, strong) NSArray<UserCouponDetail *> *dataSource;

@end

@implementation UserCouponsListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"我的优惠券";
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [self.tableView registerNib:[UINib nibWithNibName:@"UserCouponTableViewCell" bundle:nil] forCellReuseIdentifier:@"userCouponTableViewCell"];
    
    if (_canSelect) {    //如果可是选择，说明从订单填写页面进来选择优惠券，所以需要通过订单总金额对优惠券进行筛选
        [UserCouponsManager asyncLoadUserCouponsWithUserId:_userId limitMoney:_orderTotalPrice completionBlock:^(BOOL isSuccess, NSArray<UserCouponDetail *> *couponsList) {
            if (isSuccess) {
                if (couponsList.count) {
                    _dataSource = couponsList;
                    [self.tableView reloadData];
                    
                } else {
                    [self setupEmptyView];
                }
            } else {
                [SVProgressHUD showHint:HTTP_FAILED_HINT];
            }

        }];
    } else {
        [UserCouponsManager asyncLoadUserCouponsWithUserId:_userId completionBlock:^(BOOL isSuccess, NSArray<UserCouponDetail *> *couponsList) {
            if (isSuccess) {
                if (couponsList.count) {
                    _dataSource = couponsList;
                    [self.tableView reloadData];
                    
                } else {
                    [self setupEmptyView];
                }
            } else {
                [SVProgressHUD showHint:HTTP_FAILED_HINT];
            }
        }];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

//空白页面
- (void)setupEmptyView
{
    self.tableView.hidden = YES;
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_coupons_empty"]];
    imageView.center = CGPointMake(kWindowWidth/2, 180);
    [self.view addSubview:imageView];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(imageView.frame) + 40, kWindowWidth, 30)];
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = COLOR_TEXT_III;
    label.font = [UIFont systemFontOfSize:15.0];
    label.text = @"您目前没有优惠券~";
    [self.view addSubview:label];
}

- (void)setSelectedCoupon:(UserCouponDetail *)selectedCoupon
{
    _selectedCoupon = selectedCoupon;
    [_tableView reloadData];
}

- (void)didSelectedCoupon:(UIButton *)sender
{
    UserCouponDetail *coupon = _dataSource[sender.tag];
    if ([coupon.couponId isEqualToString:_selectedCoupon.couponId]) {
        _selectedCoupon = nil;
        
    } else {
        _selectedCoupon = coupon;
    }
    [_tableView reloadData];
    
    if ([_delegate respondsToSelector:@selector(didSelectedCoupon:)]) {
        [_delegate didSelectedCoupon:_selectedCoupon];
    }
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 10;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return _dataSource.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 103;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UserCouponTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"userCouponTableViewCell" forIndexPath:indexPath];
    cell.userCouponDetail = _dataSource[indexPath.section];
    cell.selectButton.tag = indexPath.section;
    cell.selectButton.hidden = _canSelect;
    cell.selectButton.selected = [_selectedCoupon.couponId isEqualToString:_dataSource[indexPath.section].couponId];
    [cell.selectButton addTarget:self action:@selector(didSelectedCoupon:) forControlEvents:UIControlEventTouchUpInside];
    return cell;
}

@end







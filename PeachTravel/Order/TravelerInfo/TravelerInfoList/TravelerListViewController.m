//
//  TravelerListViewController.m
//  PeachTravel
//
//  Created by liangpengshuai on 11/18/15.
//  Copyright © 2015 com.aizou.www. All rights reserved.
//

#import "TravelerListViewController.h"
#import "OrderTravelerInfoModel.h"
#import "TravelerListTableViewCell.h"
#import "OrderUserInfoManager.h"
#import "TravelerInfoViewController.h"

@interface TravelerListViewController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation TravelerListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"旅客信息";
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.rowHeight = 130.0;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [_tableView registerNib:[UINib nibWithNibName:@"TravelerListTableViewCell" bundle:nil] forCellReuseIdentifier:@"travelerListCell"];
    
    if (_isCheckMyTravelers) {
        UIButton *addTravelerBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
        [addTravelerBtn setTitle:@"添加" forState:UIControlStateNormal];
        addTravelerBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        [addTravelerBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        addTravelerBtn.titleLabel.font = [UIFont systemFontOfSize:16.0];
        [addTravelerBtn addTarget:self action:@selector(addTraveler:) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:addTravelerBtn];
        self.navigationItem.rightBarButtonItem = rightItem;
    }
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (_isCheckMyTravelers) {
        [OrderUserInfoManager asyncLoadTravelersFromServerOfUser:[AccountManager shareAccountManager].account.userId completionBlock:^(BOOL isSuccess, NSArray<OrderTravelerInfoModel *> *travelers) {
            _travelerList = travelers;
            [_tableView reloadData];
        }];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)addTraveler:(id)sender
{
    TravelerInfoViewController *ctl = [[TravelerInfoViewController alloc] init];
    ctl.isAddTravelerInfo = YES;

    [self.navigationController pushViewController:ctl animated:YES];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _travelerList.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.01;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0.01;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    OrderTravelerInfoModel *travelerInfo = _travelerList[indexPath.row];
    TravelerListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"travelerListCell" forIndexPath:indexPath];
    cell.numberLabel.text = [NSString stringWithFormat:@"旅客%ld", indexPath.row+1];
    cell.travelerInfo = travelerInfo;
  
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (_isCheckMyTravelers) {
        TravelerInfoViewController *ctl = [[TravelerInfoViewController alloc] init];
        ctl.traveler = [_travelerList objectAtIndex:indexPath.row];
        ctl.isEditTravelerInfo = YES;
        [self.navigationController pushViewController:ctl animated:YES];
    }
}

@end

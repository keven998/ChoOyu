//
//  TravelerInfoListViewController.m
//  PeachTravel
//
//  Created by liangpengshuai on 11/10/15.
//  Copyright © 2015 com.aizou.www. All rights reserved.
//

#import "SelectTravelerListViewController.h"
#import "TravelerInfoTableViewCell.h"
#import "OrderUserInfoManager.h"
#import "TravelerInfoViewController.h"

@interface SelectTravelerListViewController ()<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) NSArray<OrderTravelerInfoModel *> *dataSource;   //所有的联系人

@end

@implementation SelectTravelerListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"旅客列表";
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.separatorColor = COLOR_LINE;
    _tableView.backgroundColor = APP_PAGE_COLOR;
    [_tableView registerNib:[UINib nibWithNibName:@"TravelerInfoTableViewCell" bundle:nil] forCellReuseIdentifier:@"travelerInfoTableViewCell"];
    
    UIButton *confirmBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    [confirmBtn setTitle:@"确定" forState:UIControlStateNormal];
    confirmBtn.titleLabel.font = [UIFont systemFontOfSize:16.0];
    [confirmBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [confirmBtn addTarget:self action:@selector(confirm:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:confirmBtn];
    [self setupFooterView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [OrderUserInfoManager asyncLoadTravelersFromServerOfUser:[AccountManager shareAccountManager].account.userId completionBlock:^(BOOL isSuccess, NSArray<OrderTravelerInfoModel *> *travelers) {
        _dataSource = travelers;
        [_tableView reloadData];
    }];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)setupFooterView
{
    UIButton *addTravelerBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, kWindowHeight-49, kWindowWidth, 49)];
    addTravelerBtn.backgroundColor = [UIColor whiteColor];
    addTravelerBtn.layer.borderWidth = 0.5;
    addTravelerBtn.layer.borderColor = COLOR_LINE.CGColor;
    addTravelerBtn.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 10);
    addTravelerBtn.titleEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 0);
    addTravelerBtn.titleLabel.font = [UIFont systemFontOfSize:15.0];
    [addTravelerBtn setTitle:@"添加旅客" forState:UIControlStateNormal];
    [addTravelerBtn setTitleColor:APP_THEME_COLOR forState:UIControlStateNormal];
    [addTravelerBtn setImage:[UIImage imageNamed:@"icon_travlerInfo_add"] forState:UIControlStateNormal];
    [addTravelerBtn addTarget:self action:@selector(addTraveler:) forControlEvents:UIControlEventTouchUpInside];
    _tableView.tableFooterView = addTravelerBtn;
}

- (void)confirm:(UIButton *)btn
{
    if (_canMultipleSelect) {
        if ([_delegate respondsToSelector:@selector(finishSelectTraveler:)]) {
            [_delegate finishSelectTravelers:_selectedTravelers];
        }
    } else {
        if ([_delegate respondsToSelector:@selector(finishSelectTraveler:)]) {
            [_delegate finishSelectTraveler:[_selectedTravelers firstObject]];
        }
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)addTraveler:(id)sender
{
    TravelerInfoViewController *ctl = [[TravelerInfoViewController alloc] init];
    ctl.isAddTravelerInfo = YES;
    
    [self.navigationController pushViewController:ctl animated:YES];
}

- (void)editTravelerInfo:(UIButton *)btn
{
    TravelerInfoViewController *ctl = [[TravelerInfoViewController alloc] init];
    ctl.isEditTravelerInfo = YES;
    ctl.traveler = _dataSource[btn.tag];
    [self.navigationController pushViewController:ctl animated:YES];
}

- (void)selectTraveler:(UIButton *)btn
{
    if (btn.selected) {
        for (OrderTravelerInfoModel *traveler in _selectedTravelers) {
            if ([traveler.uid isEqualToString:[_dataSource objectAtIndex:btn.tag].uid]) {
                [_selectedTravelers removeObject:traveler];
                break;
            }
        }
    } else {
        if (!_canMultipleSelect) {
            [_selectedTravelers removeAllObjects];
            [_tableView reloadData];
        }
        [_selectedTravelers addObject:[_dataSource objectAtIndex:btn.tag]];
    }
    btn.selected = !btn.selected;
}

- (BOOL)travelerIsSelected:(OrderTravelerInfoModel *)traveler
{
    for (OrderTravelerInfoModel *tr in _selectedTravelers) {
        if ([traveler.uid isEqualToString:tr.uid]) {
            return YES;
        }
    }
    return NO;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _dataSource.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.01;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0.01;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 67;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    OrderTravelerInfoModel *travelerInfo = _dataSource[indexPath.row];
    TravelerInfoTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"travelerInfoTableViewCell" forIndexPath:indexPath];
    cell.selectBtn.tag = indexPath.row;
    cell.titleLabel.text = [NSString stringWithFormat:@"%@%@", travelerInfo.firstName, travelerInfo.lastName];
    cell.subTitleLabel.text = [NSString stringWithFormat:@"%@:  %@", travelerInfo.IDCategoryDesc, travelerInfo.IDNumber];
    cell.editBtn.hidden = !_canEditInfo;
    [cell.selectBtn addTarget:self action:@selector(selectTraveler:) forControlEvents:UIControlEventTouchUpInside];
    cell.selectBtn.selected = [self travelerIsSelected:travelerInfo];
    cell.editBtn.tag = indexPath.row;
    [cell.editBtn addTarget:self action:@selector(editTravelerInfo:) forControlEvents:UIControlEventTouchUpInside];
    return cell;
}

@end

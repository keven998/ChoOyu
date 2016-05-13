//
//  SellerOfCityTableViewController.m
//  PeachTravel
//
//  Created by liangpengshuai on 5/13/16.
//  Copyright © 2016 com.aizou.www. All rights reserved.
//

#import "SellerOfCityTableViewController.h"
#import "StoreDetailModel.h"
#import "StoreDetailViewController.h"

@interface SellerOfCityTableViewController ()


@end

@implementation SellerOfCityTableViewController

- (instancetype)init
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.separatorColor = COLOR_LINE;
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return _dataSource.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    
    UIImageView *headerImageView = [[UIImageView alloc] initWithFrame:CGRectMake(12, 7.5, 35, 35)];
    headerImageView.clipsToBounds = YES;
    headerImageView.layer.cornerRadius = 17.5;
    [cell addSubview:headerImageView];
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(60, 10, kWindowWidth-80, 20)];
    titleLabel.textColor = COLOR_TEXT_I;
    titleLabel.font = [UIFont systemFontOfSize:15.0];
    [cell addSubview:titleLabel];
    
    UILabel *contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(60, 30, kWindowWidth-80, 20)];
    contentLabel.textColor = COLOR_TEXT_II;
    contentLabel.font = [UIFont systemFontOfSize:13.0];
    [cell addSubview:contentLabel];
    
    StoreDetailModel *store = [_dataSource objectAtIndex:indexPath.row];
    [headerImageView sd_setImageWithURL:[NSURL URLWithString:store.business.avatar] placeholderImage:[UIImage imageNamed:@"avatar_default"]];
    titleLabel.text = store.storeName;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    StoreDetailModel *store = [_dataSource objectAtIndex:indexPath.row];
    StoreDetailViewController *ctl = [[StoreDetailViewController alloc] init];
    ctl.storeId = store.storeId;
    [self.navigationController pushViewController:ctl animated:YES];
}


@end

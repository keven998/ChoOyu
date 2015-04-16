//
//  TravelersTableViewController.m
//  PeachTravel
//
//  Created by Luo Yong on 15/4/8.
//  Copyright (c) 2015年 com.aizou.www. All rights reserved.
//

#import "TravelersTableViewController.h"
#import "TravelersTableViewCell.h"
#import "ContactDetailViewController.h"
#import "DistributionViewController.h"

@interface TravelersTableViewController ()

@property (nonatomic, strong) NSMutableArray *travelers;
@property (nonatomic, assign) NSUInteger currentPage;

@end

@implementation TravelersTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.title = @"旅行达人";
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"筛选" style:UIBarButtonItemStylePlain target:self action:@selector(goSelect)];
    
    self.enableLoadingMore = NO;
    [self.tableView setContentInset:UIEdgeInsetsMake(10, 0, 10, 0)];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView registerNib:[UINib nibWithNibName:@"TravelersTableViewCell" bundle:nil] forCellReuseIdentifier:@"travel_user_cell"];
    
    _currentPage = 0;
    [self loadTravels:_currentPage];
}

#pragma mark - http method
- (void) loadTravels:(NSInteger)pageNo {
    
}

#pragma mark - private method
- (void) goSelect {
    DistributionViewController *dctl = [[DistributionViewController alloc] init];
    [self presentViewController:[[UINavigationController alloc] initWithRootViewController:dctl] animated:YES completion:nil];
}

#pragma mark - UITableViewDataSource & UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44.0f;
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _travelers.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TravelersTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"travel_user_cell" forIndexPath:indexPath];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    ContactDetailViewController *contactDetailCtl = [[ContactDetailViewController alloc] init];
//    contactDetailCtl.contact = contact;
    [self.navigationController pushViewController:contactDetailCtl animated:YES];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

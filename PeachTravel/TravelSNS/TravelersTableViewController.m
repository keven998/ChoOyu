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
#import "UserProfile.h"

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
    [self loadTravelers:nil];
}

#pragma mark - http method
- (void)loadTravelers:(NSString *)destination
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    AppUtils *utils = [[AppUtils alloc] init];
    [manager.requestSerializer setValue:utils.appVersion forHTTPHeaderField:@"Version"];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"iOS %@",utils.systemVersion] forHTTPHeaderField:@"Platform"];
    
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [manager.requestSerializer setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    NSNumber *imageWidth = [NSNumber numberWithInt:(CGRectGetWidth(self.view.bounds) - 22)*2];
    [params setObject:imageWidth forKey:@"imgWidth"];
    [params setObject:@"expert" forKey:@"keyword"];
    [params setObject:@"roles" forKey:@"field"];
    
    TZProgressHUD *hud = [[TZProgressHUD alloc] init];
    __weak typeof(TravelersTableViewController *)weakSelf = self;
    [hud showHUDInViewController:weakSelf];
    //搜索达人
    [manager GET:API_SEARCH_USER parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [hud hideTZHUD];
        NSInteger code = [[responseObject objectForKey:@"code"] integerValue];
        if (code == 0) {
            [self parseSearchResult:[responseObject objectForKey:@"result"]];
        } else {
            [SVProgressHUD showHint:[[responseObject objectForKey:@"err"] objectForKey:@"message"]];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [hud hideTZHUD];
    }];
}

- (void)parseSearchResult:(id)searchResult
{
    NSInteger count = [searchResult count];
    if (_travelers == nil) {
        _travelers = [[NSMutableArray alloc] initWithCapacity:count];
    }
    UserProfile *user;
    for (int i = 0; i < count; ++i) {
        user = [[UserProfile alloc] initWithJsonObject:[searchResult objectAtIndex:i]];
        [_travelers addObject:user];
    }
    [self.tableView reloadData];
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
    UserProfile *up = [_travelers objectAtIndex:indexPath.row];
    [cell.avatarView sd_setImageWithURL:[NSURL URLWithString:up.avatarUrl]];
    cell.nameLabel.text = up.name;
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

#pragma mark - http method

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

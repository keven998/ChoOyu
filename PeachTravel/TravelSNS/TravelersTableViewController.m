//
//  TravelersTableViewController.m
//  PeachTravel
//
//  Created by Luo Yong on 15/4/8.
//  Copyright (c) 2015年 com.aizou.www. All rights reserved.
//

#import "TravelersTableViewController.h"
#import "TravelerTableViewCell.h"
#import "ContactDetailViewController.h"
#import "DistributionViewController.h"
#import "UserProfile.h"
#import "ScreeningViewController.h"
#import "ForeignScreeningViewController.h"
#import "OtherUserInfoViewController.h"
#import "DomesticScreeningViewController.h"
#import "TZButton.h"
@interface TravelersTableViewController ()<doScreenning>

@property (nonatomic, strong) NSMutableArray *travelers;
@property (nonatomic, assign) NSUInteger currentPage;

@end

@implementation TravelersTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.title = @"派派达人";
    
    TZButton *btn = [TZButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(0, 0, 44, 44);
    [btn setTitle:@"筛选" forState:UIControlStateNormal];
    [btn setTitleColor:APP_THEME_COLOR forState:UIControlStateNormal];
    [btn setImage:[UIImage imageNamed:@"ic_shaixuan_.png"] forState:UIControlStateNormal];
    btn.titleLabel.font = [UIFont boldSystemFontOfSize:16];
    [btn addTarget:self action:@selector(goSelect) forControlEvents:UIControlEventTouchUpInside];
    btn.imagePosition = IMAGE_AT_RIGHT;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btn];

    self.enableLoadingMore = NO;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView registerClass:[TravelerTableViewCell class] forCellReuseIdentifier:@"travel_user_cell"];
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
    NSNumber *imageWidth = [NSNumber numberWithInt:60];
    [params setObject:imageWidth forKey:@"imgWidth"];
    [params setObject:@"expert" forKey:@"keyword"];
    [params setObject:@"roles" forKey:@"field"];
    
    TZProgressHUD *hud = [[TZProgressHUD alloc] init];
    __weak typeof(TravelersTableViewController *)weakSelf = self;
    [hud showHUDInViewController:weakSelf content:64];
    //搜索达人
    [manager GET:API_SEARCH_USER parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [hud hideTZHUD];
        NSLog(@"%@",responseObject);
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
//    DistributionViewController *dctl = [[DistributionViewController alloc] init];
    ScreeningViewController *screen = [[ScreeningViewController alloc]init];
    ForeignScreeningViewController *fcvc = [[ForeignScreeningViewController alloc]init];
    DomesticScreeningViewController *dsvc = [[DomesticScreeningViewController alloc]init];
    screen.delegate = self;
    fcvc.screeningVC = screen;
    dsvc.screeningVC = screen;
    screen.viewControllers = @[fcvc,dsvc];
    screen.duration = 0;
    screen.segmentedTitles = @[@"国内", @"国外"];
    screen.selectedColor = APP_THEME_COLOR;
    screen.segmentedTitleFont = [UIFont systemFontOfSize:18.0];
    screen.normalColor= [UIColor grayColor];
    
    [self presentViewController:[[UINavigationController alloc] initWithRootViewController:screen] animated:YES completion:nil];
}

#pragma mark - UITableViewDataSource & UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 90;
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _travelers.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TravelerTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"travel_user_cell" forIndexPath:indexPath];
    UserProfile *up = [_travelers objectAtIndex:indexPath.row];
    [cell.avatarView sd_setImageWithURL:[NSURL URLWithString:up.avatarSmall]];
    cell.nameLabel.text = up.name;
    cell.footprintsLabel.text = [NSString stringWithFormat:@"足迹: %@", [up getFootprintDescription]];
    cell.signatureLabel.text = up.signature;
    cell.statusLable.text = [up getRolesDescription];
    cell.levelLabel.text = [NSString stringWithFormat:@"V%ld", up.level];
    cell.resideLabel.text = up.residence;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    OtherUserInfoViewController *otherInfoCtl = [[OtherUserInfoViewController alloc]init];
    UserProfile *model = _travelers[indexPath.row];
    otherInfoCtl.model = model;
    [self.navigationController pushViewController:otherInfoCtl animated:YES] ;
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//doscreening delegate
- (void)screeningTravelers:(NSString *)destination
{
    [_travelers removeAllObjects];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    AppUtils *utils = [[AppUtils alloc] init];
    [manager.requestSerializer setValue:utils.appVersion forHTTPHeaderField:@"Version"];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"iOS %@",utils.systemVersion] forHTTPHeaderField:@"Platform"];
    
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [manager.requestSerializer setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    NSNumber *imageWidth = [NSNumber numberWithInt:60];
    [params setObject:imageWidth forKey:@"imgWidth"];
    [params setObject:destination forKey:@"locId"];
    [params setObject:@"roles" forKey:@"field"];
    
    TZProgressHUD *hud = [[TZProgressHUD alloc] init];
    __weak typeof(TravelersTableViewController *)weakSelf = self;
    [hud showHUDInViewController:weakSelf content:64];
    //搜索达人
    [manager POST:API_SCREENING_EXPERT parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [hud hideTZHUD];
        NSLog(@"%@",responseObject);
        NSInteger code = [[responseObject objectForKey:@"code"] integerValue];
        NSLog(@"---%@",responseObject);
        if (code == 0) {
            [self parseSearchResult:[responseObject objectForKey:@"result"]];
        } else {
            [SVProgressHUD showHint:[[responseObject objectForKey:@"err"] objectForKey:@"message"]];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [hud hideTZHUD];
    }];
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

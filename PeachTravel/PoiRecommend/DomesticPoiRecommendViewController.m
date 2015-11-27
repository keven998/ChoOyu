//
//  DomesticPoiRecommendViewController.m
//  PeachTravel
//
//  Created by liangpengshuai on 9/23/15.
//  Copyright © 2015 com.aizou.www. All rights reserved.
//

#import "DomesticPoiRecommendViewController.h"
#import "PoiRecommendTableViewCell.h"
#import "PoiManager.h"
#import "CityDetailViewController.h"

@interface DomesticPoiRecommendViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *dataSource;


@end

@implementation DomesticPoiRecommendViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self.view addSubview:self.tableView];
    [PoiManager asyncLoadDomescticRecommendPoiWithCompletionBlcok:^(BOOL isSuccess, NSArray *poiList) {
        if (isSuccess) {
            _dataSource = poiList;
            [self.tableView reloadData];
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (UITableView *)tableView
{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 64, self.view.bounds.size.width, self.view.bounds.size.height-64-48)];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [_tableView registerNib:[UINib nibWithNibName:@"PoiRecommendTableViewCell" bundle:nil] forCellReuseIdentifier:@"poiRecommendCell"];
    }
    return _tableView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 210;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PoiRecommendTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"poiRecommendCell" forIndexPath:indexPath];
    cell.poi = [_dataSource objectAtIndex:indexPath.row];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    CityDetailViewController *ctl = [[CityDetailViewController alloc] init];
    PoiRecommend *poi = [_dataSource objectAtIndex:indexPath.row];
    ctl.cityId = poi.recommondId;
    [self.navigationController pushViewController:ctl animated:YES];
}


@end












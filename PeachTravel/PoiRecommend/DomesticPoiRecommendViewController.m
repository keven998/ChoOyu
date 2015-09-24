//
//  DomesticPoiRecommendViewController.m
//  PeachTravel
//
//  Created by liangpengshuai on 9/23/15.
//  Copyright © 2015 com.aizou.www. All rights reserved.
//

#import "DomesticPoiRecommendViewController.h"
#import "PoiRecommendTableViewCell.h"

@interface DomesticPoiRecommendViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;

@end

@implementation DomesticPoiRecommendViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self.view addSubview:self.tableView];
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
    return 10;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PoiRecommendTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"poiRecommendCell" forIndexPath:indexPath];
    return cell;
}

@end












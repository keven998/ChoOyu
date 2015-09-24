//
//  DomesticPoiRecommendViewController.m
//  PeachTravel
//
//  Created by liangpengshuai on 9/23/15.
//  Copyright © 2015 com.aizou.www. All rights reserved.
//

#import "DomesticPoiRecommendViewController.h"

@interface DomesticPoiRecommendViewController ()

@property (nonatomic, strong) UITableView *tableView;

@end

@implementation DomesticPoiRecommendViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UITableView *)tableView
{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:self.view.bounds];
    }
    return _tableView;
}

@end

//
//  SearchDestinationViewController.m
//  PeachTravel
//
//  Created by liangpengshuai on 12/9/14.
//  Copyright (c) 2014 com.aizou.www. All rights reserved.
//

#import "SearchDestinationViewController.h"

@interface SearchDestinationViewController () <UISearchBarDelegate, UISearchControllerDelegate, UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) NSMutableArray *dataSource;
@property (nonatomic, strong) UISearchDisplayController *searchController;
@property (nonatomic, strong) UISearchBar *searchBar;

@end

@implementation SearchDestinationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _searchBar = [[UISearchBar alloc]initWithFrame:CGRectMake(20, 64, self.view.bounds.size.width-40, 38)];
    _searchBar.searchBarStyle = UISearchBarStyleMinimal;
    _searchBar.delegate = self;
    [_searchBar setPlaceholder:@"请输入城市名或拼音"];
    _searchBar.autocorrectionType = UITextAutocorrectionTypeNo;
    _searchBar.autocapitalizationType = UITextAutocapitalizationTypeNone;
    _searchBar.translucent = YES;
    _searchBar.showsCancelButton = YES;
    _searchController = [[UISearchDisplayController alloc]initWithSearchBar:_searchBar contentsController:self];
    _searchController.active = NO;
    _searchController.searchResultsDataSource = self;
    _searchController.searchResultsDelegate = self;
    
    [self.view addSubview:_searchBar];

}

#pragma mark - tableview datasource & delegate

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 0;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 0;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}

@end

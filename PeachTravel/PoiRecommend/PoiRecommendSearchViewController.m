//
//  PoiRecommendSearchViewController.m
//  PeachTravel
//
//  Created by liangpengshuai on 9/29/15.
//  Copyright © 2015 com.aizou.www. All rights reserved.
//

#import "PoiRecommendSearchViewController.h"
#import "AreaDestination.h"
#import "PoiRecommendTableViewCell.h"

@interface PoiRecommendSearchViewController () <UISearchBarDelegate,UITableViewDataSource,UITableViewDelegate>

@property (nonatomic, strong)UITableView *tableView;
@property (nonatomic, strong)UISearchBar *searchBar;

@property (nonatomic, strong)NSMutableArray * dataSource;

@property (nonatomic, strong)NSMutableArray * allCountriesName;

@end

@implementation PoiRecommendSearchViewController

/**
 *  懒加载数组
 *
 *  @return 数组
 */
- (NSMutableArray *)dataSource
{
    if (_dataSource == nil) {
        _dataSource = [NSMutableArray array];
    }
    return _dataSource;
}

- (NSMutableArray *)allCountriesName
{
    if (_allCountriesName == nil) {
        _allCountriesName = [NSMutableArray array];
    }
    return _allCountriesName;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = APP_PAGE_COLOR;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(goBack)];
    
    _searchBar = [[UISearchBar alloc]init];
    _searchBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    _searchBar.delegate = self;
    [_searchBar setPlaceholder:@"输入城市名"];
    _searchBar.tintColor = COLOR_TEXT_II;
    _searchBar.autocorrectionType = UITextAutocorrectionTypeNo;
    [_searchBar setSearchFieldBackgroundImage:[[UIImage imageNamed:@"icon_search_bg.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(5, 5, 5, 5)] forState:UIControlStateNormal];
    [_searchBar setBackgroundColor:[UIColor whiteColor]];
    _searchBar.autocapitalizationType = UITextAutocapitalizationTypeNone;
    self.navigationItem.titleView = _searchBar;
    
    UIImageView *imageBg = [[UIImageView alloc]initWithFrame:CGRectMake((kWindowWidth - 210)/2, 68, 210, 130)];
    
    imageBg.image = [UIImage imageNamed:@"search_default_background"];
    //    [self.view addSubview:imageBg];
    
    [self.view addSubview:self.tableView];
    self.tableView.hidden = YES;
    
    [_searchBar becomeFirstResponder];
    
    // 添加TableView
    [self.view addSubview:self.tableView];
    self.tableView.hidden = YES;
}

- (void)goBack {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [_searchBar endEditing:YES];
}

#pragma mark - 赋值
- (void)setDestinations:(Destinations *)destinations
{
    _destinations = destinations;
}

#pragma mark - 实现tableView的数据源以及代理方法
- (UITableView *)tableView
{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds) - 49)];
        _tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _tableView.backgroundColor = APP_PAGE_COLOR;
        
        _tableView.contentInset = UIEdgeInsetsMake(0, 0, 26, 0);
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.dataSource = self;
        _tableView.delegate = self;
        [_tableView registerNib:[UINib nibWithNibName:@"PoiRecommendTableViewCell" bundle:nil] forCellReuseIdentifier:@"poiRecommendCell"];
        
        UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _tableView.bounds.size.width, 41)];
        footerView.backgroundColor = APP_PAGE_COLOR;
        _tableView.tableFooterView = footerView;
    }
    return _tableView;
}



#pragma mark - 实现tableView数据源方法以及代理方法
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 210.0;
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
    
    PoiRecommendTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"poiRecommendCell" forIndexPath:indexPath];
    
    // 设置cell的文字
    CityDestinationPoi * cityPoi = self.dataSource[indexPath.row];
    cell.titleLabel.text = cityPoi.zhName;
    TaoziImage *image = [cityPoi.images firstObject];
    [cell.backGroundImageView sd_setImageWithURL:[NSURL URLWithString:image.imageUrl]];
    
    return cell;
}

// 添加计划
- (void)addNewPlan:(UIButton *)sender
{
    sender.selected = !sender.selected;
    
    CityDestinationPoi * cityPoi = self.dataSource[sender.tag];
    
    // 如果当前选中,就加入到目的地选中列表中
    if (sender.selected) {
        // 需要先判断当前有没有选中城市
        for (int i = 0; i < self.destinations.destinationsSelected.count; i++) {
            CityDestinationPoi * addedCityPoi = self.destinations.destinationsSelected[i];
            
            if ([cityPoi.cityId isEqualToString:addedCityPoi.cityId]) {
                return;
            }
        }
        
        [self.destinations.destinationsSelected addObject:cityPoi];
    } else { // 如果从选中状态取消,就将此目的地从selected选择列表移除
        
        for (int i = 0; i < self.destinations.destinationsSelected.count; i++) {
            CityDestinationPoi * addedCityPoi = self.destinations.destinationsSelected[i];
            
            if ([cityPoi.cityId isEqualToString:addedCityPoi.cityId]) {
                [self.destinations.destinationsSelected removeObjectAtIndex:i];
            }
        }
    }
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}


- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self.searchBar endEditing:YES];
}


#pragma mark - 实现SearchBar的代理方法
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [self refreshTableDataWithSearchText:_searchBar.text];

}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - 输入文字时刷新表格数据
- (void)refreshTableDataWithSearchText:(NSString *)searchText{
    
    self.tableView.hidden = NO;
    
    [self.dataSource removeAllObjects];
    [self.allCountriesName removeAllObjects];
    
    // 存储所有区域数组
    NSMutableArray * allAreaDestination = [NSMutableArray array];
    [allAreaDestination addObjectsFromArray:self.destinations.domesticCities];
    [allAreaDestination addObjectsFromArray:self.destinations.foreignCountries];
    
    // 进行匹配
    // 将小写字母转换成大写字母
    NSString * newSearchText = searchText.uppercaseString;
    
    for (AreaDestination * areaDestination in allAreaDestination) {
        
        // 包含具体城市
        NSArray * detailCities = areaDestination.cities;
        for (CityDestinationPoi * cityPoi in detailCities) {
            // 搜索结果是否包含该城市
            BOOL isIncludeCities = [cityPoi.zhName.uppercaseString rangeOfString:newSearchText].location != NSNotFound;
            if (isIncludeCities) {
                [self.dataSource addObject:cityPoi];
                [self.allCountriesName addObject:areaDestination.zhName];
            }
        }
    }
    
    [self.tableView reloadData];
    [self.searchBar endEditing:YES];
    
    
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.searchBar endEditing:YES];
}

@end

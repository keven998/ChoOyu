//
//  MakePlanSearchController.m
//  PeachTravel
//
//  Created by 王聪 on 15/8/13.
//  Copyright (c) 2015年 com.aizou.www. All rights reserved.
//

#import "MakePlanSearchController.h"
#import "AreaDestination.h"
#import "MakePlanSearchCell.h"
#import "DestinationCollectionViewCell.h"

@interface MakePlanSearchController () <UISearchBarDelegate,UITableViewDataSource,UITableViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UISearchBar *searchBar;

@property (nonatomic, strong)NSMutableArray * dataSource;

@property (nonatomic, strong)NSMutableArray * allCountriesName;

@property (nonatomic, strong) UICollectionView *selectPanel;


#define makePlanCell  @"makePlanCell"

@end

@implementation MakePlanSearchController

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
    [_searchBar setBackgroundImage:[ConvertMethods createImageWithColor:APP_THEME_COLOR] forBarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
    [_searchBar setBackgroundColor:APP_THEME_COLOR];
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
    
    // 添加下方的目的地列表
    [self setupSelectPanel];
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
    
    NSLog(@"%@",destinations);
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
        
        UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _tableView.bounds.size.width, 41)];
        footerView.backgroundColor = APP_PAGE_COLOR;
        _tableView.tableFooterView = footerView;
    }
    return _tableView;
}



#pragma mark - 实现tableView数据源方法以及代理方法
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 58.0;
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
    
    MakePlanSearchCell * cell = [MakePlanSearchCell makePlanSearchWithTableView:tableView];
    
    // 设置cell的文字
    CityDestinationPoi * cityPoi = self.dataSource[indexPath.row];
    
    NSString * countryName = self.allCountriesName[indexPath.row];
    
    cell.titleLabel.text = [NSString stringWithFormat:@"%@,%@",cityPoi.zhName,countryName];
    
    cell.addPlan.tag = indexPath.row;
    
    [cell.addPlan addTarget:self action:@selector(addNewPlan:) forControlEvents:UIControlEventTouchUpInside];
    
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
    
    NSLog(@"%@",self.destinations.destinationsSelected);
    
    [self.selectPanel reloadData];
    
    if (self.destinations.destinationsSelected.count == 0) {
        [self hideDestinationBar];
    }else{
        [self showDestinationBar];
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
    NSLog(@"点击了搜索按钮");
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    NSLog(@"%s",__func__);
    
    [self refreshTableDataWithSearchText:searchText];
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


#pragma mark - 添加下面的选择面板

- (void) setupSelectPanel {
    UIView *toolBar = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height-49, self.view.frame.size.width, 49)];
    toolBar.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    toolBar.layer.shadowColor = COLOR_LINE.CGColor;
    toolBar.layer.shadowOffset = CGSizeMake(0, -1.0);
    toolBar.layer.shadowOpacity = 0.33;
    toolBar.layer.shadowRadius = 1.0;
    [self.view addSubview:toolBar];
    
    UICollectionViewFlowLayout *aFlowLayout = [[UICollectionViewFlowLayout alloc] init];
    aFlowLayout.minimumInteritemSpacing = 0;
    [aFlowLayout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    self.selectPanel = [[UICollectionView alloc] initWithFrame:toolBar.bounds collectionViewLayout:aFlowLayout];
    [self.selectPanel setBackgroundColor:[UIColor whiteColor]];
    self.selectPanel.showsHorizontalScrollIndicator = NO;
    self.selectPanel.showsVerticalScrollIndicator = NO;
    self.selectPanel.delegate = self;
    self.selectPanel.dataSource = self;
    self.selectPanel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    self.selectPanel.contentInset = UIEdgeInsetsMake(0, 15, 0, 15);
    [self.selectPanel registerNib:[UINib nibWithNibName:@"DestinationCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"cell"];
    [toolBar addSubview:_selectPanel];
    
    UILabel *hintText = [[UILabel alloc] initWithFrame:toolBar.bounds];
    hintText.textColor = TEXT_COLOR_TITLE_HINT;
    hintText.text = @"选择想去的城市";
    hintText.textAlignment = NSTextAlignmentCenter;
    hintText.font = [UIFont systemFontOfSize:14];
    hintText.tag = 1;
    [toolBar addSubview:hintText];

    if (self.destinations.destinationsSelected.count == 0) {
        [self hideDestinationBar];
    }else{
        [self showDestinationBar];
    }
}


- (void)hideDestinationBar
{
    UIView *view = [self.selectPanel.superview viewWithTag:1];
    view.hidden = NO;
}

- (void)showDestinationBar
{
    UIView *view = [self.selectPanel.superview viewWithTag:1];
    view.hidden = YES;
}

#pragma mark - Collection view

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.destinations.destinationsSelected.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    DestinationCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    CityDestinationPoi *city = [self.destinations.destinationsSelected objectAtIndex:indexPath.row];
    cell.titleLabel.text = [NSString stringWithFormat:@"%ld.%@", (long)(indexPath.row + 1), city.zhName];

    
    // 执行跳转
    [self.selectPanel performBatchUpdates:^{
        
    } completion:^(BOOL finished) {
        [collectionView scrollToItemAtIndexPath:indexPath
                               atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
    }];
    
    return cell;
}


- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    /*
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    CityDestinationPoi *city = [_destinations.destinationsSelected objectAtIndex:indexPath.row];
    [_destinations.destinationsSelected removeObjectAtIndex:indexPath.row];
    NSIndexPath *lnp = [NSIndexPath indexPathForItem:indexPath.row inSection:0];
    [_selectPanel performBatchUpdates:^{
        [_selectPanel deleteItemsAtIndexPaths:[NSArray arrayWithObject:lnp]];
    } completion:^(BOOL finished) {
        if (_destinations.destinationsSelected.count == 0) {
            [self hideDestinationBar];
        }
    }];
    [[NSNotificationCenter defaultCenter] postNotificationName:updateDestinationsSelectedNoti object:nil userInfo:@{@"city":city}];
     */
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CityDestinationPoi *city = [self.destinations.destinationsSelected objectAtIndex:indexPath.row];
    NSString *txt = [NSString stringWithFormat:@"%ld.%@", (long)(indexPath.row + 1), city.zhName];
    CGSize size = [txt sizeWithAttributes:@{NSFontAttributeName : [UIFont systemFontOfSize:17]}];
    NSLog(@"%@", NSStringFromCGSize(size));
    return CGSizeMake(size.width, 28);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 14;
}


@end

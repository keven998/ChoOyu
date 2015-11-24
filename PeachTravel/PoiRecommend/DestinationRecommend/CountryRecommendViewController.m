//
//  CountryRecommendViewController.m
//  PeachTravel
//
//  Created by liangpengshuai on 11/5/15.
//  Copyright © 2015 com.aizou.www. All rights reserved.
//

#import "CountryRecommendViewController.h"
#import "CountryRecommendTableViewCell.h"
#import "MenuButton.h"
#import "CircleMenu.h"
#import "CityListViewController.h"
#import "PoiManager.h"

@interface CountryRecommendViewController () <UITableViewDataSource, UITableViewDelegate, circleMenuDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (strong, nonatomic) UIButton *searchBtn;
@property (strong, nonatomic) CircleMenu *circleMenu;
@property (strong, nonatomic) UIButton *currentSelectedBtn;  //三角按钮
@property (strong, nonatomic) NSArray *menuTitles;
@property (strong, nonatomic) NSArray *continentCodes;
@property (weak, nonatomic) UITapGestureRecognizer *tapGesture;
@property (nonatomic, strong) NSArray<NSMutableArray *> *dataSource;
@property (nonatomic) NSInteger currentSelectIndex;   //当前选中的哪个州

@end

@implementation CountryRecommendViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _currentSelectIndex = -1;
    _menuTitles = @[@"推荐", @"亚洲", @"北美", @"南美", @"欧洲", @"非洲", @"大洋洲"];
    _continentCodes = @[[NSNumber numberWithInteger:kRECOM], [NSNumber numberWithInteger:kAS], [NSNumber numberWithInteger:kNA], [NSNumber numberWithInteger:kSA], [NSNumber numberWithInteger:kEU], [NSNumber numberWithInteger:kAF], [NSNumber numberWithInteger:kOC]];
    
    NSMutableArray *tempArray = [[NSMutableArray alloc] init];
    for (int i = 0; i<_menuTitles.count; i++) {
        [tempArray addObject:[[NSMutableArray alloc] init]];
    }
    _dataSource = tempArray;

    self.view.backgroundColor = [UIColor whiteColor];
    self.automaticallyAdjustsScrollViewInsets = NO;
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kWindowWidth, kWindowHeight)];
    [_tableView registerNib:[UINib nibWithNibName:@"CountryRecommendTableViewCell" bundle:nil] forCellReuseIdentifier:@"countryRecommendTableViewCell"];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _tableView.bounds.size.width, 49)];
    [self.view addSubview:_tableView];
    
    _searchBtn = [[UIButton alloc] initWithFrame:CGRectMake(30, 25, self.view.frame.size.width-60, 27)];
    [_searchBtn setBackgroundImage:[[UIImage imageNamed:@"icon_goods_search_bg"] resizableImageWithCapInsets:UIEdgeInsetsMake(2, 40, 2, 20)] forState:UIControlStateNormal];
    
    UILabel *searchLabel = [[UILabel alloc] initWithFrame:CGRectMake(45, 0, _searchBtn.bounds.size.width-50, 27)];
    searchLabel.text = @"搜索目的地";
    searchLabel.textColor = [UIColor whiteColor];
    searchLabel.font = [UIFont systemFontOfSize:14.0];
    [_searchBtn addSubview:searchLabel];
    [self.view addSubview:_searchBtn];
    [self setupCircleMenu];
    
    _currentSelectedBtn = [[UIButton alloc] initWithFrame:CGRectMake(kWindowWidth-25, kWindowHeight/2-30, 25, 60)];
    [_currentSelectedBtn setBackgroundImage:[UIImage imageNamed:@"icon_currentRecommend_selected.png"] forState:UIControlStateNormal];
    _currentSelectedBtn.titleLabel.numberOfLines = 0;
    _currentSelectedBtn.contentEdgeInsets = UIEdgeInsetsMake(0, 9, 0, 0);
    _currentSelectedBtn.titleLabel.font = [UIFont systemFontOfSize:10.0];
    [_currentSelectedBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_currentSelectedBtn addTarget:self action:@selector(showCircleMenu) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_currentSelectedBtn];
    [self cilckAction: 0];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if (self.navigationController.viewControllers.count > 1) {     //如果是 push 的情况下才显示 navibar ，没想到更好的解决办法
        [self.navigationController setNavigationBarHidden:NO animated:YES];
    }
}

- (void)setupCircleMenu {
    NSMutableArray *arr = [[NSMutableArray alloc] init];
    for (int i = 0; i < _menuTitles.count; i ++) {
        MenuButton *menuButton = [[MenuButton alloc] initWithFrame:CGRectMake(0, 0, 60, 40)];
        [menuButton setTitle:[_menuTitles objectAtIndex:i] forState:UIControlStateNormal];
        menuButton.tag = i;
        [menuButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [menuButton setTitleColor:APP_THEME_COLOR forState:UIControlStateSelected];
        menuButton.titleLabel.font = [UIFont systemFontOfSize:13.0];
        [menuButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 5)];
        [arr addObject:menuButton];
    }
    
    _circleMenu = [[CircleMenu alloc] initWithFrame:CGRectMake(0, 0, 230, 230)];
    _circleMenu.center = CGPointMake(kWindowWidth+115, kWindowHeight/2);
    _circleMenu.arrButton = arr;
    _circleMenu.delegate = self;
    _circleMenu.backgroundImageView.image = [UIImage imageNamed:@"icon_menu_bgk.png"];
    [self.view addSubview:_circleMenu];
    [_circleMenu loadView];
}

- (void)showCircleMenu
{
    if (!_currentSelectedBtn.hidden) {
        [UIView animateWithDuration:0.3 animations:^{
            _circleMenu.center = CGPointMake(kWindowWidth, kWindowHeight/2);
        } completion:^(BOOL finished) {
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showCircleMenu)];
            tap.numberOfTapsRequired = 1;
            tap.numberOfTouchesRequired = 1;
            _tapGesture = tap;
            [self.view addGestureRecognizer:_tapGesture];
        
        }];
        _currentSelectedBtn.hidden = YES;
    } else {
        [UIView animateWithDuration:0.2 animations:^{
            _circleMenu.center = CGPointMake(kWindowWidth+115, kWindowHeight/2);
        } completion:^(BOOL finished) {
            [self.view removeGestureRecognizer:_tapGesture];
        }];
        _currentSelectedBtn.hidden = NO;
    }
}

- (void)hideCircleMenu
{
    [UIView animateWithDuration:0.2 animations:^{
        _circleMenu.center = CGPointMake(kWindowWidth+115, kWindowHeight/2);
    } completion:^(BOOL finished) {
        
    }];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (_currentSelectIndex == -1) {
        return 0;
    }
    NSMutableArray *countriesList = [_dataSource objectAtIndex:_currentSelectIndex];
    return countriesList.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 200.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_currentSelectIndex == -1) {
        return nil;
    }
    CountryRecommendTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"countryRecommendTableViewCell" forIndexPath:indexPath];
    NSMutableArray *countriesList = [_dataSource objectAtIndex:_currentSelectIndex];
    cell.countryModel = [countriesList objectAtIndex:indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    CityListViewController *ctl = [[CityListViewController alloc] init];
    NSMutableArray *countriesList = [_dataSource objectAtIndex:_currentSelectIndex];
    CountryModel *countryModel = [countriesList objectAtIndex:indexPath.row];
    ctl.countryId = countryModel.coutryId;
    ctl.countryName = countryModel.zhName;
    [self.navigationController pushViewController:ctl animated:YES];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView.contentOffset.y < 0) {
        scrollView.contentOffset = CGPointZero;
    }
}

#pragma mark - circleMenuDelegate

- (void)cilckAction:(NSInteger)tag
{
    if (tag == _currentSelectIndex) {
        return;
    }
    _currentSelectIndex = tag;

    [_currentSelectedBtn setTitle:[_menuTitles objectAtIndex:tag] forState:UIControlStateNormal];
    NSMutableArray *countriesList = [_dataSource objectAtIndex:tag];
    if (countriesList.count == 0) {
        [PoiManager asyncLoadRecommendCountriesWithContinentCode:[[_continentCodes objectAtIndex:tag] integerValue] completionBlcok:^(BOOL isSuccess, NSArray *poiList) {
            [countriesList removeAllObjects];
            [countriesList addObjectsFromArray:poiList];
            [_tableView reloadData];
        }];
    }
    [_tableView reloadData];
}


@end

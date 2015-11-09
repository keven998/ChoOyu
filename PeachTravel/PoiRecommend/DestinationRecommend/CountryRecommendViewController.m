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

@interface CountryRecommendViewController () <UITableViewDataSource, UITableViewDelegate, circleMenuDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (strong, nonatomic) UIButton *searchBtn;
@property (strong, nonatomic) CircleMenu *circleMenu;
@property (strong, nonatomic) UIButton *currentSelectedBtn;
@property (strong, nonatomic) NSArray *menuTitles;
@property (weak, nonatomic) UITapGestureRecognizer *tapGesture;

@end

@implementation CountryRecommendViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _menuTitles = @[@"推荐", @"亚洲", @"美洲", @"欧洲", @"非洲", @"大洋洲", ];

    self.view.backgroundColor = [UIColor whiteColor];
    self.automaticallyAdjustsScrollViewInsets = NO;
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kWindowWidth, kWindowHeight)];
    [_tableView registerNib:[UINib nibWithNibName:@"CountryRecommendTableViewCell" bundle:nil] forCellReuseIdentifier:@"countryRecommendTableViewCell"];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.delegate = self;
    _tableView.dataSource = self;
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
    [_currentSelectedBtn setTitle:[_menuTitles objectAtIndex:0] forState:UIControlStateNormal];
    [_currentSelectedBtn addTarget:self action:@selector(showCircleMenu) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_currentSelectedBtn];
}

- (BOOL)fd_prefersNavigationBarHidden {
    return YES;
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
    return 5;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 200.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CountryRecommendTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"countryRecommendTableViewCell" forIndexPath:indexPath];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    CityListViewController *ctl = [[CityListViewController alloc] init];
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
    [_currentSelectedBtn setTitle:[_menuTitles objectAtIndex:tag] forState:UIControlStateNormal];
}


@end

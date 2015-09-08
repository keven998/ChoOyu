//
//  GuiderSearchViewController.m
//  PeachTravel
//
//  Created by 王聪 on 15/8/27.
//  Copyright (c) 2015年 com.aizou.www. All rights reserved.
//

#import "GuiderSearchViewController.h"
#import "FrendRequestTableViewController.h"
#import "ContactListTableViewCell.h"
#import "AccountManager.h"
#import "ChatViewController.h"
#import "ExpertManager.h"
#import "GuiderProfileViewController.h"
@interface GuiderSearchViewController () <UISearchBarDelegate, UISearchControllerDelegate, UITableViewDataSource, UITableViewDelegate,SWTableViewCellDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UISearchBar *searchBar;

@property (nonatomic, strong)NSArray * dataSource;

#define contactCell      @"contactCell2"
#define requestCell      @"requestCell"

@end

@implementation GuiderSearchViewController

- (NSArray *)dataSource
{
    if (_dataSource == nil) {
        _dataSource = [NSArray array];
    }
    return _dataSource;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = APP_PAGE_COLOR;
//    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(goBack)];
    
    self.automaticallyAdjustsScrollViewInsets = YES;
    _searchBar = [[UISearchBar alloc]init];
    _searchBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    _searchBar.delegate = self;
    [_searchBar setPlaceholder:@"输入“国家、城市” 搜索达人..."];
    _searchBar.tintColor = COLOR_TEXT_II;
    _searchBar.showsCancelButton = YES;
    _searchBar.autocorrectionType = UITextAutocorrectionTypeNo;
    [_searchBar setSearchFieldBackgroundImage:[[UIImage imageNamed:@"icon_search_bg.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(5, 5, 5, 5)] forState:UIControlStateNormal];
    [_searchBar setTranslucent:YES];
    _searchBar.autocapitalizationType = UITextAutocapitalizationTypeNone;
    self.navigationItem.titleView = _searchBar;
    
    UIImageView *imageBg = [[UIImageView alloc]initWithFrame:CGRectMake((kWindowWidth - 210)/2, 68, 210, 130)];
    
    imageBg.image = [UIImage imageNamed:@"search_default_background"];
//    [self.view addSubview:imageBg];

    [self.view addSubview:self.tableView];
    self.tableView.hidden = YES;
    
    [_searchBar becomeFirstResponder];
    
}

- (void)goBack {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [MobClick beginLogPageView:@"page_lxp_search"];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:@"page_lxp_search"];
    [_searchBar endEditing:YES];
}

- (UITableView *)tableView
{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds)+60)];
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
    
    ExpertModel * contact = self.dataSource[indexPath.row];
    
    ContactListTableViewCell *cell = [ContactListTableViewCell contactListCellWithTableView:tableView];
    cell.backgroundColor = [UIColor redColor];
    
    [cell setRightUtilityButtons:[self rightButtons] WithButtonWidth:60];
    cell.delegate = self;
    
    if (![contact.avatarSmall isBlankString]) {
        [cell.avatarImageView sd_setImageWithURL:[NSURL URLWithString:contact.avatarSmall] placeholderImage:[UIImage imageNamed:@"ic_home_default_avatar.png"]];
    } else {
        [cell.avatarImageView sd_setImageWithURL:[NSURL URLWithString:contact.avatar] placeholderImage:[UIImage imageNamed:@"ic_home_default_avatar.png"]];
    }
    
    if (contact.memo.length > 0) {
        cell.nickNameLabel.text = contact.memo;
    } else {
        cell.nickNameLabel.text = contact.nickName;
    }
    return cell;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    ExpertModel *contact = self.dataSource[indexPath.row];
    GuiderProfileViewController *contactDetailCtl = [[GuiderProfileViewController alloc]init];
    contactDetailCtl.userId = contact.userId;
    [self.navigationController pushViewController:contactDetailCtl animated:YES];
    
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}



- (NSArray *)rightButtons
{
    NSMutableArray *rightUtilityButtons = [NSMutableArray new];
    [rightUtilityButtons sw_addUtilityButtonWithColor:[UIColor lightGrayColor] icon:[UIImage imageNamed:@"ic_guide_edit.png"]];
    return rightUtilityButtons;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self.searchBar endEditing:YES];
}


#pragma mark - 实现SearchBar的代理方法
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    NSLog(@"点击了搜索按钮");
    [self loadTravelers:searchBar.text withPageNo:0];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - 加载网络数据
 - (void)loadTravelers:(NSString *)areaName withPageNo:(NSInteger)page
{
    [SVProgressHUD show];
    [ExpertManager asyncLoadExpertsWithAreaName:areaName page:page pageSize:15 completionBlock:^(BOOL isSuccess, NSArray *expertsArray) {
        if (isSuccess) {
            [SVProgressHUD showHint:@"加载完成"];
            _dataSource = expertsArray;
            [self.tableView reloadData];
            self.tableView.hidden = NO;
            [self.searchBar endEditing:YES];
        } else {
            NSString *tip = [NSString stringWithFormat:@"还没有达人去过%@",areaName];
            [SVProgressHUD showErrorWithStatus:tip];
            [self.searchBar endEditing:YES];
        }
    }];
}


#pragma mark - 输入文字时刷新表格数据

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.searchBar endEditing:YES];
}


@end

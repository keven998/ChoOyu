//
//  TravelNoteListViewController.m
//  PeachTravel
//
//  Created by liangpengshuai on 12/13/14.
//  Copyright (c) 2014 com.aizou.www. All rights reserved.
//

#import "TravelNoteListViewController.h"
#import "TravelNote.h"
#import "TravelNoteTableViewCell.h"
#import "TravelNoteDetailViewController.h"
#import "TaoziChatMessageBaseViewController.h"

@interface TravelNoteListViewController () <UISearchBarDelegate, TaoziMessageSendDelegate>

@property (nonatomic, strong) UISearchBar *searchBar;

@property (nonatomic, strong) NSMutableArray *dataSource;

@property (nonatomic) NSUInteger currentPage;
@end

@implementation TravelNoteListViewController

static NSString *reusableCellIdentifier = @"travelNoteCell";

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.view.backgroundColor = APP_PAGE_COLOR;
    CGFloat y;
    if (_isSearch) {
        y = self.searchBar.frame.size.height + self.searchBar.frame.origin.y;
        [self.view addSubview:self.searchBar];
    } else {
        y = 64;
    }
    
    self.tableView.frame = CGRectMake(11, y, self.view.frame.size.width-22, self.view.frame.size.height-y);
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.backgroundColor = APP_PAGE_COLOR;
    [self.tableView setContentInset:UIEdgeInsetsMake(10, 0, 10, 0)];
    [self.tableView registerNib:[UINib nibWithNibName:@"TravelNoteTableViewCell" bundle:nil] forCellReuseIdentifier:reusableCellIdentifier];
    _currentPage = 0;
    if (!_isSearch) {
        self.navigationItem.title = @"相关游记";
        [self loadDataWithPageNo:_currentPage andKeyWork:nil];
    } else {
        self.navigationItem.title = @"发送游记";
        self.enableLoadingMore = NO;
    }
}

#pragma mark - setter & getter

- (NSMutableArray *)dataSource
{
    if (!_dataSource) {
        _dataSource = [[NSMutableArray alloc] init];
    }
    return _dataSource;
}

- (UISearchBar *)searchBar
{
    if (!_searchBar) {
        _searchBar = [[UISearchBar alloc]initWithFrame:CGRectMake(0, 64, kWindowWidth, 40)];
        _searchBar.searchBarStyle = UISearchBarStyleProminent;
        _searchBar.delegate = self;
        [_searchBar setPlaceholder:@"游记名、景点、城市名等"];
        _searchBar.autocorrectionType = UITextAutocorrectionTypeNo;
        _searchBar.autocapitalizationType = UITextAutocapitalizationTypeNone;
        _searchBar.translucent = YES;
        [_searchBar setSearchFieldBackgroundImage:[UIImage imageNamed:@"ic_notify_flag.png"] forState:UIControlStateNormal];
        [_searchBar becomeFirstResponder];
    }
    return _searchBar;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [_searchBar endEditing:YES];
}

#pragma mark - private methods
/**
 *  加载游记数据
 *
 *  @param pageNo  取第几页
 *  @param keyWord 如果是搜索的话传入的 keyword
 */
- (void)loadDataWithPageNo:(NSInteger)pageNo andKeyWork:(NSString *)keyWord
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    AppUtils *utils = [[AppUtils alloc] init];
    [manager.requestSerializer setValue:utils.appVersion forHTTPHeaderField:@"Version"];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"iOS %@",utils.systemVersion] forHTTPHeaderField:@"Platform"];
    
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [manager.requestSerializer setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    NSNumber *imageWidth = [NSNumber numberWithInt:100];
    [params setObject:imageWidth forKey:@"imgWidth"];
    [params setObject:[NSNumber numberWithInt:15] forKey:@"pageSize"];
    [params setObject:[NSNumber numberWithInteger:pageNo] forKey:@"page"];
    
    if (_isSearch) {
        [params safeSetObject:keyWord forKey:@"keyWord"];
    } else {
        [params safeSetObject:_cityId forKey:@"locId"];
    }
    
    //获取游记列表信息
    [manager GET:API_SEARCH_TRAVELNOTE parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"%@", responseObject);
        NSInteger code = [[responseObject objectForKey:@"code"] integerValue];
        if (code == 0) {
            [self parseData:[responseObject objectForKey:@"result"]];

            if ([[responseObject objectForKey:@"result"] count] >= 15) {
                self.enableLoadingMore = YES;
                _currentPage = pageNo;
            } else {
                self.enableLoadingMore = NO;
                if (_currentPage > 0) {
                    [self showHint:@"没有了~"];
                } else {
                }
            }
        } else {
            [self showHint:[NSString stringWithFormat:@"%@",[[responseObject objectForKey:@"err"] objectForKey:@"message"]]];
        }
        
        [self loadMoreCompleted];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@", error);
        [self loadMoreCompleted];
        [self showHint:@"呃～好像没找到网络"];
    }];
}

- (void)parseData:(id)json
{
    for (id travelDic in json) {
        TravelNote *travelNote = [[TravelNote alloc] initWithJson:travelDic];
        [self.dataSource addObject:travelNote];
    }
    [self.tableView reloadData];
}

- (void)beginLoadingMore {
    [super beginLoadingMore];
    if (_isSearch) {
        if ([[self.searchBar.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] > 0) {
            [self loadDataWithPageNo:_currentPage + 1 andKeyWork:self.searchBar.text];
        } else {
            [self loadMoreCompleted];
        }
    } else {
        [self loadDataWithPageNo:_currentPage + 1 andKeyWork:nil];
    }
}

/**
 *  发送游记给好友
 *
 */

- (void)sendTravelNote:(UIButton *)sender
{
    TravelNote *travelNote = [self.dataSource objectAtIndex:sender.tag];
    TaoziChatMessageBaseViewController *taoziMessageCtl = [[TaoziChatMessageBaseViewController alloc] init];
    taoziMessageCtl.delegate = self;
    taoziMessageCtl.chatType = TZChatTypeTravelNote;
    taoziMessageCtl.messageId = travelNote.travelNoteId;
    taoziMessageCtl.messageName = travelNote.title;
    taoziMessageCtl.messageDesc = travelNote.summary;
    taoziMessageCtl.messageImage = travelNote.cover;
    [self presentPopupViewController:taoziMessageCtl atHeight:170.0 animated:YES completion:^{
        
    }];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [_searchBar endEditing:YES];
}

#pragma mark - UITableViewDataSource & Delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataSource.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 149.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TravelNoteTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reusableCellIdentifier forIndexPath:indexPath];
    TravelNote *travelNote = [self.dataSource objectAtIndex:indexPath.row];
    cell.travelNoteImage = travelNote.cover;
    cell.title = travelNote.title;
    cell.desc = travelNote.summary;
    cell.authorName = travelNote.authorName;
    cell.authorAvatar = travelNote.authorAvatar;
    cell.resource = travelNote.source;
    cell.time = travelNote.publishDateStr;
    cell.canSelect = _isSearch;
    if (_isSearch) {
        [cell.sendBtn addTarget:self action:@selector(sendTravelNote:) forControlEvents:UIControlEventTouchUpInside];
        cell.sendBtn.tag = indexPath.row;
    } 
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    TravelNote *travelNote = [self.dataSource objectAtIndex:indexPath.row];
    TravelNoteDetailViewController *travelNoteCtl = [[TravelNoteDetailViewController alloc] init];
    travelNoteCtl.title = travelNote.title;

    travelNoteCtl.travelNoteTitle = travelNote.title;
    travelNoteCtl.desc = travelNote.summary;
    travelNoteCtl.travelNoteCover = travelNote.cover;
    travelNoteCtl.travelNoteId = travelNote.travelNoteId;
    [self.navigationController pushViewController:travelNoteCtl animated:YES];
}

#pragma mark - searchBar Delegate

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [self.dataSource removeAllObjects];
    _currentPage = 0;
//    [self loadDataWithPageNo:_currentPage andKeyWork:searchBar.text];
    if ([[self.searchBar.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] > 0) {
        [self loadDataWithPageNo:_currentPage + 1 andKeyWork:self.searchBar.text];
    }
}

#pragma mark - TaoziMessageSendDelegate

//用户确定发送游记给朋友
- (void)sendSuccess:(ChatViewController *)chatCtl
{
    [self dismissPopup];
    
    [SVProgressHUD showSuccessWithStatus:@"已发送~"];
    
}

- (void)sendCancel
{
    [self dismissPopup];
}

/**
 *  消除发送 poi 对话框
 *  @param sender
 */
- (void)dismissPopup
{
    if (self.popupViewController != nil) {
        [self dismissPopupViewControllerAnimated:YES completion:^{
        }];
    }
}

@end















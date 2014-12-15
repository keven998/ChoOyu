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

@interface TravelNoteListViewController () 

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
        y = self.searchBar.frame.size.height+self.searchBar.frame.origin.y+10;
        
    } else {
        y = 64+10;
    }
    
    self.tableView.frame = CGRectMake(11, y, self.view.frame.size.width-22, self.view.frame.size.height-y);
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.backgroundColor = APP_PAGE_COLOR;
    [self.tableView registerNib:[UINib nibWithNibName:@"TravelNoteTableViewCell" bundle:nil] forCellReuseIdentifier:reusableCellIdentifier];
    _currentPage = 0;
    if (!_isSearch) {
        self.navigationItem.title = @"相关游记";
        [self loadDataWithPageNo:_currentPage andKeyWork:nil];
    } else {
        self.navigationItem.title = @"搜索游记";
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
    
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [manager.requestSerializer setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:[NSNumber numberWithInt:15] forKey:@"pageSize"];
    [params setObject:[NSNumber numberWithInt:pageNo] forKey:@"page"];
    
    if (_isSearch) {
        [params setObject:keyWord forKey:@"keyWord"];
    } else {
        [params setObject:_cityId forKey:@"locId"];
    }
    
    //获取城市的美食列表信息
    [manager GET:API_SEARCH_TRAVELNOTE parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"%@", responseObject);
        NSInteger code = [[responseObject objectForKey:@"code"] integerValue];
        if (code == 0) {
            [self parseData:[responseObject objectForKey:@"result"]];

            _currentPage = pageNo;
            if (self.dataSource.count >= 15) {
                self.enableLoadingMore = YES;
                _currentPage++;
            } else {
                [self showHint:@"人家没有那么多啦"];
            }
        } else {
            [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"%@",[[responseObject objectForKey:@"err"] objectForKey:@"message"]]];
        }
        
        [self loadMoreCompleted];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@", error);
        [self loadMoreCompleted];
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
        [self loadDataWithPageNo:_currentPage + 1 andKeyWork:self.searchBar.text];
    } else {
        [self loadDataWithPageNo:_currentPage + 1 andKeyWork:nil];
    }
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
    return cell;
}
@end















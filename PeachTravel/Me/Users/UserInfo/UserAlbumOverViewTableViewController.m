//
//  UserAlbumOverViewTableViewController.m
//  PeachTravel
//
//  Created by liangpengshuai on 9/16/15.
//  Copyright (c) 2015 com.aizou.www. All rights reserved.
//

#import <AssetsLibrary/AssetsLibrary.h>

#import "UserAlbumOverViewTableViewController.h"
#import "UserAlbumOverviewCell.h"
#import "UserAlbumSelectViewController.h"

@interface UserAlbumOverViewTableViewController ()

@property (nonatomic, strong) ALAssetsLibrary *assetsLibrary;
@property (nonatomic, strong) NSMutableArray *dataSource;

@end

@implementation UserAlbumOverViewTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIButton *backBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 35, 40)];
    [backBtn setTitle:@"取消" forState:UIControlStateNormal];
    backBtn.titleLabel.font = [UIFont systemFontOfSize:16.0];
    [backBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backBtn];
    
    self.navigationItem.title = @"相册";
    [self.tableView registerNib:[UINib nibWithNibName:@"UserAlbumOverviewCell" bundle:nil] forCellReuseIdentifier:@"userAlbumCell"];
    [self loadDataSource];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (NSMutableArray *)dataSource
{
    if (!_dataSource) {
        _dataSource = [[NSMutableArray alloc] init];
    }
    return _dataSource;
}

+ (ALAssetsLibrary *)defaultAssetsLibrary
{
    static dispatch_once_t pred = 0;
    static ALAssetsLibrary *library = nil;
    dispatch_once(&pred, ^{
        library = [[ALAssetsLibrary alloc] init];
    });
    return library;
}

- (void)loadDataSource
{
    if (!self.assetsLibrary)
        self.assetsLibrary = [self.class defaultAssetsLibrary];
    
    
    ALAssetsLibraryGroupsEnumerationResultsBlock resultsBlock = ^(ALAssetsGroup *group, BOOL *stop) {
        if (group) {
            if (group.numberOfAssets > 0) {
                [self.dataSource addObject:group];
            }
            [self.dataSource addObject:group];

        } else {
            NSLog(@"has load all");
            [self.tableView reloadData];
        }
    };
    
    
    ALAssetsLibraryAccessFailureBlock failureBlock = ^(NSError *error) {
        NSLog(@"加载相册失败");
        
    };
    
    // Enumerate Camera roll first
    [self.assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos
                                      usingBlock:resultsBlock
                                    failureBlock:failureBlock];
    
    NSUInteger type = ALAssetsGroupAll;
    
    [self.assetsLibrary enumerateGroupsWithTypes:type
                                      usingBlock:resultsBlock
                                    failureBlock:failureBlock];
    
}

- (void)goBack
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0.1;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.dataSource.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UserAlbumOverviewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"userAlbumCell" forIndexPath:indexPath];
    cell.assetsGroup = _dataSource[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    UserAlbumSelectViewController *ctl = [[UserAlbumSelectViewController alloc] init];
    ctl.assetsGroup = _dataSource[indexPath.row];
    ctl.selectedPhotos = self.selectedPhotos;
    [self.navigationController pushViewController:ctl animated:YES];
}

@end

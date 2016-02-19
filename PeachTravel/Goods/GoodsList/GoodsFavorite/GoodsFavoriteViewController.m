//
//  GoodsFavoriteViewController.m
//  PeachTravel
//
//  Created by liangpengshuai on 1/11/16.
//  Copyright © 2016 com.aizou.www. All rights reserved.
//

#import "GoodsFavoriteViewController.h"
#import "GoodsListTableViewCell.h"
#import "GoodsDetailViewController.h"
#import "GoodsManager.h"

@interface GoodsFavoriteViewController ()<UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSArray *dataSource;


@end

@implementation GoodsFavoriteViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"我的收藏";
    [_tableView registerNib:[UINib nibWithNibName:@"GoodsListTableViewCell" bundle:nil] forCellReuseIdentifier:@"goodsListCell"];
    _tableView.separatorColor = COLOR_LINE;
    _tableView.dataSource = self;
    _tableView.delegate = self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [GoodsManager asyncLoadFavoriteGoodsOfUser:[AccountManager shareAccountManager].account.userId completionBlock:^(BOOL isSuccess, NSArray *goodsList) {
        _dataSource = goodsList;
        [self.tableView reloadData];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0.01;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.01;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _dataSource.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 108;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    GoodsListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"goodsListCell" forIndexPath:indexPath];
    cell.goodsDetail = [_dataSource objectAtIndex:indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    GoodsDetailViewController *ctl = [[GoodsDetailViewController alloc] init];
    GoodsDetailModel *goodsDetail = [_dataSource objectAtIndex:indexPath.row];
    ctl.goodsId = goodsDetail.goodsId;
    [self.navigationController pushViewController:ctl animated:YES];
}

- (void) tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"确定从收藏夹中删除" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        [alertView showAlertViewWithBlock:^(NSInteger buttonIndex) {
            if (buttonIndex == 1) {
                GoodsDetailModel *goodsDetail = [_dataSource objectAtIndex:indexPath.row];
                [GoodsManager asyncFavoriteGoodsWithGoodsObjectId:goodsDetail.objectId isFavorite:NO completionBlock:^(BOOL isSuccess) {
                    if (isSuccess) {
                        NSMutableArray *tempArray = [_dataSource mutableCopy];
                        [tempArray removeObject:goodsDetail];
                        _dataSource = tempArray;
                        [self.tableView reloadData];
                    } else {
                        [SVProgressHUD showHint:@"删除失败"];
                    }
                }];
            }
        }];
    }
}


@end

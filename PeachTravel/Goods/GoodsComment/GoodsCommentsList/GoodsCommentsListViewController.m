//
//  GoodsCommentsListViewController.m
//  PeachTravel
//
//  Created by liangpengshuai on 2/1/16.
//  Copyright © 2016 com.aizou.www. All rights reserved.
//

#import "GoodsCommentsListViewController.h"
#import "GoodsCommentTableViewCell.h"
#import "UserCommentManager.h"

@interface GoodsCommentsListViewController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, strong) NSArray<GoodsCommentDetail *> *dataSource;
@end

@implementation GoodsCommentsListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"全部评价";
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.separatorColor = COLOR_LINE;
    [_tableView registerNib:[UINib nibWithNibName:@"GoodsCommentTableViewCell" bundle:nil] forCellReuseIdentifier:@"goodsCommentTableViewCell"];
    [UserCommentManager asyncLoadGoodsCommentsWithGoodsId:_goodsId completionBlock:^(BOOL isSuccess, NSArray<GoodsCommentDetail *> *commentsList) {
        _dataSource = commentsList;
        [self.tableView reloadData];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _dataSource.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return CGFLOAT_MIN;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return CGFLOAT_MIN;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [GoodsCommentTableViewCell heightWithCommentDetail:[_dataSource objectAtIndex:indexPath.row]];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    GoodsCommentTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"goodsCommentTableViewCell" forIndexPath:indexPath];
    cell.goodsComment = [_dataSource objectAtIndex:indexPath.row];
    return cell;
}

@end

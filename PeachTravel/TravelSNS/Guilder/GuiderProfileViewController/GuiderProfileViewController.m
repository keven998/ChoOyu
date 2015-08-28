//
//  GuiderProfileViewController.m
//  PeachTravel
//
//  Created by 王聪 on 8/27/15.
//  Copyright (c) 2015 com.aizou.www. All rights reserved.
//

#import "GuiderProfileViewController.h"
#import "GuiderProfileHeaderView.h"
#import "GuiderDetailInfoCell.h"
#import "GuiderProfileAlbumCell.h"
@interface GuiderProfileViewController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation GuiderProfileViewController

#pragma mark - lifeCycle

- (void)viewDidLoad {
    [super viewDidLoad];
 
//    [self setupHeaderView];
}

#pragma mark - 设置视图

#pragma mark - DataSource or Delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 5;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{

    if (indexPath.row == 0) {
        GuiderDetailInfoCell *cell = [GuiderDetailInfoCell guiderDetailInfo];
        return cell;
    } else if (indexPath.row == 1) {
        GuiderProfileAlbumCell *albumCell = [[GuiderProfileAlbumCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
        return albumCell;
    }
    else {
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
        cell.textLabel.text = @"煎蛋笑哈哈O(∩_∩)O哈！";
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        return kWindowWidth + 240;
    } else if (indexPath.row == 1) {
        return 140;
    }
    return 50;
}

@end
